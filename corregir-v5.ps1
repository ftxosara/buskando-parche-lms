# ================================================================
# CORRECCION V5 - Encoding, cursos, certificado, formador, login
# ================================================================
Write-Host "=== CORRECCION V5 ===" -ForegroundColor Yellow

# ── 1. SEED: 4 cursos con nombres CORTOS correctos ────────────
$seed = @'
const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcryptjs");
const prisma = new PrismaClient();
const CURSOS = [
  { title: "Ingles",               description: "Comunicacion en ingles para atencion de turistas internacionales.", modality: "VIRTUAL",    totalSessions: 20 },
  { title: "Gestion Empresarial",  description: "Planeacion, finanzas basicas y estructura para MiPymes.", modality: "PRESENCIAL", totalSessions: 20 },
  { title: "Gestion Turistica",    description: "Herramientas de gestion para prestadores turisticos de Kennedy.", modality: "PRESENCIAL", totalSessions: 20 },
  { title: "Marketing Digital",    description: "Posiciona tu negocio en redes sociales, SEO y campanas digitales.", modality: "VIRTUAL",    totalSessions: 20 },
];
const FORMADORES = [
  { firstName:"Maria",   lastName:"Ramirez Solano",  cedula:"9000000001", email:"formador01@buskandoparche.com" },
  { firstName:"Carlos",  lastName:"Perez Estrada",   cedula:"9000000002", email:"formador02@buskandoparche.com" },
  { firstName:"Andrea",  lastName:"Nieto Salazar",   cedula:"9000000003", email:"formador03@buskandoparche.com" },
  { firstName:"Roberto", lastName:"Lagos Cifuentes", cedula:"9000000004", email:"formador04@buskandoparche.com" },
];
const BENS = [
  {fn:"Laura",fn2:"Rodriguez Pena",c:"1020301001",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"Carlos",fn2:"Martinez Lopez",c:"1020301002",g:"MASCULINO",p:"MIPYME"},{fn:"Ana Maria",fn2:"Gomez Herrera",c:"1020301003",g:"FEMENINO",p:"PRESTADOR_TURISTICO"},{fn:"Jhon",fn2:"Vargas Castro",c:"1020301004",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Sandra",fn2:"Torres Morales",c:"1020301005",g:"FEMENINO",p:"VICTIMA_CONFLICTO"},{fn:"Miguel",fn2:"Diaz Ortega",c:"1020301006",g:"MASCULINO",p:"MIPYME"},{fn:"Valentina",fn2:"Ruiz Jimenez",c:"1020301007",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"David",fn2:"Sanchez Ramos",c:"1020301008",g:"MASCULINO",p:"PRESTADOR_TURISTICO"},{fn:"Paola",fn2:"Romero Quintero",c:"1020301009",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"Andres",fn2:"Cardenas Vega",c:"1020301010",g:"MASCULINO",p:"MIPYME"},{fn:"Natalia",fn2:"Mora Suarez",c:"1020301011",g:"FEMENINO",p:"AFRODESCENDIENTE"},{fn:"Sebastian",fn2:"Parra Mendez",c:"1020301012",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Camila",fn2:"Rios Guerrero",c:"1020301013",g:"FEMENINO",p:"PRESTADOR_TURISTICO"},{fn:"Fernando",fn2:"Munoz Salcedo",c:"1020301014",g:"MASCULINO",p:"VICTIMA_CONFLICTO"},{fn:"Marcela",fn2:"Pedraza Luna",c:"1020301015",g:"FEMENINO",p:"MIPYME"},{fn:"Ricardo",fn2:"Alvarado Nino",c:"1020301016",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Diana",fn2:"Ospina Cardona",c:"1020301017",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"Julian",fn2:"Bermudez Acosta",c:"1020301018",g:"MASCULINO",p:"PRESTADOR_TURISTICO"},{fn:"Luisa",fn2:"Caballero Toro",c:"1020301019",g:"FEMENINO",p:"AFRODESCENDIENTE"},{fn:"Esteban",fn2:"Giraldo Reyes",c:"1020301020",g:"MASCULINO",p:"MIPYME"},
  {fn:"Daniela",fn2:"Serrano Pinto",c:"1020301021",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"Mauricio",fn2:"Estrada Vidal",c:"1020301022",g:"MASCULINO",p:"VICTIMA_CONFLICTO"},{fn:"Adriana",fn2:"Monsalve Cruz",c:"1020301023",g:"FEMENINO",p:"PRESTADOR_TURISTICO"},{fn:"Alejandro",fn2:"Velasquez Duarte",c:"1020301024",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Gloria",fn2:"Zapata Figueroa",c:"1020301025",g:"FEMENINO",p:"MIPYME"},{fn:"Hernando",fn2:"Cortes Bernal",c:"1020301026",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Lina",fn2:"Medina Vargas",c:"1020301027",g:"FEMENINO",p:"AFRODESCENDIENTE"},{fn:"Oscar",fn2:"Navarro Palomino",c:"1020301028",g:"MASCULINO",p:"PRESTADOR_TURISTICO"},{fn:"Veronica",fn2:"Agudelo Soto",c:"1020301029",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"Ivan",fn2:"Gutierrez Triana",c:"1020301030",g:"MASCULINO",p:"MIPYME"},{fn:"Carolina",fn2:"Londono Arias",c:"1020301031",g:"FEMENINO",p:"VICTIMA_CONFLICTO"},{fn:"Felipe",fn2:"Arbelaez Mejia",c:"1020301032",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Marisol",fn2:"Pineda Blanco",c:"1020301033",g:"FEMENINO",p:"PRESTADOR_TURISTICO"},{fn:"Gustavo",fn2:"Montoya Espinosa",c:"1020301034",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Tatiana",fn2:"Florez Holguin",c:"1020301035",g:"FEMENINO",p:"MIPYME"},{fn:"Nicolas",fn2:"Salazar Quintana",c:"1020301036",g:"MASCULINO",p:"AFRODESCENDIENTE"},{fn:"Eliana",fn2:"Cifuentes Roa",c:"1020301037",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"Rodrigo",fn2:"Pulido Barrera",c:"1020301038",g:"MASCULINO",p:"PRESTADOR_TURISTICO"},{fn:"Yuliana",fn2:"Cano Herrera",c:"1020301039",g:"FEMENINO",p:"VICTIMA_CONFLICTO"},{fn:"Pablo",fn2:"Mejia Arango",c:"1020301040",g:"MASCULINO",p:"MIPYME"},
  {fn:"Claudia",fn2:"Velez Ochoa",c:"1020301041",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"Alvaro",fn2:"Sepulveda Jaramillo",c:"1020301042",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Bibiana",fn2:"Ossa Gallego",c:"1020301043",g:"FEMENINO",p:"AFRODESCENDIENTE"},{fn:"German",fn2:"Tobon Uribe",c:"1020301044",g:"MASCULINO",p:"PRESTADOR_TURISTICO"},{fn:"Ximena",fn2:"Bedoya Patino",c:"1020301045",g:"FEMENINO",p:"MIPYME"},{fn:"Luis",fn2:"Echavarria Posada",c:"1020301046",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Martha",fn2:"Arroyave Castano",c:"1020301047",g:"FEMENINO",p:"VICTIMA_CONFLICTO"},{fn:"Joaquin",fn2:"Restrepo Munoz",c:"1020301048",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Pilar",fn2:"Alzate Giraldo",c:"1020301049",g:"FEMENINO",p:"PRESTADOR_TURISTICO"},{fn:"Hernan",fn2:"Cardenas Osorio",c:"1020301050",g:"MASCULINO",p:"MIPYME"},{fn:"Alejandra",fn2:"Duque Moreno",c:"1020301051",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"Javier",fn2:"Marulanda Rios",c:"1020301052",g:"MASCULINO",p:"AFRODESCENDIENTE"},{fn:"Sofia",fn2:"Henao Castillo",c:"1020301053",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"Harold",fn2:"Castano Ramirez",c:"1020301054",g:"MASCULINO",p:"PRESTADOR_TURISTICO"},{fn:"Nathalia",fn2:"Lopera Vargas",c:"1020301055",g:"FEMENINO",p:"MIPYME"},{fn:"Wilmer",fn2:"Aguilar Serna",c:"1020301056",g:"MASCULINO",p:"VICTIMA_CONFLICTO"},{fn:"Leidy",fn2:"Aristizabal Gomez",c:"1020301057",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"Cesar",fn2:"Cardona Betancur",c:"1020301058",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Aura",fn2:"Rendon Acevedo",c:"1020301059",g:"FEMENINO",p:"AFRODESCENDIENTE"},{fn:"Yesid",fn2:"Quiroz Palomino",c:"1020301060",g:"MASCULINO",p:"MIPYME"},
  {fn:"Milena",fn2:"Urrego Zapata",c:"1020301061",g:"FEMENINO",p:"PRESTADOR_TURISTICO"},{fn:"Edgar",fn2:"Hincapie Santamaria",c:"1020301062",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Lorena",fn2:"Zuluaga Montes",c:"1020301063",g:"FEMENINO",p:"VICTIMA_CONFLICTO"},{fn:"Wilfredo",fn2:"Osorio Correa",c:"1020301064",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Ines",fn2:"Gallego Parra",c:"1020301065",g:"FEMENINO",p:"MIPYME"},{fn:"Raul",fn2:"Mosquera Lozano",c:"1020301066",g:"MASCULINO",p:"PRESTADOR_TURISTICO"},{fn:"Esperanza",fn2:"Moncada Vergara",c:"1020301067",g:"FEMENINO",p:"AFRODESCENDIENTE"},{fn:"Victor",fn2:"Salcedo Ortiz",c:"1020301068",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Nubia",fn2:"Garzon Ramirez",c:"1020301069",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"Armando",fn2:"Tovar Medina",c:"1020301070",g:"MASCULINO",p:"VICTIMA_CONFLICTO"},{fn:"Helena",fn2:"Prieto Suarez",c:"1020301071",g:"FEMENINO",p:"MIPYME"},{fn:"Eliseo",fn2:"Vargas Herrera",c:"1020301072",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Rocio",fn2:"Pena Castaneda",c:"1020301073",g:"FEMENINO",p:"PRESTADOR_TURISTICO"},{fn:"Camilo",fn2:"Angel Soto",c:"1020301074",g:"MASCULINO",p:"AFRODESCENDIENTE"},{fn:"Gladys",fn2:"Reyes Murillo",c:"1020301075",g:"FEMENINO",p:"EMPRENDEDOR"},{fn:"Fredy",fn2:"Naranjo Cano",c:"1020301076",g:"MASCULINO",p:"MIPYME"},{fn:"Patricia",fn2:"Caicedo Leal",c:"1020301077",g:"FEMENINO",p:"VICTIMA_CONFLICTO"},{fn:"Dario",fn2:"Ballen Pachon",c:"1020301078",g:"MASCULINO",p:"EMPRENDEDOR"},{fn:"Amparo",fn2:"Triana Buitrago",c:"1020301079",g:"FEMENINO",p:"PRESTADOR_TURISTICO"},{fn:"Nestor",fn2:"Quintero Fierro",c:"1020301080",g:"MASCULINO",p:"EMPRENDEDOR"},
];
async function main() {
  console.log("Seed v5: 4 cursos correctos...");
  const titulos = CURSOS.map(c=>c.title);
  const extra = await prisma.course.findMany({where:{title:{notIn:titulos}}});
  for(const c of extra){
    await prisma.session.deleteMany({where:{courseId:c.id}});
    await prisma.enrollment.deleteMany({where:{courseId:c.id}});
    await prisma.course.delete({where:{id:c.id}});
  }
  await prisma.user.upsert({where:{email:"admin@buskandoparche.com"},update:{},create:{email:"admin@buskandoparche.com",passwordHash:await bcrypt.hash("Admin2024!",12),role:"ADMIN",firstName:"Admin",lastName:"Sistema",cedula:"8000000001"}});
  const fUsers=[];
  for(let i=0;i<FORMADORES.length;i++){
    const f=FORMADORES[i];
    const u=await prisma.user.upsert({where:{email:f.email},update:{},create:{email:f.email,passwordHash:await bcrypt.hash("Formador2024!",12),role:"FORMADOR",firstName:f.firstName,lastName:f.lastName,cedula:f.cedula}});
    fUsers.push(u);
  }
  const cursos=[];
  for(let i=0;i<CURSOS.length;i++){
    const c=CURSOS[i];
    const ex=await prisma.course.findFirst({where:{title:c.title}});
    const course=ex?await prisma.course.update({where:{id:ex.id},data:{...c,isPublished:true,formadorId:fUsers[i].id}}):await prisma.course.create({data:{...c,isPublished:true,formadorId:fUsers[i].id}});
    cursos.push(course);
    for(let s=1;s<=20;s++){
      await prisma.session.upsert({where:{courseId_order:{courseId:course.id,order:s}},update:{},create:{courseId:course.id,title:"Sesion "+s,description:"Contenido sesion "+s,order:s}});
    }
  }
  const hashB=await bcrypt.hash("BuskandoParche2024!",12);
  for(let i=0;i<BENS.length;i++){
    const b=BENS[i]; const num=String(i+1).padStart(3,"0");
    const email="beneficiario"+num+"@buskandoparche.com";
    const u=await prisma.user.upsert({where:{email},update:{},create:{email,passwordHash:hashB,role:"BENEFICIARIO",firstName:b.fn,lastName:b.fn2,cedula:b.c,gender:b.g,populationGroup:b.p,locality:"Kennedy",upz:"Kennedy Central"}});
    const ci=Math.floor(i/20);
    if(ci<cursos.length){await prisma.enrollment.upsert({where:{userId_courseId:{userId:u.id,courseId:cursos[ci].id}},update:{},create:{userId:u.id,courseId:cursos[ci].id,status:"ACTIVO"}});}
  }
  console.log("SEED OK - Ingles | Gestion Empresarial | Gestion Turistica | Marketing Digital");
}
main().catch(e=>{console.error(e);process.exit(1);}).finally(()=>prisma.$disconnect());
'@
[System.IO.File]::WriteAllText("$PWD\backend\prisma\seed.js", $seed, [System.Text.Encoding]::UTF8)
Write-Host "seed.js OK - 4 cursos con nombres cortos" -ForegroundColor Green

# ── 2. LOGIN CON NOTIFICACIONES ───────────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\login" | Out-Null
$login = @'
"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/contexts/AuthContext";
import toast from "react-hot-toast";
import { Lock, Mail, Loader2, CheckCircle, AlertCircle } from "lucide-react";

export default function LoginPage() {
  const { login } = useAuth();
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      await login(email, password);
      const payload = JSON.parse(atob(localStorage.getItem("bp_token")!.split(".")[1]));
      toast.custom((t) => (
        <div className={`flex items-center gap-3 bg-white border border-green-200 rounded-2xl shadow-xl px-5 py-4 ${t.visible ? "animate-slide-up" : "opacity-0"}`}>
          <div className="bg-green-100 p-2 rounded-full"><CheckCircle className="w-5 h-5 text-green-600" /></div>
          <div>
            <p className="font-semibold text-text-primary text-sm">Ingreso exitoso</p>
            <p className="text-text-muted text-xs">Bienvenido a Buskando Parche</p>
          </div>
        </div>
      ), { duration: 2000 });
      setTimeout(() => {
        if (payload.role === "ADMIN") router.push("/admin");
        else if (payload.role === "FORMADOR") router.push("/formador");
        else router.push("/lobby");
      }, 800);
    } catch {
      toast.custom((t) => (
        <div className={`flex items-center gap-3 bg-white border border-red-200 rounded-2xl shadow-xl px-5 py-4 ${t.visible ? "animate-slide-up" : "opacity-0"}`}>
          <div className="bg-red-100 p-2 rounded-full"><AlertCircle className="w-5 h-5 text-red-600" /></div>
          <div>
            <p className="font-semibold text-text-primary text-sm">Credenciales incorrectas</p>
            <p className="text-text-muted text-xs">Verifica tu email y contrasena</p>
          </div>
        </div>
      ), { duration: 4000 });
    } finally {
      setLoading(false);
    }
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
            <img src="/images/logo.png" alt="Buskando Parche" className="h-20 w-auto object-contain"
              onError={(e) => { (e.target as HTMLImageElement).style.display = "none"; }} />
          </div>
          <h1 className="font-display text-3xl font-bold text-white text-center">
            Buskando <span className="text-secondary">Parche</span>
          </h1>
          <p className="text-white/80 text-sm mt-1 text-center">Plataforma de Formacion - Kennedy, Bogota</p>
        </div>
        <div className="bg-white rounded-2xl shadow-2xl p-8">
          <h2 className="text-xl font-bold text-text-primary mb-1">Iniciar sesion</h2>
          <p className="text-text-muted text-sm mb-6">Ingresa con tus credenciales asignadas</p>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-text-secondary mb-1.5">Correo electronico</label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input type="email" className="input pl-10" placeholder="tu@correo.com"
                  value={email} onChange={(e) => setEmail(e.target.value)} required />
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-text-secondary mb-1.5">Contrasena</label>
              <div className="relative">
                <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input type="password" className="input pl-10" placeholder="..." 
                  value={password} onChange={(e) => setPassword(e.target.value)} required />
              </div>
            </div>
            <button type="submit" disabled={loading}
              className="btn-primary w-full flex items-center justify-center gap-2 mt-2">
              {loading && <Loader2 className="w-5 h-5 animate-spin" />}
              {loading ? "Verificando..." : "Ingresar a la plataforma"}
            </button>
          </form>
          <p className="text-center text-text-muted text-xs mt-4">
            Problemas? Contacta al coordinador del programa.
          </p>
        </div>
        <div className="flex items-center justify-center gap-6 mt-6">
          <img src="/images/logo-kennedy.png" alt="Kennedy" className="h-8 w-auto opacity-70"
            onError={(e) => { (e.target as HTMLImageElement).style.display = "none"; }} />
          <img src="/images/logo-bogota.png" alt="Bogota" className="h-8 w-auto opacity-70"
            onError={(e) => { (e.target as HTMLImageElement).style.display = "none"; }} />
        </div>
      </div>
    </div>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\login\page.tsx", $login, [System.Text.Encoding]::UTF8)
Write-Host "Login con notificaciones OK" -ForegroundColor Green

# ── 3. SIDEBAR: formador con rutas directas ───────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\components\layout" | Out-Null
$sidebar = @'
"use client";
import Link from "next/link";
import { usePathname, useSearchParams } from "next/navigation";
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

  const navAdmin = [
    { href: "/admin",          icon: LayoutDashboard, label: "Dashboard" },
    { href: "/admin/users",    icon: Users,           label: "Usuarios" },
    { href: "/admin/courses",  icon: BookOpen,        label: "Cursos" },
    { href: "/admin/reports",  icon: BarChart3,       label: "Reportes" },
  ];

  const navFormador = [
    { href: "/formador",                                          icon: LayoutDashboard, label: "Panel" },
    { href: myCourseId ? "/formador/courses?id=" + myCourseId : "/formador/courses", icon: BookOpen, label: "Mis Cursos" },
    { href: myCourseId ? "/formador/attendance?courseId=" + myCourseId : "/formador/attendance", icon: ClipboardList, label: "Asistencia" },
    { href: myCourseId ? "/formador/grades?courseId=" + myCourseId : "/formador/grades", icon: Star, label: "Calificaciones" },
  ];

  const navBeneficiario = [
    { href: "/lobby",              icon: BookOpen,      label: "Mis Cursos" },
    { href: "/lobby/forum",        icon: MessageSquare, label: "Foro" },
    { href: "/lobby/certificates", icon: GraduationCap, label: "Certificados" },
  ];

  const nav = user?.role === "ADMIN" ? navAdmin : user?.role === "FORMADOR" ? navFormador : navBeneficiario;

  const isActive = (href: string) => {
    const base = href.split("?")[0];
    return pathname === base || pathname.startsWith(base + "/");
  };

  return (
    <aside className="w-64 min-h-screen bg-white border-r border-gray-200 flex flex-col shadow-sm">
      <div className="bg-gradient-brand p-5 flex items-center gap-3">
        <img src="/images/logo.png" alt="Logo" className="h-10 w-auto object-contain"
          onError={(e) => { (e.target as HTMLImageElement).style.display = "none"; }} />
        <div>
          <p className="font-display font-bold text-white text-sm">Buskando Parche</p>
          <p className="text-white/70 text-xs">LMS - Kennedy</p>
        </div>
      </div>

      <div className="p-4 border-b border-gray-100 bg-gray-50">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-gradient-brand rounded-full flex items-center justify-center font-bold text-white text-sm flex-shrink-0">
            {user?.firstName?.[0]}{user?.lastName?.[0]}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-semibold text-text-primary truncate">{user?.firstName} {user?.lastName}</p>
            <span className={clsx("badge text-xs mt-0.5", {
              "badge-primary": user?.role === "ADMIN",
              "badge-secondary": user?.role === "FORMADOR",
              "badge-muted": user?.role === "BENEFICIARIO",
            })}>
              {user?.role === "ADMIN" ? "Administrador" : user?.role === "FORMADOR" ? "Formador" : "Beneficiario"}
            </span>
          </div>
        </div>
      </div>

      <nav className="flex-1 p-4 space-y-1">
        {nav.map(({ href, icon: Icon, label }) => {
          const active = isActive(href);
          return (
            <Link key={label} href={href} className={clsx(
              "flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all duration-200 group",
              active ? "bg-red-50 text-primary border border-red-100" : "text-text-secondary hover:bg-gray-50 hover:text-primary"
            )}>
              <Icon className={clsx("w-5 h-5", active ? "text-primary" : "text-gray-400 group-hover:text-primary")} />
              {label}
              {active && <ChevronRight className="w-4 h-4 ml-auto text-primary" />}
            </Link>
          );
        })}
      </nav>

      <div className="p-4 border-t border-gray-100">
        <button onClick={logout} className="btn-ghost w-full flex items-center gap-3 text-sm text-gray-500">
          <LogOut className="w-5 h-5" /> Cerrar sesion
        </button>
      </div>
    </aside>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\frontend\src\components\layout\Sidebar.tsx", $sidebar, [System.Text.Encoding]::UTF8)
Write-Host "Sidebar con rutas directas para formador OK" -ForegroundColor Green

# ── 4. FORMADOR GRADES: calificacion estudiante por estudiante ─
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\formador\grades" | Out-Null
$grades = @'
"use client";
import { useEffect, useState, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { Loader2, CheckCircle, Star, Download, Plus, Trash2, Users, ChevronRight } from "lucide-react";
import clsx from "clsx";

type Student = { id: string; firstName: string; lastName: string; cedula: string; email: string };
type Session = { id: string; title: string; order: number };

function GradesContent() {
  const params = useSearchParams();
  const courseId = params.get("courseId");
  const [course, setCourse] = useState<any>(null);
  const [students, setStudents] = useState<Student[]>([]);
  const [selSession, setSelSession] = useState<Session | null>(null);
  const [selStudent, setSelStudent] = useState<Student | null>(null);
  const [submissions, setSubmissions] = useState<any[]>([]);
  const [grading, setGrading] = useState<{ score: string; feedback: string }>({ score: "", feedback: "" });
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [msg, setMsg] = useState("");
  const [showExam, setShowExam] = useState(false);
  const [examTitle, setExamTitle] = useState("");
  const [examPass, setExamPass] = useState("60");
  const [questions, setQuestions] = useState([{ text: "", options: ["", "", "", ""], correct: 0, points: 25 }]);
  const [tab, setTab] = useState<"calificar" | "examen">("calificar");

  useEffect(() => {
    if (!courseId) { setLoading(false); return; }
    Promise.all([
      api.get("/courses/" + courseId),
      api.get("/users", { params: { role: "BENEFICIARIO", limit: 100 } }),
    ]).then(([courseRes, usersRes]) => {
      setCourse(courseRes.data);
      const enrolled = usersRes.data.data.filter((u: any) => u.enrollments?.some((e: any) => e.courseId === courseId));
      setStudents(enrolled);
    }).finally(() => setLoading(false));
  }, [courseId]);

  const loadStudentGrades = async (session: Session, student: Student) => {
    setSelSession(session); setSelStudent(student); setMsg("");
    try {
      const { data } = await api.get("/assignments/grades/" + courseId + "?userId=" + student.id);
      const g = data.find((d: any) => d.id === session.id);
      setGrading({ score: g?.score?.toString() || "", feedback: g?.feedback || "" });
      const { data: subs } = await api.get("/assignments/session/" + session.id);
      setSubmissions(subs.filter((s: any) => s.userId === student.id));
    } catch (e) { console.error(e); }
  };

  const saveGrade = async () => {
    if (!selSession || !selStudent) return;
    setSaving(true);
    try {
      // Buscar submission existente o crear evaluacion temporal
      let sub = submissions[0];
      if (!sub) {
        // Crear evaluacion y submission
        const evRes = await api.post("/evaluations", { courseId, sessionId: selSession.id, title: "Calificacion manual", questions: [], passingScore: 60, maxScore: 100 });
        sub = await api.post("/assignments", JSON.stringify({ sessionId: selSession.id, courseId, textContent: "[Calificacion manual]", evaluationId: evRes.data.id, userId: selStudent.id }), { headers: { "Content-Type": "application/json" } }).then(r => r.data).catch(() => null);
      }
      if (sub) {
        await api.put("/assignments/" + sub.id + "/grade", { score: grading.score, feedback: grading.feedback });
        setMsg("Calificacion guardada para " + selStudent.firstName + " " + selStudent.lastName);
      }
    } catch (e) { setMsg("Error al guardar calificacion"); }
    finally { setSaving(false); }
  };

  const saveExam = async () => {
    if (!examTitle.trim() || !selSession) return;
    try {
      await api.post("/evaluations", { courseId, sessionId: selSession.id, title: examTitle, questions, passingScore: parseInt(examPass), maxScore: 100 });
      setMsg("Examen creado para " + selSession.title);
      setShowExam(false); setExamTitle(""); setExamPass("60");
      setQuestions([{ text: "", options: ["", "", "", ""], correct: 0, points: 25 }]);
    } catch { setMsg("Error al crear examen"); }
  };

  if (loading) return <div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div>;
  if (!courseId || !course) return <div className="card text-center py-12"><p className="text-text-muted">Accede desde el panel del formador.</p></div>;

  return (
    <div className="max-w-6xl mx-auto space-y-6">
      <div>
        <h1 className="font-display text-2xl font-bold text-text-primary">Calificaciones y Examenes</h1>
        <p className="text-text-secondary mt-1">{course?.title}</p>
      </div>
      {msg && <div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-xl text-sm flex items-center gap-2"><CheckCircle className="w-4 h-4" />{msg}</div>}

      {/* Tabs */}
      <div className="flex gap-2 border-b border-gray-200 pb-0">
        {(["calificar", "examen"] as const).map(t => (
          <button key={t} onClick={() => setTab(t)}
            className={clsx("px-5 py-2.5 text-sm font-semibold border-b-2 transition-colors -mb-px", tab === t ? "border-primary text-primary" : "border-transparent text-text-muted hover:text-text-primary")}>
            {t === "calificar" ? "Calificar estudiantes" : "Crear examen online"}
          </button>
        ))}
      </div>

      {tab === "calificar" && (
        <div className="grid md:grid-cols-4 gap-6">
          {/* Sesiones */}
          <div className="card p-0 overflow-hidden">
            <div className="p-3 bg-gray-50 border-b"><p className="font-semibold text-xs text-text-muted uppercase">Sesiones</p></div>
            <div className="divide-y divide-gray-50 max-h-[500px] overflow-y-auto">
              {course?.sessions?.map((s: any) => (
                <button key={s.id} onClick={() => { setSelSession(s); setSelStudent(null); setMsg(""); }}
                  className={clsx("w-full text-left px-3 py-2.5 text-sm transition-colors flex items-center gap-2",
                    selSession?.id === s.id ? "bg-red-50 text-primary font-semibold" : "hover:bg-gray-50 text-text-secondary")}>
                  <span className={clsx("w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0",
                    selSession?.id === s.id ? "bg-primary text-white" : "bg-gray-100 text-gray-600")}>{s.order}</span>
                  <span className="truncate">{s.title}</span>
                </button>
              ))}
            </div>
          </div>

          {/* Estudiantes */}
          <div className="card p-0 overflow-hidden">
            <div className="p-3 bg-gray-50 border-b"><p className="font-semibold text-xs text-text-muted uppercase">Estudiantes ({students.length})</p></div>
            <div className="divide-y divide-gray-50 max-h-[500px] overflow-y-auto">
              {!selSession ? (
                <p className="text-text-muted text-xs text-center py-6 px-3">Selecciona una sesion primero</p>
              ) : students.map(s => (
                <button key={s.id} onClick={() => loadStudentGrades(selSession, s)}
                  className={clsx("w-full text-left px-3 py-2.5 text-sm transition-colors flex items-center gap-2",
                    selStudent?.id === s.id ? "bg-red-50 text-primary font-semibold" : "hover:bg-gray-50 text-text-secondary")}>
                  <div className="w-7 h-7 bg-gradient-brand rounded-full flex items-center justify-center text-white text-xs font-bold flex-shrink-0">
                    {s.firstName[0]}
                  </div>
                  <div className="min-w-0">
                    <p className="truncate text-xs font-medium">{s.firstName} {s.lastName}</p>
                    <p className="text-xs text-text-muted">{s.cedula}</p>
                  </div>
                </button>
              ))}
            </div>
          </div>

          {/* Panel de calificacion */}
          <div className="md:col-span-2 space-y-4">
            {!selSession || !selStudent ? (
              <div className="card text-center py-12">
                <Star className="w-10 h-10 text-gray-300 mx-auto mb-3" />
                <p className="text-text-muted text-sm">Selecciona una sesion y un estudiante para calificar</p>
              </div>
            ) : (
              <div className="card space-y-4">
                <div className="flex items-center gap-3 pb-3 border-b border-gray-100">
                  <div className="w-10 h-10 bg-gradient-brand rounded-full flex items-center justify-center text-white font-bold">
                    {selStudent.firstName[0]}
                  </div>
                  <div>
                    <p className="font-bold text-text-primary">{selStudent.firstName} {selStudent.lastName}</p>
                    <p className="text-xs text-text-muted">{selStudent.cedula} - {selSession.title}</p>
                  </div>
                </div>

                {submissions.length > 0 && (
                  <div>
                    <p className="text-xs font-semibold text-text-muted uppercase mb-2">Entrega del estudiante</p>
                    {submissions[0]?.answers?.text && (
                      <div className="bg-gray-50 rounded-xl p-3 text-sm text-text-secondary">{submissions[0].answers.text}</div>
                    )}
                    {submissions[0]?.answers?.fileUrl && (
                      <a href={submissions[0].answers.fileUrl} target="_blank" rel="noopener noreferrer"
                        className="text-primary text-sm flex items-center gap-1 mt-2">
                        <Download className="w-4 h-4" /> Descargar archivo adjunto
                      </a>
                    )}
                    <p className="text-xs text-text-muted mt-2">Enviado: {new Date(submissions[0].submittedAt).toLocaleDateString("es-CO")}</p>
                  </div>
                )}

                {submissions.length === 0 && (
                  <div className="bg-yellow-50 rounded-xl p-3 text-sm text-yellow-700">Este estudiante no ha enviado actividad para esta sesion. Puedes asignar una nota de todas formas.</div>
                )}

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs font-semibold text-text-muted mb-1.5">Nota (0 - 100)</label>
                    <input type="number" min="0" max="100" className="input text-lg font-bold text-center"
                      placeholder="85" value={grading.score} onChange={e => setGrading(prev => ({ ...prev, score: e.target.value }))} />
                    {grading.score && (
                      <p className={clsx("text-xs mt-1 font-medium", parseFloat(grading.score) >= 60 ? "text-green-600" : "text-red-600")}>
                        {parseFloat(grading.score) >= 60 ? "Aprobado" : "Reprobado"} (minimo 60)
                      </p>
                    )}
                  </div>
                  <div>
                    <label className="block text-xs font-semibold text-text-muted mb-1.5">Retroalimentacion</label>
                    <textarea className="input text-sm resize-none" rows={3} placeholder="Comentario para el estudiante..."
                      value={grading.feedback} onChange={e => setGrading(prev => ({ ...prev, feedback: e.target.value }))} />
                  </div>
                </div>
                <button onClick={saveGrade} disabled={saving || !grading.score}
                  className="btn-primary w-full flex items-center justify-center gap-2 disabled:opacity-40">
                  {saving ? <Loader2 className="w-4 h-4 animate-spin" /> : <CheckCircle className="w-4 h-4" />}
                  {saving ? "Guardando..." : "Guardar calificacion"}
                </button>
              </div>
            )}
          </div>
        </div>
      )}

      {tab === "examen" && (
        <div className="max-w-3xl space-y-6">
          {!selSession && (
            <div className="card bg-yellow-50 border-yellow-200 text-yellow-700 text-sm flex items-center gap-2">
              <Star className="w-4 h-4" /> Primero selecciona una sesion en la pestana de calificar para asociar el examen.
            </div>
          )}
          <div className="card space-y-4">
            <h3 className="font-bold text-text-primary flex items-center gap-2"><Star className="w-4 h-4 text-primary" /> Crear examen online con resultado inmediato</h3>
            {selSession && <p className="text-xs text-text-muted bg-blue-50 px-3 py-2 rounded-lg">Examen para: <strong>{selSession.title}</strong></p>}
            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-semibold text-text-muted mb-1.5">Titulo del examen</label>
                <input className="input text-sm" placeholder="Ej: Evaluacion sesion 1" value={examTitle} onChange={e => setExamTitle(e.target.value)} />
              </div>
              <div>
                <label className="block text-xs font-semibold text-text-muted mb-1.5">Nota minima para aprobar</label>
                <input className="input text-sm" type="number" placeholder="60" value={examPass} onChange={e => setExamPass(e.target.value)} />
              </div>
            </div>
            <p className="text-xs text-text-muted">Marca con el radio la opcion correcta de cada pregunta.</p>
            {questions.map((q, qi) => (
              <div key={qi} className="border border-gray-200 rounded-xl p-4 space-y-3">
                <div className="flex items-center gap-2">
                  <span className="badge-primary text-xs w-7 h-7 flex items-center justify-center rounded-full font-bold">{qi + 1}</span>
                  <input className="input text-sm flex-1" placeholder={"Escribe la pregunta " + (qi + 1)} value={q.text}
                    onChange={e => { const nq = [...questions]; nq[qi] = { ...nq[qi], text: e.target.value }; setQuestions(nq); }} />
                  <input className="input text-sm w-20" type="number" placeholder="Pts" value={q.points}
                    onChange={e => { const nq = [...questions]; nq[qi] = { ...nq[qi], points: parseInt(e.target.value) || 0 }; setQuestions(nq); }} />
                  {qi > 0 && (
                    <button onClick={() => setQuestions(prev => prev.filter((_, i) => i !== qi))} className="text-red-400 hover:text-red-600 flex-shrink-0">
                      <Trash2 className="w-4 h-4" />
                    </button>
                  )}
                </div>
                <div className="pl-9 space-y-2">
                  {q.options.map((opt, oi) => (
                    <div key={oi} className={clsx("flex items-center gap-2 rounded-lg px-3 py-2 transition-colors", q.correct === oi ? "bg-green-50 border border-green-200" : "bg-gray-50")}>
                      <input type="radio" name={"correct-" + qi} checked={q.correct === oi}
                        onChange={() => { const nq = [...questions]; nq[qi] = { ...nq[qi], correct: oi }; setQuestions(nq); }}
                        className="accent-primary flex-shrink-0" />
                      <input className="bg-transparent border-none outline-none text-sm flex-1 text-text-primary"
                        placeholder={"Opcion " + (oi + 1) + (q.correct === oi ? " (correcta)" : "")} value={opt}
                        onChange={e => { const nq = [...questions]; nq[qi].options[oi] = e.target.value; setQuestions(nq); }} />
                      {q.correct === oi && <span className="text-xs text-green-600 font-semibold flex-shrink-0">Correcta</span>}
                    </div>
                  ))}
                </div>
              </div>
            ))}
            <div className="flex gap-3">
              <button onClick={() => setQuestions(prev => [...prev, { text: "", options: ["", "", "", ""], correct: 0, points: Math.floor(100 / (prev.length + 1)) }])}
                className="btn-outline flex items-center gap-2 text-sm">
                <Plus className="w-4 h-4" /> Agregar pregunta
              </button>
              <button onClick={saveExam} disabled={!examTitle.trim() || !selSession}
                className="btn-primary flex items-center gap-2 text-sm disabled:opacity-40">
                <CheckCircle className="w-4 h-4" /> Publicar examen
              </button>
            </div>
            <div className="bg-blue-50 rounded-xl p-3 text-xs text-blue-700">
              Una vez publicado, el examen aparece automaticamente en el visor del curso. Los estudiantes lo responden y obtienen su nota al instante.
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default function FormadorGradesPage() {
  return (
    <AppShell allowedRoles={["FORMADOR", "ADMIN"]}>
      <Suspense fallback={<div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div>}>
        <GradesContent />
      </Suspense>
    </AppShell>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\formador\grades\page.tsx", $grades, [System.Text.Encoding]::UTF8)
Write-Host "Formador grades con calificacion estudiante por estudiante OK" -ForegroundColor Green

# ── 5. FIX: next.config sin appDir ────────────────────────────
$nc = @'
/** @type {import("next").NextConfig} */
const nextConfig = { images: { domains: ["localhost"] } };
module.exports = nextConfig;
'@
[System.IO.File]::WriteAllText("$PWD\frontend\next.config.js", $nc, [System.Text.Encoding]::UTF8)
Write-Host "next.config.js OK (sin advertencias)" -ForegroundColor Green

# ── 6. FIX ENCODING: reemplazar em-dash en archivos existentes
Write-Host "Corrigiendo encoding en archivos frontend..." -ForegroundColor Cyan
$filesToFix = @(
  "frontend\src\app\(dashboard)\admin\page.tsx",
  "frontend\src\app\(dashboard)\formador\page.tsx",
  "frontend\src\app\(dashboard)\formador\attendance\page.tsx",
  "frontend\src\app\(dashboard)\formador\courses\page.tsx",
  "frontend\src\app\(student)\lobby\page.tsx",
  "frontend\src\app\(student)\courses\[id]\page.tsx",
  "frontend\src\components\layout\AppShell.tsx"
)
foreach ($f in $filesToFix) {
  if (Test-Path $f) {
    $content = Get-Content $f -Raw -Encoding UTF8
    # Reemplazar em-dash y otros caracteres problematicos
    $content = $content -replace [char]0x2014, "-"  # em dash
    $content = $content -replace [char]0x2013, "-"  # en dash
    $content = $content -replace "â€"", "-"
    $content = $content -replace "â€"", "-"
    $content = $content -replace "Â·", "."
    [System.IO.File]::WriteAllText("$PWD\$f", $content, [System.Text.Encoding]::UTF8)
  }
}
Write-Host "Encoding corregido en archivos existentes" -ForegroundColor Green

Write-Host ""
Write-Host "========================================================" -ForegroundColor Yellow
Write-Host "CORRECCION V5 COMPLETA" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Ejecuta para aplicar los 4 cursos correctos:" -ForegroundColor Cyan
Write-Host "  docker-compose down -v" -ForegroundColor White
Write-Host "  docker-compose up --build" -ForegroundColor White
