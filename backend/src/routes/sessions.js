const router = require("express").Router();
const { authenticate, authorize } = require("../middleware/auth");
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

// GET sesiones de un curso
router.get("/course/:courseId", authenticate, async (req, res) => {
  try {
    const sessions = await prisma.session.findMany({
      where: { courseId: req.params.courseId },
      include: { resources: true },
      orderBy: { order: "asc" },
    });
    return res.json(sessions);
  } catch { return res.status(500).json({ error: "Error" }); }
});

// PUT editar sesion
router.put("/:id", authenticate, authorize("FORMADOR","ADMIN"), async (req, res) => {
  try {
    const { title, description, liveUrl } = req.body;
    const s = await prisma.session.update({ where: { id: req.params.id }, data: { title, description, liveUrl } });
    return res.json(s);
  } catch { return res.status(500).json({ error: "Error" }); }
});

// DELETE eliminar sesion
router.delete("/:id", authenticate, authorize("FORMADOR","ADMIN"), async (req, res) => {
  try {
    await prisma.resource.deleteMany({ where: { sessionId: req.params.id } });
    await prisma.submission.deleteMany({ where: { sessionId: req.params.id } });
    await prisma.attendance.deleteMany({ where: { sessionId: req.params.id } });
    await prisma.session.delete({ where: { id: req.params.id } });
    return res.json({ message: "Sesion eliminada" });
  } catch(e) { return res.status(500).json({ error: "Error: "+e.message }); }
});

// DELETE eliminar recurso/material
router.delete("/resource/:id", authenticate, authorize("FORMADOR","ADMIN"), async (req, res) => {
  try {
    await prisma.resource.delete({ where: { id: req.params.id } });
    return res.json({ message: "Recurso eliminado" });
  } catch { return res.status(500).json({ error: "Error" }); }
});

// PUT editar recurso
router.put("/resource/:id", authenticate, authorize("FORMADOR","ADMIN"), async (req, res) => {
  try {
    const { title, description, url, type } = req.body;
    const r = await prisma.resource.update({ where: { id: req.params.id }, data: { title, description, url, type } });
    return res.json(r);
  } catch { return res.status(500).json({ error: "Error" }); }
});

module.exports = router;
