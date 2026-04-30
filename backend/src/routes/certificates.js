const router = require("express").Router();
const { authenticate, authorize } = require("../middleware/auth");
const { PrismaClient } = require("@prisma/client");
const PDFDocument = require("pdfkit");
const path = require("path");
const fs = require("fs");
const prisma = new PrismaClient();

// En Docker el backend corre en /app
// __dirname = /app/src/routes
// ../../cert-templates = /app/cert-templates
const CERT_DIR = path.join(__dirname, "../../cert-templates");

async function generateCertPDF(enrollment, res) {
  const { user, course } = enrollment;
  const fullName = user.firstName + " " + user.lastName;
  const courseName = course.title;
  const dateStr = enrollment.completedAt
    ? new Date(enrollment.completedAt).toLocaleDateString("es-CO", { year:"numeric", month:"long", day:"numeric" })
    : new Date().toLocaleDateString("es-CO", { year:"numeric", month:"long", day:"numeric" });

  const W = 841.89; const H = 595.28;
  const doc = new PDFDocument({ size:"A4", layout:"landscape", margin:0 });
  res.setHeader("Content-Type","application/pdf");
  res.setHeader("Content-Disposition","attachment; filename=certificado-"+user.cedula+".pdf");
  doc.pipe(res);

  const tries = [
    path.join(CERT_DIR, "certificado.jpeg"),
    path.join(CERT_DIR, "certificado.jpg"),
    path.join(CERT_DIR, "certificado.png"),
  ];

  let bgFound = false;
  for (const bp of tries) {
    if (fs.existsSync(bp)) {
      console.log("Usando plantilla:", bp);
      doc.image(bp, 0, 0, { width: W, height: H });
      bgFound = true;
      break;
    }
  }

  if (!bgFound) {
    console.log("Plantilla NO encontrada en:", CERT_DIR);
    console.log("Archivos en cert-templates:", fs.existsSync(CERT_DIR) ? fs.readdirSync(CERT_DIR) : "directorio no existe");
  }

  // Escribir solo el nombre del beneficiario y datos sobre la plantilla
  // La plantilla ya tiene logos, firma de Gerardo, etc.
  // "Tejidos Nelcy" en la imagen original esta aprox en y=258/1131 * 595.28 = 136 del PDF
  doc.font("Helvetica-Bold").fontSize(24).fillColor("#000000")
    .text(fullName, 60, 136, { width: W - 120, align: "center" });

  // Curso y fecha debajo del nombre
  doc.font("Helvetica").fontSize(10).fillColor("#444444")
    .text(courseName + "   |   " + dateStr, 60, 165, { width: W - 120, align: "center" });

  doc.end();
}

router.get("/:courseId/:userId", authenticate, authorize("ADMIN"), async (req, res) => {
  try {
    const enrollment = await prisma.enrollment.findUnique({
      where: { userId_courseId: { userId: req.params.userId, courseId: req.params.courseId } },
      include: { user: true, course: true }
    });
    if (!enrollment) return res.status(404).json({ error: "Inscripcion no encontrada" });
    if (enrollment.status !== "COMPLETADO") return res.status(403).json({ error: "El participante no ha completado el curso" });
    await generateCertPDF(enrollment, res);
  } catch (err) { console.error(err); if (!res.headersSent) res.status(500).json({ error: "Error generando certificado" }); }
});

router.post("/:courseId/unlock", authenticate, authorize("ADMIN"), async (req, res) => {
  try {
    const e = await prisma.enrollment.update({
      where: { userId_courseId: { userId: req.body.userId, courseId: req.params.courseId } },
      data: { status: "COMPLETADO", completedAt: new Date() }
    });
    return res.json(e);
  } catch { return res.status(500).json({ error: "Error" }); }
});

router.post("/:courseId/revoke", authenticate, authorize("ADMIN"), async (req, res) => {
  try {
    const e = await prisma.enrollment.update({
      where: { userId_courseId: { userId: req.body.userId, courseId: req.params.courseId } },
      data: { status: "ACTIVO", completedAt: null }
    });
    return res.json(e);
  } catch { return res.status(500).json({ error: "Error" }); }
});

module.exports = router;
