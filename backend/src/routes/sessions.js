const router = require('express').Router();
const { authenticate, authorize } = require('../middleware/auth');
const { PrismaClient } = require('@prisma/client');
const multer = require('multer');
const path = require('path');

const prisma = new PrismaClient();

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, path.join(__dirname, '../../uploads')),
  filename: (req, file, cb) => cb(null, `${Date.now()}-${file.originalname}`),
});
const upload = multer({ storage, limits: { fileSize: 50 * 1024 * 1024 } });

router.use(authenticate);

router.get('/:id', async (req, res) => {
  const session = await prisma.session.findUnique({
    where: { id: req.params.id },
    include: { resources: { orderBy: { order: 'asc' } } },
  });
  if (!session) return res.status(404).json({ error: 'Sesión no encontrada' });
  return res.json(session);
});

router.post('/:id/resources', authorize('FORMADOR', 'ADMIN'), upload.single('file'), async (req, res) => {
  const { title, type, url } = req.body;
  const resourceUrl = req.file ? `/uploads/${req.file.filename}` : url;
  const resource = await prisma.resource.create({
    data: { sessionId: req.params.id, title, type, url: resourceUrl },
  });
  return res.status(201).json(resource);
});

module.exports = router;
