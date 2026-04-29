const router = require("express").Router();
const { authenticate, authorize } = require("../middleware/auth");
const { getLobby, getCourseDetail, createCourse, enrollUser } = require("../controllers/courseController");
const { PrismaClient } = require("@prisma/client");
const multer = require("multer");
const path = require("path");
const prisma = new PrismaClient();
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, path.join(__dirname, "../../uploads")),
  filename: (req, file, cb) => cb(null, Date.now() + "-" + file.originalname),
});
const upload = multer({ storage, limits: { fileSize: 50 * 1024 * 1024 } });

router.use(authenticate);
router.get("/lobby", getLobby);

// NUEVO: obtener estudiantes inscritos en un curso (para formador/admin)
router.get("/:id/students", authorize("FORMADOR", "ADMIN"), async (req, res) => {
  try {
    const enrollments = await prisma.enrollment.findMany({
      where: { courseId: req.params.id, status: { not: "INACTIVO" } },
      include: {
        user: {
          select: {
            id: true, firstName: true, lastName: true,
            cedula: true, email: true, gender: true, phone: true
          }
        }
      },
      orderBy: { user: { firstName: "asc" } }
    });
    const students = enrollments.map(e => ({ ...e.user, enrollmentStatus: e.status }));
    return res.json(students);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Error al cargar estudiantes" });
  }
});

router.get("/:id", getCourseDetail);
router.post("/", authorize("ADMIN"), createCourse);
router.post("/enroll", authorize("ADMIN"), enrollUser);

// Recursos de sesion
router.post("/sessions/:sessionId/resources", authorize("FORMADOR", "ADMIN"), upload.single("file"), async (req, res) => {
  try {
    const { title, type, url } = req.body;
    const resourceUrl = req.file ? "/uploads/" + req.file.filename : url;
    const resource = await prisma.resource.create({
      data: { sessionId: req.params.sessionId, title, type: type || "link", url: resourceUrl }
    });
    return res.status(201).json(resource);
  } catch (err) { return res.status(500).json({ error: "Error al agregar recurso" }); }
});

module.exports = router;
