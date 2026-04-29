Write-Host "=== FIX adminController duplicado ===" -ForegroundColor Yellow

$adminCtrl = 'const { PrismaClient } = require("@prisma/client");
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

    const courseKpis = await prisma.course.findMany({
      where: { isPublished: true },
      select: {
        id: true, title: true, modality: true,
        formador: { select: { firstName: true, lastName: true } },
        enrollments: { select: { userId: true, status: true, user: { select: { gender: true, populationGroup: true } } } },
      },
    });

    const attendanceSummary = await prisma.attendance.groupBy({ by: ["status"], _count: { status: true } });
    const attMap = {};
    attendanceSummary.forEach(a => { attMap[a.status] = a._count.status; });
    const totalAtt = Object.values(attMap).reduce((a, b) => a + b, 0);
    const porcentajeAsistencia = totalAtt > 0 ? ((attMap["PRESENTE"] || 0) / totalAtt * 100).toFixed(1) : 0;

    const completados = await prisma.enrollment.count({ where: { status: "COMPLETADO" } });

    const populationBreakdown = await prisma.user.groupBy({
      by: ["populationGroup"],
      where: { role: "BENEFICIARIO", isActive: true },
      _count: { populationGroup: true },
    });

    const porcentajeMujeres = totalBeneficiarios > 0 ? ((mujeres / totalBeneficiarios) * 100).toFixed(1) : 0;

    const courseData = courseKpis.map(c => {
      const inscritos = c.enrollments.length;
      const mujeresC = c.enrollments.filter(e => e.user?.gender === "FEMENINO").length;
      return {
        id: c.id,
        title: c.title.length > 18 ? c.title.substring(0, 16) + ".." : c.title,
        fullTitle: c.title,
        modality: c.modality,
        formador: c.formador ? c.formador.firstName + " " + c.formador.lastName : "Sin asignar",
        inscritos,
        mujeres: mujeresC,
        hombres: inscritos - mujeresC,
        porcentajeMujeres: inscritos > 0 ? ((mujeresC / inscritos) * 100).toFixed(0) : "0",
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
    const path = require("path");
    const fs = require("fs");
    const doc = new PDFDocument({ size: "A4", margin: 50, bufferPages: true });
    res.setHeader("Content-Type", "application/pdf");
    res.setHeader("Content-Disposition", "attachment; filename=reporte-buskando-parche.pdf");
    doc.pipe(res);

    const PUB = path.join(__dirname, "../../frontend/public/images");
    const W = doc.page.width;

    // HEADER rojo con logo
    doc.rect(0, 0, W + 100, 90).fill("#C0392B");
    const logoPath = path.join(PUB, "logo.png");
    if (fs.existsSync(logoPath)) { doc.image(logoPath, 45, 15, { height: 60 }); }
    doc.font("Helvetica-Bold").fontSize(20).fillColor("white").text("BUSKANDO PARCHE - KENNEDY", 120, 22);
    doc.font("Helvetica").fontSize(11).fillColor("white").text("Reporte General del Programa de Formacion", 120, 46);
    doc.font("Helvetica").fontSize(9).fillColor("rgba(255,255,255,0.7)").text("Alcaldia Local de Kennedy - Bogota, Colombia", 120, 63);

    let y = 110;
    doc.font("Helvetica").fontSize(9).fillColor("#888")
      .text("Generado el: " + new Date().toLocaleDateString("es-CO", { year:"numeric", month:"long", day:"numeric" }), 50, y);
    y += 25;

    const [bens, cursos, asistencias] = await Promise.all([
      prisma.user.findMany({
        where: { role: "BENEFICIARIO", isActive: true },
        include: { enrollments: { include: { course: { select: { title: true } } } } },
        orderBy: { lastName: "asc" }
      }),
      prisma.course.findMany({
        where: { isPublished: true },
        include: {
          enrollments: { include: { user: { select: { gender: true } } } },
          formador: { select: { firstName: true, lastName: true } }
        }
      }),
      prisma.attendance.groupBy({ by: ["status"], _count: { status: true } }),
    ]);

    const attMap = {};
    asistencias.forEach(a => { attMap[a.status] = a._count.status; });
    const totalAtt = Object.values(attMap).reduce((a, b) => a + b, 0);
    const pctAsist = totalAtt > 0 ? ((attMap["PRESENTE"] || 0) / totalAtt * 100).toFixed(1) : 0;
    const mujeres = bens.filter(b => b.gender === "FEMENINO").length;

    // RESUMEN
    doc.rect(50, y, W - 100, 22).fill("#F3F4F6");
    doc.font("Helvetica-Bold").fontSize(12).fillColor("#C0392B").text("RESUMEN EJECUTIVO", 60, y + 5); y += 30;

    const kpis = [
      ["Total beneficiarios", bens.length, "de 80 cupos objetivo"],
      ["Mujeres inscritas", mujeres, ((mujeres / Math.max(bens.length, 1)) * 100).toFixed(1) + "% del total"],
      ["Hombres inscritos", bens.length - mujeres, (((bens.length - mujeres) / Math.max(bens.length, 1)) * 100).toFixed(1) + "% del total"],
      ["Cursos activos", cursos.length, "programas publicados"],
      ["Asistencia global", pctAsist + "%", totalAtt + " registros totales"],
    ];
    kpis.forEach(([l, v, s]) => {
      doc.font("Helvetica-Bold").fontSize(10).fillColor("#111").text(l + ": ", 60, y, { continued: true });
      doc.font("Helvetica").fillColor("#333").text(String(v) + "   ", { continued: true });
      doc.fillColor("#888").text("(" + s + ")");
      y += 17;
    });
    y += 15;

    // CURSOS
    if (y > 680) { doc.addPage(); y = 50; }
    doc.rect(50, y, W - 100, 22).fill("#F3F4F6");
    doc.font("Helvetica-Bold").fontSize(12).fillColor("#C0392B").text("DETALLE POR CURSO", 60, y + 5); y += 30;

    cursos.forEach(c => {
      if (y > 700) { doc.addPage(); y = 50; }
      const ins = c.enrollments.length;
      const muj = c.enrollments.filter(e => e.user?.gender === "FEMENINO").length;
      doc.fontSize(11).font("Helvetica-Bold").fillColor("#111").text(c.title, 60, y); y += 15;
      doc.fontSize(9).font("Helvetica").fillColor("#555")
        .text("Formador: " + (c.formador ? c.formador.firstName + " " + c.formador.lastName : "N/A") +
          "  |  Inscritos: " + ins + "  |  Mujeres: " + muj + " (" + (ins > 0 ? ((muj / ins) * 100).toFixed(0) : 0) + "%)  |  " + c.modality, 70, y);
      y += 20;
    });
    y += 10;

    // LISTADO BENEFICIARIOS
    if (y > 650) { doc.addPage(); y = 50; }
    doc.rect(50, y, W - 100, 22).fill("#F3F4F6");
    doc.font("Helvetica-Bold").fontSize(12).fillColor("#C0392B").text("LISTADO COMPLETO DE BENEFICIARIOS", 60, y + 5); y += 30;

    doc.fontSize(8).font("Helvetica-Bold").fillColor("#666");
    doc.text("NOMBRE", 60, y); doc.text("CEDULA", 210, y); doc.text("GENERO", 300, y);
    doc.text("CURSO", 365, y); doc.text("ESTADO", 495, y);
    y += 13;
    doc.moveTo(50, y).lineTo(W - 50, y).lineWidth(0.5).stroke("#ddd"); y += 7;

    bens.forEach(b => {
      if (y > 760) { doc.addPage(); y = 50; }
      const curso = b.enrollments[0]?.course?.title?.substring(0, 20) || "Sin curso";
      doc.fontSize(7.5).font("Helvetica").fillColor("#111");
      doc.text(b.firstName + " " + b.lastName, 60, y, { width: 142 });
      doc.text(b.cedula, 210, y);
      doc.text(b.gender || "-", 300, y);
      doc.text(curso, 365, y, { width: 122 });
      doc.text(b.enrollments[0]?.status || "-", 495, y);
      y += 14;
    });

    // FOOTER en cada pagina
    const range = doc.bufferedPageRange();
    for (let i = 0; i < range.count; i++) {
      doc.switchToPage(i);
      doc.rect(0, doc.page.height - 28, doc.page.width + 100, 28).fill("#C0392B");
      doc.font("Helvetica").fontSize(8).fillColor("white")
        .text("Buskando Parche - Alcaldia Local de Kennedy - Bogota", 50, doc.page.height - 16);
      doc.text("Pagina " + (i + 1) + " de " + range.count, doc.page.width - 100, doc.page.height - 16, { align: "right" });
    }

    doc.end();
  } catch (err) {
    console.error(err);
    if (!res.headersSent) res.status(500).json({ error: "Error generando reporte" });
  }
};

module.exports = { getDashboard, getReport };
'

[System.IO.File]::WriteAllText("$PWD\backend\src\controllers\adminController.js", $adminCtrl, [System.Text.Encoding]::UTF8)
Write-Host "adminController.js reescrito limpio OK" -ForegroundColor Green

Write-Host ""
Write-Host "Ejecuta:" -ForegroundColor Cyan
Write-Host "  docker-compose down" -ForegroundColor White
Write-Host "  docker-compose up --build" -ForegroundColor White
