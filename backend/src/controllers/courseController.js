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