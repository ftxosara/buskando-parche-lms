Write-Host "=== CORRECCION V5 LIMPIA ===" -ForegroundColor Yellow

# ── SEED corregido ────────────────────────────────────────────
$seedContent = 'const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcryptjs");
const prisma = new PrismaClient();
const CURSOS = [
  { title: "Ingles", description: "Comunicacion en ingles para turismo.", modality: "VIRTUAL", totalSessions: 20 },
  { title: "Gestion Empresarial", description: "Planeacion y finanzas para MiPymes.", modality: "PRESENCIAL", totalSessions: 20 },
  { title: "Gestion Turistica", description: "Herramientas para prestadores turisticos.", modality: "PRESENCIAL", totalSessions: 20 },
  { title: "Marketing Digital", description: "Redes sociales y SEO para tu negocio.", modality: "VIRTUAL", totalSessions: 20 },
];
const FORMADORES = [
  { firstName:"Maria", lastName:"Ramirez Solano", cedula:"9000000001", email:"formador01@buskandoparche.com" },
  { firstName:"Carlos", lastName:"Perez Estrada", cedula:"9000000002", email:"formador02@buskandoparche.com" },
  { firstName:"Andrea", lastName:"Nieto Salazar", cedula:"9000000003", email:"formador03@buskandoparche.com" },
  { firstName:"Roberto", lastName:"Lagos Cifuentes", cedula:"9000000004", email:"formador04@buskandoparche.com" },
];
const BENS = [
  {fn:"Laura",ln:"Rodriguez Pena",c:"1020301001",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"Carlos",ln:"Martinez Lopez",c:"1020301002",g:"MASCULINO",p:"MIPYME"},{fn:"Ana Maria",ln:"Gomez Herrera",c:"1020301003",g:"FEMENINO",p:"PRESTADOR_TURISTICO"},{fn:"Jhon",ln:"Vargas Castro",c:"1020301004",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Sandra",ln:"Torres Morales",c:"1020301005",g:"FEMENINO",p:"VICTIMA_CONFLICTO"},{fn:"Miguel",ln:"Diaz Ortega",c:"1020301006",g:"MASCULINO",p:"MIPYME"},{fn:"Valentina",ln:"Ruiz Jimenez",c:"1020301007",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"David",ln:"Sanchez Ramos",c:"1020301008",g:"MASCULINO",p:"PRESTADOR_TURISTICO"},{fn:"Paola",ln:"Romero Quintero",c:"1020301009",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"Andres",ln:"Cardenas Vega",c:"1020301010",g:"MASCULINO",p:"MIPYME"},{fn:"Natalia",ln:"Mora Suarez",c:"1020301011",g:"FEMENINO",p:"AFRODESCENDIENTE"},{fn:"Sebastian",ln:"Parra Mendez",c:"1020301012",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Camila",ln:"Rios Guerrero",c:"1020301013",g:"FEMENINO",p:"PRESTADOR_TURISTICO"},{fn:"Fernando",ln:"Munoz Salcedo",c:"1020301014",g:"MASCULINO",p:"VICTIMA_CONFLICTO"},{fn:"Marcela",ln:"Pedraza Luna",c:"1020301015",g:"FEMENINO",p:"MIPYME"},{fn:"Ricardo",ln:"Alvarado Nino",c:"1020301016",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Diana",ln:"Ospina Cardona",c:"1020301017",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"Julian",ln:"Bermudez Acosta",c:"1020301018",g:"MASCULINO",p:"PRESTADOR_TURISTICO"},{fn:"Luisa",ln:"Caballero Toro",c:"1020301019",g:"FEMENINO",p:"AFRODESCENDIENTE"},{fn:"Esteban",ln:"Giraldo Reyes",c:"1020301020",g:"MASCULINO",p:"MIPYME"},
  {fn:"Daniela",ln:"Serrano Pinto",c:"1020301021",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"Mauricio",ln:"Estrada Vidal",c:"1020301022",g:"MASCULINO",p:"VICTIMA_CONFLICTO"},{fn:"Adriana",ln:"Monsalve Cruz",c:"1020301023",g:"FEMENINO",p:"PRESTADOR_TURISTICO"},{fn:"Alejandro",ln:"Velasquez Duarte",c:"1020301024",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Gloria",ln:"Zapata Figueroa",c:"1020301025",g:"FEMENINO",p:"MIPYME"},{fn:"Hernando",ln:"Cortes Bernal",c:"1020301026",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Lina",ln:"Medina Vargas",c:"1020301027",g:"FEMENINO",p:"AFRODESCENDIENTE"},{fn:"Oscar",ln:"Navarro Palomino",c:"1020301028",g:"MASCULINO",p:"PRESTADOR_TURISTICO"},{fn:"Veronica",ln:"Agudelo Soto",c:"1020301029",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"Ivan",ln:"Gutierrez Triana",c:"1020301030",g:"MASCULINO",p:"MIPYME"},{fn:"Carolina",ln:"Londono Arias",c:"1020301031",g:"FEMENINO",p:"VICTIMA_CONFLICTO"},{fn:"Felipe",ln:"Arbelaez Mejia",c:"1020301032",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Marisol",ln:"Pineda Blanco",c:"1020301033",g:"FEMENINO",p:"PRESTADOR_TURISTICO"},{fn:"Gustavo",ln:"Montoya Espinosa",c:"1020301034",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Tatiana",ln:"Florez Holguin",c:"1020301035",g:"FEMENINO",p:"MIPYME"},{fn:"Nicolas",ln:"Salazar Quintana",c:"1020301036",g:"MASCULINO",p:"AFRODESCENDIENTE"},{fn:"Eliana",ln:"Cifuentes Roa",c:"1020301037",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"Rodrigo",ln:"Pulido Barrera",c:"1020301038",g:"MASCULINO",p:"PRESTADOR_TURISTICO"},{fn:"Yuliana",ln:"Cano Herrera",c:"1020301039",g:"FEMENINO",p:"VICTIMA_CONFLICTO"},{fn:"Pablo",ln:"Mejia Arango",c:"1020301040",g:"MASCULINO",p:"MIPYME"},
  {fn:"Claudia",ln:"Velez Ochoa",c:"1020301041",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"Alvaro",ln:"Sepulveda Jaramillo",c:"1020301042",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Bibiana",ln:"Ossa Gallego",c:"1020301043",g:"FEMENINO",p:"AFRODESCENDIENTE"},{fn:"German",ln:"Tobon Uribe",c:"1020301044",g:"MASCULINO",p:"PRESTADOR_TURISTICO"},{fn:"Ximena",ln:"Bedoya Patino",c:"1020301045",g:"FEMENINO",p:"MIPYME"},{fn:"Luis",ln:"Echavarria Posada",c:"1020301046",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Martha",ln:"Arroyave Castano",c:"1020301047",g:"FEMENINO",p:"VICTIMA_CONFLICTO"},{fn:"Joaquin",ln:"Restrepo Munoz",c:"1020301048",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Pilar",ln:"Alzate Giraldo",c:"1020301049",g:"FEMENINO",p:"PRESTADOR_TURISTICO"},{fn:"Hernan",ln:"Cardenas Osorio",c:"1020301050",g:"MASCULINO",p:"MIPYME"},{fn:"Alejandra",ln:"Duque Moreno",c:"1020301051",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"Javier",ln:"Marulanda Rios",c:"1020301052",g:"MASCULINO",p:"AFRODESCENDIENTE"},{fn:"Sofia",ln:"Henao Castillo",c:"1020301053",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"Harold",ln:"Castano Ramirez",c:"1020301054",g:"MASCULINO",p:"PRESTADOR_TURISTICO"},{fn:"Nathalia",ln:"Lopera Vargas",c:"1020301055",g:"FEMENINO",p:"MIPYME"},{fn:"Wilmer",ln:"Aguilar Serna",c:"1020301056",g:"MASCULINO",p:"VICTIMA_CONFLICTO"},{fn:"Leidy",ln:"Aristizabal Gomez",c:"1020301057",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"Cesar",ln:"Cardona Betancur",c:"1020301058",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Aura",ln:"Rendon Acevedo",c:"1020301059",g:"FEMENINO",p:"AFRODESCENDIENTE"},{fn:"Yesid",ln:"Quiroz Palomino",c:"1020301060",g:"MASCULINO",p:"MIPYME"},
  {fn:"Milena",ln:"Urrego Zapata",c:"1020301061",g:"FEMENINO",p:"PRESTADOR_TURISTICO"},{fn:"Edgar",ln:"Hincapie Santamaria",c:"1020301062",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Lorena",ln:"Zuluaga Montes",c:"1020301063",g:"FEMENINO",p:"VICTIMA_CONFLICTO"},{fn:"Wilfredo",ln:"Osorio Correa",c:"1020301064",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Ines",ln:"Gallego Parra",c:"1020301065",g:"FEMENINO",p:"MIPYME"},{fn:"Raul",ln:"Mosquera Lozano",c:"1020301066",g:"MASCULINO",p:"PRESTADOR_TURISTICO"},{fn:"Esperanza",ln:"Moncada Vergara",c:"1020301067",g:"FEMENINO",p:"AFRODESCENDIENTE"},{fn:"Victor",ln:"Salcedo Ortiz",c:"1020301068",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Nubia",ln:"Garzon Ramirez",c:"1020301069",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"Armando",ln:"Tovar Medina",c:"1020301070",g:"MASCULINO",p:"VICTIMA_CONFLICTO"},{fn:"Helena",ln:"Prieto Suarez",c:"1020301071",g:"FEMENINO",p:"MIPYME"},{fn:"Eliseo",ln:"Vargas Herrera",c:"1020301072",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Rocio",ln:"Pena Castaneda",c:"1020301073",g:"FEMENINO",p:"PRESTADOR_TURISTICO"},{fn:"Camilo",ln:"Angel Soto",c:"1020301074",g:"MASCULINO",p:"AFRODESCENDIENTE"},{fn:"Gladys",ln:"Reyes Murillo",c:"1020301075",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"Fredy",ln:"Naranjo Cano",c:"1020301076",g:"MASCULINO",p:"MIPYME"},{fn:"Patricia",ln:"Caicedo Leal",c:"1020301077",g:"FEMENINO",p:"VICTIMA_CONFLICTO"},{fn:"Dario",ln:"Ballen Pachon",c:"1020301078",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Amparo",ln:"Triana Buitrago",c:"1020301079",g:"FEMENINO",p:"PRESTADOR_TURISTICO"},{fn:"Nestor",ln:"Quintero Fierro",c:"1020301080",g:"MASCULINO",p:"EMPRENDEDOR"},
];
async function main() {
  console.log("Seed v5...");
  const titulos = CURSOS.map(c => c.title);
  const extra = await prisma.course.findMany({ where: { title: { notIn: titulos } } });
  for (const c of extra) {
    await prisma.session.deleteMany({ where: { courseId: c.id } });
    await prisma.enrollment.deleteMany({ where: { courseId: c.id } });
    await prisma.course.delete({ where: { id: c.id } });
  }
  await prisma.user.upsert({ where: { email: "admin@buskandoparche.com" }, update: {}, create: { email: "admin@buskandoparche.com", passwordHash: await bcrypt.hash("Admin2024!", 12), role: "ADMIN", firstName: "Admin", lastName: "Sistema", cedula: "8000000001" } });
  const fUsers = [];
  for (let i = 0; i < FORMADORES.length; i++) {
    const f = FORMADORES[i];
    const u = await prisma.user.upsert({ where: { email: f.email }, update: {}, create: { email: f.email, passwordHash: await bcrypt.hash("Formador2024!", 12), role: "FORMADOR", firstName: f.firstName, lastName: f.lastName, cedula: f.cedula } });
    fUsers.push(u);
  }
  const cursos = [];
  for (let i = 0; i < CURSOS.length; i++) {
    const c = CURSOS[i];
    const ex = await prisma.course.findFirst({ where: { title: c.title } });
    const course = ex ? await prisma.course.update({ where: { id: ex.id }, data: { ...c, isPublished: true, formadorId: fUsers[i].id } }) : await prisma.course.create({ data: { ...c, isPublished: true, formadorId: fUsers[i].id } });
    cursos.push(course);
    for (let s = 1; s <= 20; s++) {
      await prisma.session.upsert({ where: { courseId_order: { courseId: course.id, order: s } }, update: {}, create: { courseId: course.id, title: "Sesion " + s, description: "Contenido sesion " + s, order: s } });
    }
  }
  const hashB = await bcrypt.hash("BuskandoParche2024!", 12);
  for (let i = 0; i < BENS.length; i++) {
    const b = BENS[i]; const num = String(i + 1).padStart(3, "0");
    const email = "beneficiario" + num + "@buskandoparche.com";
    const u = await prisma.user.upsert({ where: { email }, update: {}, create: { email, passwordHash: hashB, role: "BENEFICIARIO", firstName: b.fn, lastName: b.ln, cedula: b.c, gender: b.g, populationGroup: b.p, locality: "Kennedy" } });
    const ci = Math.floor(i / 20);
    if (ci < cursos.length) { await prisma.enrollment.upsert({ where: { userId_courseId: { userId: u.id, courseId: cursos[ci].id } }, update: {}, create: { userId: u.id, courseId: cursos[ci].id, status: "ACTIVO" } }); }
  }
  console.log("SEED OK: Ingles | Gestion Empresarial | Gestion Turistica | Marketing Digital");
  console.log("admin@buskandoparche.com / Admin2024!");
  console.log("formador01-04@buskandoparche.com / Formador2024!");
  console.log("beneficiario001-080@buskandoparche.com / BuskandoParche2024!");
}
main().catch(e => { console.error(e); process.exit(1); }).finally(() => prisma.$disconnect());
'
[System.IO.File]::WriteAllText("$PWD\backend\prisma\seed.js", $seedContent, [System.Text.Encoding]::UTF8)
Write-Host "seed.js OK" -ForegroundColor Green

# ── next.config limpio ────────────────────────────────────────
$nc = 'module.exports = { images: { domains: ["localhost"] } };'
[System.IO.File]::WriteAllText("$PWD\frontend\next.config.js", $nc, [System.Text.Encoding]::UTF8)
Write-Host "next.config.js OK" -ForegroundColor Green

# ── LOGIN con notificaciones ──────────────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\login" | Out-Null
$loginContent = '"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/contexts/AuthContext";
import toast from "react-hot-toast";
import { Lock, Mail, Loader2, CheckCircle, AlertCircle } from "lucide-react";
export default function LoginPage() {
  const { login } = useAuth(); const router = useRouter();
  const [email, setEmail] = useState(""); const [password, setPassword] = useState(""); const [loading, setLoading] = useState(false);
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault(); setLoading(true);
    try {
      await login(email, password);
      const payload = JSON.parse(atob(localStorage.getItem("bp_token")!.split(".")[1]));
      toast.custom((t) => (
        <div className={"flex items-center gap-3 bg-white border border-green-200 rounded-2xl shadow-xl px-5 py-4 " + (t.visible ? "animate-slide-up" : "opacity-0")}>
          <div className="bg-green-100 p-2 rounded-full"><CheckCircle className="w-5 h-5 text-green-600" /></div>
          <div><p className="font-semibold text-text-primary text-sm">Ingreso exitoso</p><p className="text-text-muted text-xs">Bienvenido a Buskando Parche</p></div>
        </div>
      ), { duration: 2000 });
      setTimeout(() => {
        if (payload.role === "ADMIN") router.push("/admin");
        else if (payload.role === "FORMADOR") router.push("/formador");
        else router.push("/lobby");
      }, 800);
    } catch {
      toast.custom((t) => (
        <div className={"flex items-center gap-3 bg-white border border-red-200 rounded-2xl shadow-xl px-5 py-4 " + (t.visible ? "animate-slide-up" : "opacity-0")}>
          <div className="bg-red-100 p-2 rounded-full"><AlertCircle className="w-5 h-5 text-red-600" /></div>
          <div><p className="font-semibold text-text-primary text-sm">Credenciales incorrectas</p><p className="text-text-muted text-xs">Verifica tu email y contrasena</p></div>
        </div>
      ), { duration: 4000 });
    } finally { setLoading(false); }
  };
  return (
    <div className="min-h-screen flex items-center justify-center relative overflow-hidden">
      <video autoPlay muted loop playsInline className="absolute inset-0 w-full h-full object-cover z-0">
        <source src="/videos/kennedy.mp4" type="video/mp4" />
      </video>
      <div className="absolute inset-0 bg-black/60 z-10" />
      <div className="relative z-20 w-full max-w-md px-6 animate-slide-up">
        <div className="flex flex-col items-center mb-8">
          <div className="bg-white rounded-2xl p-4 shadow-2xl mb-4">
            <img src="/images/logo.png" alt="Buskando Parche" className="h-20 w-auto object-contain" onError={(e) => { (e.target as HTMLImageElement).style.display = "none"; }} />
          </div>
          <h1 className="font-display text-3xl font-bold text-white text-center">Buskando <span className="text-secondary">Parche</span></h1>
          <p className="text-white/80 text-sm mt-1 text-center">Plataforma de Formacion - Kennedy, Bogota</p>
        </div>
        <div className="bg-white rounded-2xl shadow-2xl p-8">
          <h2 className="text-xl font-bold text-text-primary mb-1">Iniciar sesion</h2>
          <p className="text-text-muted text-sm mb-6">Ingresa con tus credenciales asignadas</p>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-text-secondary mb-1.5">Correo electronico</label>
              <div className="relative"><Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input type="email" className="input pl-10" placeholder="tu@correo.com" value={email} onChange={(e) => setEmail(e.target.value)} required />
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-text-secondary mb-1.5">Contrasena</label>
              <div className="relative"><Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input type="password" className="input pl-10" placeholder="..." value={password} onChange={(e) => setPassword(e.target.value)} required />
              </div>
            </div>
            <button type="submit" disabled={loading} className="btn-primary w-full flex items-center justify-center gap-2 mt-2">
              {loading && <Loader2 className="w-5 h-5 animate-spin" />}
              {loading ? "Verificando..." : "Ingresar a la plataforma"}
            </button>
          </form>
          <p className="text-center text-text-muted text-xs mt-4">Problemas? Contacta al coordinador.</p>
        </div>
        <div className="flex items-center justify-center gap-6 mt-6">
          <img src="/images/logo-kennedy.png" alt="Kennedy" className="h-8 w-auto opacity-70" onError={(e) => { (e.target as HTMLImageElement).style.display = "none"; }} />
          <img src="/images/logo-bogota.png" alt="Bogota" className="h-8 w-auto opacity-70" onError={(e) => { (e.target as HTMLImageElement).style.display = "none"; }} />
        </div>
      </div>
    </div>
  );
}'
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\login\page.tsx", $loginContent, [System.Text.Encoding]::UTF8)
Write-Host "Login con notificaciones OK" -ForegroundColor Green

# ── SIDEBAR con rutas directas para formador ─────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\components\layout" | Out-Null
$sidebarContent = '"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useAuth } from "@/contexts/AuthContext";
import { LayoutDashboard, BookOpen, Users, ClipboardList, MessageSquare, Award, LogOut, ChevronRight, BarChart3, GraduationCap, Star } from "lucide-react";
import { useEffect, useState } from "react";
import clsx from "clsx";
import api from "@/lib/api";
export default function Sidebar() {
  const { user, logout } = useAuth();
  const pathname = usePathname();
  const [myCourseId, setMyCourseId] = useState<string | null>(null);
  useEffect(() => {
    if (user?.role === "FORMADOR") {
      api.get("/courses/lobby").then(({ data }) => {
        const mine = data.find((c: any) => c.isMyCourseFomador);
        if (mine) setMyCourseId(mine.id);
      }).catch(() => {});
    }
  }, [user]);
  const cid = myCourseId || "";
  const navAdmin = [
    { href: "/admin", icon: LayoutDashboard, label: "Dashboard" },
    { href: "/admin/users", icon: Users, label: "Usuarios" },
    { href: "/admin/courses", icon: BookOpen, label: "Cursos" },
    { href: "/admin/reports", icon: BarChart3, label: "Reportes" },
  ];
  const navFormador = [
    { href: "/formador", icon: LayoutDashboard, label: "Panel" },
    { href: cid ? "/formador/courses?id=" + cid : "/formador/courses", icon: BookOpen, label: "Mis Cursos" },
    { href: cid ? "/formador/attendance?courseId=" + cid : "/formador/attendance", icon: ClipboardList, label: "Asistencia" },
    { href: cid ? "/formador/grades?courseId=" + cid : "/formador/grades", icon: Star, label: "Calificaciones" },
  ];
  const navBeneficiario = [
    { href: "/lobby", icon: BookOpen, label: "Mis Cursos" },
    { href: "/lobby/forum", icon: MessageSquare, label: "Foro" },
    { href: "/lobby/certificates", icon: GraduationCap, label: "Certificados" },
  ];
  const nav = user?.role === "ADMIN" ? navAdmin : user?.role === "FORMADOR" ? navFormador : navBeneficiario;
  const isActive = (href: string) => { const base = href.split("?")[0]; return pathname === base || pathname.startsWith(base + "/"); };
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
            <Link key={label} href={href} className={clsx("flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all duration-200 group", active ? "bg-red-50 text-primary border border-red-100" : "text-text-secondary hover:bg-gray-50 hover:text-primary")}>
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
Write-Host "Sidebar con rutas directas OK" -ForegroundColor Green

# ── ADMIN DASHBOARD sin caracteres especiales ─────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\admin" | Out-Null
$adminContent = '"use client";
import { useEffect, useState } from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { Users, BookOpen, TrendingUp, Heart, Loader2, AlertTriangle, CheckCircle, Award } from "lucide-react";
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, Cell, PieChart, Pie, CartesianGrid, ReferenceLine, Legend } from "recharts";
function KpiCard({ label, value, icon: Icon, color, subtitle, tooltip }: any) {
  const [show, setShow] = useState(false);
  const c: any = { red: "bg-red-50 text-red-600 border-red-200", yellow: "bg-yellow-50 text-yellow-600 border-yellow-200", green: "bg-green-50 text-green-600 border-green-200", blue: "bg-blue-50 text-blue-600 border-blue-200", purple: "bg-purple-50 text-purple-600 border-purple-200" };
  return (
    <div className="card flex items-start gap-4 relative cursor-help hover:shadow-lg transition-all duration-200 hover:-translate-y-0.5" onMouseEnter={() => setShow(true)} onMouseLeave={() => setShow(false)}>
      <div className={"p-3 rounded-xl border flex-shrink-0 " + c[color]}><Icon className="w-6 h-6" /></div>
      <div className="flex-1">
        <p className="text-text-muted text-sm">{label}</p>
        <p className="text-2xl font-bold font-display text-text-primary mt-0.5">{value}</p>
        {subtitle && <p className="text-text-muted text-xs mt-1">{subtitle}</p>}
      </div>
      {show && tooltip && (
        <div className="absolute bottom-full left-0 mb-2 w-64 bg-gray-900 text-white text-xs rounded-xl p-3 shadow-xl z-50 leading-relaxed">
          {tooltip}<div className="absolute top-full left-6 border-4 border-transparent border-t-gray-900" />
        </div>
      )}
    </div>
  );
}
const PC = ["#C0392B", "#2563EB", "#16A34A", "#D97706", "#7C3AED", "#EC4899", "#0891B2"];
export default function AdminDashboard() {
  const [data, setData] = useState<any>(null); const [loading, setLoading] = useState(true); const [error, setError] = useState("");
  useEffect(() => { api.get("/admin/dashboard").then(({ data }) => setData(data)).catch(() => setError("Error cargando dashboard")).finally(() => setLoading(false)); }, []);
  if (loading) return <AppShell allowedRoles={["ADMIN"]}><div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div></AppShell>;
  if (error) return <AppShell allowedRoles={["ADMIN"]}><div className="card bg-red-50 border-red-200 text-red-700 flex items-center gap-3"><AlertTriangle className="w-5 h-5" />{error}</div></AppShell>;
  const genderData = [{ name: "Mujeres", value: data?.kpis.mujeres, color: "#C0392B" }, { name: "Hombres", value: data?.kpis.hombres, color: "#2563EB" }];
  return (
    <AppShell allowedRoles={["ADMIN"]}>
      <div className="max-w-7xl mx-auto space-y-8">
        <div><h1 className="font-display text-3xl font-bold text-text-primary">Dashboard Administrativo</h1><p className="text-text-secondary mt-1">Pasa el mouse sobre las tarjetas para ver detalles</p></div>
        <div className="grid grid-cols-2 xl:grid-cols-4 gap-4">
          <KpiCard label="Total beneficiarios" value={data?.kpis.totalBeneficiarios} icon={Users} color="red" subtitle="de 80 cupos objetivo" tooltip={"80 beneficiarios objetivo. Actualmente: " + data?.kpis.totalBeneficiarios + " activos."} />
          <KpiCard label="% Asistencia global" value={data?.kpis.porcentajeAsistencia} icon={TrendingUp} color="green" subtitle="Todas las sesiones" tooltip="Porcentaje de asistencias PRESENTE sobre el total registrado." />
          <KpiCard label="Mujeres inscritas" value={data?.kpis.mujeres} icon={Heart} color="yellow" subtitle={data?.kpis.porcentajeMujeres + " - Meta: " + data?.kpis.metaMujeres} tooltip={"Meta: minimo 50% mujeres. Actualmente " + data?.kpis.porcentajeMujeres + ". Hombres: " + data?.kpis.hombres + "."} />
          <KpiCard label="Cursos completados" value={data?.kpis.completados} icon={Award} color="purple" subtitle={data?.kpis.porcentajeCompletados + " de finalizacion"} tooltip="Beneficiarios con curso completado y certificado habilitado." />
        </div>
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="card lg:col-span-2">
            <h3 className="font-bold text-text-primary mb-1">Inscripciones por curso - desglose por genero</h3>
            <p className="text-text-muted text-xs mb-4">Meta: minimo 50% mujeres por curso</p>
            <ResponsiveContainer width="100%" height={230}>
              <BarChart data={data?.courseKpis} barGap={4}>
                <XAxis dataKey="title" tick={{ fill: "#6B7280", fontSize: 10 }} tickLine={false} axisLine={false} />
                <YAxis tick={{ fill: "#6B7280", fontSize: 10 }} axisLine={false} tickLine={false} />
                <Tooltip contentStyle={{ background: "#fff", border: "1px solid #E5E7EB", borderRadius: 8 }} />
                <Legend wrapperStyle={{ fontSize: 11 }} />
                <Bar dataKey="mujeres" name="Mujeres" fill="#C0392B" radius={[4, 4, 0, 0]} maxBarSize={30} />
                <Bar dataKey="hombres" name="Hombres" fill="#2563EB" radius={[4, 4, 0, 0]} maxBarSize={30} />
              </BarChart>
            </ResponsiveContainer>
          </div>
          <div className="card">
            <h3 className="font-bold text-text-primary mb-1">Distribucion por genero</h3>
            <p className="text-text-muted text-xs mb-2">Total programa</p>
            <ResponsiveContainer width="100%" height={230}>
              <PieChart>
                <Pie data={genderData} dataKey="value" nameKey="name" cx="50%" cy="45%" innerRadius={55} outerRadius={85} label={({ name, percent }: any) => name + " " + (percent * 100).toFixed(0) + "%"} labelLine={false}>
                  {genderData.map((g, i) => <Cell key={i} fill={g.color} />)}
                </Pie>
                <Tooltip formatter={(v: any, n: any) => [v + " personas", n]} />
              </PieChart>
            </ResponsiveContainer>
            <div className="flex justify-center gap-4 mt-2 text-xs">
              <span className="flex items-center gap-1"><span className="w-3 h-3 rounded-full bg-primary inline-block" /> Mujeres: {data?.kpis.mujeres}</span>
              <span className="flex items-center gap-1"><span className="w-3 h-3 rounded-full bg-blue-600 inline-block" /> Hombres: {data?.kpis.hombres}</span>
            </div>
          </div>
        </div>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="card">
            <h3 className="font-bold text-text-primary mb-1">Meta de genero por curso</h3>
            <p className="text-text-muted text-xs mb-4">Verde = cumplida (>=50%), Rojo = en riesgo</p>
            <ResponsiveContainer width="100%" height={200}>
              <BarChart data={data?.courseKpis} barSize={40}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" vertical={false} />
                <XAxis dataKey="title" tick={{ fill: "#6B7280", fontSize: 10 }} tickLine={false} axisLine={false} />
                <YAxis domain={[0, 100]} tick={{ fill: "#6B7280", fontSize: 10 }} axisLine={false} tickLine={false} unit="%" />
                <Tooltip formatter={(v: any) => [v + "%", "Mujeres"]} />
                <ReferenceLine y={50} stroke="#C0392B" strokeDasharray="5 5" label={{ value: "Meta 50%", fill: "#C0392B", fontSize: 10 }} />
                <Bar dataKey="porcentajeMujeres" name="% Mujeres" radius={[6, 6, 0, 0]}>
                  {data?.courseKpis?.map((c: any, i: number) => <Cell key={i} fill={parseFloat(c.porcentajeMujeres) >= 50 ? "#16A34A" : "#C0392B"} />)}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>
          <div className="card">
            <h3 className="font-bold text-text-primary mb-3">Grupos poblacionales - enfoque diferencial</h3>
            <div className="space-y-2.5">
              {data?.populationBreakdown?.map((p: any, i: number) => (
                <div key={i} className="flex items-center gap-3">
                  <div className="w-3 h-3 rounded-full flex-shrink-0" style={{ background: PC[i % PC.length] }} />
                  <span className="text-sm text-text-secondary w-44 truncate">{p.grupo?.replace(/_/g, " ")}</span>
                  <div className="flex-1 bg-gray-100 rounded-full h-2"><div className="h-2 rounded-full" style={{ width: Math.min((p.cantidad / data.kpis.totalBeneficiarios) * 100, 100) + "%", background: PC[i % PC.length] }} /></div>
                  <span className="text-sm font-bold text-text-primary w-8 text-right">{p.cantidad}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
        <div className={"card flex items-start gap-4 " + (data?.kpis.metaMujeres === "Cumplida" ? "bg-green-50 border-green-200" : "bg-red-50 border-red-200")}>
          {data?.kpis.metaMujeres === "Cumplida" ? <CheckCircle className="w-6 h-6 text-green-600 mt-0.5 flex-shrink-0" /> : <AlertTriangle className="w-6 h-6 text-red-600 mt-0.5 flex-shrink-0" />}
          <div>
            <p className={"font-bold " + (data?.kpis.metaMujeres === "Cumplida" ? "text-green-800" : "text-red-800")}>Meta paridad de genero - {data?.kpis.metaMujeres}</p>
            <p className={"text-sm mt-1 " + (data?.kpis.metaMujeres === "Cumplida" ? "text-green-700" : "text-red-700")}>
              Contrato exige minimo 50% mujeres. Actualmente: {data?.kpis.mujeres} mujeres ({data?.kpis.porcentajeMujeres}) de {data?.kpis.totalBeneficiarios} inscritos.
            </p>
          </div>
        </div>
      </div>
    </AppShell>
  );
}'
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\admin\page.tsx", $adminContent, [System.Text.Encoding]::UTF8)
Write-Host "Admin dashboard sin caracteres especiales OK" -ForegroundColor Green

# ── FORMADOR panel sin caracteres especiales ──────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\formador" | Out-Null
$formadorContent = '"use client";
import { useEffect, useState } from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { BookOpen, ClipboardList, Lock, Star, Loader2 } from "lucide-react";
import Link from "next/link";
import { useAuth } from "@/contexts/AuthContext";
import clsx from "clsx";
export default function FormadorPanel() {
  const { user } = useAuth();
  const [courses, setCourses] = useState<any[]>([]); const [loading, setLoading] = useState(true);
  useEffect(() => { api.get("/courses/lobby").then(({ data }) => setCourses(data)).finally(() => setLoading(false)); }, []);
  const myCourse = courses.find((c: any) => c.isMyCourseFomador);
  const otherCourses = courses.filter((c: any) => !c.isMyCourseFomador);
  return (
    <AppShell allowedRoles={["FORMADOR"]}>
      <div className="max-w-4xl mx-auto space-y-8">
        <div><h1 className="font-display text-3xl font-bold text-text-primary">Bienvenido, {user?.firstName}</h1><p className="text-text-secondary mt-1">Panel del formador - gestiona tu curso asignado.</p></div>
        {loading ? <div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div> : (
          <>
            {myCourse && (
              <div>
                <div className="flex items-center gap-2 mb-4"><div className="w-1 h-6 bg-primary rounded-full" /><h2 className="text-lg font-bold text-text-primary">Mi curso asignado</h2></div>
                <div className="card border-l-4 border-l-primary">
                  <div className="flex items-start gap-4 mb-4">
                    <div className="p-3 bg-red-50 rounded-xl"><BookOpen className="w-7 h-7 text-primary" /></div>
                    <div><h3 className="font-bold text-xl text-text-primary">{myCourse.title}</h3><p className="text-text-muted text-sm mt-1">{myCourse.modality === "VIRTUAL" ? "Virtual" : "Presencial"} - {myCourse.totalSessions} sesiones - {myCourse.totalEnrolled} estudiantes</p></div>
                  </div>
                  <div className="grid grid-cols-3 gap-3">
                    <Link href={"/formador/courses?id=" + myCourse.id} className="btn-primary flex items-center justify-center gap-2 py-2.5 text-sm"><BookOpen className="w-4 h-4" /> Contenido</Link>
                    <Link href={"/formador/attendance?courseId=" + myCourse.id} className="btn-outline flex items-center justify-center gap-2 py-2.5 text-sm"><ClipboardList className="w-4 h-4" /> Asistencia</Link>
                    <Link href={"/formador/grades?courseId=" + myCourse.id} className="btn-ghost flex items-center justify-center gap-2 py-2.5 text-sm border border-gray-200 rounded-lg"><Star className="w-4 h-4" /> Calificaciones</Link>
                  </div>
                </div>
              </div>
            )}
            {!myCourse && <div className="card text-center py-12"><BookOpen className="w-12 h-12 text-gray-300 mx-auto mb-3" /><p className="text-text-muted">No tienes un curso asignado. Contacta al administrador.</p></div>}
            {otherCourses.length > 0 && (
              <div>
                <div className="flex items-center gap-2 mb-4"><div className="w-1 h-6 bg-gray-300 rounded-full" /><h2 className="text-lg font-bold text-text-primary">Otros cursos</h2><span className="badge-muted">{otherCourses.length} bloqueados</span></div>
                <div className="grid md:grid-cols-3 gap-4">
                  {otherCourses.map((c: any) => (
                    <div key={c.id} className="card opacity-50 cursor-not-allowed relative overflow-hidden">
                      <div className="absolute inset-0 flex items-center justify-center bg-gray-50/80"><div className="flex flex-col items-center gap-2"><Lock className="w-8 h-8 text-gray-400" /><p className="text-xs text-gray-500 font-medium">Acceso restringido</p></div></div>
                      <div className="p-3 bg-gray-100 rounded-xl w-fit mb-3"><BookOpen className="w-5 h-5 text-gray-400" /></div>
                      <h3 className="font-semibold text-gray-400">{c.title}</h3>
                      <p className="text-xs text-gray-400 mt-1">{c.formador}</p>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </>
        )}
      </div>
    </AppShell>
  );
}'
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\formador\page.tsx", $formadorContent, [System.Text.Encoding]::UTF8)
Write-Host "Formador panel OK" -ForegroundColor Green

Write-Host ""
Write-Host "========================================================" -ForegroundColor Yellow
Write-Host "CORRECCION V5 COMPLETA - SIN ERRORES DE ENCODING" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Ahora ejecuta:" -ForegroundColor Cyan
Write-Host "  docker-compose down -v" -ForegroundColor White
Write-Host "  docker-compose up --build" -ForegroundColor White
