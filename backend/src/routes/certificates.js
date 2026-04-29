const router = require("express").Router();
const { authenticate, authorize } = require("../middleware/auth");
const { PrismaClient } = require("@prisma/client");
const PDFDocument = require("pdfkit");
const path = require("path");
const fs = require("fs");
const prisma = new PrismaClient();

// RUTA CORRECTA: /app/cert-templates/ (montado desde ./backend/cert-templates)
const CERT_DIR = path.join(__dirname, "../../../cert-templates");

async function generateCertPDF(enrollment, res) {
  const { user, course } = enrollment;
  const fullName = user.firstName + " " + user.lastName;
  const courseName = course.title;
  const dateStr = enrollment.completedAt
    ? new Date(enrollment.completedAt).toLocaleDateString("es-CO", { year:"numeric", month:"long", day:"numeric" })
    : new Date().toLocaleDateString("es-CO", { year:"numeric", month:"long", day:"numeric" });

  const W = 841.89; const H = 595.28;
  const doc = new PDFDocument({ size: "A4", layout: "landscape", margin: 0 });
  res.setHeader("Content-Type", "application/pdf");
  res.setHeader("Content-Disposition", "attachment; filename=certificado-" + user.cedula + ".pdf");
  doc.pipe(res);

  // Buscar plantilla en /app/cert-templates/
  const tries = [
    path.join(CERT_DIR, "certificado.jpeg"),
    path.join(CERT_DIR, "certificado.jpg"),
    path.join(CERT_DIR, "certificado.png"),
  ];

  let bgFound = false;
  for (const bp of tries) {
    if (fs.existsSync(bp)) {
      doc.image(bp, 0, 0, { width: W, height: H });
      bgFound = true;
      console.log("Usando plantilla:", bp);
      break;
    }
  }

  if (!bgFound) {
    console.log("Plantilla no encontrada en:", CERT_DIR, "- usando diseno manual");
    doc.rect(0,0,W,H).fill("#FFFFFF");
    doc.rect(0,0,W,12).fill("#C0392B"); doc.rect(0,H-12,W,12).fill("#C0392B");
    doc.rect(0,12,W,6).fill("#F39C12"); doc.rect(0,H-18,W,6).fill("#F39C12");
    const sq=70;
    [[0,18],[W-sq,18],[0,H-18-sq],[W-sq,H-18-sq]].forEach(([x,y])=>doc.rect(x,y,sq,sq).fill("#C0392B"));
    doc.rect(55,55,W-110,H-110).lineWidth(1.5).stroke("#C0392B");
    let y=100;
    doc.font("Helvetica-Bold").fontSize(36).fillColor("#1a1a1a").text("CERTIFICADO",0,y,{align:"center"}); y+=44;
    doc.font("Helvetica").fontSize(13).fillColor("#777").text("DE PARTICIPACION",0,y,{align:"center",characterSpacing:4}); y+=30;
    doc.font("Helvetica").fontSize(11).fillColor("#444").text("Este certificado se entrega a:",0,y,{align:"center"}); y+=26;
    doc.moveTo(130,y+24).lineTo(W-130,y+24).lineWidth(0.8).stroke("#ccc");
    doc.font("Helvetica-Bold").fontSize(24).fillColor("#C0392B").text(fullName.toUpperCase(),0,y,{align:"center"}); y+=42;
    doc.font("Helvetica").fontSize(11).fillColor("#444").text("Por haber asistido y aprobado satisfactoriamente el curso:",0,y,{align:"center"}); y+=26;
    doc.font("Helvetica-Bold").fontSize(15).fillColor("#1a1a1a").text(courseName.toUpperCase(),80,y,{align:"center",width:W-160,characterSpacing:2}); y+=36;
    doc.font("Helvetica-Bold").fontSize(10).fillColor("#555").text("Fecha: "+dateStr+"   Duracion: 40 horas  |  Modalidad "+course.modality,0,y,{align:"center"}); y+=52;
    const fW=200;const gap=90;const x1=W/2-fW-gap/2;const x2=W/2+gap/2;
    doc.moveTo(x1,y).lineTo(x1+fW,y).lineWidth(0.8).stroke("#333");
    doc.font("Helvetica-Bold").fontSize(9.5).fillColor("#111").text("JAVIER PRIETO TRISTANCHO",x1,y+6,{width:fW,align:"center"});
    doc.font("Helvetica").fontSize(8.5).fillColor("#666").text("ALCALDE (E) LOCAL DE KENNEDY",x1,y+18,{width:fW,align:"center"});
    doc.moveTo(x2,y).lineTo(x2+fW,y).lineWidth(0.8).stroke("#333");
    doc.font("Helvetica-Bold").fontSize(9.5).fillColor("#111").text("GERARDO SANTAMARIA BORDA",x2,y+6,{width:fW,align:"center"});
    doc.font("Helvetica").fontSize(8.5).fillColor("#666").text("CEO - BOOST BUSINESS CONSULTING",x2,y+18,{width:fW,align:"center"});
  } else {
    // CON PLANTILLA: solo el nombre del beneficiario en el espacio en blanco
    // La plantilla 1600x1131 -> PDF 841.89x595.28 (escala 0.526)
    // "Tejidos Nelcy" en la imagen esta a ~y=258px -> PDF: 258*0.526 = 136
    doc.font("Helvetica-Bold").fontSize(22).fillColor("#000000")
      .text(fullName, 60, 136, { width: W - 120, align: "center" });
    // El nombre del curso (opcional, pequeÃ±o) 
    doc.font("Helvetica").fontSize(10).fillColor("#555555")
      .text(courseName + "   |   " + dateStr, 60, 162, { width: W - 120, align: "center" });
  }
  doc.end();
}

router.get("/:courseId/:userId", authenticate, authorize("ADMIN"), async (req, res) => {
  try {
    const enrollment = await prisma.enrollment.findUnique({
      where: { userId_courseId: { userId: req.params.userId, courseId: req.params.courseId } },
      include: { user: true, course: true }
    });
    if (!enrollment) return res.status(404).json({ error: "Inscripcion no encontrada" });
    if (enrollment.status !== "COMPLETADO") return res.status(403).json({ error: "Participante no ha completado el curso" });
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
