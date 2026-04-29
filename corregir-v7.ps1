Write-Host "=== CORRECCION V7 FINAL ===" -ForegroundColor Yellow

# ── 1. LOBBY con imagen ingles.jpg corregida ─────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(student)\lobby" | Out-Null
$lobbyContent = '"use client";
import { useEffect, useState } from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { useAuth } from "@/contexts/AuthContext";
import { BookOpen, Lock, Users, PlayCircle, Search, CheckCircle, Loader2 } from "lucide-react";
import Link from "next/link";
import clsx from "clsx";
const IMGS: Record<string,string> = {
  "Ingles": "/images/ingles.jpg",
  "Gestion Empresarial": "/images/gestion.jpg",
  "Gestion Turistica": "/images/turismo.jpg",
  "Marketing Digital": "/images/marketing.jpg",
};
const COLORS = ["#C0392B","#2563EB","#16A34A","#D97706"];
export default function LobbyPage() {
  const { user } = useAuth();
  const [courses, setCourses] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  useEffect(() => { api.get("/courses/lobby").then(({ data }) => setCourses(data)).finally(() => setLoading(false)); }, []);
  const filtered = courses.filter((c: any) => c.title.toLowerCase().includes(search.toLowerCase()));
  const enrolled = filtered.filter((c: any) => c.isEnrolled);
  const locked = filtered.filter((c: any) => !c.isEnrolled);
  return (
    <AppShell allowedRoles={["BENEFICIARIO"]}>
      <div className="max-w-5xl mx-auto space-y-8">
        <div>
          <h1 className="font-display text-3xl font-bold text-text-primary">Hola, <span className="text-primary">{user?.firstName}</span></h1>
          <p className="text-text-secondary mt-1">Bienvenido a tu espacio de aprendizaje en Buskando Parche.</p>
        </div>
        <div className="relative max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
          <input className="input pl-10" placeholder="Buscar cursos..." value={search} onChange={(e) => setSearch(e.target.value)} />
        </div>
        {loading ? (
          <div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div>
        ) : (
          <>
            {enrolled.length > 0 && (
              <section>
                <div className="flex items-center gap-2 mb-5">
                  <div className="w-1 h-6 bg-primary rounded-full" />
                  <h2 className="text-xl font-bold text-text-primary">Mis Cursos</h2>
                  <span className="badge-primary ml-1">{enrolled.length}</span>
                </div>
                <div className="grid md:grid-cols-2 gap-5">
                  {enrolled.map((c: any, i: number) => (
                    <div key={c.id} className="card overflow-hidden p-0 hover:shadow-lg transition-shadow group">
                      <div className="relative h-44 overflow-hidden" style={{ background: COLORS[i % 4] }}>
                        <img
                          src={IMGS[c.title] || "/images/marketing.jpg"}
                          alt={c.title}
                          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                          onError={(e) => { (e.target as HTMLImageElement).style.display = "none"; }}
                        />
                        <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
                        <div className="absolute top-3 left-3">
                          <span className="badge-success"><CheckCircle className="w-3 h-3" /> Inscrito</span>
                        </div>
                        <div className="absolute top-3 right-3">
                          <span className={clsx("badge", c.modality === "VIRTUAL" ? "bg-blue-100 text-blue-700" : "bg-green-100 text-green-700")}>
                            {c.modality === "VIRTUAL" ? "Virtual" : "Presencial"}
                          </span>
                        </div>
                      </div>
                      <div className="p-5">
                        <h3 className="font-bold text-lg text-text-primary mb-1">{c.title}</h3>
                        <p className="text-text-muted text-sm line-clamp-2 mb-4">{c.description}</p>
                        <div className="flex items-center gap-4 text-xs text-text-muted mb-4">
                          <span className="flex items-center gap-1"><PlayCircle className="w-4 h-4" /> {c.totalSessions} sesiones</span>
                          <span className="flex items-center gap-1"><Users className="w-4 h-4" /> {c.totalEnrolled} inscritos</span>
                        </div>
                        <Link href={"/courses/" + c.id} className="btn-primary w-full text-center block py-2.5 text-sm">
                          Acceder al curso
                        </Link>
                      </div>
                    </div>
                  ))}
                </div>
              </section>
            )}
            {locked.length > 0 && (
              <section>
                <div className="flex items-center gap-2 mb-4">
                  <div className="w-1 h-6 bg-gray-300 rounded-full" />
                  <h2 className="text-xl font-bold text-text-primary">Otros programas</h2>
                  <span className="badge-muted">{locked.length}</span>
                </div>
                <div className="grid md:grid-cols-2 gap-5">
                  {locked.map((c: any, i: number) => (
                    <div key={c.id} className="card overflow-hidden p-0 opacity-60 cursor-not-allowed">
                      <div className="relative h-44 bg-gray-200">
                        <img src={IMGS[c.title] || "/images/marketing.jpg"} alt={c.title} className="w-full h-full object-cover grayscale"
                          onError={(e) => { (e.target as HTMLImageElement).style.display = "none"; }} />
                        <div className="absolute inset-0 bg-gray-900/50 flex items-center justify-center">
                          <div className="bg-white/90 rounded-full p-3"><Lock className="w-6 h-6 text-gray-500" /></div>
                        </div>
                      </div>
                      <div className="p-5">
                        <h3 className="font-bold text-lg text-gray-500 mb-1">{c.title}</h3>
                        <div className="bg-gray-100 rounded-lg px-4 py-2.5 text-center text-sm text-gray-500 flex items-center justify-center gap-2">
                          <Lock className="w-4 h-4" /> Solo para participantes asignados
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </section>
            )}
          </>
        )}
      </div>
    </AppShell>
  );
}'
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(student)\lobby\page.tsx", $lobbyContent, [System.Text.Encoding]::UTF8)
Write-Host "Lobby OK" -ForegroundColor Green

# ── 2. CERTIFICADO: solo admin, sin firmas (se entrega fisico) ─
$certRoute = 'const router = require("express").Router();
const { authenticate, authorize } = require("../middleware/auth");
const { PrismaClient } = require("@prisma/client");
const PDFDocument = require("pdfkit");
const path = require("path");
const fs = require("fs");
const prisma = new PrismaClient();

async function generateCertPDF(enrollment, res) {
  const { user, course } = enrollment;
  const fullName = (user.firstName + " " + user.lastName).toUpperCase();
  const courseTitle = course.title.toUpperCase();
  const dateStr = enrollment.completedAt
    ? new Date(enrollment.completedAt).toLocaleDateString("es-CO", { year:"numeric", month:"long", day:"numeric" })
    : new Date().toLocaleDateString("es-CO", { year:"numeric", month:"long", day:"numeric" });

  const W = 841.89; const H = 595.28;
  const doc = new PDFDocument({ size: "A4", layout: "landscape", margin: 0 });
  res.setHeader("Content-Type", "application/pdf");
  res.setHeader("Content-Disposition", "attachment; filename=certificado-" + user.cedula + ".pdf");
  doc.pipe(res);

  const PUB = path.join(__dirname, "../../frontend/public/images");

  // Fondo
  doc.rect(0, 0, W, H).fill("#FFFFFF");
  // Franjas
  doc.rect(0, 0, W, 12).fill("#C0392B");
  doc.rect(0, H - 12, W, 12).fill("#C0392B");
  doc.rect(0, 12, W, 6).fill("#F39C12");
  doc.rect(0, H - 18, W, 6).fill("#F39C12");
  // Esquinas
  const sq = 70;
  doc.rect(0, 18, sq, sq).fill("#C0392B");
  doc.rect(W - sq, 18, sq, sq).fill("#C0392B");
  doc.rect(0, H - 18 - sq, sq, sq).fill("#C0392B");
  doc.rect(W - sq, H - 18 - sq, sq, sq).fill("#C0392B");
  // Borde interior
  doc.rect(55, 55, W - 110, H - 110).lineWidth(1.5).stroke("#C0392B");

  let y = 72;

  // Logo
  const logoPath = path.join(PUB, "logo.png");
  if (fs.existsSync(logoPath)) { doc.image(logoPath, W / 2 - 30, y, { width: 60 }); y += 74; }
  else { y += 12; }

  doc.font("Helvetica-Bold").fontSize(36).fillColor("#1a1a1a").text("CERTIFICADO", 0, y, { align: "center" }); y += 44;
  doc.font("Helvetica").fontSize(13).fillColor("#777").text("DE PARTICIPACION", 0, y, { align: "center", characterSpacing: 4 }); y += 30;
  doc.font("Helvetica").fontSize(11).fillColor("#444").text("Este certificado se entrega a:", 0, y, { align: "center" }); y += 26;

  // Nombre
  doc.moveTo(130, y + 24).lineTo(W - 130, y + 24).lineWidth(0.8).stroke("#ccc");
  doc.font("Helvetica-Bold").fontSize(26).fillColor("#C0392B").text(fullName, 0, y, { align: "center" }); y += 42;

  doc.font("Helvetica").fontSize(11).fillColor("#444").text("Por haber asistido y aprobado satisfactoriamente el curso de capacitacion:", 0, y, { align: "center" }); y += 26;
  doc.font("Helvetica-Bold").fontSize(15).fillColor("#1a1a1a").text(courseTitle, 80, y, { align: "center", width: W - 160, characterSpacing: 2 }); y += 36;

  doc.font("Helvetica-Bold").fontSize(10).fillColor("#555")
    .text("Realizado el:  " + dateStr + "          Duracion:  40 horas  |  Modalidad " + (course.modality === "VIRTUAL" ? "Virtual" : "Presencial"), 0, y, { align: "center" });
  y += 50;

  // Lineas de firma (sin texto - se firma en la ceremonia)
  const fW = 200; const gap = 90;
  const x1 = W / 2 - fW - gap / 2;
  const x2 = W / 2 + gap / 2;

  doc.moveTo(x1, y).lineTo(x1 + fW, y).lineWidth(0.8).stroke("#333");
  doc.font("Helvetica-Bold").fontSize(9.5).fillColor("#1a1a1a").text("KARLA TATHYANNA MARIN OSPINA", x1, y + 6, { width: fW, align: "center" });
  doc.font("Helvetica").fontSize(8.5).fillColor("#666").text("ALCALDESA LOCAL DE KENNEDY", x1, y + 18, { width: fW, align: "center" });

  doc.moveTo(x2, y).lineTo(x2 + fW, y).lineWidth(0.8).stroke("#333");
  doc.font("Helvetica-Bold").fontSize(9.5).fillColor("#1a1a1a").text("GERARDO SANTAMARIA BORDA", x2, y + 6, { width: fW, align: "center" });
  doc.font("Helvetica").fontSize(8.5).fillColor("#666").text("CEO - BOOST BUSINESS CONSULTING", x2, y + 18, { width: fW, align: "center" });

  // Logos
  const logoY = H - 60;
  let logoX = W / 2 - 135;
  ["logo.png", "logo-kennedy.png", "logo-bogota.png"].forEach((lf) => {
    const lp = path.join(PUB, lf);
    if (fs.existsSync(lp)) { doc.image(lp, logoX, logoY, { height: 28 }); logoX += 95; }
  });

  doc.end();
}

// Solo ADMIN puede descargar certificados
router.get("/:courseId/:userId", authenticate, authorize("ADMIN"), async (req, res) => {
  try {
    const enrollment = await prisma.enrollment.findUnique({
      where: { userId_courseId: { userId: req.params.userId, courseId: req.params.courseId } },
      include: { user: true, course: true }
    });
    if (!enrollment) return res.status(404).json({ error: "Inscripcion no encontrada" });
    if (enrollment.status !== "COMPLETADO") return res.status(403).json({ error: "El participante no ha completado el curso" });
    await generateCertPDF(enrollment, res);
  } catch (err) {
    console.error(err);
    if (!res.headersSent) res.status(500).json({ error: "Error generando certificado" });
  }
});

// Habilitar certificado
router.post("/:courseId/unlock", authenticate, authorize("ADMIN"), async (req, res) => {
  try {
    const { userId } = req.body;
    const enrollment = await prisma.enrollment.update({
      where: { userId_courseId: { userId, courseId: req.params.courseId } },
      data: { status: "COMPLETADO", completedAt: new Date() }
    });
    return res.json(enrollment);
  } catch (err) { return res.status(500).json({ error: "Error" }); }
});

module.exports = router;
'
[System.IO.File]::WriteAllText("$PWD\backend\src\routes\certificates.js", $certRoute, [System.Text.Encoding]::UTF8)
Write-Host "certificates.js - solo admin, sin firmas OK" -ForegroundColor Green

# ── 3. ADMIN USERS: boton descargar certificado ───────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\admin\users" | Out-Null
$adminUsers = '"use client";
import { useEffect, useState } from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { Search, Download, Loader2, CheckCircle, XCircle, BookOpen, Award } from "lucide-react";
import clsx from "clsx";
const SHORT: Record<string,string> = {
  "Ingles":"Ingles","Gestion Empresarial":"Gestion Emp.","Gestion Turistica":"Gestion Tur.","Marketing Digital":"Marketing"
};
const CCOLORS: Record<string,string> = {
  "Ingles":"bg-blue-100 text-blue-700","Gestion Empresarial":"bg-green-100 text-green-700",
  "Gestion Turistica":"bg-teal-100 text-teal-700","Marketing Digital":"bg-orange-100 text-orange-700",
};
export default function AdminUsersPage() {
  const [users, setUsers] = useState<any[]>([]); const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState(""); const [roleFilter, setRoleFilter] = useState("BENEFICIARIO");
  const [page, setPage] = useState(1); const [total, setTotal] = useState(0); const [msg, setMsg] = useState("");
  const fetch = () => {
    setLoading(true);
    api.get("/users", { params: { role: roleFilter, page, limit: 20 } })
      .then(({ data }) => { setUsers(data.data); setTotal(data.total); }).finally(() => setLoading(false));
  };
  useEffect(() => { fetch(); }, [roleFilter, page]);
  const filtered = users.filter((u: any) =>
    (u.firstName + " " + u.lastName + " " + u.cedula + " " + u.email).toLowerCase().includes(search.toLowerCase())
  );
  const exportCSV = () => {
    const hdr = "Nombre,Cedula,Email,Contrasena,Genero,Curso,Estado\n";
    const rows = users.map((u: any) => [
      u.firstName + " " + u.lastName, u.cedula, u.email,
      roleFilter === "BENEFICIARIO" ? "BuskandoParche2024!" : roleFilter === "FORMADOR" ? "Formador2024!" : "Admin2024!",
      u.gender || "", u.enrollments?.[0]?.course?.title || "Sin curso", u.isActive ? "Activo" : "Inactivo"
    ].join(",")).join("\n");
    const blob = new Blob(["\uFEFF" + hdr + rows], { type: "text/csv;charset=utf-8" });
    const a = document.createElement("a"); a.href = URL.createObjectURL(blob); a.download = "usuarios.csv"; a.click();
  };
  const enableCert = async (userId: string, courseId: string) => {
    await api.post("/certificates/" + courseId + "/unlock", { userId });
    setMsg("Certificado habilitado"); fetch();
  };
  const downloadCert = async (userId: string, courseId: string, cedula: string) => {
    try {
      const res = await api.get("/certificates/" + courseId + "/" + userId, { responseType: "blob" });
      const url = window.URL.createObjectURL(new Blob([res.data]));
      const a = document.createElement("a"); a.href = url; a.download = "certificado-" + cedula + ".pdf"; a.click();
    } catch (e: any) { alert(e.response?.data?.error || "Error al descargar certificado"); }
  };
  return (
    <AppShell allowedRoles={["ADMIN"]}>
      <div className="max-w-7xl mx-auto space-y-6">
        <div className="flex items-center justify-between">
          <div><h1 className="font-display text-3xl font-bold text-text-primary">Gestion de Usuarios</h1>
            <p className="text-text-secondary mt-1">Total: <strong>{total}</strong></p>
          </div>
          <button onClick={exportCSV} className="btn-outline flex items-center gap-2 text-sm"><Download className="w-4 h-4" /> Exportar CSV</button>
        </div>
        {msg && <div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-xl text-sm flex items-center gap-2"><CheckCircle className="w-4 h-4" />{msg}<button onClick={() => setMsg("")} className="ml-auto text-green-500">x</button></div>}
        <div className="card">
          <div className="flex flex-col md:flex-row gap-4 mb-6">
            <div className="relative flex-1"><Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
              <input className="input pl-10" placeholder="Buscar nombre, cedula, email..." value={search} onChange={(e) => setSearch(e.target.value)} />
            </div>
            <select className="input w-auto" value={roleFilter} onChange={(e) => { setRoleFilter(e.target.value); setPage(1); }}>
              <option value="BENEFICIARIO">Beneficiarios</option>
              <option value="FORMADOR">Formadores</option>
              <option value="ADMIN">Admins</option>
            </select>
          </div>
          {loading ? <div className="flex justify-center py-12"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div> : (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="bg-gray-50">
                    <th className="text-left py-3 px-4 font-semibold text-text-secondary rounded-l-xl">Nombre</th>
                    <th className="text-left py-3 px-4 font-semibold text-text-secondary">Cedula</th>
                    <th className="text-left py-3 px-4 font-semibold text-text-secondary">Email / Clave</th>
                    <th className="text-left py-3 px-4 font-semibold text-text-secondary">Genero</th>
                    <th className="text-left py-3 px-4 font-semibold text-text-secondary">Curso</th>
                    <th className="text-left py-3 px-4 font-semibold text-text-secondary">Estado</th>
                    {roleFilter === "BENEFICIARIO" && <th className="text-left py-3 px-4 font-semibold text-text-secondary rounded-r-xl">Certificado</th>}
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-50">
                  {filtered.map((u: any) => {
                    const ct = u.enrollments?.[0]?.course?.title || "";
                    const cid = u.enrollments?.[0]?.courseId || u.enrollments?.[0]?.course?.id || "";
                    const completed = u.enrollments?.[0]?.status === "COMPLETADO";
                    return (
                      <tr key={u.id} className="hover:bg-gray-50 transition-colors">
                        <td className="py-3 px-4 font-medium text-text-primary">{u.firstName} {u.lastName}</td>
                        <td className="py-3 px-4 font-mono text-xs text-text-secondary">{u.cedula}</td>
                        <td className="py-3 px-4">
                          <p className="text-xs text-text-secondary">{u.email}</p>
                          <p className="text-xs font-mono text-text-muted">{roleFilter === "BENEFICIARIO" ? "BuskandoParche2024!" : roleFilter === "FORMADOR" ? "Formador2024!" : "Admin2024!"}</p>
                        </td>
                        <td className="py-3 px-4">
                          <span className={clsx("badge", u.gender === "FEMENINO" ? "bg-pink-100 text-pink-700" : u.gender === "MASCULINO" ? "badge-info" : "badge-muted")}>{u.gender || "N/A"}</span>
                        </td>
                        <td className="py-3 px-4">
                          {ct ? <span className={"badge " + (CCOLORS[ct] || "badge-muted")}><BookOpen className="w-3 h-3" /> {SHORT[ct] || ct}</span> : <span className="text-text-muted text-xs">Sin inscripcion</span>}
                        </td>
                        <td className="py-3 px-4">
                          {u.isActive ? <span className="badge-success flex items-center gap-1"><CheckCircle className="w-3 h-3" /> Activo</span> : <span className="badge-muted flex items-center gap-1"><XCircle className="w-3 h-3" /> Inactivo</span>}
                        </td>
                        {roleFilter === "BENEFICIARIO" && (
                          <td className="py-3 px-4">
                            {completed ? (
                              <button onClick={() => downloadCert(u.id, cid, u.cedula)} className="btn-primary flex items-center gap-1.5 text-xs py-1.5 px-3">
                                <Download className="w-3.5 h-3.5" /> PDF
                              </button>
                            ) : cid ? (
                              <button onClick={() => enableCert(u.id, cid)} className="text-xs bg-orange-100 text-orange-700 px-3 py-1.5 rounded-lg hover:bg-orange-200 transition-colors">
                                Habilitar cert.
                              </button>
                            ) : <span className="text-text-muted text-xs">-</span>}
                          </td>
                        )}
                      </tr>
                    );
                  })}
                </tbody>
              </table>
              {filtered.length === 0 && <p className="text-center text-text-muted py-8">Sin resultados</p>}
            </div>
          )}
          <div className="flex items-center justify-between mt-4 pt-4 border-t border-gray-100">
            <p className="text-sm text-text-muted">{filtered.length} de {total}</p>
            <div className="flex gap-2">
              <button onClick={() => setPage((p) => Math.max(1, p - 1))} disabled={page === 1} className="btn-ghost text-sm disabled:opacity-40">Anterior</button>
              <span className="px-3 py-1 text-sm bg-gray-100 rounded-lg text-text-secondary">Pag. {page}</span>
              <button onClick={() => setPage((p) => p + 1)} disabled={users.length < 20} className="btn-ghost text-sm disabled:opacity-40">Siguiente</button>
            </div>
          </div>
        </div>
      </div>
    </AppShell>
  );
}'
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\admin\users\page.tsx", $adminUsers, [System.Text.Encoding]::UTF8)
Write-Host "Admin users con descarga de certificado OK" -ForegroundColor Green

# ── 4. FORMADOR GRADES: calificar por sesion con promedio ─────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\formador\grades" | Out-Null
$grades = '"use client";
import { useEffect, useState, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { Loader2, CheckCircle, Star, Download, Plus, Trash2, TrendingUp } from "lucide-react";
import clsx from "clsx";

function GradesContent() {
  const params = useSearchParams();
  const courseId = params.get("courseId");
  const [course, setCourse] = useState<any>(null);
  const [students, setStudents] = useState<any[]>([]);
  const [selStudent, setSelStudent] = useState<any>(null);
  const [selSession, setSelSession] = useState<any>(null);
  const [grades, setGrades] = useState<any[]>([]);
  const [grading, setGrading] = useState({ score: "", feedback: "" });
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [msg, setMsg] = useState("");
  const [tab, setTab] = useState<"calificar"|"examen">("calificar");
  const [examTitle, setExamTitle] = useState(""); const [examPass, setExamPass] = useState("60");
  const [questions, setQuestions] = useState([{text:"",options:["","","",""],correct:0,points:25}]);

  useEffect(() => {
    if (!courseId) { setLoading(false); return; }
    Promise.all([
      api.get("/courses/" + courseId),
      api.get("/users", { params: { role: "BENEFICIARIO", limit: 100 } }),
    ]).then(([cRes, uRes]) => {
      setCourse(cRes.data);
      const enrolled = uRes.data.data.filter((u: any) => u.enrollments?.some((e: any) => e.courseId === courseId));
      setStudents(enrolled);
    }).finally(() => setLoading(false));
  }, [courseId]);

  const loadStudentGrades = async (student: any) => {
    setSelStudent(student); setSelSession(null); setGrading({ score: "", feedback: "" }); setMsg("");
    try {
      const { data } = await api.get("/assignments/grades/" + courseId + "?userId=" + student.id);
      setGrades(data);
    } catch { setGrades([]); }
  };

  const selectSession = (s: any) => {
    setSelSession(s);
    const g = grades.find((gr: any) => gr.id === s.id);
    setGrading({ score: g?.score?.toString() || "", feedback: g?.feedback || "" });
  };

  const saveGrade = async () => {
    if (!selSession || !selStudent || !grading.score) return;
    setSaving(true);
    try {
      const { data: subs } = await api.get("/assignments/session/" + selSession.id);
      const mySubmission = subs.find((s: any) => s.userId === selStudent.id);
      if (mySubmission) {
        await api.put("/assignments/" + mySubmission.id + "/grade", { score: grading.score, feedback: grading.feedback });
      } else {
        const evRes = await api.post("/evaluations", { courseId, sessionId: selSession.id, title: "Nota - " + selSession.title, questions: [], passingScore: 60, maxScore: 100 });
        const fd = new FormData();
        fd.append("sessionId", selSession.id); fd.append("courseId", courseId!);
        fd.append("textContent", "Nota manual"); fd.append("evaluationId", evRes.data.id);
        const subRes = await api.post("/assignments", fd);
        if (subRes.data?.id) await api.put("/assignments/" + subRes.data.id + "/grade", { score: grading.score, feedback: grading.feedback });
      }
      setMsg("Nota guardada - " + selStudent.firstName + " / " + selSession.title);
      const { data } = await api.get("/assignments/grades/" + courseId + "?userId=" + selStudent.id);
      setGrades(data);
    } catch (e: any) { setMsg("Error: " + (e?.response?.data?.error || "intenta de nuevo")); }
    finally { setSaving(false); }
  };

  const saveExam = async () => {
    if (!examTitle.trim() || !selSession) return;
    try {
      await api.post("/evaluations", { courseId, sessionId: selSession.id, title: examTitle, questions, passingScore: parseInt(examPass), maxScore: 100 });
      setMsg("Examen publicado para " + selSession.title);
      setExamTitle(""); setExamPass("60"); setQuestions([{text:"",options:["","","",""],correct:0,points:25}]);
    } catch { setMsg("Error al crear examen"); }
  };

  const calcPromedio = () => {
    const graded = grades.filter((g: any) => g.score !== null);
    if (!graded.length) return null;
    return (graded.reduce((s: number, g: any) => s + g.score, 0) / graded.length).toFixed(1);
  };

  if (loading) return <div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div>;
  if (!courseId || !course) return <div className="card text-center py-12"><p className="text-text-muted">Accede desde el panel del formador.</p></div>;

  const prom = calcPromedio();

  return (
    <div className="max-w-6xl mx-auto space-y-6">
      <div>
        <h1 className="font-display text-2xl font-bold text-text-primary">Calificaciones y Examenes</h1>
        <p className="text-text-secondary mt-1">{course?.title} - {students.length} estudiantes</p>
      </div>
      {msg && (
        <div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-xl text-sm flex items-center gap-2">
          <CheckCircle className="w-4 h-4" />{msg}
          <button onClick={() => setMsg("")} className="ml-auto text-green-500 font-bold">x</button>
        </div>
      )}
      <div className="flex gap-2 border-b border-gray-200">
        {(["calificar","examen"] as const).map(t => (
          <button key={t} onClick={() => setTab(t)} className={clsx("px-5 py-2.5 text-sm font-semibold border-b-2 transition-colors -mb-px",
            tab === t ? "border-primary text-primary" : "border-transparent text-text-muted hover:text-text-primary")}>
            {t === "calificar" ? "Calificar estudiantes" : "Crear examen online"}
          </button>
        ))}
      </div>

      {tab === "calificar" && (
        <div className="grid md:grid-cols-4 gap-5">
          {/* Col 1: Lista de estudiantes */}
          <div className="card p-0 overflow-hidden">
            <div className="p-3 bg-gray-50 border-b">
              <p className="font-semibold text-xs text-text-muted uppercase tracking-wide">Estudiantes ({students.length})</p>
            </div>
            <div className="divide-y divide-gray-50 max-h-[540px] overflow-y-auto">
              {students.map((s: any) => (
                <button key={s.id} onClick={() => loadStudentGrades(s)}
                  className={clsx("w-full text-left px-3 py-3 transition-colors flex items-center gap-2",
                    selStudent?.id === s.id ? "bg-red-50 border-r-2 border-primary" : "hover:bg-gray-50")}>
                  <div className="w-8 h-8 bg-gradient-brand rounded-full flex items-center justify-center text-white text-xs font-bold flex-shrink-0">{s.firstName[0]}</div>
                  <div className="flex-1 min-w-0">
                    <p className={clsx("text-xs font-semibold truncate", selStudent?.id === s.id ? "text-primary" : "text-text-primary")}>{s.firstName} {s.lastName}</p>
                    <p className="text-xs text-text-muted">{s.cedula}</p>
                  </div>
                </button>
              ))}
            </div>
          </div>

          {/* Col 2: Sesiones */}
          <div className="card p-0 overflow-hidden">
            <div className="p-3 bg-gray-50 border-b">
              <p className="font-semibold text-xs text-text-muted uppercase tracking-wide">{selStudent ? "Sesiones" : "Selecciona estudiante"}</p>
            </div>
            {!selStudent ? (
              <div className="flex flex-col items-center justify-center py-12 px-4">
                <Star className="w-8 h-8 text-gray-200 mb-2" />
                <p className="text-text-muted text-xs text-center">Selecciona un estudiante</p>
              </div>
            ) : (
              <div className="divide-y divide-gray-50 max-h-[540px] overflow-y-auto">
                {course?.sessions?.map((s: any) => {
                  const g = grades.find((gr: any) => gr.id === s.id);
                  const hasScore = g?.score !== null && g?.score !== undefined;
                  return (
                    <button key={s.id} onClick={() => selectSession(s)}
                      className={clsx("w-full text-left px-3 py-2.5 text-xs transition-colors flex items-center gap-2",
                        selSession?.id === s.id ? "bg-red-50 border-r-2 border-primary text-primary font-semibold" : "hover:bg-gray-50 text-text-secondary")}>
                      <span className={clsx("w-6 h-6 rounded-full flex items-center justify-center font-bold flex-shrink-0 text-xs",
                        selSession?.id === s.id ? "bg-primary text-white" : hasScore ? "bg-green-100 text-green-700" : "bg-gray-100 text-gray-500")}>
                        {hasScore ? <CheckCircle className="w-3 h-3" /> : s.order}
                      </span>
                      <span className="flex-1 truncate">{s.title}</span>
                      {hasScore && (
                        <span className={clsx("text-xs font-bold flex-shrink-0", g.score >= 60 ? "text-green-600" : "text-red-600")}>{g.score}</span>
                      )}
                    </button>
                  );
                })}
              </div>
            )}
          </div>

          {/* Col 3-4: Panel de calificacion */}
          <div className="md:col-span-2 space-y-4">
            {!selStudent ? (
              <div className="card text-center py-16">
                <Star className="w-12 h-12 text-gray-200 mx-auto mb-3" />
                <p className="text-text-muted">Selecciona un estudiante para calificar</p>
              </div>
            ) : !selSession ? (
              <div className="card space-y-4">
                {/* Resumen del estudiante */}
                <div className="flex items-start gap-4">
                  <div className="w-12 h-12 bg-gradient-brand rounded-full flex items-center justify-center text-white font-bold text-lg flex-shrink-0">{selStudent.firstName[0]}</div>
                  <div className="flex-1">
                    <h3 className="font-bold text-text-primary text-lg">{selStudent.firstName} {selStudent.lastName}</h3>
                    <p className="text-text-muted text-sm">{selStudent.cedula}</p>
                  </div>
                  {prom !== null && (
                    <div className={clsx("text-center px-4 py-2 rounded-xl flex-shrink-0", parseFloat(prom) >= 60 ? "bg-green-50" : "bg-red-50")}>
                      <p className={clsx("text-2xl font-bold", parseFloat(prom) >= 60 ? "text-green-600" : "text-red-600")}>{prom}</p>
                      <p className="text-xs text-text-muted">Promedio</p>
                    </div>
                  )}
                </div>
                <p className="text-text-muted text-sm">Selecciona una sesion para ingresar o editar la nota.</p>
                {grades.length > 0 && (
                  <div>
                    <p className="text-xs font-semibold text-text-muted uppercase mb-2 flex items-center gap-1.5"><TrendingUp className="w-3.5 h-3.5" /> Sabana de notas</p>
                    <div className="space-y-2 max-h-72 overflow-y-auto">
                      {grades.map((g: any) => (
                        <div key={g.id} className="flex items-center gap-3 bg-gray-50 rounded-lg px-3 py-2">
                          <span className="text-xs text-text-muted w-16 truncate">{g.title}</span>
                          <div className="flex-1 bg-gray-200 rounded-full h-2">
                            {g.score !== null && (
                              <div className="h-2 rounded-full transition-all" style={{ width: Math.min(g.score, 100) + "%", background: g.score >= 60 ? "#16A34A" : "#C0392B" }} />
                            )}
                          </div>
                          {g.score !== null
                            ? <span className={clsx("text-xs font-bold w-10 text-right flex-shrink-0", g.score >= 60 ? "text-green-600" : "text-red-600")}>{g.score}/100</span>
                            : <span className="text-xs text-text-muted w-10 text-right flex-shrink-0">Sin nota</span>
                          }
                          {g.feedback && <span className="text-xs text-text-muted italic truncate max-w-24" title={g.feedback}>{g.feedback}</span>}
                        </div>
                      ))}
                    </div>
                    {prom !== null && (
                      <div className="mt-3 pt-3 border-t border-gray-100 flex items-center justify-between">
                        <span className="text-sm font-bold text-text-primary flex items-center gap-2"><TrendingUp className="w-4 h-4 text-primary" /> Promedio final</span>
                        <div className="text-right">
                          <span className={clsx("text-xl font-bold", parseFloat(prom) >= 60 ? "text-green-600" : "text-red-600")}>{prom} / 100</span>
                          <p className={clsx("text-xs font-medium", parseFloat(prom) >= 60 ? "text-green-600" : "text-red-600")}>{parseFloat(prom) >= 60 ? "Aprobado" : "Reprobado"}</p>
                        </div>
                      </div>
                    )}
                  </div>
                )}
              </div>
            ) : (
              <div className="card space-y-4">
                <div className="flex items-center justify-between pb-3 border-b border-gray-100">
                  <div>
                    <div className="flex items-center gap-2">
                      <div className="w-9 h-9 bg-gradient-brand rounded-full flex items-center justify-center text-white text-sm font-bold">{selStudent.firstName[0]}</div>
                      <div>
                        <p className="font-bold text-text-primary text-sm">{selStudent.firstName} {selStudent.lastName}</p>
                        <p className="text-xs text-text-muted">{selSession.title}</p>
                      </div>
                    </div>
                  </div>
                  <div className="flex gap-2">
                    {prom !== null && (
                      <div className={clsx("text-center px-3 py-1.5 rounded-lg", parseFloat(prom) >= 60 ? "bg-green-50" : "bg-red-50")}>
                        <p className={clsx("text-base font-bold", parseFloat(prom) >= 60 ? "text-green-600" : "text-red-600")}>{prom}</p>
                        <p className="text-xs text-text-muted">Prom.</p>
                      </div>
                    )}
                    <button onClick={() => setSelSession(null)} className="btn-ghost border border-gray-200 rounded-lg px-3 text-xs">Ver sabana</button>
                  </div>
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs font-semibold text-text-muted mb-1.5">Nota (0 - 100)</label>
                    <input type="number" min="0" max="100" className="input text-2xl font-bold text-center" placeholder="0"
                      value={grading.score} onChange={(e) => setGrading((p) => ({ ...p, score: e.target.value }))} />
                    {grading.score && (
                      <p className={clsx("text-xs mt-1 font-medium text-center", parseFloat(grading.score) >= 60 ? "text-green-600" : "text-red-600")}>
                        {parseFloat(grading.score) >= 60 ? "Aprobado" : "Reprobado"} (min 60)
                      </p>
                    )}
                  </div>
                  <div>
                    <label className="block text-xs font-semibold text-text-muted mb-1.5">Retroalimentacion</label>
                    <textarea className="input text-sm resize-none" rows={3} placeholder="Comentario para el estudiante..."
                      value={grading.feedback} onChange={(e) => setGrading((p) => ({ ...p, feedback: e.target.value }))} />
                  </div>
                </div>
                <button onClick={saveGrade} disabled={saving || !grading.score}
                  className="btn-primary w-full flex items-center justify-center gap-2 disabled:opacity-40">
                  {saving ? <Loader2 className="w-4 h-4 animate-spin" /> : <CheckCircle className="w-4 h-4" />}
                  {saving ? "Guardando..." : "Guardar nota"}
                </button>
              </div>
            )}
          </div>
        </div>
      )}

      {tab === "examen" && (
        <div className="max-w-3xl space-y-5">
          {!selSession && <div className="card bg-yellow-50 border-yellow-200 text-yellow-700 text-sm p-3">Ve a Calificar, selecciona un estudiante y una sesion para asociar el examen a esa sesion.</div>}
          <div className="card space-y-4">
            <h3 className="font-bold text-text-primary flex items-center gap-2"><Star className="w-4 h-4 text-primary" /> Crear examen online - resultado inmediato al estudiante</h3>
            {selSession && <div className="bg-blue-50 text-blue-700 text-xs px-3 py-2 rounded-lg">Sesion seleccionada: <strong>{selSession.title}</strong></div>}
            <div className="grid grid-cols-2 gap-3">
              <div><label className="block text-xs font-semibold text-text-muted mb-1.5">Titulo del examen</label><input className="input text-sm" placeholder="Ej: Evaluacion sesion 1" value={examTitle} onChange={(e) => setExamTitle(e.target.value)} /></div>
              <div><label className="block text-xs font-semibold text-text-muted mb-1.5">Nota minima para aprobar</label><input className="input text-sm" type="number" placeholder="60" value={examPass} onChange={(e) => setExamPass(e.target.value)} /></div>
            </div>
            {questions.map((q, qi) => (
              <div key={qi} className="border border-gray-200 rounded-xl p-4 space-y-2">
                <div className="flex items-center gap-2">
                  <span className="badge-primary w-7 h-7 flex items-center justify-center rounded-full text-xs font-bold">{qi + 1}</span>
                  <input className="input text-sm flex-1" placeholder={"Pregunta " + (qi + 1)} value={q.text}
                    onChange={(e) => { const nq = [...questions]; nq[qi] = { ...nq[qi], text: e.target.value }; setQuestions(nq); }} />
                  <input className="input text-sm w-16" type="number" placeholder="Pts" value={q.points}
                    onChange={(e) => { const nq = [...questions]; nq[qi] = { ...nq[qi], points: parseInt(e.target.value) || 0 }; setQuestions(nq); }} />
                  {qi > 0 && <button onClick={() => setQuestions((p) => p.filter((_, i) => i !== qi))} className="text-red-400 hover:text-red-600"><Trash2 className="w-4 h-4" /></button>}
                </div>
                {q.options.map((opt, oi) => (
                  <div key={oi} className={clsx("flex items-center gap-2 rounded-lg px-3 py-2", q.correct === oi ? "bg-green-50 border border-green-200" : "bg-gray-50")}>
                    <input type="radio" name={"c" + qi} checked={q.correct === oi}
                      onChange={() => { const nq = [...questions]; nq[qi] = { ...nq[qi], correct: oi }; setQuestions(nq); }} className="accent-primary flex-shrink-0" />
                    <input className="bg-transparent border-none outline-none text-sm flex-1"
                      placeholder={"Opcion " + (oi + 1) + (q.correct === oi ? " (correcta)" : "")} value={opt}
                      onChange={(e) => { const nq = [...questions]; nq[qi].options[oi] = e.target.value; setQuestions(nq); }} />
                    {q.correct === oi && <span className="text-xs text-green-600 font-semibold flex-shrink-0">Correcta</span>}
                  </div>
                ))}
              </div>
            ))}
            <div className="flex gap-3">
              <button onClick={() => setQuestions((p) => [...p, { text: "", options: ["", "", "", ""], correct: 0, points: Math.floor(100 / (p.length + 1)) }])}
                className="btn-outline flex items-center gap-2 text-sm"><Plus className="w-4 h-4" /> Agregar pregunta</button>
              <button onClick={saveExam} disabled={!examTitle.trim() || !selSession} className="btn-primary flex items-center gap-2 text-sm disabled:opacity-40">
                <CheckCircle className="w-4 h-4" /> Publicar examen
              </button>
            </div>
            <div className="bg-blue-50 rounded-xl p-3 text-xs text-blue-700">Una vez publicado, el examen aparece en el visor del curso. El estudiante lo responde y obtiene su nota al instante.</div>
          </div>
        </div>
      )}
    </div>
  );
}

export default function FormadorGradesPage() {
  return (
    <AppShell allowedRoles={["FORMADOR","ADMIN"]}>
      <Suspense fallback={<div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div>}>
        <GradesContent />
      </Suspense>
    </AppShell>
  );
}'
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\formador\grades\page.tsx", $grades, [System.Text.Encoding]::UTF8)
Write-Host "Formador grades completo OK" -ForegroundColor Green

# ── 5. FIX ENCODING en archivos con em-dash ───────────────────
Write-Host "Corrigiendo encoding..." -ForegroundColor Cyan
$toFix = @(
  "frontend\src\app\(dashboard)\formador\courses\page.tsx",
  "frontend\src\app\(dashboard)\formador\attendance\page.tsx",
  "frontend\src\app\(student)\courses\[id]\page.tsx",
  "frontend\src\app\(dashboard)\formador\page.tsx"
)
foreach ($fp in $toFix) {
  if (Test-Path "$PWD\$fp") {
    $bytes = [System.IO.File]::ReadAllBytes("$PWD\$fp")
    $text = [System.Text.Encoding]::UTF8.GetString($bytes)
    $text = $text.Replace([char]8212, "-").Replace([char]8211, "-")
    [System.IO.File]::WriteAllText("$PWD\$fp", $text, [System.Text.Encoding]::UTF8)
    Write-Host "  OK: $fp" -ForegroundColor Gray
  }
}

Write-Host ""
Write-Host "======================================================" -ForegroundColor Yellow
Write-Host "V7 COMPLETO" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Ejecuta para aplicar:" -ForegroundColor Cyan
Write-Host "  docker-compose down -v" -ForegroundColor White
Write-Host "  docker-compose up --build" -ForegroundColor White
