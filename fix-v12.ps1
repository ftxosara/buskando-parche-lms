Write-Host "=== FIX COMPLETO V12 ===" -ForegroundColor Yellow

# ── 0. Copiar certificado.jpeg al proyecto ─────────────────────
$certSrc = "C:\Users\USUARIO\Desktop\Buskando parche Kennedy\buskando-parche-lms\frontend\public\images\certificado.jpeg"
if (-not (Test-Path $certSrc)) {
  Write-Host "AVISO: Copia manualmente certificado.jpeg a frontend\public\images\" -ForegroundColor Yellow
}

# ── 1. CERTIFICADO: usa la plantilla, escribe solo el nombre ──
# La imagen es landscape 1600x1131 -> PDF A4 landscape 841.89x595.28
# Factor de escala: 841.89/1600 = 0.526
# El nombre "Tejidos Nelcy" esta en y~280px de la imagen -> 280*0.526 = 147 en PDF
# Ajustamos a 152 para centrar bien en la linea en blanco
$certRoute = 'const router = require("express").Router();
const { authenticate, authorize } = require("../middleware/auth");
const { PrismaClient } = require("@prisma/client");
const PDFDocument = require("pdfkit");
const path = require("path");
const fs = require("fs");
const prisma = new PrismaClient();

async function generateCertPDF(enrollment, res) {
  const { user, course } = enrollment;
  // Solo el nombre completo del beneficiario va sobre la plantilla
  const fullName = user.firstName + " " + user.lastName;
  const courseName = course.title;
  const dateStr = enrollment.completedAt
    ? new Date(enrollment.completedAt).toLocaleDateString("es-CO", { year:"numeric", month:"long", day:"numeric" })
    : new Date().toLocaleDateString("es-CO", { year:"numeric", month:"long", day:"numeric" });

  // La plantilla es landscape: 1600x1131 -> A4 landscape: 841.89x595.28
  const W = 841.89; const H = 595.28;
  const doc = new PDFDocument({ size:"A4", layout:"landscape", margin:0 });
  res.setHeader("Content-Type","application/pdf");
  res.setHeader("Content-Disposition","attachment; filename=certificado-" + user.cedula + ".pdf");
  doc.pipe(res);

  const PUB = path.join(__dirname, "../../frontend/public/images");

  // Buscar plantilla
  const tryPaths = [
    path.join(PUB, "certificado.jpeg"),
    path.join(PUB, "certificado.jpg"),
    path.join(PUB, "certificado.png"),
  ];

  let bgFound = false;
  for (const bp of tryPaths) {
    if (fs.existsSync(bp)) {
      doc.image(bp, 0, 0, { width: W, height: H });
      bgFound = true;
      break;
    }
  }

  if (bgFound) {
    // La plantilla ya tiene: logos, titulos, textos fijos, firma de Gerardo
    // Solo escribimos el nombre del beneficiario en el espacio en blanco
    // y opcionalmente el curso y la fecha

    // NOMBRE (donde dice "Tejidos Nelcy" en la plantilla)
    // y=152 es aproximadamente donde esta ese campo en el PDF
    doc.font("Helvetica-Bold").fontSize(22).fillColor("#000000")
      .text(fullName, 60, 152, { width: W - 120, align: "center" });

    // CURSO (debajo de la linea horizontal, si hay espacio)
    doc.font("Helvetica").fontSize(11).fillColor("#333333")
      .text(courseName, 60, 195, { width: W - 120, align: "center" });

    // FECHA (pequena, cerca de las firmas)
    doc.font("Helvetica").fontSize(9).fillColor("#555555")
      .text(dateStr, 60, 222, { width: W - 120, align: "center" });

  } else {
    // Sin plantilla: construir certificado manual
    doc.rect(0,0,W,H).fill("#FFFFFF");
    doc.rect(0,0,W,12).fill("#C0392B");
    doc.rect(0,H-12,W,12).fill("#C0392B");
    doc.rect(0,12,W,6).fill("#F39C12");
    doc.rect(0,H-18,W,6).fill("#F39C12");
    const sq=70;
    [0,W-sq].forEach(x=>{ [18,H-18-sq].forEach(y=>doc.rect(x,y,sq,sq).fill("#C0392B")); });
    doc.rect(55,55,W-110,H-110).lineWidth(1.5).stroke("#C0392B");
    let y=80;
    const lp=path.join(PUB,"logo.png");
    if(fs.existsSync(lp)){doc.image(lp,W/2-30,y,{width:60});y+=72;}
    doc.font("Helvetica-Bold").fontSize(36).fillColor("#1a1a1a").text("CERTIFICADO",0,y,{align:"center"});y+=44;
    doc.font("Helvetica").fontSize(13).fillColor("#777").text("DE PARTICIPACION",0,y,{align:"center",characterSpacing:4});y+=30;
    doc.font("Helvetica").fontSize(11).fillColor("#444").text("Este certificado se entrega a:",0,y,{align:"center"});y+=26;
    doc.moveTo(130,y+24).lineTo(W-130,y+24).lineWidth(0.8).stroke("#ccc");
    doc.font("Helvetica-Bold").fontSize(24).fillColor("#C0392B").text(fullName.toUpperCase(),0,y,{align:"center"});y+=42;
    doc.font("Helvetica").fontSize(11).fillColor("#444").text("Por haber asistido y aprobado el curso:",0,y,{align:"center"});y+=26;
    doc.font("Helvetica-Bold").fontSize(15).fillColor("#1a1a1a").text(courseName.toUpperCase(),80,y,{align:"center",width:W-160,characterSpacing:2});y+=36;
    doc.font("Helvetica-Bold").fontSize(10).fillColor("#555").text("Fecha: "+dateStr+"     Duracion: 40 horas  |  "+course.modality,0,y,{align:"center"});y+=52;
    const fW=200;const gap=90;const x1=W/2-fW-gap/2;const x2=W/2+gap/2;
    doc.moveTo(x1,y).lineTo(x1+fW,y).lineWidth(0.8).stroke("#333");
    doc.font("Helvetica-Bold").fontSize(9.5).fillColor("#111").text("JAVIER PRIETO TRISTANCHO",x1,y+6,{width:fW,align:"center"});
    doc.font("Helvetica").fontSize(8.5).fillColor("#666").text("ALCALDE (E) LOCAL DE KENNEDY",x1,y+18,{width:fW,align:"center"});
    doc.moveTo(x2,y).lineTo(x2+fW,y).lineWidth(0.8).stroke("#333");
    doc.font("Helvetica-Bold").fontSize(9.5).fillColor("#111").text("GERARDO SANTAMARIA BORDA",x2,y+6,{width:fW,align:"center"});
    doc.font("Helvetica").fontSize(8.5).fillColor("#666").text("CEO - BOOST BUSINESS CONSULTING",x2,y+18,{width:fW,align:"center"});
  }
  doc.end();
}

// Descargar certificado (solo ADMIN)
router.get("/:courseId/:userId", authenticate, authorize("ADMIN"), async (req, res) => {
  try {
    const enrollment = await prisma.enrollment.findUnique({
      where: { userId_courseId: { userId: req.params.userId, courseId: req.params.courseId } },
      include: { user: true, course: true }
    });
    if (!enrollment) return res.status(404).json({ error: "Inscripcion no encontrada" });
    if (enrollment.status !== "COMPLETADO") return res.status(403).json({ error: "El participante no ha completado el curso" });
    await generateCertPDF(enrollment, res);
  } catch (err) { console.error(err); if (!res.headersSent) res.status(500).json({ error: "Error generando certificado" }); }
});

// Habilitar certificado
router.post("/:courseId/unlock", authenticate, authorize("ADMIN"), async (req, res) => {
  try {
    const { userId } = req.body;
    const e = await prisma.enrollment.update({
      where: { userId_courseId: { userId, courseId: req.params.courseId } },
      data: { status: "COMPLETADO", completedAt: new Date() }
    });
    return res.json(e);
  } catch { return res.status(500).json({ error: "Error" }); }
});

// NUEVO: Revocar certificado (volver a ACTIVO)
router.post("/:courseId/revoke", authenticate, authorize("ADMIN"), async (req, res) => {
  try {
    const { userId } = req.body;
    const e = await prisma.enrollment.update({
      where: { userId_courseId: { userId, courseId: req.params.courseId } },
      data: { status: "ACTIVO", completedAt: null }
    });
    return res.json(e);
  } catch { return res.status(500).json({ error: "Error" }); }
});

module.exports = router;
'
[System.IO.File]::WriteAllText("$PWD\backend\src\routes\certificates.js", $certRoute, [System.Text.Encoding]::UTF8)
Write-Host "certificates.js con firma OK + ruta revoke" -ForegroundColor Green

# ── 2. BACKEND: userController con CRUD completo ──────────────
$userCtrl = 'const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcryptjs");
const prisma = new PrismaClient();

const listUsers = async (req, res) => {
  const { role, page = 1, limit = 20, search } = req.query;
  const where = {};
  if (role) where.role = role;
  if (search) {
    where.OR = [
      { firstName: { contains: search, mode: "insensitive" } },
      { lastName: { contains: search, mode: "insensitive" } },
      { cedula: { contains: search } },
      { email: { contains: search, mode: "insensitive" } },
    ];
  }
  const [users, total] = await Promise.all([
    prisma.user.findMany({
      where,
      skip: (page - 1) * Number(limit),
      take: Number(limit),
      select: {
        id: true, email: true, firstName: true, lastName: true,
        cedula: true, phone: true, role: true, gender: true,
        populationGroup: true, locality: true, isActive: true, createdAt: true,
        enrollments: { select: { courseId: true, status: true, course: { select: { id: true, title: true } } } },
      },
      orderBy: { firstName: "asc" },
    }),
    prisma.user.count({ where }),
  ]);
  return res.json({ data: users, total, page: Number(page), limit: Number(limit) });
};

const createUser = async (req, res) => {
  try {
    const { email, password, role, firstName, lastName, cedula, phone, gender, populationGroup, upz, locality, courseId } = req.body;
    const hash = await bcrypt.hash(password || "BuskandoParche2024!", 12);
    const user = await prisma.user.create({
      data: { email: email.toLowerCase(), passwordHash: hash, role: role || "BENEFICIARIO", firstName, lastName, cedula, phone, gender, populationGroup, upz, locality },
    });
    // Inscribir en curso si se especifica
    if (courseId && role === "BENEFICIARIO") {
      await prisma.enrollment.create({ data: { userId: user.id, courseId, status: "ACTIVO" } });
    }
    const { passwordHash, ...safe } = user;
    return res.status(201).json(safe);
  } catch (err) {
    if (err.code === "P2002") return res.status(409).json({ error: "Email o cedula ya registrado" });
    return res.status(500).json({ error: "Error al crear usuario: " + err.message });
  }
};

const updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const { password, courseId, currentCourseId, ...data } = req.body;
    delete data.passwordHash;
    if (password) data.passwordHash = await bcrypt.hash(password, 12);
    const user = await prisma.user.update({ where: { id }, data });
    // Cambiar curso si se especifica
    if (courseId && currentCourseId && courseId !== currentCourseId) {
      // Desactivar inscripcion anterior
      await prisma.enrollment.updateMany({ where: { userId: id, courseId: currentCourseId }, data: { status: "INACTIVO" } });
      // Crear nueva inscripcion
      await prisma.enrollment.upsert({
        where: { userId_courseId: { userId: id, courseId } },
        update: { status: "ACTIVO" },
        create: { userId: id, courseId, status: "ACTIVO" }
      });
    } else if (courseId && !currentCourseId) {
      await prisma.enrollment.upsert({
        where: { userId_courseId: { userId: id, courseId } },
        update: { status: "ACTIVO" },
        create: { userId: id, courseId, status: "ACTIVO" }
      });
    }
    const { passwordHash, ...safe } = user;
    return res.json(safe);
  } catch (err) { return res.status(500).json({ error: "Error al actualizar: " + err.message }); }
};

const deleteUser = async (req, res) => {
  try {
    const { id } = req.params;
    // Soft delete
    await prisma.user.update({ where: { id }, data: { isActive: false } });
    return res.json({ message: "Usuario desactivado" });
  } catch { return res.status(500).json({ error: "Error" }); }
};

const hardDeleteUser = async (req, res) => {
  try {
    const { id } = req.params;
    await prisma.enrollment.deleteMany({ where: { userId: id } });
    await prisma.attendance.deleteMany({ where: { userId: id } });
    await prisma.submission.deleteMany({ where: { userId: id } });
    await prisma.user.delete({ where: { id } });
    return res.json({ message: "Usuario eliminado permanentemente" });
  } catch { return res.status(500).json({ error: "Error al eliminar" }); }
};

module.exports = { listUsers, createUser, updateUser, deactivateUser: deleteUser, hardDeleteUser };
'
[System.IO.File]::WriteAllText("$PWD\backend\src\controllers\userController.js", $userCtrl, [System.Text.Encoding]::UTF8)
Write-Host "userController con CRUD OK" -ForegroundColor Green

# ── userRoute: agregar hard delete ────────────────────────────
$userRoute = 'const router = require("express").Router();
const { authenticate, authorize } = require("../middleware/auth");
const { listUsers, createUser, updateUser, deactivateUser, hardDeleteUser } = require("../controllers/userController");
router.use(authenticate);
router.get("/", authorize("ADMIN","FORMADOR"), listUsers);
router.post("/", authorize("ADMIN"), createUser);
router.put("/:id", authorize("ADMIN"), updateUser);
router.delete("/:id", authorize("ADMIN"), deactivateUser);
router.delete("/:id/hard", authorize("ADMIN"), hardDeleteUser);
module.exports = router;
'
[System.IO.File]::WriteAllText("$PWD\backend\src\routes\users.js", $userRoute, [System.Text.Encoding]::UTF8)
Write-Host "users.js con hard delete OK" -ForegroundColor Green

# ── 3. ADMIN USERS PAGE: CRUD completo ────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\admin\users" | Out-Null
$adminUsers = '"use client";
import { useEffect, useState } from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { Search, Download, Loader2, CheckCircle, XCircle, BookOpen, Award, Plus, Edit2, Trash2, Key, X, ChevronDown } from "lucide-react";
import clsx from "clsx";

const COLORS: Record<string,string> = {
  "Ingles":"bg-blue-100 text-blue-700",
  "Gestion Empresarial":"bg-green-100 text-green-700",
  "Gestion Turistica":"bg-teal-100 text-teal-700",
  "Marketing Digital":"bg-orange-100 text-orange-700",
};

const EMPTY_FORM = { firstName:"", lastName:"", cedula:"", email:"", phone:"", gender:"FEMENINO", populationGroup:"EMPRENDEDOR", locality:"Kennedy", role:"BENEFICIARIO", courseId:"", password:"" };

export default function AdminUsersPage() {
  const [users, setUsers] = useState<any[]>([]);
  const [courses, setCourses] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [roleFilter, setRoleFilter] = useState("BENEFICIARIO");
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [total, setTotal] = useState(0);
  const [msg, setMsg] = useState({ text:"", type:"" });
  // Modal state
  const [modal, setModal] = useState<"create"|"edit"|"delete"|"password"|"course"|null>(null);
  const [selUser, setSelUser] = useState<any>(null);
  const [form, setForm] = useState<any>(EMPTY_FORM);
  const [saving, setSaving] = useState(false);

  const fetch = () => {
    setLoading(true);
    api.get("/users", { params: { role: roleFilter, page, limit: 20, search } })
      .then(({ data }) => { setUsers(data.data); setTotal(data.total); })
      .finally(() => setLoading(false));
  };
  useEffect(() => { fetch(); }, [roleFilter, page, search]);
  useEffect(() => { api.get("/courses/lobby").then(({ data }) => setCourses(data)); }, []);

  const showMsg = (text: string, type = "success") => { setMsg({ text, type }); setTimeout(() => setMsg({ text:"", type:"" }), 4000); };

  const openCreate = () => { setForm({ ...EMPTY_FORM }); setModal("create"); };
  const openEdit = (u: any) => { setSelUser(u); setForm({ ...u, password:"", courseId: u.enrollments?.[0]?.courseId || "" }); setModal("edit"); };
  const openDelete = (u: any) => { setSelUser(u); setModal("delete"); };
  const openPassword = (u: any) => { setSelUser(u); setForm({ password:"", confirm:"" }); setModal("password"); };
  const openCourse = (u: any) => { setSelUser(u); setForm({ courseId: u.enrollments?.[0]?.courseId || "" }); setModal("course"); };

  const handleCreate = async () => {
    if (!form.firstName || !form.lastName || !form.cedula || !form.email) return showMsg("Completa los campos requeridos","error");
    setSaving(true);
    try {
      await api.post("/users", form);
      showMsg("Usuario creado correctamente"); setModal(null); fetch();
    } catch (e: any) { showMsg(e.response?.data?.error || "Error al crear", "error"); }
    finally { setSaving(false); }
  };

  const handleEdit = async () => {
    setSaving(true);
    try {
      const payload: any = { ...form };
      if (!payload.password) delete payload.password;
      payload.currentCourseId = selUser?.enrollments?.[0]?.courseId;
      await api.put("/users/" + selUser.id, payload);
      showMsg("Usuario actualizado"); setModal(null); fetch();
    } catch (e: any) { showMsg(e.response?.data?.error || "Error","error"); }
    finally { setSaving(false); }
  };

  const handleDelete = async (hard = false) => {
    setSaving(true);
    try {
      await api[hard ? "delete" : "delete"]("/users/" + selUser.id + (hard ? "/hard" : ""));
      showMsg(hard ? "Usuario eliminado permanentemente" : "Usuario desactivado"); setModal(null); fetch();
    } catch (e: any) { showMsg(e.response?.data?.error || "Error","error"); }
    finally { setSaving(false); }
  };

  const handlePassword = async () => {
    if (!form.password || form.password !== form.confirm) return showMsg("Las contrasenas no coinciden","error");
    setSaving(true);
    try {
      await api.put("/users/" + selUser.id, { password: form.password });
      showMsg("Contrasena actualizada"); setModal(null);
    } catch { showMsg("Error","error"); }
    finally { setSaving(false); }
  };

  const handleCourse = async () => {
    setSaving(true);
    try {
      await api.put("/users/" + selUser.id, { courseId: form.courseId, currentCourseId: selUser.enrollments?.[0]?.courseId });
      showMsg("Curso asignado correctamente"); setModal(null); fetch();
    } catch { showMsg("Error","error"); }
    finally { setSaving(false); }
  };

  const enableCert = async (userId: string, courseId: string) => {
    await api.post("/certificates/" + courseId + "/unlock", { userId });
    showMsg("Certificado habilitado"); fetch();
  };
  const revokeCert = async (userId: string, courseId: string) => {
    await api.post("/certificates/" + courseId + "/revoke", { userId });
    showMsg("Certificado revocado"); fetch();
  };
  const downloadCert = async (userId: string, courseId: string, cedula: string) => {
    try {
      const res = await api.get("/certificates/" + courseId + "/" + userId, { responseType: "blob" });
      const url = window.URL.createObjectURL(new Blob([res.data]));
      const a = document.createElement("a"); a.href = url; a.download = "certificado-" + cedula + ".pdf"; a.click();
    } catch (e: any) { showMsg(e.response?.data?.error || "Error al descargar","error"); }
  };

  const exportCSV = () => {
    const h = "Nombre,Cedula,Email,Contrasena,Genero,Curso,Estado\n";
    const rows = users.map((u: any) => [
      u.firstName+" "+u.lastName, u.cedula, u.email,
      roleFilter==="BENEFICIARIO"?"BuskandoParche2024!":roleFilter==="FORMADOR"?"Formador2024!":"Admin2024!",
      u.gender||"", u.enrollments?.[0]?.course?.title||"Sin curso", u.isActive?"Activo":"Inactivo"
    ].join(",")).join("\n");
    const blob = new Blob(["\uFEFF"+h+rows], { type:"text/csv;charset=utf-8" });
    const a = document.createElement("a"); a.href = URL.createObjectURL(blob); a.download="usuarios.csv"; a.click();
  };

  const F = (k: string, v: any) => setForm((p: any) => ({ ...p, [k]: v }));

  return (
    <AppShell allowedRoles={["ADMIN"]}>
      <div className="max-w-7xl mx-auto space-y-5">
        <div className="flex items-center justify-between">
          <div><h1 className="font-display text-3xl font-bold text-text-primary">Gestion de Usuarios</h1><p className="text-text-secondary mt-1">Total: <strong>{total}</strong></p></div>
          <div className="flex gap-2">
            <button onClick={openCreate} className="btn-primary flex items-center gap-2 text-sm"><Plus className="w-4 h-4" /> Nuevo usuario</button>
            <button onClick={exportCSV} className="btn-outline flex items-center gap-2 text-sm"><Download className="w-4 h-4" /> CSV</button>
          </div>
        </div>

        {msg.text && (
          <div className={clsx("px-4 py-3 rounded-xl text-sm flex items-center gap-2", msg.type==="error"?"bg-red-50 border border-red-200 text-red-700":"bg-green-50 border border-green-200 text-green-700")}>
            {msg.type==="error"?<XCircle className="w-4 h-4"/>:<CheckCircle className="w-4 h-4"/>}{msg.text}
            <button onClick={()=>setMsg({text:"",type:""})} className="ml-auto"><X className="w-4 h-4"/></button>
          </div>
        )}

        <div className="card">
          <div className="flex flex-col md:flex-row gap-4 mb-5">
            <div className="relative flex-1"><Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400"/><input className="input pl-10" placeholder="Buscar..." value={search} onChange={e=>{setSearch(e.target.value);setPage(1);}}/></div>
            <select className="input w-auto" value={roleFilter} onChange={e=>{setRoleFilter(e.target.value);setPage(1);}}>
              <option value="BENEFICIARIO">Beneficiarios</option>
              <option value="FORMADOR">Formadores</option>
              <option value="ADMIN">Admins</option>
            </select>
          </div>
          {loading?<div className="flex justify-center py-12"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div>:(
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead><tr className="bg-gray-50">
                  <th className="text-left py-3 px-4 font-semibold text-text-secondary rounded-l-xl">Nombre</th>
                  <th className="text-left py-3 px-4 font-semibold text-text-secondary">Cedula</th>
                  <th className="text-left py-3 px-4 font-semibold text-text-secondary">Email</th>
                  <th className="text-left py-3 px-4 font-semibold text-text-secondary">Genero</th>
                  <th className="text-left py-3 px-4 font-semibold text-text-secondary">Curso</th>
                  <th className="text-left py-3 px-4 font-semibold text-text-secondary">Estado</th>
                  <th className="text-center py-3 px-4 font-semibold text-text-secondary rounded-r-xl">Acciones</th>
                </tr></thead>
                <tbody className="divide-y divide-gray-50">
                  {users.map((u: any) => {
                    const ct = u.enrollments?.[0]?.course?.title || "";
                    const cid = u.enrollments?.[0]?.courseId || u.enrollments?.[0]?.course?.id || "";
                    const completed = u.enrollments?.[0]?.status === "COMPLETADO";
                    return (
                      <tr key={u.id} className="hover:bg-gray-50 transition-colors">
                        <td className="py-3 px-4 font-medium">{u.firstName} {u.lastName}</td>
                        <td className="py-3 px-4 font-mono text-xs text-text-secondary">{u.cedula}</td>
                        <td className="py-3 px-4 text-xs text-text-secondary">{u.email}</td>
                        <td className="py-3 px-4"><span className={clsx("badge",u.gender==="FEMENINO"?"bg-pink-100 text-pink-700":"badge-info")}>{u.gender||"N/A"}</span></td>
                        <td className="py-3 px-4">
                          {ct?<span className={"badge text-xs "+(COLORS[ct]||"badge-muted")}>{ct}</span>:<span className="text-text-muted text-xs">Sin curso</span>}
                        </td>
                        <td className="py-3 px-4">
                          {u.isActive?<span className="badge-success flex items-center gap-1"><CheckCircle className="w-3 h-3"/>Activo</span>:<span className="badge-muted flex items-center gap-1"><XCircle className="w-3 h-3"/>Inactivo</span>}
                        </td>
                        <td className="py-3 px-4">
                          <div className="flex items-center gap-1 justify-center flex-wrap">
                            <button onClick={()=>openEdit(u)} title="Editar" className="p-1.5 rounded-lg hover:bg-blue-50 text-blue-600 transition-colors"><Edit2 className="w-3.5 h-3.5"/></button>
                            <button onClick={()=>openPassword(u)} title="Cambiar clave" className="p-1.5 rounded-lg hover:bg-yellow-50 text-yellow-600 transition-colors"><Key className="w-3.5 h-3.5"/></button>
                            <button onClick={()=>openCourse(u)} title="Asignar curso" className="p-1.5 rounded-lg hover:bg-green-50 text-green-600 transition-colors"><BookOpen className="w-3.5 h-3.5"/></button>
                            <button onClick={()=>openDelete(u)} title="Eliminar" className="p-1.5 rounded-lg hover:bg-red-50 text-red-600 transition-colors"><Trash2 className="w-3.5 h-3.5"/></button>
                            {roleFilter==="BENEFICIARIO" && cid && (
                              completed?(
                                <div className="flex gap-1">
                                  <button onClick={()=>downloadCert(u.id,cid,u.cedula)} title="Descargar PDF" className="p-1.5 rounded-lg hover:bg-primary/10 text-primary transition-colors"><Award className="w-3.5 h-3.5"/></button>
                                  <button onClick={()=>revokeCert(u.id,cid)} title="Revocar certificado" className="text-xs bg-orange-100 text-orange-700 px-2 py-1 rounded-lg hover:bg-orange-200 transition-colors">Revocar</button>
                                </div>
                              ):(
                                <button onClick={()=>enableCert(u.id,cid)} className="text-xs bg-green-100 text-green-700 px-2 py-1 rounded-lg hover:bg-green-200 transition-colors">Habilitar</button>
                              )
                            )}
                          </div>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
              {users.length===0&&<p className="text-center text-text-muted py-8">Sin resultados</p>}
            </div>
          )}
          <div className="flex items-center justify-between mt-4 pt-4 border-t border-gray-100">
            <p className="text-sm text-text-muted">{users.length} de {total}</p>
            <div className="flex gap-2">
              <button onClick={()=>setPage(p=>Math.max(1,p-1))} disabled={page===1} className="btn-ghost text-sm disabled:opacity-40">Anterior</button>
              <span className="px-3 py-1 text-sm bg-gray-100 rounded-lg">Pag. {page}</span>
              <button onClick={()=>setPage(p=>p+1)} disabled={users.length<20} className="btn-ghost text-sm disabled:opacity-40">Siguiente</button>
            </div>
          </div>
        </div>
      </div>

      {/* MODAL */}
      {modal && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4" onClick={e=>{if(e.target===e.currentTarget)setModal(null);}}>
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between p-5 border-b border-gray-100">
              <h2 className="font-bold text-text-primary text-lg">
                {modal==="create"?"Crear usuario":modal==="edit"?"Editar usuario":modal==="delete"?"Eliminar usuario":modal==="password"?"Cambiar contrasena":"Asignar curso"}
              </h2>
              <button onClick={()=>setModal(null)} className="p-2 hover:bg-gray-100 rounded-xl"><X className="w-5 h-5"/></button>
            </div>
            <div className="p-5 space-y-3">
              {(modal==="create"||modal==="edit")&&(
                <>
                  <div className="grid grid-cols-2 gap-3">
                    <div><label className="label">Nombre *</label><input className="input text-sm" value={form.firstName||""} onChange={e=>F("firstName",e.target.value)} placeholder="Nombre"/></div>
                    <div><label className="label">Apellido *</label><input className="input text-sm" value={form.lastName||""} onChange={e=>F("lastName",e.target.value)} placeholder="Apellido"/></div>
                  </div>
                  <div className="grid grid-cols-2 gap-3">
                    <div><label className="label">Cedula *</label><input className="input text-sm" value={form.cedula||""} onChange={e=>F("cedula",e.target.value)} placeholder="1020301001"/></div>
                    <div><label className="label">Telefono</label><input className="input text-sm" value={form.phone||""} onChange={e=>F("phone",e.target.value)} placeholder="3001234567"/></div>
                  </div>
                  <div><label className="label">Email *</label><input className="input text-sm" type="email" value={form.email||""} onChange={e=>F("email",e.target.value)} placeholder="correo@ejemplo.com"/></div>
                  {modal==="create"&&<div><label className="label">Contrasena (dejar vacio = BuskandoParche2024!)</label><input className="input text-sm" type="password" value={form.password||""} onChange={e=>F("password",e.target.value)} placeholder="Opcional"/></div>}
                  <div className="grid grid-cols-2 gap-3">
                    <div><label className="label">Genero</label>
                      <select className="input text-sm" value={form.gender||"FEMENINO"} onChange={e=>F("gender",e.target.value)}>
                        <option value="FEMENINO">Femenino</option><option value="MASCULINO">Masculino</option><option value="NO_BINARIO">No binario</option>
                      </select>
                    </div>
                    <div><label className="label">Rol</label>
                      <select className="input text-sm" value={form.role||"BENEFICIARIO"} onChange={e=>F("role",e.target.value)}>
                        <option value="BENEFICIARIO">Beneficiario</option><option value="FORMADOR">Formador</option><option value="ADMIN">Admin</option>
                      </select>
                    </div>
                  </div>
                  <div><label className="label">Grupo poblacional</label>
                    <select className="input text-sm" value={form.populationGroup||"EMPRENDEDOR"} onChange={e=>F("populationGroup",e.target.value)}>
                      {["EMPRENDEDOR","MIPYME","PRESTADOR_TURISTICO","VICTIMA_CONFLICTO","AFRODESCENDIENTE","INDIGENA","DISCAPACIDAD","ADULTO_MAYOR"].map(g=>(
                        <option key={g} value={g}>{g.replace(/_/g," ")}</option>
                      ))}
                    </select>
                  </div>
                  {(form.role==="BENEFICIARIO")&&(
                    <div><label className="label">Asignar a curso</label>
                      <select className="input text-sm" value={form.courseId||""} onChange={e=>F("courseId",e.target.value)}>
                        <option value="">Sin curso</option>
                        {courses.map((c:any)=><option key={c.id} value={c.id}>{c.title}</option>)}
                      </select>
                    </div>
                  )}
                  <button onClick={modal==="create"?handleCreate:handleEdit} disabled={saving} className="btn-primary w-full flex items-center justify-center gap-2">
                    {saving?<Loader2 className="w-4 h-4 animate-spin"/>:<CheckCircle className="w-4 h-4"/>}
                    {saving?"Guardando...":modal==="create"?"Crear usuario":"Guardar cambios"}
                  </button>
                </>
              )}
              {modal==="password"&&(
                <>
                  <p className="text-text-muted text-sm">Cambiar contrasena de <strong>{selUser?.firstName} {selUser?.lastName}</strong></p>
                  <div><label className="label">Nueva contrasena</label><input className="input" type="password" value={form.password||""} onChange={e=>F("password",e.target.value)} placeholder="Min. 8 caracteres"/></div>
                  <div><label className="label">Confirmar contrasena</label><input className="input" type="password" value={form.confirm||""} onChange={e=>F("confirm",e.target.value)} placeholder="Repite la contrasena"/></div>
                  {form.password&&form.confirm&&form.password!==form.confirm&&<p className="text-red-500 text-xs">Las contrasenas no coinciden</p>}
                  <button onClick={handlePassword} disabled={saving||!form.password||form.password!==form.confirm} className="btn-primary w-full flex items-center justify-center gap-2 disabled:opacity-40">
                    {saving?<Loader2 className="w-4 h-4 animate-spin"/>:<Key className="w-4 h-4"/>} Cambiar contrasena
                  </button>
                </>
              )}
              {modal==="course"&&(
                <>
                  <p className="text-text-muted text-sm">Asignar o cambiar el curso de <strong>{selUser?.firstName} {selUser?.lastName}</strong></p>
                  {selUser?.enrollments?.[0]?.course?.title&&(
                    <div className="bg-yellow-50 border border-yellow-200 rounded-xl p-3 text-sm text-yellow-700">
                      Curso actual: <strong>{selUser.enrollments[0].course.title}</strong>. Cambiar moverá al estudiante al nuevo curso.
                    </div>
                  )}
                  <div><label className="label">Nuevo curso</label>
                    <select className="input" value={form.courseId||""} onChange={e=>F("courseId",e.target.value)}>
                      <option value="">Sin curso</option>
                      {courses.map((c:any)=><option key={c.id} value={c.id}>{c.title}</option>)}
                    </select>
                  </div>
                  <button onClick={handleCourse} disabled={saving||!form.courseId} className="btn-primary w-full flex items-center justify-center gap-2 disabled:opacity-40">
                    {saving?<Loader2 className="w-4 h-4 animate-spin"/>:<BookOpen className="w-4 h-4"/>} Asignar curso
                  </button>
                </>
              )}
              {modal==="delete"&&(
                <>
                  <p className="text-text-muted text-sm">Que accion quieres realizar con <strong>{selUser?.firstName} {selUser?.lastName}</strong>?</p>
                  <div className="space-y-2">
                    <button onClick={()=>handleDelete(false)} disabled={saving} className="w-full bg-yellow-100 text-yellow-700 hover:bg-yellow-200 rounded-xl py-3 text-sm font-semibold transition-colors flex items-center justify-center gap-2">
                      <XCircle className="w-4 h-4"/> Desactivar (puede reactivarse)
                    </button>
                    <button onClick={()=>handleDelete(true)} disabled={saving} className="w-full bg-red-100 text-red-700 hover:bg-red-200 rounded-xl py-3 text-sm font-semibold transition-colors flex items-center justify-center gap-2">
                      <Trash2 className="w-4 h-4"/> Eliminar permanentemente
                    </button>
                  </div>
                  <p className="text-xs text-text-muted text-center">La eliminacion permanente borra todos los datos del usuario.</p>
                </>
              )}
            </div>
          </div>
        </div>
      )}

      <style>{`.label { display:block; font-size:0.75rem; font-weight:600; color:#6B7280; margin-bottom:0.375rem; }`}</style>
    </AppShell>
  );
}'
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\admin\users\page.tsx", $adminUsers, [System.Text.Encoding]::UTF8)
Write-Host "Admin users CRUD completo OK" -ForegroundColor Green

Write-Host ""
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host "FIX V12 COMPLETO" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "IMPORTANTE: Copia el certificado.jpeg a:" -ForegroundColor Cyan
Write-Host "  frontend\public\images\certificado.jpeg" -ForegroundColor White
Write-Host ""
Write-Host "Si el nombre no cae en el espacio correcto" -ForegroundColor Cyan
Write-Host "ajusta los valores y= en certificates.js:" -ForegroundColor White
Write-Host "  y=152 -> nombre, y=195 -> curso, y=222 -> fecha" -ForegroundColor Gray
Write-Host ""
Write-Host "Ejecuta:" -ForegroundColor Cyan
Write-Host "  docker-compose down" -ForegroundColor White
Write-Host "  docker-compose up --build" -ForegroundColor White
