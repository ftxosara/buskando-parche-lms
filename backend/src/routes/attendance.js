const router = require('express').Router();
const { authenticate, authorize } = require('../middleware/auth');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

router.use(authenticate);

// Registrar asistencia (formador / admin)
router.post('/', authorize('FORMADOR', 'ADMIN'), async (req, res) => {
  const { sessionId, attendances } = req.body;
  // attendances: [{ userId, status, notes }]
  const ops = attendances.map((a) =>
    prisma.attendance.upsert({
      where: { userId_sessionId: { userId: a.userId, sessionId } },
      update: { status: a.status, notes: a.notes },
      create: { userId: a.userId, sessionId, status: a.status, notes: a.notes },
    })
  );
  const result = await Promise.all(ops);
  return res.json(result);
});

// Ver asistencia de una sesiÃ³n
router.get('/session/:sessionId', authorize('FORMADOR', 'ADMIN'), async (req, res) => {
  const records = await prisma.attendance.findMany({
    where: { sessionId: req.params.sessionId },
    include: { user: { select: { firstName: true, lastName: true, cedula: true } } },
  });
  return res.json(records);
});


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
module.exports = router;
