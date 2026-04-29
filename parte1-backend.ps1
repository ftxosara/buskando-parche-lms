$ErrorActionPreference = "Stop"
Write-Host "=== ACTUALIZACION COMPLETA V3 ===" -ForegroundColor Yellow

# ─── BACKEND: adminController mejorado ────────────────────────
$adminCtrl = @'
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

const getDashboard = async (req, res) => {
  try {
    const [totalUsers, totalBeneficiarios, mujeres, totalCourses, totalEnrollments] = await Promise.all([
      prisma.user.count({ where: { isActive: true } }),
      prisma.user.count({ where: { role: "BENEFICIARIO", isActive: true } }),
      prisma.user.count({ where: { role: "BENEFICIARIO", gender: "FEMENINO", isActive: true } }),
      prisma.course.count({ where: { isPublished: true } }),
      prisma.enrollment.count({ where: { status: "ACTIVO" } }),
    ]);

    // Inscritos por curso con detalles
    const courseKpis = await prisma.course.findMany({
      where: { isPublished: true },
      select: {
        id: true, title: true, modality: true,
        formador: { select: { firstName: true, lastName: true } },
        enrollments: {
          select: { userId: true, status: true,
            user: { select: { gender: true, populationGroup: true } }
          }
        },
        sessions: { select: { id: true, _count: { select: { attendances: true } } } },
      },
    });

    // Asistencia global
    const attendanceSummary = await prisma.attendance.groupBy({
      by: ["status"], _count: { status: true }
    });
    const attMap = {};
    attendanceSummary.forEach(a => { attMap[a.status] = a._count.status; });
    const totalAtt = Object.values(attMap).reduce((a, b) => a + b, 0);
    const porcentajeAsistencia = totalAtt > 0 ? ((attMap["PRESENTE"] || 0) / totalAtt * 100).toFixed(1) : 0;

    // Grupos poblacionales
    const populationBreakdown = await prisma.user.groupBy({
      by: ["populationGroup"],
      where: { role: "BENEFICIARIO", isActive: true },
      _count: { populationGroup: true },
    });

    // Completados
    const completados = await prisma.enrollment.count({ where: { status: "COMPLETADO" } });

    const porcentajeMujeres = totalBeneficiarios > 0 ? ((mujeres / totalBeneficiarios) * 100).toFixed(1) : 0;

    const courseData = courseKpis.map(c => {
      const inscritos = c.enrollments.length;
      const mujeresC = c.enrollments.filter(e => e.user?.gender === "FEMENINO").length;
      return {
        id: c.id,
        title: c.title.length > 20 ? c.title.substring(0, 18) + "..." : c.title,
        fullTitle: c.title,
        modality: c.modality,
        formador: c.formador ? c.formador.firstName + " " + c.formador.lastName : "Sin asignar",
        inscritos,
        mujeres: mujeresC,
        hombres: inscritos - mujeresC,
        porcentajeMujeres: inscritos > 0 ? ((mujeresC / inscritos) * 100).toFixed(0) : 0,
      };
    });

    return res.json({
      kpis: {
        totalUsers, totalBeneficiarios, mujeres, hombres: totalBeneficiarios - mujeres,
        porcentajeMujeres: porcentajeMujeres + "%",
        metaMujeres: parseFloat(porcentajeMujeres) >= 50 ? "Cumplida" : "En riesgo",
        totalCourses, totalEnrollments, completados,
        porcentajeAsistencia: porcentajeAsistencia + "%",
        porcentajeCompletados: totalEnrollments > 0 ? ((completados / totalEnrollments) * 100).toFixed(1) + "%" : "0%",
      },
      courseKpis: courseData,
      populationBreakdown: populationBreakdown.map(p => ({
        grupo: p.populationGroup || "Sin clasificar",
        cantidad: p._count.populationGroup,
      })),
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Error al cargar el dashboard" });
  }
};

const getReport = async (req, res) => {
  try {
    const PDFDocument = require("pdfkit");
    const doc = new PDFDocument({ size: "A4", margin: 50 });
    res.setHeader("Content-Type", "application/pdf");
    res.setHeader("Content-Disposition", "attachment; filename=reporte-buskando-parche.pdf");
    doc.pipe(res);

    // Header
    doc.rect(0, 0, doc.page.width, 80).fill("#C0392B");
    doc.fontSize(22).font("Helvetica-Bold").fillColor("white")
      .text("REPORTE GENERAL - BUSKANDO PARCHE", 50, 25);
    doc.fontSize(11).font("Helvetica").fillColor("white")
      .text("Programa de Formacion - Localidad Kennedy, Bogota", 50, 52);

    let y = 100;

    // Fecha
    doc.fontSize(10).fillColor("#555").text("Generado el: " + new Date().toLocaleDateString("es-CO", { year:"numeric", month:"long", day:"numeric" }), 50, y);
    y += 30;

    // Obtener datos
    const [beneficiarios, cursos, asistencias] = await Promise.all([
      prisma.user.findMany({
        where: { role: "BENEFICIARIO", isActive: true },
        include: { enrollments: { include: { course: true } } },
        orderBy: { lastName: "asc" }
      }),
      prisma.course.findMany({
        where: { isPublished: true },
        include: {
          enrollments: { include: { user: { select: { gender: true, populationGroup: true } } } },
          formador: { select: { firstName: true, lastName: true } }
        }
      }),
      prisma.attendance.groupBy({ by: ["status"], _count: { status: true } })
    ]);

    const attMap = {};
    asistencias.forEach(a => { attMap[a.status] = a._count.status; });
    const totalAtt = Object.values(attMap).reduce((a, b) => a + b, 0);
    const pctAsist = totalAtt > 0 ? ((attMap["PRESENTE"] || 0) / totalAtt * 100).toFixed(1) : 0;
    const mujeres = beneficiarios.filter(b => b.gender === "FEMENINO").length;

    // RESUMEN EJECUTIVO
    doc.rect(50, y, doc.page.width - 100, 25).fill("#F3F4F6");
    doc.fontSize(13).font("Helvetica-Bold").fillColor("#C0392B").text("RESUMEN EJECUTIVO", 60, y + 6);
    y += 35;

    const kpiData = [
      ["Total Beneficiarios", beneficiarios.length, "de 80 cupos"],
      ["Mujeres", mujeres, `${((mujeres/beneficiarios.length)*100).toFixed(1)}% del total`],
      ["Hombres", beneficiarios.length - mujeres, `${(((beneficiarios.length-mujeres)/beneficiarios.length)*100).toFixed(1)}% del total`],
      ["Cursos Activos", cursos.length, "programas publicados"],
      ["% Asistencia Global", pctAsist + "%", `${attMap["PRESENTE"]||0} asistencias registradas`],
    ];

    kpiData.forEach(([label, value, sub]) => {
      doc.fontSize(10).font("Helvetica-Bold").fillColor("#111").text(label + ": ", 60, y, { continued: true });
      doc.font("Helvetica").text(String(value) + "  ", { continued: true });
      doc.fillColor("#888").text("(" + sub + ")");
      y += 16;
    });
    y += 15;

    // POR CURSO
    doc.rect(50, y, doc.page.width - 100, 25).fill("#F3F4F6");
    doc.fontSize(13).font("Helvetica-Bold").fillColor("#C0392B").text("DETALLE POR CURSO", 60, y + 6);
    y += 35;

    cursos.forEach(c => {
      const ins = c.enrollments.length;
      const muj = c.enrollments.filter(e => e.user?.gender === "FEMENINO").length;
      doc.fontSize(11).font("Helvetica-Bold").fillColor("#111").text(c.title, 60, y);
      y += 14;
      doc.fontSize(9).font("Helvetica").fillColor("#555")
        .text(`Formador: ${c.formador ? c.formador.firstName + " " + c.formador.lastName : "Sin asignar"}  |  Inscritos: ${ins}  |  Mujeres: ${muj} (${ins>0?((muj/ins)*100).toFixed(0):0}%)  |  Modalidad: ${c.modality}`, 70, y);
      y += 18;
    });
    y += 10;

    // LISTA DE BENEFICIARIOS
    if (y > 650) { doc.addPage(); y = 50; }
    doc.rect(50, y, doc.page.width - 100, 25).fill("#F3F4F6");
    doc.fontSize(13).font("Helvetica-Bold").fillColor("#C0392B").text("LISTADO DE BENEFICIARIOS", 60, y + 6);
    y += 35;

    // Cabecera tabla
    doc.fontSize(8).font("Helvetica-Bold").fillColor("#555");
    doc.text("NOMBRE", 60, y); doc.text("CEDULA", 210, y); doc.text("GENERO", 300, y);
    doc.text("CURSO", 360, y); doc.text("ESTADO", 490, y);
    y += 12;
    doc.moveTo(50, y).lineTo(doc.page.width - 50, y).lineWidth(0.5).stroke("#ddd");
    y += 6;

    beneficiarios.forEach(b => {
      if (y > 760) { doc.addPage(); y = 50; }
      const curso = b.enrollments[0]?.course?.title?.substring(0, 18) || "Sin curso";
      doc.fontSize(7.5).font("Helvetica").fillColor("#111");
      doc.text(b.firstName + " " + b.lastName, 60, y, { width: 140 });
      doc.text(b.cedula, 210, y);
      doc.text(b.gender || "-", 300, y);
      doc.text(curso, 360, y, { width: 120 });
      doc.text(b.enrollments[0]?.status || "-", 490, y);
      y += 14;
    });

    doc.end();
  } catch (err) {
    console.error(err);
    if (!res.headersSent) res.status(500).json({ error: "Error generando reporte" });
  }
};

module.exports = { getDashboard, getReport };
'@
[System.IO.File]::WriteAllText("$PWD\backend\src\controllers\adminController.js", $adminCtrl, [System.Text.Encoding]::UTF8)
Write-Host "adminController.js OK" -ForegroundColor Green

# ─── BACKEND: admin route actualizada ─────────────────────────
$adminRoute = @'
const router = require("express").Router();
const { authenticate, authorize } = require("../middleware/auth");
const { getDashboard, getReport } = require("../controllers/adminController");
router.use(authenticate, authorize("ADMIN"));
router.get("/dashboard", getDashboard);
router.get("/report/pdf", getReport);
module.exports = router;
'@
[System.IO.File]::WriteAllText("$PWD\backend\src\routes\admin.js", $adminRoute, [System.Text.Encoding]::UTF8)
Write-Host "admin route OK" -ForegroundColor Green

# ─── BACKEND: assignments route ───────────────────────────────
$assignRoute = @'
const router = require("express").Router();
const { authenticate, authorize } = require("../middleware/auth");
const { PrismaClient } = require("@prisma/client");
const multer = require("multer");
const path = require("path");
const prisma = new PrismaClient();

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, path.join(__dirname, "../../uploads")),
  filename: (req, file, cb) => cb(null, Date.now() + "-" + file.originalname),
});
const upload = multer({ storage, limits: { fileSize: 50 * 1024 * 1024 } });

// POST /api/assignments - estudiante entrega tarea
router.post("/", authenticate, upload.single("file"), async (req, res) => {
  try {
    const { sessionId, courseId, evaluationId, textContent } = req.body;
    const userId = req.user.id;
    const fileUrl = req.file ? "/uploads/" + req.file.filename : null;

    // Crear o actualizar evaluacion si no existe
    let evalId = evaluationId;
    if (!evalId) {
      const ev = await prisma.evaluation.create({
        data: { sessionId, courseId, title: "Entrega de actividad", maxScore: 100, passingScore: 60, questions: [] }
      });
      evalId = ev.id;
    }

    const submission = await prisma.submission.upsert({
      where: { evaluationId_userId: { evaluationId: evalId, userId } },
      update: { answers: { text: textContent || "", fileUrl }, submittedAt: new Date() },
      create: {
        evaluationId: evalId, userId, sessionId,
        answers: { text: textContent || "", fileUrl },
      }
    }).catch(async () => {
      return prisma.submission.create({
        data: {
          evaluationId: evalId, userId, sessionId,
          answers: { text: textContent || "", fileUrl },
        }
      });
    });
    return res.status(201).json(submission);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Error al enviar la tarea" });
  }
});

// GET /api/assignments/session/:sessionId - ver entregas de una sesion (formador/admin)
router.get("/session/:sessionId", authenticate, authorize("FORMADOR", "ADMIN"), async (req, res) => {
  try {
    const evals = await prisma.evaluation.findMany({ where: { sessionId: req.params.sessionId } });
    if (!evals.length) return res.json([]);
    const subs = await prisma.submission.findMany({
      where: { evaluationId: { in: evals.map(e => e.id) } },
      include: { user: { select: { firstName: true, lastName: true, cedula: true, email: true } } },
      orderBy: { submittedAt: "desc" }
    });
    return res.json(subs);
  } catch (err) {
    return res.status(500).json({ error: "Error al cargar entregas" });
  }
});

// PUT /api/assignments/:id/grade - formador califica
router.put("/:id/grade", authenticate, authorize("FORMADOR", "ADMIN"), async (req, res) => {
  try {
    const { score, feedback } = req.body;
    const sub = await prisma.submission.update({
      where: { id: req.params.id },
      data: { score: parseFloat(score), feedback, gradedAt: new Date() }
    });
    return res.json(sub);
  } catch (err) {
    return res.status(500).json({ error: "Error al calificar" });
  }
});

// GET /api/assignments/grades/:courseId - sabana de notas de un curso
router.get("/grades/:courseId", authenticate, async (req, res) => {
  try {
    const { courseId } = req.params;
    const userId = req.user.role === "BENEFICIARIO" ? req.user.id : req.query.userId;

    const sessions = await prisma.session.findMany({
      where: { courseId }, orderBy: { order: "asc" },
      include: {
        evaluations: {
          include: {
            submissions: {
              where: userId ? { userId } : {},
              include: { user: { select: { firstName: true, lastName: true } } }
            }
          }
        },
        attendances: { where: userId ? { userId } : {} }
      }
    });

    return res.json(sessions.map(s => ({
      id: s.id, title: s.title, order: s.order,
      attendance: s.attendances[0]?.status || null,
      submission: s.evaluations[0]?.submissions[0] || null,
      score: s.evaluations[0]?.submissions[0]?.score || null,
      feedback: s.evaluations[0]?.submissions[0]?.feedback || null,
    })));
  } catch (err) {
    return res.status(500).json({ error: "Error al cargar notas" });
  }
});

module.exports = router;
'@
[System.IO.File]::WriteAllText("$PWD\backend\src\routes\assignments.js", $assignRoute, [System.Text.Encoding]::UTF8)
Write-Host "assignments.js OK" -ForegroundColor Green

# ─── BACKEND: actualizar index.js ─────────────────────────────
$idx = Get-Content "$PWD\backend\src\index.js" -Raw
if ($idx -notmatch "assignments") {
  $idx = $idx -replace "const certRoutes", "const assignRoutes = require('./routes/assignments');`nconst certRoutes"
  $idx = $idx -replace "app.use\('/api/certificates'", "app.use('/api/assignments', assignRoutes);`napp.use('/api/certificates'"
  [System.IO.File]::WriteAllText("$PWD\backend\src\index.js", $idx, [System.Text.Encoding]::UTF8)
}
Write-Host "index.js actualizado con assignments" -ForegroundColor Green
