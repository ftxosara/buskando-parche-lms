"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useAuth } from "@/contexts/AuthContext";
import { LayoutDashboard, BookOpen, Users, ClipboardList, MessageSquare, Star, LogOut, ChevronRight, BarChart3, GraduationCap, User } from "lucide-react";
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
    { href:"/admin",           icon:LayoutDashboard, label:"Dashboard" },
    { href:"/admin/users",     icon:Users,           label:"Usuarios" },
    { href:"/admin/courses",   icon:BookOpen,        label:"Cursos" },
    { href:"/admin/reports",   icon:BarChart3,       label:"Reportes" },
    { href:"/admin/forum",     icon:MessageSquare,   label:"Foro" },
  ];
  const navFormador = [
    { href:"/formador",                                                  icon:LayoutDashboard, label:"Panel" },
    { href:cid?"/formador/courses?id="+cid:"/formador/courses",          icon:BookOpen,        label:"Mis Cursos" },
    { href:cid?"/formador/attendance?courseId="+cid:"/formador/attendance", icon:ClipboardList, label:"Asistencia" },
    { href:cid?"/formador/grades?courseId="+cid:"/formador/grades",      icon:Star,            label:"Calificaciones" },
    { href:cid?"/formador/forum?courseId="+cid:"/formador/forum",        icon:MessageSquare,   label:"Foro" },
    { href:"/formador/profile",                                          icon:User,            label:"Mi Perfil" },
  ];
  const navBen = [
    { href:"/lobby",             icon:BookOpen,        label:"Mis Cursos" },
    { href:"/lobby/grades",      icon:GraduationCap,   label:"Mis Notas" },
    { href:"/lobby/forum",       icon:MessageSquare,   label:"Foro" },
    { href:"/lobby/profile",     icon:User,            label:"Mi Perfil" },
  ];
  const nav = user?.role==="ADMIN"?navAdmin:user?.role==="FORMADOR"?navFormador:navBen;
  const isActive = (href: string) => { const b=href.split("?")[0]; return pathname===b||pathname.startsWith(b+"/"); };
  return (
    <aside className="w-64 min-h-screen bg-white border-r border-gray-200 flex flex-col shadow-sm">
      <div className="bg-gradient-brand p-5 flex items-center gap-3">
        <img src="/images/logo.png" alt="Logo" className="h-10 w-auto object-contain" onError={(e)=>{(e.target as HTMLImageElement).style.display="none";}}/>
        <div><p className="font-display font-bold text-white text-sm">Buskando Parche</p><p className="text-white/70 text-xs">LMS - Kennedy</p></div>
      </div>
      <div className="p-4 border-b border-gray-100 bg-gray-50">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-gradient-brand rounded-full flex items-center justify-center font-bold text-white text-sm flex-shrink-0">
            {user?.firstName?.[0]}{user?.lastName?.[0]}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-semibold text-text-primary truncate">{user?.firstName} {user?.lastName}</p>
            <span className={clsx("badge text-xs mt-0.5",{"badge-primary":user?.role==="ADMIN","badge-secondary":user?.role==="FORMADOR","badge-muted":user?.role==="BENEFICIARIO"})}>
              {user?.role==="ADMIN"?"Administrador":user?.role==="FORMADOR"?"Formador":"Beneficiario"}
            </span>
          </div>
        </div>
      </div>
      <nav className="flex-1 p-4 space-y-1">
        {nav.map(({href,icon:Icon,label})=>{
          const active=isActive(href);
          return (
            <Link key={label} href={href} className={clsx("flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all duration-200 group",
              active?"bg-red-50 text-primary border border-red-100":"text-text-secondary hover:bg-gray-50 hover:text-primary")}>
              <Icon className={clsx("w-5 h-5",active?"text-primary":"text-gray-400 group-hover:text-primary")}/>
              {label}
              {active&&<ChevronRight className="w-4 h-4 ml-auto text-primary"/>}
            </Link>
          );
        })}
      </nav>
      <div className="p-4 border-t border-gray-100">
        <button onClick={logout} className="btn-ghost w-full flex items-center gap-3 text-sm text-gray-500"><LogOut className="w-5 h-5"/> Cerrar sesion</button>
      </div>
    </aside>
  );
}