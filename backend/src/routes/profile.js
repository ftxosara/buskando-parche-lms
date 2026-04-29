const router = require("express").Router();
const { authenticate } = require("../middleware/auth");
const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcryptjs");
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const prisma = new PrismaClient();

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = path.join(__dirname,"../../uploads/avatars");
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive:true });
    cb(null, dir);
  },
  filename: (req, file, cb) => cb(null, req.user.id + "-" + Date.now() + path.extname(file.originalname)),
});
const upload = multer({ storage, limits:{fileSize:5*1024*1024}, fileFilter:(req,file,cb)=>{
  if (file.mimetype.startsWith("image/")) cb(null,true);
  else cb(new Error("Solo imagenes"));
}});

// GET /api/profile - ver mi perfil
router.get("/", authenticate, async (req, res) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      select: { id:true, firstName:true, lastName:true, email:true, phone:true, role:true, gender:true, populationGroup:true, locality:true, upz:true, avatarUrl:true, createdAt:true,
        enrollments:{ select:{ status:true, course:{ select:{ title:true, modality:true } } } }
      }
    });
    return res.json(user);
  } catch { return res.status(500).json({ error:"Error" }); }
});

// PUT /api/profile/password - cambiar solo la contrasena
router.put("/password", authenticate, async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;
    if (!newPassword || newPassword.length < 6) return res.status(400).json({ error:"La nueva contrasena debe tener al menos 6 caracteres" });
    const user = await prisma.user.findUnique({ where:{ id:req.user.id } });
    const ok = await bcrypt.compare(currentPassword, user.passwordHash);
    if (!ok) return res.status(401).json({ error:"La contrasena actual es incorrecta" });
    await prisma.user.update({ where:{id:req.user.id}, data:{ passwordHash: await bcrypt.hash(newPassword,12) } });
    return res.json({ message:"Contrasena actualizada" });
  } catch { return res.status(500).json({ error:"Error" }); }
});

// POST /api/profile/avatar - subir foto de perfil
router.post("/avatar", authenticate, upload.single("avatar"), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error:"No se recibio imagen" });
    const avatarUrl = "/uploads/avatars/" + req.file.filename;
    await prisma.user.update({ where:{id:req.user.id}, data:{ avatarUrl } });
    return res.json({ avatarUrl });
  } catch { return res.status(500).json({ error:"Error al subir foto" }); }
});

module.exports = router;
