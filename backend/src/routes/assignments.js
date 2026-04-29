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