# =============================================================
# ACTUALIZACION COMPLETA LMS BUSKANDO PARCHE
# Incluye: seed 85 usuarios, UI rediseno, certificados PDF,
# admin usuarios, portal formador, visor de curso
# =============================================================

Write-Host "Iniciando actualizacion completa del LMS..." -ForegroundColor Yellow

# ── SEED ──────────────────────────────────────────────────────
$seed = @'
const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcryptjs");
const prisma = new PrismaClient();
const beneficiarios = [
  { firstName:"Laura",     lastName:"Rodriguez Pena",      cedula:"1020301001", gender:"FEMENINO",  pop:"EMPRENDEDOR" },
  { firstName:"Carlos",    lastName:"Martinez Lopez",      cedula:"1020301002", gender:"MASCULINO", pop:"MIPYME" },
  { firstName:"Ana Maria", lastName:"Gomez Herrera",       cedula:"1020301003", gender:"FEMENINO",  pop:"PRESTADOR_TURISTICO" },
  { firstName:"Jhon",      lastName:"Vargas Castro",       cedula:"1020301004", gender:"MASCULINO", pop:"EMPRENDEDOR" },
  { firstName:"Sandra",    lastName:"Torres Morales",      cedula:"1020301005", gender:"FEMENINO",  pop:"VICTIMA_CONFLICTO" },
  { firstName:"Miguel",    lastName:"Diaz Ortega",         cedula:"1020301006", gender:"MASCULINO", pop:"MIPYME" },
  { firstName:"Valentina", lastName:"Ruiz Jimenez",        cedula:"1020301007", gender:"FEMENINO",  pop:"EMPRENDEDOR" },
  { firstName:"David",     lastName:"Sanchez Ramos",       cedula:"1020301008", gender:"MASCULINO", pop:"PRESTADOR_TURISTICO" },
  { firstName:"Paola",     lastName:"Romero Quintero",     cedula:"1020301009", gender:"FEMENINO",  pop:"EMPRENDEDOR" },
  { firstName:"Andres",    lastName:"Cardenas Vega",       cedula:"1020301010", gender:"MASCULINO", pop:"MIPYME" },
  { firstName:"Natalia",   lastName:"Mora Suarez",         cedula:"1020301011", gender:"FEMENINO",  pop:"AFRODESCENDIENTE" },
  { firstName:"Sebastian", lastName:"Parra Mendez",        cedula:"1020301012", gender:"MASCULINO", pop:"EMPRENDEDOR" },
  { firstName:"Camila",    lastName:"Rios Guerrero",       cedula:"1020301013", gender:"FEMENINO",  pop:"PRESTADOR_TURISTICO" },
  { firstName:"Fernando",  lastName:"Munoz Salcedo",       cedula:"1020301014", gender:"MASCULINO", pop:"VICTIMA_CONFLICTO" },
  { firstName:"Marcela",   lastName:"Pedraza Luna",        cedula:"1020301015", gender:"FEMENINO",  pop:"MIPYME" },
  { firstName:"Ricardo",   lastName:"Alvarado Nino",       cedula:"1020301016", gender:"MASCULINO", pop:"EMPRENDEDOR" },
  { firstName:"Diana",     lastName:"Ospina Cardona",      cedula:"1020301017", gender:"FEMENINO",  pop:"EMPRENDEDOR" },
  { firstName:"Julian",    lastName:"Bermudez Acosta",     cedula:"1020301018", gender:"MASCULINO", pop:"PRESTADOR_TURISTICO" },
  { firstName:"Luisa",     lastName:"Caballero Toro",      cedula:"1020301019", gender:"FEMENINO",  pop:"AFRODESCENDIENTE" },
  { firstName:"Esteban",   lastName:"Giraldo Reyes",       cedula:"1020301020", gender:"MASCULINO", pop:"MIPYME" },
  { firstName:"Daniela",   lastName:"Serrano Pinto",       cedula:"1020301021", gender:"FEMENINO",  pop:"EMPRENDEDOR" },
  { firstName:"Mauricio",  lastName:"Estrada Vidal",       cedula:"1020301022", gender:"MASCULINO", pop:"VICTIMA_CONFLICTO" },
  { firstName:"Adriana",   lastName:"Monsalve Cruz",       cedula:"1020301023", gender:"FEMENINO",  pop:"PRESTADOR_TURISTICO" },
  { firstName:"Alejandro", lastName:"Velasquez Duarte",    cedula:"1020301024", gender:"MASCULINO", pop:"EMPRENDEDOR" },
  { firstName:"Gloria",    lastName:"Zapata Figueroa",     cedula:"1020301025", gender:"FEMENINO",  pop:"MIPYME" },
  { firstName:"Hernando",  lastName:"Cortes Bernal",       cedula:"1020301026", gender:"MASCULINO", pop:"EMPRENDEDOR" },
  { firstName:"Lina",      lastName:"Medina Vargas",       cedula:"1020301027", gender:"FEMENINO",  pop:"AFRODESCENDIENTE" },
  { firstName:"Oscar",     lastName:"Navarro Palomino",    cedula:"1020301028", gender:"MASCULINO", pop:"PRESTADOR_TURISTICO" },
  { firstName:"Veronica",  lastName:"Agudelo Soto",        cedula:"1020301029", gender:"FEMENINO",  pop:"EMPRENDEDOR" },
  { firstName:"Ivan",      lastName:"Gutierrez Triana",    cedula:"1020301030", gender:"MASCULINO", pop:"MIPYME" },
  { firstName:"Carolina",  lastName:"Londono Arias",       cedula:"1020301031", gender:"FEMENINO",  pop:"VICTIMA_CONFLICTO" },
  { firstName:"Felipe",    lastName:"Arbelaez Mejia",      cedula:"1020301032", gender:"MASCULINO", pop:"EMPRENDEDOR" },
  { firstName:"Marisol",   lastName:"Pineda Blanco",       cedula:"1020301033", gender:"FEMENINO",  pop:"PRESTADOR_TURISTICO" },
  { firstName:"Gustavo",   lastName:"Montoya Espinosa",    cedula:"1020301034", gender:"MASCULINO", pop:"EMPRENDEDOR" },
  { firstName:"Tatiana",   lastName:"Florez Holguin",      cedula:"1020301035", gender:"FEMENINO",  pop:"MIPYME" },
  { firstName:"Nicolas",   lastName:"Salazar Quintana",    cedula:"1020301036", gender:"MASCULINO", pop:"AFRODESCENDIENTE" },
  { firstName:"Eliana",    lastName:"Cifuentes Roa",       cedula:"1020301037", gender:"FEMENINO",  pop:"EMPRENDEDOR" },
  { firstName:"Rodrigo",   lastName:"Pulido Barrera",      cedula:"1020301038", gender:"MASCULINO", pop:"PRESTADOR_TURISTICO" },
  { firstName:"Yuliana",   lastName:"Cano Herrera",        cedula:"1020301039", gender:"FEMENINO",  pop:"VICTIMA_CONFLICTO" },
  { firstName:"Pablo",     lastName:"Mejia Arango",        cedula:"1020301040", gender:"MASCULINO", pop:"MIPYME" },
  { firstName:"Claudia",   lastName:"Velez Ochoa",         cedula:"1020301041", gender:"FEMENINO",  pop:"EMPRENDEDOR" },
  { firstName:"Alvaro",    lastName:"Sepulveda Jaramillo", cedula:"1020301042", gender:"MASCULINO", pop:"EMPRENDEDOR" },
  { firstName:"Bibiana",   lastName:"Ossa Gallego",        cedula:"1020301043", gender:"FEMENINO",  pop:"AFRODESCENDIENTE" },
  { firstName:"German",    lastName:"Tobon Uribe",         cedula:"1020301044", gender:"MASCULINO", pop:"PRESTADOR_TURISTICO" },
  { firstName:"Ximena",    lastName:"Bedoya Patino",       cedula:"1020301045", gender:"FEMENINO",  pop:"MIPYME" },
  { firstName:"Luis",      lastName:"Echavarria Posada",   cedula:"1020301046", gender:"MASCULINO", pop:"EMPRENDEDOR" },
  { firstName:"Martha",    lastName:"Arroyave Castano",    cedula:"1020301047", gender:"FEMENINO",  pop:"VICTIMA_CONFLICTO" },
  { firstName:"Joaquin",   lastName:"Restrepo Munoz",      cedula:"1020301048", gender:"MASCULINO", pop:"EMPRENDEDOR" },
  { firstName:"Pilar",     lastName:"Alzate Giraldo",      cedula:"1020301049", gender:"FEMENINO",  pop:"PRESTADOR_TURISTICO" },
  { firstName:"Hernan",    lastName:"Cardenas Osorio",     cedula:"1020301050", gender:"MASCULINO", pop:"MIPYME" },
  { firstName:"Alejandra", lastName:"Duque Moreno",        cedula:"1020301051", gender:"FEMENINO",  pop:"EMPRENDEDOR" },
  { firstName:"Javier",    lastName:"Marulanda Rios",      cedula:"1020301052", gender:"MASCULINO", pop:"AFRODESCENDIENTE" },
  { firstName:"Sofia",     lastName:"Henao Castillo",      cedula:"1020301053", gender:"FEMENINO",  pop:"EMPRENDEDOR" },
  { firstName:"Harold",    lastName:"Castano Ramirez",     cedula:"1020301054", gender:"MASCULINO", pop:"PRESTADOR_TURISTICO" },
  { firstName:"Nathalia",  lastName:"Lopera Vargas",       cedula:"1020301055", gender:"FEMENINO",  pop:"MIPYME" },
  { firstName:"Wilmer",    lastName:"Aguilar Serna",       cedula:"1020301056", gender:"MASCULINO", pop:"VICTIMA_CONFLICTO" },
  { firstName:"Leidy",     lastName:"Aristizabal Gomez",   cedula:"1020301057", gender:"FEMENINO",  pop:"EMPRENDEDOR" },
  { firstName:"Cesar",     lastName:"Cardona Betancur",    cedula:"1020301058", gender:"MASCULINO", pop:"EMPRENDEDOR" },
  { firstName:"Aura",      lastName:"Rendon Acevedo",      cedula:"1020301059", gender:"FEMENINO",  pop:"AFRODESCENDIENTE" },
  { firstName:"Yesid",     lastName:"Quiroz Palomino",     cedula:"1020301060", gender:"MASCULINO", pop:"MIPYME" },
  { firstName:"Milena",    lastName:"Urrego Zapata",       cedula:"1020301061", gender:"FEMENINO",  pop:"PRESTADOR_TURISTICO" },
  { firstName:"Edgar",     lastName:"Hincapie Santamaria", cedula:"1020301062", gender:"MASCULINO", pop:"EMPRENDEDOR" },
  { firstName:"Lorena",    lastName:"Zuluaga Montes",      cedula:"1020301063", gender:"FEMENINO",  pop:"VICTIMA_CONFLICTO" },
  { firstName:"Wilfredo",  lastName:"Osorio Correa",       cedula:"1020301064", gender:"MASCULINO", pop:"EMPRENDEDOR" },
  { firstName:"Ines",      lastName:"Gallego Parra",       cedula:"1020301065", gender:"FEMENINO",  pop:"MIPYME" },
  { firstName:"Raul",      lastName:"Mosquera Lozano",     cedula:"1020301066", gender:"MASCULINO", pop:"PRESTADOR_TURISTICO" },
  { firstName:"Esperanza", lastName:"Moncada Vergara",     cedula:"1020301067", gender:"FEMENINO",  pop:"AFRODESCENDIENTE" },
  { firstName:"Victor",    lastName:"Salcedo Ortiz",       cedula:"1020301068", gender:"MASCULINO", pop:"EMPRENDEDOR" },
  { firstName:"Nubia",     lastName:"Garzon Ramirez",      cedula:"1020301069", gender:"FEMENINO",  pop:"EMPRENDEDOR" },
  { firstName:"Armando",   lastName:"Tovar Medina",        cedula:"1020301070", gender:"MASCULINO", pop:"VICTIMA_CONFLICTO" },
  { firstName:"Helena",    lastName:"Prieto Suarez",       cedula:"1020301071", gender:"FEMENINO",  pop:"MIPYME" },
  { firstName:"Eliseo",    lastName:"Vargas Herrera",      cedula:"1020301072", gender:"MASCULINO", pop:"EMPRENDEDOR" },
  { firstName:"Rocio",     lastName:"Pena Castaneda",      cedula:"1020301073", gender:"FEMENINO",  pop:"PRESTADOR_TURISTICO" },
  { firstName:"Camilo",    lastName:"Angel Soto",          cedula:"1020301074", gender:"MASCULINO", pop:"AFRODESCENDIENTE" },
  { firstName:"Gladys",    lastName:"Reyes Murillo",       cedula:"1020301075", gender:"FEMENINO",  pop:"EMPRENDEDOR" },
  { firstName:"Fredy",     lastName:"Naranjo Cano",        cedula:"1020301076", gender:"MASCULINO", pop:"MIPYME" },
  { firstName:"Patricia",  lastName:"Caicedo Leal",        cedula:"1020301077", gender:"FEMENINO",  pop:"VICTIMA_CONFLICTO" },
  { firstName:"Dario",     lastName:"Ballen Pachon",       cedula:"1020301078", gender:"MASCULINO", pop:"EMPRENDEDOR" },
  { firstName:"Amparo",    lastName:"Triana Buitrago",     cedula:"1020301079", gender:"FEMENINO",  pop:"PRESTADOR_TURISTICO" },
  { firstName:"Nestor",    lastName:"Quintero Fierro",     cedula:"1020301080", gender:"MASCULINO", pop:"EMPRENDEDOR" },
];
const formadores = [
  { firstName:"Maria",   lastName:"Ramirez Solano",  cedula:"9000000001", esp:"Marketing Digital" },
  { firstName:"Carlos",  lastName:"Perez Estrada",   cedula:"9000000002", esp:"Ingles Turistico" },
  { firstName:"Andrea",  lastName:"Nieto Salazar",   cedula:"9000000003", esp:"Gestion Empresarial" },
  { firstName:"Roberto", lastName:"Lagos Cifuentes", cedula:"9000000004", esp:"Turismo Sostenible" },
];
const cursosData = [
  { title:"Marketing Digital Turistico", description:"Posiciona tu negocio en redes sociales, SEO local y campanas digitales.", modality:"VIRTUAL",    totalSessions:20, isPublished:true },
  { title:"Ingles en el Turismo",        description:"Comunicacion en ingles para atencion de turistas internacionales.",        modality:"VIRTUAL",    totalSessions:20, isPublished:true },
  { title:"Gestion Empresarial",         description:"Planeacion, finanzas basicas y estructura para MiPymes y emprendedores.",  modality:"PRESENCIAL", totalSessions:20, isPublished:true },
  { title:"Turismo Sostenible",          description:"Buenas practicas ambientales para prestadores turisticos de Kennedy.",     modality:"PRESENCIAL", totalSessions:20, isPublished:true },
];
async function main() {
  console.log("Seeding 85 usuarios...");
  const hash = await bcrypt.hash("BuskandoParche2024!", 12);
  await prisma.user.upsert({ where:{email:"admin@buskandoparche.com"}, update:{}, create:{
    email:"admin@buskandoparche.com", passwordHash:await bcrypt.hash("Admin2024!",12),
    role:"ADMIN", firstName:"Admin", lastName:"Sistema", cedula:"8000000001", phone:"3001234567"
  }});
  const fUsers = [];
  for(let i=0;i<formadores.length;i++){
    const f=formadores[i]; const num=String(i+1).padStart(2,"0");
    const email="formador"+num+"@buskandoparche.com";
    const u=await prisma.user.upsert({ where:{email}, update:{}, create:{
      email, passwordHash:await bcrypt.hash("Formador2024!",12), role:"FORMADOR",
      firstName:f.firstName, lastName:f.lastName, cedula:f.cedula, phone:"310000000"+i
    }});
    fUsers.push(u);
  }
  const cursos=[];
  for(let i=0;i<cursosData.length;i++){
    const c=cursosData[i];
    const ex=await prisma.course.findFirst({where:{title:c.title}});
    const course=ex
      ? await prisma.course.update({where:{id:ex.id},data:{...c,formadorId:fUsers[i]?.id}})
      : await prisma.course.create({data:{...c,formadorId:fUsers[i]?.id}});
    cursos.push(course);
    for(let s=1;s<=20;s++){
      await prisma.session.upsert({
        where:{courseId_order:{courseId:course.id,order:s}}, update:{},
        create:{courseId:course.id,title:"Sesion "+s,description:"Contenido sesion "+s+" - "+c.title,order:s}
      });
    }
  }
  for(let i=0;i<beneficiarios.length;i++){
    const b=beneficiarios[i]; const num=String(i+1).padStart(3,"0");
    const email="beneficiario"+num+"@buskandoparche.com";
    const u=await prisma.user.upsert({ where:{email}, update:{}, create:{
      email, passwordHash:hash, role:"BENEFICIARIO",
      firstName:b.firstName, lastName:b.lastName, cedula:b.cedula,
      gender:b.gender, populationGroup:b.pop, locality:"Kennedy", upz:"Kennedy Central",
      phone:"3"+String(100000000+i)
    }});
    const ci=Math.floor(i/20);
    if(ci<cursos.length){
      await prisma.enrollment.upsert({
        where:{userId_courseId:{userId:u.id,courseId:cursos[ci].id}}, update:{},
        create:{userId:u.id,courseId:cursos[ci].id,status:"ACTIVO"}
      });
    }
  }
  console.log("SEED OK: 1 Admin + 4 Formadores + 80 Beneficiarios");
  console.log("admin@buskandoparche.com / Admin2024!");
  console.log("formador01-04@buskandoparche.com / Formador2024!");
  console.log("beneficiario001-080@buskandoparche.com / BuskandoParche2024!");
}
main().catch(e=>{console.error(e);process.exit(1);}).finally(()=>prisma.$disconnect());
'@
[System.IO.File]::WriteAllText("$PWD\backend\prisma\seed.js", $seed, [System.Text.Encoding]::UTF8)
Write-Host "seed.js OK" -ForegroundColor Green

# ── INSTALAR DEPENDENCIA PDF EN BACKEND ──────────────────────
$pkgPath = "$PWD\backend\package.json"
$pkg = Get-Content $pkgPath -Raw | ConvertFrom-Json
if (-not $pkg.dependencies."pdfkit") {
  $pkg.dependencies | Add-Member -NotePropertyName "pdfkit" -NotePropertyValue "^0.15.0" -Force
  $pkg | ConvertTo-Json -Depth 10 | Set-Content $pkgPath
  Write-Host "pdfkit agregado al package.json" -ForegroundColor Green
}

# ── CERTIFICADO ROUTE EN BACKEND ──────────────────────────────
$certRoute = @'
const router = require("express").Router();
const { authenticate } = require("../middleware/auth");
const { PrismaClient } = require("@prisma/client");
const PDFDocument = require("pdfkit");
const path = require("path");
const fs = require("fs");
const prisma = new PrismaClient();

// GET /api/certificates/:courseId  - genera PDF del certificado
router.get("/:courseId", authenticate, async (req, res) => {
  try {
    const { courseId } = req.params;
    const userId = req.user.id;

    const enrollment = await prisma.enrollment.findUnique({
      where: { userId_courseId: { userId, courseId } },
      include: {
        user: true,
        course: { include: { formador: true } }
      }
    });

    if (!enrollment) return res.status(404).json({ error: "No estas inscrito en este curso" });
    if (enrollment.status !== "COMPLETADO") return res.status(403).json({ error: "Debes completar el curso para obtener el certificado" });

    const { user, course } = enrollment;
    const fullName = (user.firstName + " " + user.lastName).toUpperCase();
    const courseTitle = course.title.toUpperCase();
    const completedDate = enrollment.completedAt
      ? new Date(enrollment.completedAt).toLocaleDateString("es-CO", { year:"numeric", month:"long", day:"numeric" })
      : new Date().toLocaleDateString("es-CO", { year:"numeric", month:"long", day:"numeric" });

    const doc = new PDFDocument({ size: "A4", layout: "landscape", margin: 60 });
    res.setHeader("Content-Type", "application/pdf");
    res.setHeader("Content-Disposition", `attachment; filename=certificado-${user.cedula}.pdf`);
    doc.pipe(res);

    // Fondo blanco
    doc.rect(0, 0, doc.page.width, doc.page.height).fill("#FFFFFF");

    // Franja roja superior
    doc.rect(0, 0, doc.page.width, 18).fill("#C0392B");
    // Franja amarilla
    doc.rect(0, 18, doc.page.width, 8).fill("#F39C12");

    // Esquinas decorativas rojo
    doc.rect(0, 26, 80, 80).fill("#C0392B");
    doc.rect(doc.page.width - 80, 26, 80, 80).fill("#C0392B");
    doc.rect(0, doc.page.height - 80, 80, 80).fill("#C0392B");
    doc.rect(doc.page.width - 80, doc.page.height - 80, 80, 80).fill("#C0392B");

    // Triangulos amarillos en esquinas
    doc.save();
    doc.translate(0, 26).polygon([0,0],[0,40],[40,0]).fill("#F39C12");
    doc.restore();

    // Franja roja inferior
    doc.rect(0, doc.page.height - 18, doc.page.width, 18).fill("#C0392B");
    doc.rect(0, doc.page.height - 26, doc.page.width, 8).fill("#F39C12");

    // Borde interior
    doc.rect(50, 50, doc.page.width - 100, doc.page.height - 100).lineWidth(2).stroke("#C0392B");

    // Logo plantilla (si existe)
    const logoPath = path.join(__dirname, "../../frontend/public/images/logo.png");
    if (fs.existsSync(logoPath)) {
      doc.image(logoPath, doc.page.width / 2 - 40, 60, { width: 80, align: "center" });
    }

    let y = 145;

    // Titulo
    doc.font("Helvetica-Bold").fontSize(36).fillColor("#1a1a1a").text("CERTIFICADO", 0, y, { align: "center" });
    y += 42;
    doc.font("Helvetica").fontSize(14).fillColor("#555").text("DE PARTICIPACION", 0, y, { align: "center", characterSpacing: 4 });
    y += 36;

    doc.font("Helvetica").fontSize(13).fillColor("#333").text("Este certificado se entrega a:", 0, y, { align: "center" });
    y += 38;

    // Linea nombre
    doc.moveTo(120, y + 22).lineTo(doc.page.width - 120, y + 22).lineWidth(1).stroke("#999");
    doc.font("Helvetica-Bold").fontSize(24).fillColor("#C0392B").text(fullName, 0, y, { align: "center" });
    y += 46;

    doc.font("Helvetica").fontSize(12).fillColor("#333")
      .text("Por haber asistido y aprobado satisfactoriamente el curso de capacitacion:", 0, y, { align: "center" });
    y += 30;

    doc.font("Helvetica-Bold").fontSize(16).fillColor("#1a1a1a")
      .text(courseTitle, 60, y, { align: "center", width: doc.page.width - 120, characterSpacing: 2 });
    y += 40;

    doc.font("Helvetica-Bold").fontSize(12).fillColor("#333").text("Realizado el: ", 0, y, { align: "center", continued: true });
    doc.font("Helvetica").text(completedDate, { align: "center" });
    y += 20;
    doc.font("Helvetica-Bold").text("Duracion:  ", 0, y, { align: "center", continued: true });
    doc.font("Helvetica").text("40 horas  Modalidad " + (course.modality === "VIRTUAL" ? "Virtual" : "Presencial"), { align: "center" });
    y += 50;

    // Firmas
    const fw = 180; const fy = y;
    const x1 = 110; const x2 = doc.page.width - x1 - fw;

    doc.moveTo(x1, fy).lineTo(x1 + fw, fy).lineWidth(1).stroke("#333");
    doc.font("Helvetica-Bold").fontSize(10).fillColor("#1a1a1a")
      .text("KARLA TATHYANNA MARIN OSPINA", x1, fy + 6, { width: fw, align: "center" });
    doc.font("Helvetica").fontSize(9).fillColor("#555")
      .text("ALCALDESA LOCAL DE KENNEDY", x1, fy + 18, { width: fw, align: "center" });

    doc.moveTo(x2, fy).lineTo(x2 + fw, fy).lineWidth(1).stroke("#333");
    doc.font("Helvetica-Bold").fontSize(10).fillColor("#1a1a1a")
      .text("GERARDO SANTAMARIA BORDA", x2, fy + 6, { width: fw, align: "center" });
    doc.font("Helvetica").fontSize(9).fillColor("#555")
      .text("CEO - BOOST BUSINESS CONSULTING", x2, fy + 18, { width: fw, align: "center" });

    // Logos inferiores
    const logoKPath = path.join(__dirname, "../../frontend/public/images/logo-kennedy.png");
    const logoBPath = path.join(__dirname, "../../frontend/public/images/logo-bogota.png");
    const logoLPath = path.join(__dirname, "../../frontend/public/images/logo.png");
    const bottomY = doc.page.height - 75;
    const centerX = doc.page.width / 2;
    if (fs.existsSync(logoLPath)) doc.image(logoLPath, centerX - 120, bottomY, { height: 35 });
    if (fs.existsSync(logoKPath)) doc.image(logoKPath, centerX - 30, bottomY, { height: 35 });
    if (fs.existsSync(logoBPath)) doc.image(logoBPath, centerX + 60, bottomY, { height: 35 });

    doc.end();
  } catch (err) {
    console.error(err);
    if (!res.headersSent) res.status(500).json({ error: "Error generando certificado" });
  }
});

// POST /api/certificates/:courseId/unlock  - admin marca curso como completado
router.post("/:courseId/unlock", authenticate, async (req, res) => {
  try {
    const { userId } = req.body;
    const { courseId } = req.params;
    const enrollment = await prisma.enrollment.update({
      where: { userId_courseId: { userId, courseId } },
      data: { status: "COMPLETADO", completedAt: new Date() }
    });
    return res.json(enrollment);
  } catch (err) {
    return res.status(500).json({ error: "Error actualizando inscripcion" });
  }
});

module.exports = router;
'@
[System.IO.File]::WriteAllText("$PWD\backend\src\routes\certificates.js", $certRoute, [System.Text.Encoding]::UTF8)
Write-Host "certificates.js OK" -ForegroundColor Green

# ── AGREGAR RUTA DE CERTIFICADOS AL INDEX.JS ──────────────────
$indexPath = "$PWD\backend\src\index.js"
$index = Get-Content $indexPath -Raw
if ($index -notmatch "certificates") {
  $index = $index -replace "const adminRoutes", "const certRoutes = require('./routes/certificates');`nconst adminRoutes"
  $index = $index -replace "app.use\('/api/admin'", "app.use('/api/certificates', certRoutes);`napp.use('/api/admin'"
  [System.IO.File]::WriteAllText($indexPath, $index, [System.Text.Encoding]::UTF8)
  Write-Host "index.js actualizado con ruta /api/certificates" -ForegroundColor Green
}

# ── DOCKERFILE BACKEND (agregar pdfkit deps) ──────────────────
$dockerfile = @'
FROM node:20-alpine
RUN apk add --no-cache openssl openssl-dev libc6-compat
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npx prisma generate
EXPOSE 4000
'@
[System.IO.File]::WriteAllText("$PWD\backend\Dockerfile", $dockerfile, [System.Text.Encoding]::UTF8)
Write-Host "Dockerfile backend OK" -ForegroundColor Green

# ── TAILWIND ──────────────────────────────────────────────────
$tw = @'
module.exports = {
  content: ["./src/**/*.{js,ts,jsx,tsx,mdx}"],
  theme: {
    extend: {
      colors: {
        primary:   { DEFAULT:"#C0392B", light:"#E74C3C", dark:"#922B21" },
        secondary: { DEFAULT:"#F39C12", light:"#F5C518", dark:"#D68910" },
        surface:   { DEFAULT:"#FFFFFF", card:"#FFFFFF", border:"#E5E7EB", muted:"#F3F4F6" },
        text:      { primary:"#111827", secondary:"#374151", muted:"#9CA3AF" },
        success:"#16A34A", warning:"#D97706", error:"#DC2626", info:"#2563EB",
      },
      fontFamily: { sans:["Inter","system-ui","sans-serif"], display:["Poppins","sans-serif"] },
      backgroundImage: { "gradient-brand":"linear-gradient(135deg,#C0392B 0%,#922B21 100%)" },
      boxShadow: { brand:"0 4px 24px rgba(192,57,43,0.25)", card:"0 2px 12px rgba(0,0,0,0.08)" },
      animation: { "fade-in":"fadeIn 0.3s ease-out", "slide-up":"slideUp 0.4s ease-out" },
      keyframes: {
        fadeIn:  { from:{opacity:"0"}, to:{opacity:"1"} },
        slideUp: { from:{transform:"translateY(20px)",opacity:"0"}, to:{transform:"translateY(0)",opacity:"1"} },
      },
    },
  },
  plugins: [],
};
'@
[System.IO.File]::WriteAllText("$PWD\frontend\tailwind.config.js", $tw, [System.Text.Encoding]::UTF8)
Write-Host "tailwind.config.js OK" -ForegroundColor Green

# ── GLOBALS CSS ───────────────────────────────────────────────
$css = @'
@import url("https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Poppins:wght@600;700;800&display=swap");
@tailwind base;
@tailwind components;
@tailwind utilities;
@layer base { html { @apply bg-white text-text-primary; } body { @apply bg-gray-50; } }
@layer components {
  .btn-primary   { @apply bg-primary hover:bg-primary-dark text-white font-semibold px-6 py-3 rounded-lg transition-all duration-200 shadow-brand active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed; }
  .btn-secondary { @apply bg-secondary hover:bg-secondary-dark text-white font-semibold px-6 py-3 rounded-lg transition-all duration-200 active:scale-95; }
  .btn-ghost     { @apply text-text-secondary hover:text-primary hover:bg-red-50 px-4 py-2 rounded-lg transition-all duration-200; }
  .btn-outline   { @apply border border-primary text-primary hover:bg-primary hover:text-white px-6 py-3 rounded-lg transition-all duration-200; }
  .card          { @apply bg-white rounded-2xl border border-surface-border shadow-card p-6; }
  .input         { @apply w-full bg-white border border-gray-300 rounded-lg px-4 py-3 text-text-primary placeholder-text-muted focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all duration-200; }
  .badge         { @apply inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold; }
  .badge-primary   { @apply badge bg-red-100 text-primary; }
  .badge-secondary { @apply badge bg-yellow-100 text-yellow-700; }
  .badge-success   { @apply badge bg-green-100 text-green-700; }
  .badge-warning   { @apply badge bg-orange-100 text-orange-700; }
  .badge-muted     { @apply badge bg-gray-100 text-gray-600; }
  .badge-info      { @apply badge bg-blue-100 text-blue-700; }
}
'@
New-Item -ItemType Directory -Force -Path "frontend\src\app" | Out-Null
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\globals.css", $css, [System.Text.Encoding]::UTF8)
Write-Host "globals.css OK" -ForegroundColor Green

# ── SIDEBAR ───────────────────────────────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\components\layout" | Out-Null
$sidebar = @'
"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useAuth } from "@/contexts/AuthContext";
import { LayoutDashboard,BookOpen,Users,ClipboardList,MessageSquare,Award,LogOut,ChevronRight,BarChart3,GraduationCap } from "lucide-react";
import clsx from "clsx";
const navByRole: Record<string,{href:string;icon:any;label:string}[]> = {
  ADMIN: [
    {href:"/admin",         icon:LayoutDashboard, label:"Dashboard"},
    {href:"/admin/users",   icon:Users,           label:"Usuarios"},
    {href:"/admin/courses", icon:BookOpen,        label:"Cursos"},
    {href:"/admin/reports", icon:BarChart3,       label:"Reportes"},
  ],
  FORMADOR: [
    {href:"/formador",            icon:LayoutDashboard, label:"Panel"},
    {href:"/formador/courses",    icon:BookOpen,        label:"Mis Cursos"},
    {href:"/formador/attendance", icon:ClipboardList,   label:"Asistencia"},
  ],
  BENEFICIARIO: [
    {href:"/lobby",              icon:BookOpen,        label:"Mis Cursos"},
    {href:"/lobby/forum",        icon:MessageSquare,   label:"Foro"},
    {href:"/lobby/certificates", icon:GraduationCap,   label:"Certificados"},
  ],
};
export default function Sidebar() {
  const {user,logout} = useAuth();
  const pathname = usePathname();
  const nav = user?(navByRole[user.role]||[]):[];
  return (
    <aside className="w-64 min-h-screen bg-white border-r border-gray-200 flex flex-col shadow-sm">
      <div className="bg-gradient-brand p-5 flex items-center gap-3">
        <img src="/images/logo.png" alt="Logo" className="h-10 w-auto object-contain"
          onError={(e)=>{(e.target as HTMLImageElement).style.display="none";}}/>
        <div>
          <p className="font-display font-bold text-white text-sm">Buskando Parche</p>
          <p className="text-white/70 text-xs">LMS - Kennedy</p>
        </div>
      </div>
      <div className="p-4 border-b border-gray-100 bg-gray-50">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-gradient-brand rounded-full flex items-center justify-center font-bold text-white text-sm flex-shrink-0">
            {user?.firstName?.[0]}{user?.lastName?.[0]}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-semibold text-text-primary truncate">{user?.firstName} {user?.lastName}</p>
            <span className={clsx("badge text-xs mt-0.5",{"badge-primary":user?.role==="ADMIN","badge-secondary":user?.role==="FORMADOR","badge-muted":user?.role==="BENEFICIARIO"})}>
              {user?.role==="ADMIN"?"Administrador":user?.role==="FORMADOR"?"Formador":"Beneficiario"}
            </span>
          </div>
        </div>
      </div>
      <nav className="flex-1 p-4 space-y-1">
        {nav.map(({href,icon:Icon,label})=>{
          const isActive=pathname===href||pathname.startsWith(href+"/");
          return (
            <Link key={href} href={href} className={clsx("flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all duration-200 group",
              isActive?"bg-red-50 text-primary border border-red-100":"text-text-secondary hover:bg-gray-50 hover:text-primary")}>
              <Icon className={clsx("w-5 h-5",isActive?"text-primary":"text-gray-400 group-hover:text-primary")}/>
              {label}
              {isActive&&<ChevronRight className="w-4 h-4 ml-auto text-primary"/>}
            </Link>
          );
        })}
      </nav>
      <div className="p-4 border-t border-gray-100">
        <button onClick={logout} className="btn-ghost w-full flex items-center gap-3 text-sm text-gray-500">
          <LogOut className="w-5 h-5"/> Cerrar sesion
        </button>
      </div>
    </aside>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\frontend\src\components\layout\Sidebar.tsx", $sidebar, [System.Text.Encoding]::UTF8)
Write-Host "Sidebar.tsx OK" -ForegroundColor Green

# ── APPSHELL ──────────────────────────────────────────────────
$shell = @'
"use client";
import {useAuth} from "@/contexts/AuthContext";
import {useRouter} from "next/navigation";
import {useEffect} from "react";
import Sidebar from "./Sidebar";
import {Loader2} from "lucide-react";
export default function AppShell({children,allowedRoles}:{children:React.ReactNode;allowedRoles:string[]}) {
  const {user,isLoading}=useAuth(); const router=useRouter();
  useEffect(()=>{
    if(!isLoading&&!user) router.push("/login");
    if(!isLoading&&user&&!allowedRoles.includes(user.role)) router.push("/login");
  },[user,isLoading]);
  if(isLoading) return <div className="min-h-screen flex items-center justify-center bg-gray-50"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div>;
  return (
    <div className="flex min-h-screen bg-gray-50">
      <Sidebar/>
      <main className="flex-1 overflow-y-auto animate-fade-in">
        <div className="bg-white border-b border-gray-200 px-8 py-4 flex items-center justify-between">
          <span className="font-display font-bold text-primary text-xl">Buskando <span className="text-secondary">Parche</span></span>
          <span className="text-sm text-text-muted">Programa de Formacion - Kennedy</span>
        </div>
        <div className="p-8">{children}</div>
      </main>
    </div>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\frontend\src\components\layout\AppShell.tsx", $shell, [System.Text.Encoding]::UTF8)
Write-Host "AppShell.tsx OK" -ForegroundColor Green

# ── LOGIN CON VIDEO ───────────────────────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\login" | Out-Null
$login = @'
"use client";
import {useState} from "react";
import {useRouter} from "next/navigation";
import {useAuth} from "@/contexts/AuthContext";
import toast from "react-hot-toast";
import {Lock,Mail,Loader2} from "lucide-react";
export default function LoginPage() {
  const {login}=useAuth(); const router=useRouter();
  const [email,setEmail]=useState(""); const [password,setPassword]=useState(""); const [loading,setLoading]=useState(false);
  const handleSubmit=async(e:React.FormEvent)=>{
    e.preventDefault(); setLoading(true);
    try {
      await login(email,password);
      const p=JSON.parse(atob(localStorage.getItem("bp_token")!.split(".")[1]));
      if(p.role==="ADMIN") router.push("/admin");
      else if(p.role==="FORMADOR") router.push("/formador");
      else router.push("/lobby");
    } catch { toast.error("Credenciales incorrectas."); }
    finally { setLoading(false); }
  };
  return (
    <div className="min-h-screen flex items-center justify-center relative overflow-hidden">
      <video autoPlay muted loop playsInline className="absolute inset-0 w-full h-full object-cover z-0">
        <source src="/videos/kennedy.mp4" type="video/mp4"/>
      </video>
      <div className="absolute inset-0 bg-black/60 z-10"/>
      <div className="relative z-20 w-full max-w-md px-6 animate-slide-up">
        <div className="flex flex-col items-center mb-8">
          <div className="bg-white rounded-2xl p-4 shadow-2xl mb-4">
            <img src="/images/logo.png" alt="Buskando Parche" className="h-20 w-auto object-contain"
              onError={(e)=>{(e.target as HTMLImageElement).style.display="none";}}/>
          </div>
          <h1 className="font-display text-3xl font-bold text-white text-center">Buskando <span className="text-secondary">Parche</span></h1>
          <p className="text-white/80 text-sm mt-1 text-center">Plataforma de Formacion - Kennedy, Bogota</p>
        </div>
        <div className="bg-white rounded-2xl shadow-2xl p-8">
          <h2 className="text-xl font-bold text-text-primary mb-1">Iniciar sesion</h2>
          <p className="text-text-muted text-sm mb-6">Ingresa con tus credenciales asignadas</p>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-text-secondary mb-1.5">Correo electronico</label>
              <div className="relative"><Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400"/>
                <input type="email" className="input pl-10" placeholder="tu@correo.com" value={email} onChange={e=>setEmail(e.target.value)} required/>
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-text-secondary mb-1.5">Contrasena</label>
              <div className="relative"><Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400"/>
                <input type="password" className="input pl-10" placeholder="..." value={password} onChange={e=>setPassword(e.target.value)} required/>
              </div>
            </div>
            <button type="submit" disabled={loading} className="btn-primary w-full flex items-center justify-center gap-2 mt-2">
              {loading&&<Loader2 className="w-5 h-5 animate-spin"/>}
              {loading?"Ingresando...":"Ingresar a la plataforma"}
            </button>
          </form>
          <p className="text-center text-text-muted text-xs mt-4">Problemas? Contacta al coordinador del programa.</p>
        </div>
        <div className="flex items-center justify-center gap-6 mt-6">
          <img src="/images/logo-kennedy.png" alt="Kennedy" className="h-8 w-auto opacity-70"
            onError={(e)=>{(e.target as HTMLImageElement).style.display="none";}}/>
          <img src="/images/logo-bogota.png" alt="Bogota" className="h-8 w-auto opacity-70"
            onError={(e)=>{(e.target as HTMLImageElement).style.display="none";}}/>
        </div>
      </div>
    </div>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\login\page.tsx", $login, [System.Text.Encoding]::UTF8)
Write-Host "Login con video OK" -ForegroundColor Green

# ── LOBBY ─────────────────────────────────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(student)\lobby" | Out-Null
$lobby = @'
"use client";
import {useEffect,useState} from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import {useAuth} from "@/contexts/AuthContext";
import {BookOpen,Lock,Users,PlayCircle,Search,CheckCircle,Loader2} from "lucide-react";
import Link from "next/link";
import clsx from "clsx";
const imgs: Record<string,string> = {
  "Marketing Digital Turistico":"/images/marketing.jpg",
  "Ingles en el Turismo":"/images/ingles.jpg",
  "Gestion Empresarial":"/images/gestion.jpg",
  "Turismo Sostenible":"/images/turismo.jpg",
};
const colors=["#C0392B","#2563EB","#16A34A","#D97706"];
export default function LobbyPage() {
  const {user}=useAuth();
  const [courses,setCourses]=useState<any[]>([]); const [loading,setLoading]=useState(true); const [search,setSearch]=useState("");
  useEffect(()=>{ api.get("/courses/lobby").then(({data})=>setCourses(data)).finally(()=>setLoading(false)); },[]);
  const filtered=courses.filter((c:any)=>c.title.toLowerCase().includes(search.toLowerCase()));
  const enrolled=filtered.filter((c:any)=>c.isEnrolled);
  const locked=filtered.filter((c:any)=>!c.isEnrolled);
  return (
    <AppShell allowedRoles={["BENEFICIARIO"]}>
      <div className="max-w-5xl mx-auto space-y-8">
        <div>
          <h1 className="font-display text-3xl font-bold text-text-primary">Hola, <span className="text-primary">{user?.firstName}</span></h1>
          <p className="text-text-secondary mt-1">Bienvenido a tu espacio de aprendizaje.</p>
        </div>
        <div className="relative max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400"/>
          <input className="input pl-10" placeholder="Buscar cursos..." value={search} onChange={e=>setSearch(e.target.value)}/>
        </div>
        {loading?<div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div>:(
          <>
            {enrolled.length>0&&(
              <section>
                <div className="flex items-center gap-2 mb-5"><div className="w-1 h-6 bg-primary rounded-full"/>
                  <h2 className="text-xl font-bold text-text-primary">Mis Cursos</h2>
                  <span className="badge-primary ml-1">{enrolled.length}</span>
                </div>
                <div className="grid md:grid-cols-2 gap-5">
                  {enrolled.map((c:any,i:number)=>(
                    <div key={c.id} className="card overflow-hidden p-0 hover:shadow-lg transition-shadow group">
                      <div className="relative h-44 overflow-hidden" style={{background:colors[i%4]}}>
                        <img src={imgs[c.title]||""} alt={c.title} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                          onError={(e)=>{(e.target as HTMLImageElement).style.display="none";}}/>
                        <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"/>
                        <div className="absolute top-3 left-3"><span className="badge-success"><CheckCircle className="w-3 h-3"/> Inscrito</span></div>
                        <div className="absolute top-3 right-3">
                          <span className={clsx("badge",c.modality==="VIRTUAL"?"bg-blue-100 text-blue-700":"bg-green-100 text-green-700")}>
                            {c.modality==="VIRTUAL"?"Virtual":"Presencial"}
                          </span>
                        </div>
                      </div>
                      <div className="p-5">
                        <h3 className="font-bold text-lg text-text-primary mb-1">{c.title}</h3>
                        <p className="text-text-muted text-sm line-clamp-2 mb-4">{c.description}</p>
                        <div className="flex items-center gap-4 text-xs text-text-muted mb-4">
                          <span className="flex items-center gap-1"><PlayCircle className="w-4 h-4"/> {c.totalSessions} sesiones</span>
                          <span className="flex items-center gap-1"><Users className="w-4 h-4"/> {c.totalEnrolled} inscritos</span>
                        </div>
                        <Link href={"/courses/"+c.id} className="btn-primary w-full text-center block py-2.5 text-sm">Acceder al curso</Link>
                      </div>
                    </div>
                  ))}
                </div>
              </section>
            )}
            {locked.length>0&&(
              <section>
                <div className="flex items-center gap-2 mb-5"><div className="w-1 h-6 bg-gray-300 rounded-full"/>
                  <h2 className="text-xl font-bold text-text-primary">Otros programas</h2>
                  <span className="badge-muted">{locked.length}</span>
                </div>
                <p className="text-text-muted text-sm mb-4 flex items-center gap-2"><Lock className="w-4 h-4"/> Acceso solo para participantes asignados.</p>
                <div className="grid md:grid-cols-2 gap-5">
                  {locked.map((c:any,i:number)=>(
                    <div key={c.id} className="card overflow-hidden p-0 opacity-60 cursor-not-allowed">
                      <div className="relative h-44 bg-gray-200">
                        <img src={imgs[c.title]||""} alt={c.title} className="w-full h-full object-cover grayscale"
                          onError={(e)=>{(e.target as HTMLImageElement).style.display="none";}}/>
                        <div className="absolute inset-0 bg-gray-900/50 flex items-center justify-center">
                          <div className="bg-white/90 rounded-full p-3"><Lock className="w-6 h-6 text-gray-500"/></div>
                        </div>
                      </div>
                      <div className="p-5">
                        <h3 className="font-bold text-lg text-gray-500 mb-1">{c.title}</h3>
                        <p className="text-gray-400 text-sm line-clamp-2 mb-4">{c.description}</p>
                        <div className="bg-gray-100 rounded-lg px-4 py-2.5 text-center text-sm text-gray-500 flex items-center justify-center gap-2">
                          <Lock className="w-4 h-4"/> Solo para participantes asignados
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </section>
            )}
          </>
        )}
      </div>
    </AppShell>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(student)\lobby\page.tsx", $lobby, [System.Text.Encoding]::UTF8)
Write-Host "Lobby OK" -ForegroundColor Green

# ── CERTIFICADOS PAGE ─────────────────────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(student)\lobby\certificates" | Out-Null
$certsPage = @'
"use client";
import {useEffect,useState} from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import {GraduationCap,Download,Lock,Loader2,CheckCircle} from "lucide-react";
import clsx from "clsx";
export default function CertificatesPage() {
  const [courses,setCourses]=useState<any[]>([]); const [loading,setLoading]=useState(true);
  useEffect(()=>{ api.get("/courses/lobby").then(({data})=>setCourses(data)).finally(()=>setLoading(false)); },[]);
  const handleDownload=async(courseId:string)=>{
    try {
      const res=await api.get("/certificates/"+courseId,{responseType:"blob"});
      const url=window.URL.createObjectURL(new Blob([res.data]));
      const a=document.createElement("a"); a.href=url; a.download="certificado.pdf"; a.click();
    } catch(e:any) {
      const msg=e.response?.data?.error||"Error al descargar";
      alert(msg);
    }
  };
  return (
    <AppShell allowedRoles={["BENEFICIARIO"]}>
      <div className="max-w-3xl mx-auto space-y-6">
        <div><h1 className="font-display text-3xl font-bold text-text-primary">Mis Certificados</h1>
          <p className="text-text-secondary mt-1">Descarga tus certificados al completar cada curso.</p>
        </div>
        {loading?<div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div>:(
          <div className="space-y-4">
            {courses.filter((c:any)=>c.isEnrolled).map((c:any)=>(
              <div key={c.id} className="card flex items-center gap-5">
                <div className={clsx("p-4 rounded-xl flex-shrink-0",c.enrollmentStatus==="COMPLETADO"?"bg-green-100":"bg-gray-100")}>
                  <GraduationCap className={clsx("w-8 h-8",c.enrollmentStatus==="COMPLETADO"?"text-green-600":"text-gray-400")}/>
                </div>
                <div className="flex-1">
                  <h3 className="font-bold text-text-primary">{c.title}</h3>
                  <p className="text-sm text-text-muted mt-0.5">
                    {c.enrollmentStatus==="COMPLETADO"
                      ?"Curso completado - Certificado disponible"
                      :"Completa el curso para habilitar el certificado"}
                  </p>
                  {c.enrollmentStatus==="COMPLETADO"&&(
                    <span className="badge-success mt-2 inline-flex"><CheckCircle className="w-3 h-3"/> Completado</span>
                  )}
                </div>
                {c.enrollmentStatus==="COMPLETADO"?(
                  <button onClick={()=>handleDownload(c.id)} className="btn-primary flex items-center gap-2 flex-shrink-0">
                    <Download className="w-4 h-4"/> Descargar PDF
                  </button>
                ):(
                  <div className="flex items-center gap-2 text-gray-400 flex-shrink-0 text-sm">
                    <Lock className="w-4 h-4"/> Bloqueado
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </AppShell>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(student)\lobby\certificates\page.tsx", $certsPage, [System.Text.Encoding]::UTF8)
Write-Host "Certificates page OK" -ForegroundColor Green

# ── ADMIN DASHBOARD ───────────────────────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\admin" | Out-Null
$admin = @'
"use client";
import {useEffect,useState} from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import {Users,BookOpen,TrendingUp,Heart,Loader2,AlertTriangle,CheckCircle} from "lucide-react";
import {BarChart,Bar,XAxis,YAxis,Tooltip,ResponsiveContainer,Cell,PieChart,Pie,Legend} from "recharts";
function KpiCard({label,value,icon:Icon,color,subtitle}:any) {
  const c:any={red:"bg-red-50 text-red-600 border-red-100",yellow:"bg-yellow-50 text-yellow-600 border-yellow-100",green:"bg-green-50 text-green-600 border-green-100",blue:"bg-blue-50 text-blue-600 border-blue-100"};
  return <div className="card flex items-start gap-4"><div className={"p-3 rounded-xl border flex-shrink-0 "+c[color]}><Icon className="w-6 h-6"/></div><div><p className="text-text-muted text-sm">{label}</p><p className="text-2xl font-bold font-display text-text-primary mt-0.5">{value}</p>{subtitle&&<p className="text-text-muted text-xs mt-1">{subtitle}</p>}</div></div>;
}
const PC=["#C0392B","#2563EB","#16A34A","#D97706","#7C3AED","#EC4899"];
export default function AdminDashboard() {
  const [data,setData]=useState<any>(null); const [loading,setLoading]=useState(true); const [error,setError]=useState("");
  useEffect(()=>{ api.get("/admin/dashboard").then(({data})=>setData(data)).catch(()=>setError("No se pudo cargar el dashboard.")).finally(()=>setLoading(false)); },[]);
  if(loading) return <AppShell allowedRoles={["ADMIN"]}><div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div></AppShell>;
  if(error) return <AppShell allowedRoles={["ADMIN"]}><div className="card bg-red-50 border-red-200 text-red-700 flex items-center gap-3"><AlertTriangle className="w-5 h-5"/>{error}</div></AppShell>;
  return (
    <AppShell allowedRoles={["ADMIN"]}>
      <div className="max-w-6xl mx-auto space-y-8">
        <div><h1 className="font-display text-3xl font-bold text-text-primary">Dashboard Administrativo</h1><p className="text-text-secondary mt-1">Monitoreo del programa de formacion</p></div>
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-4">
          <KpiCard label="Total beneficiarios"  value={data?.kpis.totalBeneficiarios}   icon={Users}      color="red"    subtitle="de 80 cupos objetivo"/>
          <KpiCard label="% Asistencia global"  value={data?.kpis.porcentajeAsistencia} icon={TrendingUp} color="green"  subtitle="Todas las sesiones"/>
          <KpiCard label="Cursos activos"       value={data?.kpis.totalCourses}         icon={BookOpen}   color="blue"   subtitle="Programas publicados"/>
          <KpiCard label="Meta genero mujeres"  value={data?.kpis.porcentajeMujeres}    icon={Heart}      color="yellow" subtitle={data?.kpis.metaMujeres}/>
        </div>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="card"><h3 className="font-bold text-text-primary mb-4">Inscritos por curso</h3>
            <ResponsiveContainer width="100%" height={220}>
              <BarChart data={data?.courseKpis} barSize={36}>
                <XAxis dataKey="title" tick={{fill:"#6B7280",fontSize:10}} tickLine={false}/>
                <YAxis tick={{fill:"#6B7280",fontSize:11}} axisLine={false} tickLine={false}/>
                <Tooltip contentStyle={{background:"#fff",border:"1px solid #E5E7EB",borderRadius:8}}/>
                <Bar dataKey="inscritos" radius={[6,6,0,0]}>{data?.courseKpis?.map((_:any,i:number)=><Cell key={i} fill={i%2===0?"#C0392B":"#F39C12"}/>)}</Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>
          <div className="card"><h3 className="font-bold text-text-primary mb-4">Grupos poblacionales</h3>
            {data?.populationBreakdown?.length>0?(
              <ResponsiveContainer width="100%" height={220}>
                <PieChart><Pie data={data.populationBreakdown} dataKey="cantidad" nameKey="grupo" cx="50%" cy="50%" outerRadius={80} label>
                  {data.populationBreakdown.map((_:any,i:number)=><Cell key={i} fill={PC[i%PC.length]}/>)}
                </Pie><Tooltip/><Legend/></PieChart>
              </ResponsiveContainer>
            ):<p className="text-text-muted text-sm py-8 text-center">Sin datos aun</p>}
          </div>
        </div>
        <div className={"flex items-start gap-4 p-4 rounded-xl border "+(data?.kpis.metaMujeres?.includes("Cumplida")?"bg-green-50 border-green-200 text-green-700":"bg-yellow-50 border-yellow-200 text-yellow-700")}>
          {data?.kpis.metaMujeres?.includes("Cumplida")?<CheckCircle className="w-5 h-5 mt-0.5"/>:<AlertTriangle className="w-5 h-5 mt-0.5"/>}
          <div><p className="font-semibold text-sm">Meta paridad de genero</p>
            <p className="text-sm opacity-80 mt-0.5">Minimo 50% mujeres. Actualmente: <strong>{data?.kpis.porcentajeMujeres}</strong> - {data?.kpis.metaMujeres}</p>
          </div>
        </div>
      </div>
    </AppShell>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\admin\page.tsx", $admin, [System.Text.Encoding]::UTF8)
Write-Host "Admin dashboard OK" -ForegroundColor Green

# ── ADMIN USUARIOS PAGE ───────────────────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\admin\users" | Out-Null
$adminUsers = @'
"use client";
import {useEffect,useState} from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import {Users,Search,Plus,Download,Loader2,CheckCircle,XCircle,BookOpen} from "lucide-react";
import clsx from "clsx";
export default function AdminUsersPage() {
  const [users,setUsers]=useState<any[]>([]); const [loading,setLoading]=useState(true);
  const [search,setSearch]=useState(""); const [roleFilter,setRoleFilter]=useState("BENEFICIARIO");
  const [page,setPage]=useState(1); const [total,setTotal]=useState(0);
  const fetchUsers=()=>{
    setLoading(true);
    api.get("/users",{params:{role:roleFilter,page,limit:20}})
      .then(({data})=>{setUsers(data.data);setTotal(data.total);})
      .finally(()=>setLoading(false));
  };
  useEffect(()=>{ fetchUsers(); },[roleFilter,page]);
  const filtered=users.filter((u:any)=>(u.firstName+" "+u.lastName+" "+u.cedula+" "+u.email).toLowerCase().includes(search.toLowerCase()));
  const exportCSV=()=>{
    const header="Nombre,Cedula,Email,Genero,Grupo Poblacional,Localidad,Estado\n";
    const rows=users.map((u:any)=>[u.firstName+" "+u.lastName,u.cedula,u.email,u.gender||"",u.populationGroup||"",u.locality||"",u.isActive?"Activo":"Inactivo"].join(",")).join("\n");
    const blob=new Blob([header+rows],{type:"text/csv"});
    const a=document.createElement("a"); a.href=URL.createObjectURL(blob); a.download="usuarios.csv"; a.click();
  };
  const markComplete=async(userId:string,courseId:string)=>{
    await api.post("/certificates/"+courseId+"/unlock",{userId});
    alert("Certificado habilitado para el usuario");
    fetchUsers();
  };
  return (
    <AppShell allowedRoles={["ADMIN"]}>
      <div className="max-w-6xl mx-auto space-y-6">
        <div className="flex items-center justify-between">
          <div><h1 className="font-display text-3xl font-bold text-text-primary">Gestion de Usuarios</h1><p className="text-text-secondary mt-1">Total: {total} usuarios</p></div>
          <div className="flex gap-3">
            <button onClick={exportCSV} className="btn-outline flex items-center gap-2 text-sm"><Download className="w-4 h-4"/> Exportar CSV</button>
          </div>
        </div>
        <div className="card">
          <div className="flex flex-col md:flex-row gap-4 mb-6">
            <div className="relative flex-1"><Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400"/>
              <input className="input pl-10" placeholder="Buscar por nombre, cedula o email..." value={search} onChange={e=>setSearch(e.target.value)}/>
            </div>
            <select className="input w-auto" value={roleFilter} onChange={e=>{setRoleFilter(e.target.value);setPage(1);}}>
              <option value="BENEFICIARIO">Beneficiarios</option>
              <option value="FORMADOR">Formadores</option>
              <option value="ADMIN">Admins</option>
            </select>
          </div>
          {loading?<div className="flex justify-center py-12"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div>:(
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b border-gray-100">
                    <th className="text-left py-3 px-4 font-semibold text-text-secondary">Nombre</th>
                    <th className="text-left py-3 px-4 font-semibold text-text-secondary">Cedula</th>
                    <th className="text-left py-3 px-4 font-semibold text-text-secondary">Email / Contrasena</th>
                    <th className="text-left py-3 px-4 font-semibold text-text-secondary">Genero</th>
                    <th className="text-left py-3 px-4 font-semibold text-text-secondary">Grupo</th>
                    <th className="text-left py-3 px-4 font-semibold text-text-secondary">Curso inscrito</th>
                    <th className="text-left py-3 px-4 font-semibold text-text-secondary">Estado</th>
                    {roleFilter==="BENEFICIARIO"&&<th className="text-left py-3 px-4 font-semibold text-text-secondary">Certificado</th>}
                  </tr>
                </thead>
                <tbody>
                  {filtered.map((u:any)=>(
                    <tr key={u.id} className="border-b border-gray-50 hover:bg-gray-50 transition-colors">
                      <td className="py-3 px-4 font-medium text-text-primary">{u.firstName} {u.lastName}</td>
                      <td className="py-3 px-4 text-text-secondary">{u.cedula}</td>
                      <td className="py-3 px-4">
                        <p className="text-text-secondary text-xs">{u.email}</p>
                        <p className="text-text-muted text-xs">{roleFilter==="BENEFICIARIO"?"BuskandoParche2024!":roleFilter==="FORMADOR"?"Formador2024!":"Admin2024!"}</p>
                      </td>
                      <td className="py-3 px-4"><span className={clsx("badge",u.gender==="FEMENINO"?"badge-secondary":u.gender==="MASCULINO"?"badge-info":"badge-muted")}>{u.gender||"N/A"}</span></td>
                      <td className="py-3 px-4 text-text-secondary text-xs">{u.populationGroup||"N/A"}</td>
                      <td className="py-3 px-4">
                        {u.enrollments?.length>0
                          ?<span className="badge-primary flex items-center gap-1"><BookOpen className="w-3 h-3"/> {u.enrollments[0].status}</span>
                          :<span className="text-text-muted text-xs">Sin inscripcion</span>}
                      </td>
                      <td className="py-3 px-4">
                        {u.isActive
                          ?<span className="badge-success flex items-center gap-1"><CheckCircle className="w-3 h-3"/> Activo</span>
                          :<span className="badge-muted flex items-center gap-1"><XCircle className="w-3 h-3"/> Inactivo</span>}
                      </td>
                      {roleFilter==="BENEFICIARIO"&&(
                        <td className="py-3 px-4">
                          {u.enrollments?.length>0&&u.enrollments[0].status!=="COMPLETADO"?(
                            <button onClick={()=>markComplete(u.id,u.enrollments[0].courseId)}
                              className="text-xs bg-green-100 text-green-700 px-3 py-1 rounded-lg hover:bg-green-200 transition-colors">
                              Habilitar cert.
                            </button>
                          ):u.enrollments?.[0]?.status==="COMPLETADO"?(
                            <span className="badge-success text-xs"><CheckCircle className="w-3 h-3"/> Habilitado</span>
                          ):<span className="text-text-muted text-xs">-</span>}
                        </td>
                      )}
                    </tr>
                  ))}
                </tbody>
              </table>
              {filtered.length===0&&<p className="text-center text-text-muted py-8">No se encontraron usuarios</p>}
            </div>
          )}
          <div className="flex items-center justify-between mt-4 pt-4 border-t border-gray-100">
            <p className="text-sm text-text-muted">Mostrando {filtered.length} de {total}</p>
            <div className="flex gap-2">
              <button onClick={()=>setPage(p=>Math.max(1,p-1))} disabled={page===1} className="btn-ghost text-sm disabled:opacity-40">Anterior</button>
              <span className="px-3 py-1 text-sm text-text-secondary">Pag. {page}</span>
              <button onClick={()=>setPage(p=>p+1)} disabled={users.length<20} className="btn-ghost text-sm disabled:opacity-40">Siguiente</button>
            </div>
          </div>
        </div>
      </div>
    </AppShell>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\admin\users\page.tsx", $adminUsers, [System.Text.Encoding]::UTF8)
Write-Host "Admin users page OK" -ForegroundColor Green

# ── FORMADOR PANEL ────────────────────────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\formador" | Out-Null
$formador = @'
"use client";
import {useEffect,useState} from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import {BookOpen,Users,ClipboardList,CheckCircle,Loader2} from "lucide-react";
import Link from "next/link";
export default function FormadorPanel() {
  const [courses,setCourses]=useState<any[]>([]); const [loading,setLoading]=useState(true);
  useEffect(()=>{ api.get("/courses/lobby").then(({data})=>setCourses(data.filter((c:any)=>c.isEnrolled||true))).finally(()=>setLoading(false)); },[]);
  return (
    <AppShell allowedRoles={["FORMADOR"]}>
      <div className="max-w-4xl mx-auto space-y-8">
        <div><h1 className="font-display text-3xl font-bold text-text-primary">Portal del Formador</h1><p className="text-text-secondary mt-1">Gestiona tus cursos, asistencia y retroalimentacion.</p></div>
        {loading?<div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div>:(
          <div className="grid md:grid-cols-2 gap-5">
            {courses.map((c:any)=>(
              <div key={c.id} className="card hover:shadow-lg transition-shadow">
                <div className="flex items-start gap-4">
                  <div className="p-3 bg-red-50 rounded-xl"><BookOpen className="w-6 h-6 text-primary"/></div>
                  <div className="flex-1">
                    <h3 className="font-bold text-text-primary">{c.title}</h3>
                    <p className="text-text-muted text-sm mt-1">{c.modality==="VIRTUAL"?"Virtual":"Presencial"} - {c.totalSessions} sesiones</p>
                    <div className="flex items-center gap-2 mt-2"><Users className="w-4 h-4 text-text-muted"/><span className="text-sm text-text-secondary">{c.totalEnrolled} inscritos</span></div>
                  </div>
                </div>
                <div className="flex gap-3 mt-4">
                  <Link href={"/courses/"+c.id} className="btn-primary flex-1 text-center py-2 text-sm flex items-center justify-center gap-2"><BookOpen className="w-4 h-4"/> Ver curso</Link>
                  <Link href={"/formador/attendance?courseId="+c.id} className="btn-outline flex-1 text-center py-2 text-sm flex items-center justify-center gap-2"><ClipboardList className="w-4 h-4"/> Asistencia</Link>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </AppShell>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\formador\page.tsx", $formador, [System.Text.Encoding]::UTF8)
Write-Host "Formador panel OK" -ForegroundColor Green

# ── CREAR CARPETAS NECESARIAS ─────────────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\public\images" | Out-Null
New-Item -ItemType Directory -Force -Path "frontend\public\videos" | Out-Null
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\admin\courses" | Out-Null
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\admin\reports" | Out-Null
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\formador\courses" | Out-Null
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\formador\attendance" | Out-Null
New-Item -ItemType Directory -Force -Path "frontend\src\app\(student)\courses\[id]" | Out-Null

# Paginas placeholder para rutas pendientes
$placeholder = @'
"use client";
import AppShell from "@/components/layout/AppShell";
export default function Page() {
  return <AppShell allowedRoles={["ADMIN","FORMADOR","BENEFICIARIO"]}><div className="card"><h1 className="font-display text-2xl font-bold text-text-primary">Modulo en construccion</h1><p className="text-text-muted mt-2">Esta seccion estara disponible pronto.</p></div></AppShell>;
}
'@
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\admin\courses\page.tsx", $placeholder, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\admin\reports\page.tsx", $placeholder, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\formador\courses\page.tsx", $placeholder, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\formador\attendance\page.tsx", $placeholder, [System.Text.Encoding]::UTF8)

Write-Host "Paginas placeholder creadas" -ForegroundColor Green

Write-Host ""
Write-Host "============================================================" -ForegroundColor Yellow
Write-Host "ACTUALIZACION COMPLETA OK" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "AHORA copia tus imagenes (una sola vez):" -ForegroundColor Cyan
Write-Host ""
Write-Host '  copy "..\imagenes\LOGO-.png"       "frontend\public\images\logo.png"'
Write-Host '  copy "..\imagenes\certificado.png" "frontend\public\images\certificado-template.png"'
Write-Host '  copy "..\imagenes\kenn1__1_.jpg"   "frontend\public\images\marketing.jpg"'
Write-Host '  copy "..\imagenes\kenn2__1_.jpg"   "frontend\public\images\ingles.jpg"'
Write-Host '  copy "..\imagenes\kenn3__1_.jpg"   "frontend\public\images\gestion.jpg"'
Write-Host '  copy "..\imagenes\kenn4__1_.jpg"   "frontend\public\images\turismo.jpg"'
Write-Host '  copy "..\imagenes\kennedy.mp4"     "frontend\public\videos\kennedy.mp4"'
Write-Host ""
Write-Host "Luego ejecuta:" -ForegroundColor Cyan
Write-Host "  docker-compose up --build" -ForegroundColor White
