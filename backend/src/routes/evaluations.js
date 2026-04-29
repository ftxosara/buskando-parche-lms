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