# ================================================================
# CORRECCION COMPLETA V4 - BUSKANDO PARCHE
# ================================================================
Write-Host "=== APLICANDO CORRECCIONES V4 ===" -ForegroundColor Yellow

# ── SEED CORREGIDO: exactamente 4 cursos ─────────────────────
$seed = @'
const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcryptjs");
const prisma = new PrismaClient();

// Solo 4 cursos exactos
const CURSOS = [
  { title: "Ingles en el Turismo",   description: "Comunicacion en ingles para atencion de turistas internacionales.", modality: "VIRTUAL",    totalSessions: 20 },
  { title: "Gestion Empresarial",    description: "Planeacion, finanzas basicas y estructura para MiPymes y emprendedores.", modality: "PRESENCIAL", totalSessions: 20 },
  { title: "Gestion Turistica",      description: "Herramientas de gestion para prestadores turisticos de Kennedy.", modality: "PRESENCIAL", totalSessions: 20 },
  { title: "Marketing Digital",      description: "Posiciona tu negocio en redes sociales, SEO y campanas digitales.", modality: "VIRTUAL",    totalSessions: 20 },
];

// 4 formadores, 1 por curso
const FORMADORES = [
  { firstName: "Maria",   lastName: "Ramirez Solano",  cedula: "9000000001", email: "formador01@buskandoparche.com" },
  { firstName: "Carlos",  lastName: "Perez Estrada",   cedula: "9000000002", email: "formador02@buskandoparche.com" },
  { firstName: "Andrea",  lastName: "Nieto Salazar",   cedula: "9000000003", email: "formador03@buskandoparche.com" },
  { firstName: "Roberto", lastName: "Lagos Cifuentes", cedula: "9000000004", email: "formador04@buskandoparche.com" },
];

const BENEFICIARIOS = [
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

async function main() {
  console.log("Limpiando cursos anteriores y recreando exactamente 4...");
  
  // Eliminar cursos que no son los 4 correctos
  const titulos4 = CURSOS.map(c => c.title);
  const cursosExtra = await prisma.course.findMany({ where: { title: { notIn: titulos4 } } });
  for (const c of cursosExtra) {
    await prisma.session.deleteMany({ where: { courseId: c.id } });
    await prisma.enrollment.deleteMany({ where: { courseId: c.id } });
    await prisma.course.delete({ where: { id: c.id } });
  }

  // Admin
  await prisma.user.upsert({ where: { email: "admin@buskandoparche.com" }, update: {}, create: {
    email: "admin@buskandoparche.com", passwordHash: await bcrypt.hash("Admin2024!", 12),
    role: "ADMIN", firstName: "Admin", lastName: "Sistema", cedula: "8000000001"
  }});

  // 4 Formadores
  const formUsers = [];
  for (let i = 0; i < FORMADORES.length; i++) {
    const f = FORMADORES[i];
    const u = await prisma.user.upsert({ where: { email: f.email }, update: {}, create: {
      email: f.email, passwordHash: await bcrypt.hash("Formador2024!", 12),
      role: "FORMADOR", firstName: f.firstName, lastName: f.lastName, cedula: f.cedula
    }});
    formUsers.push(u);
  }

  // 4 Cursos exactos
  const cursos = [];
  for (let i = 0; i < CURSOS.length; i++) {
    const c = CURSOS[i];
    const existing = await prisma.course.findFirst({ where: { title: c.title } });
    let course;
    if (existing) {
      course = await prisma.course.update({ where: { id: existing.id }, data: { ...c, isPublished: true, formadorId: formUsers[i].id } });
    } else {
      course = await prisma.course.create({ data: { ...c, isPublished: true, formadorId: formUsers[i].id } });
    }
    cursos.push(course);
    // 20 sesiones por curso
    for (let s = 1; s <= 20; s++) {
      await prisma.session.upsert({
        where: { courseId_order: { courseId: course.id, order: s } }, update: {},
        create: { courseId: course.id, title: "Sesion " + s, description: "Contenido sesion " + s, order: s }
      });
    }
  }

  // 80 Beneficiarios - 20 por curso
  const hashB = await bcrypt.hash("BuskandoParche2024!", 12);
  for (let i = 0; i < BENEFICIARIOS.length; i++) {
    const b = BENEFICIARIOS[i];
    const num = String(i + 1).padStart(3, "0");
    const email = "beneficiario" + num + "@buskandoparche.com";
    const u = await prisma.user.upsert({ where: { email }, update: {}, create: {
      email, passwordHash: hashB, role: "BENEFICIARIO",
      firstName: b.firstName, lastName: b.lastName, cedula: b.cedula,
      gender: b.gender, populationGroup: b.pop, locality: "Kennedy", upz: "Kennedy Central"
    }});
    const ci = Math.floor(i / 20);
    if (ci < cursos.length) {
      await prisma.enrollment.upsert({
        where: { userId_courseId: { userId: u.id, courseId: cursos[ci].id } }, update: {},
        create: { userId: u.id, courseId: cursos[ci].id, status: "ACTIVO" }
      });
    }
  }

  console.log("SEED OK - 4 cursos exactos + 85 usuarios");
  console.log("Cursos: Ingles | Gestion Empresarial | Gestion Turistica | Marketing Digital");
  console.log("admin@buskandoparche.com / Admin2024!");
  console.log("formador01-04@buskandoparche.com / Formador2024!");
  console.log("beneficiario001-080@buskandoparche.com / BuskandoParche2024!");
}
main().catch(e => { console.error(e); process.exit(1); }).finally(() => prisma.$disconnect());
'@
[System.IO.File]::WriteAllText("$PWD\backend\prisma\seed.js", $seed, [System.Text.Encoding]::UTF8)
Write-Host "seed.js corregido - 4 cursos exactos" -ForegroundColor Green

# ── RUTA DE EVALUACIONES ONLINE ──────────────────────────────
$evalRoute = @'
const router = require("express").Router();
const { authenticate, authorize } = require("../middleware/auth");
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

// GET /api/evaluations/course/:courseId - listar evaluaciones del curso
router.get("/course/:courseId", authenticate, async (req, res) => {
  try {
    const evals = await prisma.evaluation.findMany({
      where: { courseId: req.params.courseId },
      orderBy: { createdAt: "asc" }
    });
    return res.json(evals);
  } catch (err) { return res.status(500).json({ error: "Error al cargar evaluaciones" }); }
});

// POST /api/evaluations - crear examen (formador/admin)
router.post("/", authenticate, authorize("FORMADOR", "ADMIN"), async (req, res) => {
  try {
    const { courseId, sessionId, title, description, questions, passingScore, maxScore } = req.body;
    // questions: [{ text, options: ["a","b","c","d"], correct: 0, points: 10 }]
    const ev = await prisma.evaluation.create({
      data: { courseId, sessionId, title, description: description || "", questions, passingScore: passingScore || 60, maxScore: maxScore || 100 }
    });
    return res.status(201).json(ev);
  } catch (err) { console.error(err); return res.status(500).json({ error: "Error al crear evaluacion" }); }
});

// POST /api/evaluations/:id/submit - beneficiario responde y recibe resultado inmediato
router.post("/:id/submit", authenticate, async (req, res) => {
  try {
    const { answers } = req.body; // answers: [0, 2, 1, ...] (index de opcion elegida por pregunta)
    const ev = await prisma.evaluation.findUnique({ where: { id: req.params.id } });
    if (!ev) return res.status(404).json({ error: "Evaluacion no encontrada" });

    // Calcular puntaje automaticamente
    const questions = ev.questions;
    let correct = 0; let total = 0;
    const results = questions.map((q, i) => {
      const pts = q.points || (ev.maxScore / questions.length);
      total += pts;
      const isCorrect = answers[i] === q.correct;
      if (isCorrect) correct += pts;
      return { question: q.text, selected: q.options[answers[i]], correct: q.options[q.correct], isCorrect, points: isCorrect ? pts : 0 };
    });
    const score = Math.round((correct / total) * 100);
    const passed = score >= ev.passingScore;

    // Guardar submission
    const existing = await prisma.submission.findFirst({
      where: { evaluationId: ev.id, userId: req.user.id }
    });
    if (existing) {
      await prisma.submission.update({ where: { id: existing.id }, data: { answers: { responses: answers, results }, score, gradedAt: new Date() } });
    } else {
      await prisma.submission.create({ data: {
        evaluationId: ev.id, userId: req.user.id, sessionId: ev.sessionId,
        answers: { responses: answers, results }, score, gradedAt: new Date()
      }});
    }

    return res.json({ score, passed, passingScore: ev.passingScore, correct: Math.round(correct), total: Math.round(total), results });
  } catch (err) { console.error(err); return res.status(500).json({ error: "Error al procesar evaluacion" }); }
});

// GET /api/evaluations/:id/results/:userId - ver resultados de un usuario
router.get("/:id/results/:userId", authenticate, authorize("FORMADOR", "ADMIN"), async (req, res) => {
  try {
    const sub = await prisma.submission.findFirst({
      where: { evaluationId: req.params.id, userId: req.params.userId },
      include: { user: { select: { firstName: true, lastName: true, cedula: true } } }
    });
    return res.json(sub);
  } catch (err) { return res.status(500).json({ error: "Error" }); }
});

// GET /api/evaluations/:id - obtener una evaluacion (sin mostrar respuestas correctas al estudiante)
router.get("/:id", authenticate, async (req, res) => {
  try {
    const ev = await prisma.evaluation.findUnique({ where: { id: req.params.id } });
    if (!ev) return res.status(404).json({ error: "No encontrada" });
    // Ocultar respuestas correctas si es beneficiario
    if (req.user.role === "BENEFICIARIO") {
      const safeQ = ev.questions.map(q => ({ text: q.text, options: q.options, points: q.points }));
      return res.json({ ...ev, questions: safeQ });
    }
    return res.json(ev);
  } catch (err) { return res.status(500).json({ error: "Error" }); }
});

module.exports = router;
'@
[System.IO.File]::WriteAllText("$PWD\backend\src\routes\evaluations.js", $evalRoute, [System.Text.Encoding]::UTF8)
Write-Host "evaluations.js OK" -ForegroundColor Green

# ── RUTA AUTO-ASISTENCIA (estudiante marca su propia asistencia) ──
$attRoute = Get-Content "$PWD\backend\src\routes\attendance.js" -Raw
if ($attRoute -notmatch "self-checkin") {
  $selfCheckin = @'

// POST /api/attendance/self-checkin - estudiante marca su propia asistencia
router.post("/self-checkin", authenticate, async (req, res) => {
  try {
    const { sessionId } = req.body;
    const userId = req.user.id;
    const record = await prisma.attendance.upsert({
      where: { userId_sessionId: { userId, sessionId } },
      update: { status: "PRESENTE", markedAt: new Date() },
      create: { userId, sessionId, status: "PRESENTE" }
    });
    return res.json(record);
  } catch (err) {
    return res.status(500).json({ error: "Error al registrar asistencia" });
  }
});

'@
  $attRoute = $attRoute -replace "module\.exports = router;", ($selfCheckin + "module.exports = router;")
  [System.IO.File]::WriteAllText("$PWD\backend\src\routes\attendance.js", $attRoute, [System.Text.Encoding]::UTF8)
}
Write-Host "attendance.js actualizado con self-checkin" -ForegroundColor Green

# ── COURSE CONTROLLER: formador solo ve SU curso ─────────────
$courseCtrl = @'
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

// LOBBY: todos los cursos con flag isEnrolled
// Para FORMADOR: solo su curso asignado, el resto locked
const getLobby = async (req, res) => {
  try {
    const userId = req.user.id;
    const role = req.user.role;

    const courses = await prisma.course.findMany({
      where: { isPublished: true },
      include: {
        formador: { select: { id: true, firstName: true, lastName: true } },
        _count: { select: { enrollments: true } },
        enrollments: { where: { userId } },
      },
      orderBy: { title: "asc" }
    });

    const data = courses.map(c => ({
      id: c.id, title: c.title, description: c.description,
      modality: c.modality, coverImageUrl: c.coverImageUrl,
      totalSessions: c.totalSessions,
      formador: c.formador ? c.formador.firstName + " " + c.formador.lastName : "Sin asignar",
      formadorId: c.formador?.id || null,
      totalEnrolled: c._count.enrollments,
      isEnrolled: role === "BENEFICIARIO" ? c.enrollments.length > 0 : false,
      isMyCourseFomador: role === "FORMADOR" ? c.formador?.id === userId : false,
      enrollmentStatus: c.enrollments[0]?.status ?? null,
    }));

    return res.json(data);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Error al cargar el lobby" });
  }
};

const getCourseDetail = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;
    const role = req.user.role;

    // Verificar acceso
    if (role === "BENEFICIARIO") {
      const enrollment = await prisma.enrollment.findUnique({ where: { userId_courseId: { userId, courseId: id } } });
      if (!enrollment) return res.status(403).json({ error: "No tienes acceso a este curso" });
    }
    if (role === "FORMADOR") {
      const course = await prisma.course.findUnique({ where: { id }, select: { formadorId: true } });
      if (course?.formadorId !== userId) return res.status(403).json({ error: "Solo puedes ver tu curso asignado" });
    }

    const course = await prisma.course.findUnique({
      where: { id },
      include: {
        sessions: {
          orderBy: { order: "asc" },
          include: {
            resources: { orderBy: { order: "asc" } },
            attendances: { where: { userId } },
          }
        },
        formador: { select: { firstName: true, lastName: true, email: true } },
        enrollments: { where: { userId } }
      }
    });

    if (!course) return res.status(404).json({ error: "Curso no encontrado" });
    return res.json({ ...course, enrollment: course.enrollments[0] || null });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Error al cargar el curso" });
  }
};

const createCourse = async (req, res) => {
  try {
    const { title, description, modality, totalSessions, formadorId } = req.body;
    const course = await prisma.course.create({ data: { title, description, modality, totalSessions: totalSessions || 20, formadorId, isPublished: true } });
    for (let i = 1; i <= course.totalSessions; i++) {
      await prisma.session.create({ data: { courseId: course.id, title: "Sesion " + i, order: i } });
    }
    return res.status(201).json(course);
  } catch (err) { return res.status(500).json({ error: "Error al crear curso" }); }
};

const enrollUser = async (req, res) => {
  try {
    const { courseId, userId } = req.body;
    const enrollment = await prisma.enrollment.create({ data: { courseId, userId } });
    return res.status(201).json(enrollment);
  } catch (err) {
    if (err.code === "P2002") return res.status(409).json({ error: "Usuario ya inscrito" });
    return res.status(500).json({ error: "Error al inscribir" });
  }
};

module.exports = { getLobby, getCourseDetail, createCourse, enrollUser };
'@
[System.IO.File]::WriteAllText("$PWD\backend\src\controllers\courseController.js", $courseCtrl, [System.Text.Encoding]::UTF8)
Write-Host "courseController.js corregido" -ForegroundColor Green

# ── ACTUALIZAR INDEX.JS CON RUTA EVALUACIONES ────────────────
$idx = Get-Content "$PWD\backend\src\index.js" -Raw
if ($idx -notmatch "evaluations") {
  $idx = $idx -replace "const assignRoutes", "const evalRoutes = require('./routes/evaluations');`nconst assignRoutes"
  $idx = $idx -replace "app.use\('/api/assignments'", "app.use('/api/evaluations', evalRoutes);`napp.use('/api/assignments'"
  [System.IO.File]::WriteAllText("$PWD\backend\src\index.js", $idx, [System.Text.Encoding]::UTF8)
}
Write-Host "index.js con /api/evaluations OK" -ForegroundColor Green

# ── CERTIFICADO CORREGIDO (sin texto sobrepuesto, con firmas) ─
$certRoute = @'
const router = require("express").Router();
const { authenticate } = require("../middleware/auth");
const { PrismaClient } = require("@prisma/client");
const PDFDocument = require("pdfkit");
const path = require("path");
const fs = require("fs");
const prisma = new PrismaClient();

router.get("/:courseId", authenticate, async (req, res) => {
  try {
    const { courseId } = req.params;
    const userId = req.user.id;
    const enrollment = await prisma.enrollment.findUnique({
      where: { userId_courseId: { userId, courseId } },
      include: { user: true, course: { include: { formador: true } } }
    });
    if (!enrollment) return res.status(404).json({ error: "No inscrito en este curso" });
    if (enrollment.status !== "COMPLETADO") return res.status(403).json({ error: "Completa el curso para obtener el certificado" });

    const { user, course } = enrollment;
    const fullName = (user.firstName + " " + user.lastName).toUpperCase();
    const courseTitle = course.title.toUpperCase();
    const completedDate = enrollment.completedAt
      ? new Date(enrollment.completedAt).toLocaleDateString("es-CO", { year: "numeric", month: "long", day: "numeric" })
      : new Date().toLocaleDateString("es-CO", { year: "numeric", month: "long", day: "numeric" });

    const W = 841.89; const H = 595.28; // A4 landscape
    const doc = new PDFDocument({ size: "A4", layout: "landscape", margin: 0 });
    res.setHeader("Content-Type", "application/pdf");
    res.setHeader("Content-Disposition", "attachment; filename=certificado-" + user.cedula + ".pdf");
    doc.pipe(res);

    // Fondo blanco
    doc.rect(0, 0, W, H).fill("#FFFFFF");

    // Franja roja superior e inferior
    doc.rect(0, 0, W, 12).fill("#C0392B");
    doc.rect(0, H - 12, W, 12).fill("#C0392B");
    // Franjas amarillas
    doc.rect(0, 12, W, 6).fill("#F39C12");
    doc.rect(0, H - 18, W, 6).fill("#F39C12");

    // Esquinas rojas
    const sq = 70;
    doc.rect(0, 18, sq, sq).fill("#C0392B");         // sup izq
    doc.rect(W - sq, 18, sq, sq).fill("#C0392B");    // sup der
    doc.rect(0, H - 18 - sq, sq, sq).fill("#C0392B"); // inf izq
    doc.rect(W - sq, H - 18 - sq, sq, sq).fill("#C0392B"); // inf der

    // Borde interior
    doc.rect(55, 55, W - 110, H - 110).lineWidth(1.5).stroke("#C0392B");

    // === CONTENIDO - espaciado corregido ===
    let y = 75;

    // Logo (si existe)
    const logoPath = path.join(__dirname, "../../frontend/public/images/logo.png");
    if (fs.existsSync(logoPath)) {
      doc.image(logoPath, W / 2 - 35, y, { width: 70 });
      y += 80;
    } else {
      y += 10;
    }

    // Titulo
    doc.font("Helvetica-Bold").fontSize(38).fillColor("#1a1a1a")
      .text("CERTIFICADO", 0, y, { align: "center" });
    y += 46;

    doc.font("Helvetica").fontSize(13).fillColor("#555")
      .text("DE PARTICIPACION", 0, y, { align: "center", characterSpacing: 5 });
    y += 30;

    doc.font("Helvetica").fontSize(12).fillColor("#333")
      .text("Este certificado se entrega a:", 0, y, { align: "center" });
    y += 28;

    // Linea + nombre
    doc.moveTo(120, y + 24).lineTo(W - 120, y + 24).lineWidth(0.8).stroke("#aaa");
    doc.font("Helvetica-Bold").fontSize(26).fillColor("#C0392B")
      .text(fullName, 0, y, { align: "center" });
    y += 42;

    doc.font("Helvetica").fontSize(12).fillColor("#444")
      .text("Por haber asistido y aprobado satisfactoriamente el curso de capacitacion:", 0, y, { align: "center" });
    y += 26;

    doc.font("Helvetica-Bold").fontSize(15).fillColor("#1a1a1a")
      .text(courseTitle, 80, y, { align: "center", width: W - 160, characterSpacing: 2 });
    y += 36;

    // Fecha y duracion en la misma linea, separados
    doc.font("Helvetica-Bold").fontSize(11).fillColor("#333")
      .text("Realizado el:  " + completedDate + "          Duracion:  40 horas  |  Modalidad " + (course.modality === "VIRTUAL" ? "Virtual" : "Presencial"),
        0, y, { align: "center" });
    y += 50;

    // === FIRMAS ===
    const fW = 200; const gap = 80;
    const x1 = (W / 2) - fW - (gap / 2);
    const x2 = (W / 2) + (gap / 2);

    // Firma izquierda
    doc.moveTo(x1, y).lineTo(x1 + fW, y).lineWidth(0.8).stroke("#333");
    doc.font("Helvetica-Bold").fontSize(9.5).fillColor("#1a1a1a")
      .text("KARLA TATHYANNA MARIN OSPINA", x1, y + 6, { width: fW, align: "center" });
    doc.font("Helvetica").fontSize(8.5).fillColor("#555")
      .text("ALCALDESA LOCAL DE KENNEDY", x1, y + 18, { width: fW, align: "center" });

    // Firma derecha
    doc.moveTo(x2, y).lineTo(x2 + fW, y).lineWidth(0.8).stroke("#333");
    doc.font("Helvetica-Bold").fontSize(9.5).fillColor("#1a1a1a")
      .text("GERARDO SANTAMARIA BORDA", x2, y + 6, { width: fW, align: "center" });
    doc.font("Helvetica").fontSize(8.5).fillColor("#555")
      .text("CEO - BOOST BUSINESS CONSULTING", x2, y + 18, { width: fW, align: "center" });

    y += 50;

    // === LOGOS INFERIORES ===
    const logoH = 30; const logoY = H - 60;
    const logos = [
      path.join(__dirname, "../../frontend/public/images/logo.png"),
      path.join(__dirname, "../../frontend/public/images/logo-kennedy.png"),
      path.join(__dirname, "../../frontend/public/images/logo-bogota.png"),
    ];
    const logoCount = logos.filter(p => fs.existsSync(p)).length;
    let logoX = W / 2 - (logoCount * 80) / 2;
    logos.forEach(lp => {
      if (fs.existsSync(lp)) {
        doc.image(lp, logoX, logoY, { height: logoH });
        logoX += 90;
      }
    });

    doc.end();
  } catch (err) {
    console.error(err);
    if (!res.headersSent) res.status(500).json({ error: "Error generando certificado" });
  }
});

// Habilitar certificado
router.post("/:courseId/unlock", authenticate, async (req, res) => {
  try {
    const { userId } = req.body;
    const enrollment = await prisma.enrollment.update({
      where: { userId_courseId: { userId, courseId: req.params.courseId } },
      data: { status: "COMPLETADO", completedAt: new Date() }
    });
    return res.json(enrollment);
  } catch (err) { return res.status(500).json({ error: "Error" }); }
});

module.exports = router;
'@
[System.IO.File]::WriteAllText("$PWD\backend\src\routes\certificates.js", $certRoute, [System.Text.Encoding]::UTF8)
Write-Host "certificates.js corregido (sin texto sobrepuesto, con firmas)" -ForegroundColor Green

Write-Host "PARTE 1 OK" -ForegroundColor Green
