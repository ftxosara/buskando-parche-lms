Write-Host "=== V8 - FORMADOR + FORO + CALIFICACIONES ESTUDIANTE ===" -ForegroundColor Yellow

# ── 1. SIDEBAR actualizado: foro para formador y admin ───────
New-Item -ItemType Directory -Force -Path "frontend\src\components\layout" | Out-Null
$sidebarContent = '"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useAuth } from "@/contexts/AuthContext";
import { LayoutDashboard, BookOpen, Users, ClipboardList, MessageSquare, Star, LogOut, ChevronRight, BarChart3, Award, GraduationCap } from "lucide-react";
import { useEffect, useState } from "react";
import clsx from "clsx";
import api from "@/lib/api";
export default function Sidebar() {
  const { user, logout } = useAuth();
  const pathname = usePathname();
  const [cid, setCid] = useState("");
  useEffect(() => {
    if (user?.role === "FORMADOR") {
      api.get("/courses/lobby").then(({ data }) => {
        const mine = data.find((c: any) => c.isMyCourseFomador);
        if (mine) setCid(mine.id);
      }).catch(() => {});
    }
  }, [user]);
  const navAdmin = [
    { href: "/admin", icon: LayoutDashboard, label: "Dashboard" },
    { href: "/admin/users", icon: Users, label: "Usuarios" },
    { href: "/admin/courses", icon: BookOpen, label: "Cursos" },
    { href: "/admin/reports", icon: BarChart3, label: "Reportes" },
    { href: "/admin/forum", icon: MessageSquare, label: "Foro" },
  ];
  const navFormador = [
    { href: "/formador", icon: LayoutDashboard, label: "Panel" },
    { href: cid ? "/formador/courses?id=" + cid : "/formador/courses", icon: BookOpen, label: "Mis Cursos" },
    { href: cid ? "/formador/attendance?courseId=" + cid : "/formador/attendance", icon: ClipboardList, label: "Asistencia" },
    { href: cid ? "/formador/grades?courseId=" + cid : "/formador/grades", icon: Star, label: "Calificaciones" },
    { href: cid ? "/formador/forum?courseId=" + cid : "/formador/forum", icon: MessageSquare, label: "Foro" },
  ];
  const navBen = [
    { href: "/lobby", icon: BookOpen, label: "Mis Cursos" },
    { href: "/lobby/grades", icon: GraduationCap, label: "Mis Notas" },
    { href: "/lobby/forum", icon: MessageSquare, label: "Foro" },
  ];
  const nav = user?.role === "ADMIN" ? navAdmin : user?.role === "FORMADOR" ? navFormador : navBen;
  const isActive = (href: string) => { const b = href.split("?")[0]; return pathname === b || pathname.startsWith(b + "/"); };
  return (
    <aside className="w-64 min-h-screen bg-white border-r border-gray-200 flex flex-col shadow-sm">
      <div className="bg-gradient-brand p-5 flex items-center gap-3">
        <img src="/images/logo.png" alt="Logo" className="h-10 w-auto object-contain" onError={(e) => { (e.target as HTMLImageElement).style.display = "none"; }} />
        <div><p className="font-display font-bold text-white text-sm">Buskando Parche</p><p className="text-white/70 text-xs">LMS - Kennedy</p></div>
      </div>
      <div className="p-4 border-b border-gray-100 bg-gray-50">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-gradient-brand rounded-full flex items-center justify-center font-bold text-white text-sm flex-shrink-0">{user?.firstName?.[0]}{user?.lastName?.[0]}</div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-semibold text-text-primary truncate">{user?.firstName} {user?.lastName}</p>
            <span className={clsx("badge text-xs mt-0.5", { "badge-primary": user?.role === "ADMIN", "badge-secondary": user?.role === "FORMADOR", "badge-muted": user?.role === "BENEFICIARIO" })}>
              {user?.role === "ADMIN" ? "Administrador" : user?.role === "FORMADOR" ? "Formador" : "Beneficiario"}
            </span>
          </div>
        </div>
      </div>
      <nav className="flex-1 p-4 space-y-1">
        {nav.map(({ href, icon: Icon, label }) => {
          const active = isActive(href);
          return (
            <Link key={label} href={href} className={clsx("flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all duration-200 group",
              active ? "bg-red-50 text-primary border border-red-100" : "text-text-secondary hover:bg-gray-50 hover:text-primary")}>
              <Icon className={clsx("w-5 h-5", active ? "text-primary" : "text-gray-400 group-hover:text-primary")} />
              {label}
              {active && <ChevronRight className="w-4 h-4 ml-auto text-primary" />}
            </Link>
          );
        })}
      </nav>
      <div className="p-4 border-t border-gray-100">
        <button onClick={logout} className="btn-ghost w-full flex items-center gap-3 text-sm text-gray-500"><LogOut className="w-5 h-5" /> Cerrar sesion</button>
      </div>
    </aside>
  );
}'
[System.IO.File]::WriteAllText("$PWD\frontend\src\components\layout\Sidebar.tsx", $sidebarContent, [System.Text.Encoding]::UTF8)
Write-Host "Sidebar OK" -ForegroundColor Green

# ── 2. FORO COMPARTIDO (componente reutilizable) ───────────────
New-Item -ItemType Directory -Force -Path "frontend\src\components\forum" | Out-Null
$forumComp = '"use client";
import { useEffect, useState } from "react";
import api from "@/lib/api";
import { useAuth } from "@/contexts/AuthContext";
import { MessageSquare, Send, Plus, ChevronDown, ChevronRight, Loader2, Pin } from "lucide-react";
import clsx from "clsx";

export default function ForumComponent({ courseId, courseTitle }: { courseId: string; courseTitle: string }) {
  const { user } = useAuth();
  const [posts, setPosts] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [expanded, setExpanded] = useState<string | null>(null);
  const [newPost, setNewPost] = useState({ title: "", body: "" });
  const [replyBody, setReplyBody] = useState<Record<string, string>>({});
  const [posting, setPosting] = useState(false);

  const load = () => {
    setLoading(true);
    api.get("/forum/course/" + courseId).then(({ data }) => setPosts(data)).finally(() => setLoading(false));
  };
  useEffect(() => { load(); }, [courseId]);

  const submitPost = async () => {
    if (!newPost.title.trim()) return;
    setPosting(true);
    await api.post("/forum", { courseId, ...newPost });
    setNewPost({ title: "", body: "" });
    load();
    setPosting(false);
  };
  const submitReply = async (postId: string) => {
    if (!replyBody[postId]?.trim()) return;
    await api.post("/forum/" + postId + "/replies", { body: replyBody[postId] });
    setReplyBody((p) => ({ ...p, [postId]: "" }));
    load();
  };

  const roleBadge = (r: string) => r === "ADMIN" ? "badge-primary" : r === "FORMADOR" ? "badge-secondary" : "badge-muted";
  const roleLabel = (r: string) => r === "ADMIN" ? "Admin" : r === "FORMADOR" ? "Formador" : "Estudiante";

  return (
    <div className="space-y-5">
      <div className="card">
        <p className="font-bold text-text-primary mb-3 flex items-center gap-2"><Plus className="w-4 h-4 text-primary" /> Nueva publicacion</p>
        <input className="input mb-2 text-sm" placeholder="Titulo..." value={newPost.title} onChange={(e) => setNewPost((p) => ({ ...p, title: e.target.value }))} />
        <textarea className="input resize-none mb-3 text-sm" rows={3} placeholder="Escribe tu mensaje..." value={newPost.body} onChange={(e) => setNewPost((p) => ({ ...p, body: e.target.value }))} />
        <button onClick={submitPost} disabled={posting || !newPost.title.trim()} className="btn-primary flex items-center gap-2 text-sm disabled:opacity-40">
          {posting ? <Loader2 className="w-4 h-4 animate-spin" /> : <Send className="w-4 h-4" />} Publicar
        </button>
      </div>
      {loading ? <div className="flex justify-center py-8"><Loader2 className="w-6 h-6 text-primary animate-spin" /></div> : (
        <div className="space-y-3">
          {posts.length === 0 && (
            <div className="card text-center py-10"><MessageSquare className="w-10 h-10 text-gray-200 mx-auto mb-3" /><p className="text-text-muted text-sm">Sin publicaciones aun. Se el primero en participar.</p></div>
          )}
          {posts.map((p: any) => (
            <div key={p.id} className="card p-0 overflow-hidden">
              <button onClick={() => setExpanded((prev) => prev === p.id ? null : p.id)}
                className="w-full text-left p-4 hover:bg-gray-50 transition-colors flex items-start gap-3">
                {p.isPinned && <Pin className="w-4 h-4 text-primary flex-shrink-0 mt-0.5" />}
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between gap-2">
                    <p className="font-semibold text-text-primary text-sm">{p.title}</p>
                    <span className={clsx("badge text-xs flex-shrink-0", roleBadge(p.author?.role))}>{roleLabel(p.author?.role)}</span>
                  </div>
                  <p className="text-text-secondary text-xs mt-1 line-clamp-2">{p.body}</p>
                  <div className="flex items-center gap-3 mt-2 text-xs text-text-muted">
                    <span>{p.author?.firstName} {p.author?.lastName}</span>
                    <span>{new Date(p.createdAt).toLocaleDateString("es-CO")}</span>
                    <span className="flex items-center gap-1"><MessageSquare className="w-3 h-3" /> {p.replies?.length || 0}</span>
                  </div>
                </div>
                {expanded === p.id ? <ChevronDown className="w-4 h-4 text-text-muted flex-shrink-0 mt-1" /> : <ChevronRight className="w-4 h-4 text-text-muted flex-shrink-0 mt-1" />}
              </button>
              {expanded === p.id && (
                <div className="border-t border-gray-100 bg-gray-50 p-4 space-y-3">
                  <div className="bg-white rounded-xl p-3 border border-gray-100 text-sm text-text-secondary">{p.body}</div>
                  {p.replies?.map((r: any) => (
                    <div key={r.id} className="bg-white rounded-xl p-3 border border-gray-100 ml-4">
                      <div className="flex items-center gap-2 mb-1">
                        <span className="font-medium text-xs text-text-primary">{r.author?.firstName} {r.author?.lastName}</span>
                        <span className={clsx("badge text-xs", roleBadge(r.author?.role))}>{roleLabel(r.author?.role)}</span>
                        <span className="text-xs text-text-muted ml-auto">{new Date(r.createdAt).toLocaleDateString("es-CO")}</span>
                      </div>
                      <p className="text-xs text-text-secondary">{r.body}</p>
                    </div>
                  ))}
                  <div className="flex gap-2 mt-2">
                    <input className="input text-sm flex-1" placeholder="Responder..."
                      value={replyBody[p.id] || ""} onChange={(e) => setReplyBody((prev) => ({ ...prev, [p.id]: e.target.value }))}
                      onKeyDown={(e) => e.key === "Enter" && submitReply(p.id)} />
                    <button onClick={() => submitReply(p.id)} className="btn-primary px-4 py-2 text-sm"><Send className="w-4 h-4" /></button>
                  </div>
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}'
[System.IO.File]::WriteAllText("$PWD\frontend\src\components\forum\ForumComponent.tsx", $forumComp, [System.Text.Encoding]::UTF8)
Write-Host "ForumComponent OK" -ForegroundColor Green

# ── 3. FORO para FORMADOR ─────────────────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\formador\forum" | Out-Null
$formForum = '"use client";
import { useEffect, useState, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import ForumComponent from "@/components/forum/ForumComponent";
import { Loader2, MessageSquare } from "lucide-react";
function FormadorForumContent() {
  const params = useSearchParams();
  const courseId = params.get("courseId");
  const [course, setCourse] = useState<any>(null);
  useEffect(() => { if (courseId) api.get("/courses/" + courseId).then(({ data }) => setCourse(data)); }, [courseId]);
  if (!courseId) return (
    <div className="card text-center py-12"><MessageSquare className="w-10 h-10 text-gray-300 mx-auto mb-3" /><p className="text-text-muted">Accede desde el panel del formador.</p></div>
  );
  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <div><h1 className="font-display text-2xl font-bold text-text-primary">Foro del curso</h1><p className="text-text-secondary mt-1">{course?.title}</p></div>
      {course && <ForumComponent courseId={courseId} courseTitle={course.title} />}
    </div>
  );
}
export default function FormadorForumPage() {
  return (
    <AppShell allowedRoles={["FORMADOR","ADMIN"]}>
      <Suspense fallback={<div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div>}>
        <FormadorForumContent />
      </Suspense>
    </AppShell>
  );
}'
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\formador\forum\page.tsx", $formForum, [System.Text.Encoding]::UTF8)
Write-Host "Formador forum OK" -ForegroundColor Green

# ── 4. FORO para ADMIN ────────────────────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\admin\forum" | Out-Null
$adminForum = '"use client";
import { useEffect, useState } from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import ForumComponent from "@/components/forum/ForumComponent";
import { Loader2, MessageSquare } from "lucide-react";
export default function AdminForumPage() {
  const [courses, setCourses] = useState<any[]>([]);
  const [selCourse, setSelCourse] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    api.get("/courses/lobby").then(({ data }) => {
      setCourses(data);
      if (data.length > 0) setSelCourse(data[0]);
    }).finally(() => setLoading(false));
  }, []);
  return (
    <AppShell allowedRoles={["ADMIN"]}>
      <div className="max-w-4xl mx-auto space-y-6">
        <div><h1 className="font-display text-2xl font-bold text-text-primary">Foro general</h1><p className="text-text-secondary mt-1">Modera y participa en los foros de cada curso.</p></div>
        {loading ? <div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div> : (
          <>
            <div className="flex gap-2 flex-wrap">
              {courses.map((c: any) => (
                <button key={c.id} onClick={() => setSelCourse(c)}
                  className={`px-4 py-2 rounded-full text-sm font-medium transition-colors ${selCourse?.id === c.id ? "bg-primary text-white" : "bg-gray-100 text-text-secondary hover:bg-gray-200"}`}>
                  {c.title}
                </button>
              ))}
            </div>
            {selCourse && <ForumComponent courseId={selCourse.id} courseTitle={selCourse.title} />}
          </>
        )}
      </div>
    </AppShell>
  );
}'
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\admin\forum\page.tsx", $adminForum, [System.Text.Encoding]::UTF8)
Write-Host "Admin forum OK" -ForegroundColor Green

# ── 5. FORO para BENEFICIARIO (actualizado) ───────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(student)\lobby\forum" | Out-Null
$benForum = '"use client";
import { useEffect, useState } from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import ForumComponent from "@/components/forum/ForumComponent";
import { Loader2, MessageSquare } from "lucide-react";
export default function BenForumPage() {
  const [courses, setCourses] = useState<any[]>([]);
  const [selCourse, setSelCourse] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    api.get("/courses/lobby").then(({ data }) => {
      const enrolled = data.filter((c: any) => c.isEnrolled);
      setCourses(enrolled);
      if (enrolled.length > 0) setSelCourse(enrolled[0]);
    }).finally(() => setLoading(false));
  }, []);
  return (
    <AppShell allowedRoles={["BENEFICIARIO"]}>
      <div className="max-w-3xl mx-auto space-y-6">
        <div><h1 className="font-display text-2xl font-bold text-text-primary">Foro del curso</h1><p className="text-text-secondary mt-1">Participa y comparte con tus compañeros y formador.</p></div>
        {loading ? <div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div> : (
          <>
            {courses.length > 1 && (
              <div className="flex gap-2 flex-wrap">
                {courses.map((c: any) => (
                  <button key={c.id} onClick={() => setSelCourse(c)}
                    className={`px-4 py-2 rounded-full text-sm font-medium transition-colors ${selCourse?.id === c.id ? "bg-primary text-white" : "bg-gray-100 text-text-secondary hover:bg-gray-200"}`}>
                    {c.title}
                  </button>
                ))}
              </div>
            )}
            {selCourse ? <ForumComponent courseId={selCourse.id} courseTitle={selCourse.title} /> : (
              <div className="card text-center py-12"><MessageSquare className="w-10 h-10 text-gray-200 mx-auto mb-3" /><p className="text-text-muted">No tienes cursos inscritos aun.</p></div>
            )}
          </>
        )}
      </div>
    </AppShell>
  );
}'
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(student)\lobby\forum\page.tsx", $benForum, [System.Text.Encoding]::UTF8)
Write-Host "Beneficiario forum OK" -ForegroundColor Green

# ── 6. BENEFICIARIO - NOTAS (reemplaza certificados) ─────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(student)\lobby\grades" | Out-Null
$benGrades = '"use client";
import { useEffect, useState } from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { useAuth } from "@/contexts/AuthContext";
import { GraduationCap, TrendingUp, CheckCircle, Loader2, BookOpen } from "lucide-react";
import clsx from "clsx";
export default function BenGradesPage() {
  const { user } = useAuth();
  const [courses, setCourses] = useState<any[]>([]);
  const [selCourse, setSelCourse] = useState<any>(null);
  const [grades, setGrades] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadingGrades, setLoadingGrades] = useState(false);
  useEffect(() => {
    api.get("/courses/lobby").then(({ data }) => {
      const en = data.filter((c: any) => c.isEnrolled);
      setCourses(en);
      if (en.length > 0) loadGrades(en[0]);
    }).finally(() => setLoading(false));
  }, []);
  const loadGrades = async (course: any) => {
    setSelCourse(course); setLoadingGrades(true);
    try {
      const { data } = await api.get("/assignments/grades/" + course.id);
      setGrades(data);
    } catch { setGrades([]); }
    finally { setLoadingGrades(false); }
  };
  const graded = grades.filter((g: any) => g.score !== null);
  const promedio = graded.length ? (graded.reduce((s: number, g: any) => s + g.score, 0) / graded.length).toFixed(1) : null;
  const presente = grades.filter((g: any) => g.attendance === "PRESENTE").length;
  const pctAsis = grades.length ? ((presente / grades.length) * 100).toFixed(0) : 0;
  return (
    <AppShell allowedRoles={["BENEFICIARIO"]}>
      <div className="max-w-4xl mx-auto space-y-6">
        <div><h1 className="font-display text-2xl font-bold text-text-primary">Mis Calificaciones</h1><p className="text-text-secondary mt-1">Sabana de notas y asistencia por sesion.</p></div>
        {loading ? <div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div> : (
          <>
            {courses.length > 1 && (
              <div className="flex gap-2 flex-wrap">
                {courses.map((c: any) => (
                  <button key={c.id} onClick={() => loadGrades(c)}
                    className={`px-4 py-2 rounded-full text-sm font-medium transition-colors ${selCourse?.id === c.id ? "bg-primary text-white" : "bg-gray-100 text-text-secondary hover:bg-gray-200"}`}>
                    {c.title}
                  </button>
                ))}
              </div>
            )}
            {selCourse && (
              <>
                {/* KPIs */}
                <div className="grid grid-cols-3 gap-4">
                  <div className="card text-center">
                    <p className={clsx("text-3xl font-bold font-display", promedio && parseFloat(promedio) >= 60 ? "text-green-600" : "text-red-500")}>{promedio || "-"}</p>
                    <p className="text-text-muted text-sm mt-1">Promedio general</p>
                    {promedio && <p className={clsx("text-xs font-semibold mt-1", parseFloat(promedio) >= 60 ? "text-green-600" : "text-red-500")}>{parseFloat(promedio) >= 60 ? "Aprobado" : "Reprobado"}</p>}
                  </div>
                  <div className="card text-center">
                    <p className="text-3xl font-bold font-display text-blue-600">{pctAsis}%</p>
                    <p className="text-text-muted text-sm mt-1">Asistencia</p>
                    <p className="text-xs text-text-muted mt-1">{presente} de {grades.length} sesiones</p>
                  </div>
                  <div className="card text-center">
                    <p className="text-3xl font-bold font-display text-text-primary">{graded.length}</p>
                    <p className="text-text-muted text-sm mt-1">Sesiones calificadas</p>
                    <p className="text-xs text-text-muted mt-1">de {grades.length} totales</p>
                  </div>
                </div>
                {/* Tabla de notas */}
                {loadingGrades ? (
                  <div className="flex justify-center py-8"><Loader2 className="w-6 h-6 text-primary animate-spin" /></div>
                ) : (
                  <div className="card overflow-hidden p-0">
                    <div className="p-4 bg-gray-50 border-b flex items-center gap-2">
                      <GraduationCap className="w-5 h-5 text-primary" />
                      <h3 className="font-bold text-text-primary">Sabana de notas - {selCourse.title}</h3>
                    </div>
                    <div className="overflow-x-auto">
                      <table className="w-full text-sm">
                        <thead>
                          <tr className="bg-gray-50 border-b border-gray-100">
                            <th className="text-left py-3 px-4 font-semibold text-text-secondary">Sesion</th>
                            <th className="text-center py-3 px-4 font-semibold text-text-secondary">Asistencia</th>
                            <th className="text-center py-3 px-4 font-semibold text-text-secondary">Nota</th>
                            <th className="text-center py-3 px-4 font-semibold text-text-secondary">Estado</th>
                            <th className="text-left py-3 px-4 font-semibold text-text-secondary">Retroalimentacion</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-50">
                          {grades.map((g: any) => (
                            <tr key={g.id} className="hover:bg-gray-50 transition-colors">
                              <td className="py-3 px-4 font-medium text-text-primary">{g.title}</td>
                              <td className="py-3 px-4 text-center">
                                <span className={clsx("badge text-xs", g.attendance === "PRESENTE" ? "badge-success" : g.attendance === "AUSENTE" ? "badge-primary" : g.attendance === "EXCUSA" ? "badge-warning" : "badge-muted")}>
                                  {g.attendance || "Sin registro"}
                                </span>
                              </td>
                              <td className="py-3 px-4 text-center">
                                {g.score !== null ? (
                                  <div className="flex flex-col items-center">
                                    <span className={clsx("text-lg font-bold", g.score >= 60 ? "text-green-600" : "text-red-500")}>{g.score}</span>
                                    <div className="w-16 bg-gray-200 rounded-full h-1.5 mt-1">
                                      <div className="h-1.5 rounded-full" style={{ width: Math.min(g.score, 100) + "%", background: g.score >= 60 ? "#16A34A" : "#C0392B" }} />
                                    </div>
                                  </div>
                                ) : (
                                  <span className="text-text-muted text-xs">Pendiente</span>
                                )}
                              </td>
                              <td className="py-3 px-4 text-center">
                                {g.score !== null ? (
                                  <span className={clsx("badge text-xs", g.score >= 60 ? "badge-success" : "badge-primary")}>{g.score >= 60 ? "Aprobado" : "Reprobado"}</span>
                                ) : <span className="text-text-muted text-xs">-</span>}
                              </td>
                              <td className="py-3 px-4 text-text-secondary text-xs italic">{g.feedback || "-"}</td>
                            </tr>
                          ))}
                        </tbody>
                        {promedio && (
                          <tfoot>
                            <tr className="border-t-2 border-gray-200 bg-gray-50">
                              <td className="py-3 px-4 font-bold text-text-primary" colSpan={2}>PROMEDIO FINAL</td>
                              <td className="py-3 px-4 text-center">
                                <span className={clsx("text-xl font-bold", parseFloat(promedio) >= 60 ? "text-green-600" : "text-red-500")}>{promedio}</span>
                              </td>
                              <td className="py-3 px-4 text-center">
                                <span className={clsx("badge", parseFloat(promedio) >= 60 ? "badge-success" : "badge-primary")}>{parseFloat(promedio) >= 60 ? "Aprobado" : "Reprobado"}</span>
                              </td>
                              <td className="py-3 px-4 text-xs text-text-muted">{graded.length} sesiones calificadas</td>
                            </tr>
                          </tfoot>
                        )}
                      </table>
                      {grades.length === 0 && (
                        <div className="text-center py-10"><p className="text-text-muted text-sm">El formador aun no ha registrado calificaciones.</p></div>
                      )}
                    </div>
                  </div>
                )}
              </>
            )}
          </>
        )}
      </div>
    </AppShell>
  );
}'
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(student)\lobby\grades\page.tsx", $benGrades, [System.Text.Encoding]::UTF8)
Write-Host "Beneficiario grades (sabana de notas) OK" -ForegroundColor Green

# ── 7. FORMADOR GRADES: reescritura limpia sin em-dash ────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\formador\grades" | Out-Null
$formGrades = '"use client";
import { useEffect, useState, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { Loader2, CheckCircle, Star, Plus, Trash2, TrendingUp } from "lucide-react";
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
  const [examTitle, setExamTitle] = useState("");
  const [examPass, setExamPass] = useState("60");
  const [qs, setQs] = useState([{text:"",options:["","","",""],correct:0,points:25}]);

  useEffect(() => {
    if (!courseId) { setLoading(false); return; }
    Promise.all([
      api.get("/courses/" + courseId),
      api.get("/users", { params: { role:"BENEFICIARIO", limit:100 } }),
    ]).then(([cr, ur]) => {
      setCourse(cr.data);
      const en = ur.data.data.filter((u: any) => u.enrollments?.some((e: any) => e.courseId === courseId));
      setStudents(en);
    }).finally(() => setLoading(false));
  }, [courseId]);

  const pickStudent = async (s: any) => {
    setSelStudent(s); setSelSession(null); setGrading({ score:"", feedback:"" }); setMsg("");
    try {
      const { data } = await api.get("/assignments/grades/" + courseId + "?userId=" + s.id);
      setGrades(data);
    } catch { setGrades([]); }
  };

  const pickSession = (s: any) => {
    setSelSession(s);
    const g = grades.find((gr: any) => gr.id === s.id);
    setGrading({ score: g?.score?.toString() || "", feedback: g?.feedback || "" });
  };

  const saveGrade = async () => {
    if (!selSession || !selStudent || !grading.score) return;
    setSaving(true);
    try {
      const { data: subs } = await api.get("/assignments/session/" + selSession.id);
      const mySub = subs.find((s: any) => s.userId === selStudent.id);
      if (mySub) {
        await api.put("/assignments/" + mySub.id + "/grade", { score: grading.score, feedback: grading.feedback });
      } else {
        const ev = await api.post("/evaluations", { courseId, sessionId: selSession.id, title:"Nota - "+selSession.title, questions:[], passingScore:60, maxScore:100 });
        const fd = new FormData();
        fd.append("sessionId", selSession.id); fd.append("courseId", courseId!);
        fd.append("textContent","Nota manual"); fd.append("evaluationId", ev.data.id);
        const nr = await api.post("/assignments", fd);
        if (nr.data?.id) await api.put("/assignments/"+nr.data.id+"/grade", { score: grading.score, feedback: grading.feedback });
      }
      setMsg("Nota guardada: " + selStudent.firstName + " / " + selSession.title);
      const { data } = await api.get("/assignments/grades/" + courseId + "?userId=" + selStudent.id);
      setGrades(data);
    } catch (e: any) {
      setMsg("Error: " + (e?.response?.data?.error || "intenta de nuevo"));
    } finally { setSaving(false); }
  };

  const saveExam = async () => {
    if (!examTitle.trim() || !selSession) return;
    try {
      await api.post("/evaluations", { courseId, sessionId: selSession.id, title: examTitle, questions: qs, passingScore: parseInt(examPass), maxScore: 100 });
      setMsg("Examen publicado para " + selSession.title);
      setExamTitle(""); setExamPass("60"); setQs([{text:"",options:["","","",""],correct:0,points:25}]);
    } catch { setMsg("Error al crear examen"); }
  };

  const prom = () => {
    const g = grades.filter((gr: any) => gr.score !== null);
    return g.length ? (g.reduce((s: number, gr: any) => s + gr.score, 0) / g.length).toFixed(1) : null;
  };

  if (loading) return <div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div>;
  if (!courseId || !course) return <div className="card text-center py-12"><p className="text-text-muted">Accede desde el panel del formador.</p></div>;

  const promedio = prom();

  return (
    <div className="max-w-6xl mx-auto space-y-5">
      <div>
        <h1 className="font-display text-2xl font-bold text-text-primary">Calificaciones</h1>
        <p className="text-text-secondary mt-1">{course?.title} - {students.length} estudiantes inscritos</p>
      </div>

      {msg && <div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-xl text-sm flex items-center gap-2"><CheckCircle className="w-4 h-4" />{msg}<button onClick={() => setMsg("")} className="ml-auto font-bold">x</button></div>}

      <div className="flex gap-2 border-b border-gray-200 pb-0">
        {(["calificar","examen"] as const).map(t => (
          <button key={t} onClick={() => setTab(t)} className={clsx("px-5 py-2.5 text-sm font-semibold border-b-2 transition-colors -mb-px",
            tab === t ? "border-primary text-primary" : "border-transparent text-text-muted hover:text-text-primary")}>
            {t === "calificar" ? "Calificar estudiantes" : "Crear examen online"}
          </button>
        ))}
      </div>

      {tab === "calificar" && (
        <div className="grid grid-cols-4 gap-4">

          {/* COL 1: Estudiantes */}
          <div className="col-span-1 bg-white rounded-2xl border border-gray-200 shadow-card overflow-hidden">
            <div className="px-3 py-3 bg-gray-50 border-b"><p className="text-xs font-bold text-text-muted uppercase tracking-wide">Estudiantes</p></div>
            <div className="overflow-y-auto max-h-[520px] divide-y divide-gray-50">
              {students.map((s: any) => (
                <button key={s.id} onClick={() => pickStudent(s)} className={clsx("w-full text-left px-3 py-3 flex items-center gap-2 transition-colors",
                  selStudent?.id === s.id ? "bg-red-50 border-r-2 border-primary" : "hover:bg-gray-50")}>
                  <div className="w-7 h-7 bg-gradient-brand rounded-full flex items-center justify-center text-white text-xs font-bold flex-shrink-0">{s.firstName[0]}</div>
                  <div className="min-w-0 flex-1">
                    <p className={clsx("text-xs font-semibold truncate", selStudent?.id === s.id ? "text-primary" : "text-text-primary")}>{s.firstName} {s.lastName}</p>
                    <p className="text-xs text-text-muted truncate">{s.cedula}</p>
                  </div>
                </button>
              ))}
            </div>
          </div>

          {/* COL 2: Sesiones */}
          <div className="col-span-1 bg-white rounded-2xl border border-gray-200 shadow-card overflow-hidden">
            <div className="px-3 py-3 bg-gray-50 border-b"><p className="text-xs font-bold text-text-muted uppercase tracking-wide">{selStudent ? "Sesiones" : "Elige estudiante"}</p></div>
            {!selStudent ? (
              <div className="flex flex-col items-center justify-center py-12 px-3"><Star className="w-8 h-8 text-gray-200 mb-2" /><p className="text-text-muted text-xs text-center">Selecciona un estudiante</p></div>
            ) : (
              <div className="overflow-y-auto max-h-[520px] divide-y divide-gray-50">
                {course?.sessions?.map((s: any) => {
                  const g = grades.find((gr: any) => gr.id === s.id);
                  const hasNote = g?.score !== null && g?.score !== undefined;
                  return (
                    <button key={s.id} onClick={() => pickSession(s)} className={clsx("w-full text-left px-3 py-2.5 flex items-center gap-2 text-xs transition-colors",
                      selSession?.id === s.id ? "bg-red-50 border-r-2 border-primary text-primary font-semibold" : "hover:bg-gray-50 text-text-secondary")}>
                      <span className={clsx("w-6 h-6 rounded-full flex items-center justify-center font-bold flex-shrink-0",
                        selSession?.id === s.id ? "bg-primary text-white" : hasNote ? "bg-green-100 text-green-700" : "bg-gray-100 text-gray-500")}>
                        {hasNote ? <CheckCircle className="w-3 h-3" /> : s.order}
                      </span>
                      <span className="flex-1 truncate">{s.title}</span>
                      {hasNote && <span className={clsx("font-bold flex-shrink-0", g.score >= 60 ? "text-green-600" : "text-red-500")}>{g.score}</span>}
                    </button>
                  );
                })}
              </div>
            )}
          </div>

          {/* COL 3-4: Panel */}
          <div className="col-span-2 space-y-4">
            {!selStudent ? (
              <div className="bg-white rounded-2xl border border-gray-200 shadow-card text-center py-16">
                <Star className="w-12 h-12 text-gray-200 mx-auto mb-3" />
                <p className="text-text-muted text-sm">Selecciona un estudiante para calificar</p>
              </div>
            ) : !selSession ? (
              <div className="bg-white rounded-2xl border border-gray-200 shadow-card p-5 space-y-4">
                <div className="flex items-center gap-3">
                  <div className="w-11 h-11 bg-gradient-brand rounded-full flex items-center justify-center text-white font-bold">{selStudent.firstName[0]}</div>
                  <div className="flex-1">
                    <p className="font-bold text-text-primary">{selStudent.firstName} {selStudent.lastName}</p>
                    <p className="text-text-muted text-xs">{selStudent.cedula}</p>
                  </div>
                  {promedio !== null && (
                    <div className={clsx("text-center px-4 py-2 rounded-xl", parseFloat(promedio) >= 60 ? "bg-green-50" : "bg-red-50")}>
                      <p className={clsx("text-2xl font-bold", parseFloat(promedio) >= 60 ? "text-green-600" : "text-red-500")}>{promedio}</p>
                      <p className="text-xs text-text-muted">Promedio</p>
                    </div>
                  )}
                </div>
                <p className="text-text-muted text-sm">Selecciona una sesion para ingresar o editar la nota.</p>
                {grades.length > 0 && (
                  <div>
                    <p className="text-xs font-bold text-text-muted uppercase mb-2">Sabana de notas</p>
                    <div className="space-y-1.5 max-h-64 overflow-y-auto pr-1">
                      {grades.map((g: any) => (
                        <div key={g.id} className="flex items-center gap-2 bg-gray-50 rounded-lg px-3 py-2">
                          <span className="text-xs text-text-muted w-16 truncate">{g.title}</span>
                          <div className="flex-1 bg-gray-200 rounded-full h-1.5">
                            {g.score !== null && <div className="h-1.5 rounded-full" style={{ width: Math.min(g.score,100)+"%", background: g.score>=60?"#16A34A":"#C0392B" }} />}
                          </div>
                          {g.score !== null
                            ? <span className={clsx("text-xs font-bold w-14 text-right flex-shrink-0", g.score>=60?"text-green-600":"text-red-500")}>{g.score}/100</span>
                            : <span className="text-xs text-text-muted w-14 text-right flex-shrink-0">Sin nota</span>}
                        </div>
                      ))}
                    </div>
                    {promedio !== null && (
                      <div className="mt-3 pt-3 border-t border-gray-100 flex items-center justify-between">
                        <span className="text-sm font-bold text-text-primary flex items-center gap-1.5"><TrendingUp className="w-4 h-4 text-primary" /> Promedio final</span>
                        <div className="text-right">
                          <span className={clsx("text-xl font-bold", parseFloat(promedio)>=60?"text-green-600":"text-red-500")}>{promedio}/100</span>
                          <p className={clsx("text-xs font-semibold", parseFloat(promedio)>=60?"text-green-600":"text-red-500")}>{parseFloat(promedio)>=60?"Aprobado":"Reprobado"}</p>
                        </div>
                      </div>
                    )}
                  </div>
                )}
              </div>
            ) : (
              <div className="bg-white rounded-2xl border border-gray-200 shadow-card p-5 space-y-4">
                <div className="flex items-center justify-between pb-3 border-b border-gray-100">
                  <div className="flex items-center gap-3">
                    <div className="w-9 h-9 bg-gradient-brand rounded-full flex items-center justify-center text-white text-sm font-bold flex-shrink-0">{selStudent.firstName[0]}</div>
                    <div>
                      <p className="font-bold text-text-primary text-sm">{selStudent.firstName} {selStudent.lastName}</p>
                      <p className="text-xs text-text-muted">{selSession.title}</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    {promedio !== null && (
                      <div className={clsx("text-center px-3 py-1.5 rounded-lg", parseFloat(promedio)>=60?"bg-green-50":"bg-red-50")}>
                        <p className={clsx("text-base font-bold", parseFloat(promedio)>=60?"text-green-600":"text-red-500")}>{promedio}</p>
                        <p className="text-xs text-text-muted">Prom.</p>
                      </div>
                    )}
                    <button onClick={() => setSelSession(null)} className="text-xs border border-gray-200 rounded-lg px-3 py-2 text-text-muted hover:bg-gray-50">Ver sabana</button>
                  </div>
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs font-bold text-text-muted mb-1.5">Nota (0 a 100)</label>
                    <input type="number" min="0" max="100" className="input text-2xl font-bold text-center" placeholder="0"
                      value={grading.score} onChange={(e) => setGrading((p) => ({...p, score: e.target.value}))} />
                    {grading.score && (
                      <p className={clsx("text-xs mt-1 font-semibold text-center", parseFloat(grading.score)>=60?"text-green-600":"text-red-500")}>
                        {parseFloat(grading.score)>=60?"Aprobado":"Reprobado"} (minimo 60)
                      </p>
                    )}
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-text-muted mb-1.5">Retroalimentacion</label>
                    <textarea className="input text-sm resize-none" rows={3} placeholder="Comentario para el estudiante..."
                      value={grading.feedback} onChange={(e) => setGrading((p) => ({...p, feedback: e.target.value}))} />
                  </div>
                </div>
                <button onClick={saveGrade} disabled={saving || !grading.score} className="btn-primary w-full flex items-center justify-center gap-2 disabled:opacity-40">
                  {saving ? <Loader2 className="w-4 h-4 animate-spin" /> : <CheckCircle className="w-4 h-4" />}
                  {saving ? "Guardando..." : "Guardar nota"}
                </button>
              </div>
            )}
          </div>
        </div>
      )}

      {tab === "examen" && (
        <div className="max-w-3xl space-y-4">
          {!selSession && <div className="bg-yellow-50 border border-yellow-200 text-yellow-700 text-sm p-3 rounded-xl">Primero ve a Calificar, selecciona un estudiante y una sesion para asociar el examen.</div>}
          <div className="bg-white rounded-2xl border border-gray-200 shadow-card p-5 space-y-4">
            <h3 className="font-bold text-text-primary flex items-center gap-2"><Star className="w-4 h-4 text-primary" /> Crear examen online - resultado inmediato</h3>
            {selSession && <div className="bg-blue-50 text-blue-700 text-xs px-3 py-2 rounded-lg">Sesion: <strong>{selSession.title}</strong></div>}
            <div className="grid grid-cols-2 gap-3">
              <div><label className="block text-xs font-bold text-text-muted mb-1.5">Titulo del examen</label><input className="input text-sm" placeholder="Ej: Evaluacion sesion 1" value={examTitle} onChange={(e) => setExamTitle(e.target.value)} /></div>
              <div><label className="block text-xs font-bold text-text-muted mb-1.5">Nota minima para aprobar</label><input className="input text-sm" type="number" placeholder="60" value={examPass} onChange={(e) => setExamPass(e.target.value)} /></div>
            </div>
            {qs.map((q, qi) => (
              <div key={qi} className="border border-gray-200 rounded-xl p-4 space-y-2">
                <div className="flex items-center gap-2">
                  <span className="bg-primary text-white text-xs w-7 h-7 rounded-full flex items-center justify-center font-bold flex-shrink-0">{qi+1}</span>
                  <input className="input text-sm flex-1" placeholder={"Pregunta " + (qi+1)} value={q.text}
                    onChange={(e) => { const n=[...qs]; n[qi]={...n[qi],text:e.target.value}; setQs(n); }} />
                  <input className="input text-sm w-16" type="number" placeholder="Pts" value={q.points}
                    onChange={(e) => { const n=[...qs]; n[qi]={...n[qi],points:parseInt(e.target.value)||0}; setQs(n); }} />
                  {qi>0 && <button onClick={() => setQs((p) => p.filter((_,i) => i!==qi))} className="text-red-400 hover:text-red-600"><Trash2 className="w-4 h-4" /></button>}
                </div>
                {q.options.map((opt, oi) => (
                  <div key={oi} className={clsx("flex items-center gap-2 rounded-lg px-3 py-2", q.correct===oi?"bg-green-50 border border-green-200":"bg-gray-50")}>
                    <input type="radio" name={"c"+qi} checked={q.correct===oi} onChange={() => { const n=[...qs]; n[qi]={...n[qi],correct:oi}; setQs(n); }} className="accent-primary flex-shrink-0" />
                    <input className="bg-transparent border-none outline-none text-sm flex-1" placeholder={"Opcion "+(oi+1)+(q.correct===oi?" (correcta)":"")} value={opt}
                      onChange={(e) => { const n=[...qs]; n[qi].options[oi]=e.target.value; setQs(n); }} />
                    {q.correct===oi && <span className="text-xs text-green-600 font-bold flex-shrink-0">Correcta</span>}
                  </div>
                ))}
              </div>
            ))}
            <div className="flex gap-3">
              <button onClick={() => setQs((p) => [...p,{text:"",options:["","","",""],correct:0,points:Math.floor(100/(p.length+1))}])} className="btn-outline flex items-center gap-2 text-sm"><Plus className="w-4 h-4" /> Agregar pregunta</button>
              <button onClick={saveExam} disabled={!examTitle.trim()||!selSession} className="btn-primary flex items-center gap-2 text-sm disabled:opacity-40"><CheckCircle className="w-4 h-4" /> Publicar examen</button>
            </div>
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
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\formador\grades\page.tsx", $formGrades, [System.Text.Encoding]::UTF8)
Write-Host "Formador grades 3 columnas OK" -ForegroundColor Green

# ── 8. ENCODING: reemplazar em-dash en archivos existentes ────
$files = @(
  "frontend\src\app\(dashboard)\formador\courses\page.tsx",
  "frontend\src\app\(dashboard)\formador\attendance\page.tsx",
  "frontend\src\app\(dashboard)\formador\page.tsx",
  "frontend\src\app\(student)\courses\[id]\page.tsx",
  "frontend\src\app\(student)\lobby\page.tsx"
)
foreach ($fp in $files) {
  if (Test-Path "$PWD\$fp") {
    $bytes = [System.IO.File]::ReadAllBytes("$PWD\$fp")
    $text = [System.Text.Encoding]::UTF8.GetString($bytes)
    $text = $text.Replace([char]8212, "-").Replace([char]8211, "-")
    [System.IO.File]::WriteAllText("$PWD\$fp", $text, [System.Text.Encoding]::UTF8)
    Write-Host "  Encoding OK: $fp" -ForegroundColor Gray
  }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "V8 COMPLETO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Ejecuta:" -ForegroundColor Cyan
Write-Host "  docker-compose down" -ForegroundColor White
Write-Host "  docker-compose up --build" -ForegroundColor White
