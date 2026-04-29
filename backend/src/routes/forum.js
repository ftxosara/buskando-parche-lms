const router = require('express').Router();
const { authenticate } = require('../middleware/auth');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

router.use(authenticate);

router.get('/course/:courseId', async (req, res) => {
  const posts = await prisma.forumPost.findMany({
    where: { courseId: req.params.courseId },
    include: {
      author: { select: { firstName: true, lastName: true, role: true } },
      replies: {
        include: { author: { select: { firstName: true, lastName: true, role: true } } },
        orderBy: { createdAt: 'asc' },
      },
    },
    orderBy: [{ isPinned: 'desc' }, { createdAt: 'desc' }],
  });
  return res.json(posts);
});

router.post('/', async (req, res) => {
  const { courseId, title, body } = req.body;
  const post = await prisma.forumPost.create({
    data: { courseId, title, body, authorId: req.user.id },
  });
  return res.status(201).json(post);
});

router.post('/:postId/replies', async (req, res) => {
  const reply = await prisma.forumReply.create({
    data: { postId: req.params.postId, body: req.body.body, authorId: req.user.id },
  });
  return res.status(201).json(reply);
});

module.exports = router;
