Write-Host "=== FIX SUBIDA DE ARCHIVOS COMPLETO ===" -ForegroundColor Yellow

# ── 1. BACKEND: sessions.js con upload de archivos ───────────
$sessionsJs = 'const router = require("express").Router();
const { authenticate, authorize } = require("../middleware/auth");
const { PrismaClient } = require("@prisma/client");
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const prisma = new PrismaClient();

const matStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = path.join(__dirname, "../../uploads/materials");
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    const unique = Date.now() + "-" + Math.round(Math.random()*1e9);
    cb(null, unique + path.extname(file.originalname));
  }
});
const uploadMat = multer({ storage: matStorage, limits: { fileSize: 50*1024*1024 } });

const subStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = path.join(__dirname, "../../uploads/submissions");
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    const unique = Date.now() + "-" + Math.round(Math.random()*1e9);
    cb(null, unique + path.extname(file.originalname));
  }
});
const uploadSub = multer({ storage: subStorage, limits: { fileSize: 50*1024*1024 } });

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

router.put("/:id", authenticate, authorize("FORMADOR","ADMIN"), async (req, res) => {
  try {
    const { title, description, liveUrl } = req.body;
    const s = await prisma.session.update({ where: { id: req.params.id }, data: { title, description, liveUrl } });
    return res.json(s);
  } catch { return res.status(500).json({ error: "Error" }); }
});

router.delete("/:id", authenticate, authorize("FORMADOR","ADMIN"), async (req, res) => {
  try {
    await prisma.resource.deleteMany({ where: { sessionId: req.params.id } });
    await prisma.submission.deleteMany({ where: { sessionId: req.params.id } });
    await prisma.attendance.deleteMany({ where: { sessionId: req.params.id } });
    await prisma.session.delete({ where: { id: req.params.id } });
    return res.json({ message: "Sesion eliminada" });
  } catch(e) { return res.status(500).json({ error: "Error: "+e.message }); }
});

router.delete("/resource/:id", authenticate, authorize("FORMADOR","ADMIN"), async (req, res) => {
  try {
    const resource = await prisma.resource.findUnique({ where: { id: req.params.id } });
    if (resource && resource.url && resource.url.startsWith("/uploads/")) {
      const filePath = path.join(__dirname, "../../", resource.url);
      if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
    }
    await prisma.resource.delete({ where: { id: req.params.id } });
    return res.json({ message: "Recurso eliminado" });
  } catch { return res.status(500).json({ error: "Error" }); }
});

router.put("/resource/:id", authenticate, authorize("FORMADOR","ADMIN"), async (req, res) => {
  try {
    const { title, description, url, type } = req.body;
    const r = await prisma.resource.update({ where: { id: req.params.id }, data: { title, description, url, type } });
    return res.json(r);
  } catch { return res.status(500).json({ error: "Error" }); }
});

// Subir archivo como material del curso
router.post("/:sessionId/resources/file", authenticate, authorize("FORMADOR","ADMIN"), uploadMat.single("file"), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error: "No se recibio archivo" });
    const { title } = req.body;
    const fileUrl = "/uploads/materials/" + req.file.filename;
    const originalName = req.file.originalname;
    const ext = path.extname(originalName).toLowerCase();
    let fileType = "file";
    if (ext === ".pdf") fileType = "pdf";
    else if ([".mp4",".avi",".mov"].includes(ext)) fileType = "video";
    else if ([".doc",".docx"].includes(ext)) fileType = "doc";
    else if ([".ppt",".pptx"].includes(ext)) fileType = "ppt";
    else if ([".xls",".xlsx"].includes(ext)) fileType = "excel";
    const r = await prisma.resource.create({
      data: { sessionId: req.params.sessionId, title: title || originalName, type: fileType, url: fileUrl, description: originalName }
    });
    return res.json(r);
  } catch(e) { return res.status(500).json({ error: "Error: "+e.message }); }
});

// Entregar trabajo (beneficiario sube archivo)
router.post("/:sessionId/submit", authenticate, uploadSub.single("file"), async (req, res) => {
  try {
    const { courseId, comment } = req.body;
    const userId = req.user.id;
    const fileUrl = req.file ? "/uploads/submissions/" + req.file.filename : null;
    const fileName = req.file ? req.file.originalname : null;
    const existing = await prisma.submission.findFirst({ where: { userId, sessionId: req.params.sessionId } });
    let sub;
    if (existing) {
      sub = await prisma.submission.update({
        where: { id: existing.id },
        data: { fileUrl, fileName, comment, submittedAt: new Date(), status: "ENTREGADO" }
      });
    } else {
      sub = await prisma.submission.create({
        data: { userId, sessionId: req.params.sessionId, courseId, fileUrl, fileName, comment, status: "ENTREGADO" }
      });
    }
    return res.json(sub);
  } catch(e) { return res.status(500).json({ error: "Error: "+e.message }); }
});

// Ver entregas de una sesion (formador)
router.get("/:sessionId/submissions", authenticate, authorize("FORMADOR","ADMIN"), async (req, res) => {
  try {
    const subs = await prisma.submission.findMany({
      where: { sessionId: req.params.sessionId },
      include: { user: { select: { firstName: true, lastName: true, email: true, cedula: true } } },
      orderBy: { submittedAt: "desc" }
    });
    return res.json(subs);
  } catch { return res.status(500).json({ error: "Error" }); }
});

module.exports = router;
'
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("$PWD\backend\src\routes\sessions.js", $sessionsJs, $utf8NoBom)
Write-Host "sessions.js OK" -ForegroundColor Green

# ── 2. SCHEMA: agregar fileName y comment a Submission ───────
$schemaPath = "$PWD\backend\prisma\schema.prisma"
$schema = [System.IO.File]::ReadAllText($schemaPath, [System.Text.Encoding]::UTF8)
if ($schema -notmatch "fileName") {
  $schema = $schema -replace "fileUrl\s+String\?", "fileUrl      String?`n  fileName     String?`n  comment      String?"
  [System.IO.File]::WriteAllText($schemaPath, $schema, $utf8NoBom)
  Write-Host "schema.prisma con fileName OK" -ForegroundColor Green
} else {
  Write-Host "schema.prisma ya tiene fileName" -ForegroundColor Gray
}

# ── 3. NGINX: servir archivos subidos ────────────────────────
$nginxPath = "$PWD\nginx\nginx.conf"
if (Test-Path $nginxPath) {
  $nginx = [System.IO.File]::ReadAllText($nginxPath, [System.Text.Encoding]::UTF8)
  if ($nginx -notmatch "materials") {
    $nginx = $nginx -replace "location /uploads/ \{[^}]+\}", "location /uploads/ {
      alias /app/uploads/;
      expires 7d;
      add_header Content-Disposition 'attachment';
    }"
    [System.IO.File]::WriteAllText($nginxPath, $nginx, $utf8NoBom)
    Write-Host "nginx.conf con downloads OK" -ForegroundColor Green
  }
}

# ── 4. FORMADOR COURSES: boton subir archivo ─────────────────
$coursesPath = "$PWD\frontend\src\app\(dashboard)\formador\courses\page.tsx"
$courses = [System.IO.File]::ReadAllText($coursesPath, [System.Text.Encoding]::UTF8)

# Agregar funcion uploadFile si no existe
if ($courses -notmatch "uploadFile") {
  $courses = $courses -replace "const addResource = async \(sessionId: string\)", @'
const uploadFile = async (sessionId: string) => {
    const input = document.createElement("input");
    input.type = "file";
    input.accept = ".pdf,.doc,.docx,.ppt,.pptx,.xls,.xlsx,.mp4,.jpg,.png,.zip";
    input.onchange = async (e: any) => {
      const file = e.target.files[0];
      if (!file) return;
      const title = prompt("Nombre del material (dejar vacio = nombre del archivo):", file.name);
      if (title === null) return;
      const fd = new FormData();
      fd.append("file", file);
      fd.append("title", title || file.name);
      try {
        await api.post("/sessions/" + sessionId + "/resources/file", fd, { headers: { "Content-Type": "multipart/form-data" } });
        const res = await api.get("/courses/lobby");
        const updated = res.data.find((c: any) => c.id === courseId);
        if (updated) setCourse(updated);
        alert("Archivo subido correctamente");
      } catch { alert("Error al subir el archivo"); }
    };
    input.click();
  };

  const addResource = async (sessionId: string)
'@
  [System.IO.File]::WriteAllText($coursesPath, $courses, $utf8NoBom)
  Write-Host "Formador courses con uploadFile OK" -ForegroundColor Green
}

# Agregar boton "Subir archivo" en la UI del formador
$courses = [System.IO.File]::ReadAllText($coursesPath, [System.Text.Encoding]::UTF8)
if ($courses -notmatch "Subir archivo") {
  $courses = $courses -replace '<button[^>]+Material / Enlace[^/]+/button>', @'
<button
                          onClick={() => { setActiveTab(s.id, "material"); setShowForm({...showForm, [s.id]: true}); }}
                          className={`flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium transition-all ${activeTab[s.id] === "material" ? "bg-primary text-white shadow-sm" : "bg-gray-100 text-text-secondary hover:bg-gray-200"}`}>
                          <Upload className="w-4 h-4" /> Material / Enlace
                        </button>
                        <button
                          onClick={() => uploadFile(s.id)}
                          className="flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium bg-blue-100 text-blue-700 hover:bg-blue-200 transition-all">
                          <Upload className="w-4 h-4" /> Subir archivo
                        </button>
'@
  [System.IO.File]::WriteAllText($coursesPath, $courses, $utf8NoBom)
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host "FIX UPLOAD COMPLETO" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. GitHub Desktop -> Commit 'Fix subida archivos' -> Push" -ForegroundColor Cyan
Write-Host "2. En VPS:" -ForegroundColor Cyan
Write-Host "   cd /home/proyectos/buskandoparche-LMS" -ForegroundColor White
Write-Host "   git pull" -ForegroundColor White
Write-Host "   docker compose -f docker-compose.prod.yml --env-file .env up -d --build" -ForegroundColor White
