﻿"use client";
import {useEffect,useState} from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import {BookOpen,Users,Loader2,ChevronDown,ChevronRight,CheckCircle,Upload,Plus,Eye} from "lucide-react";
export default function AdminCoursesPage() {
  const [courses,setCourses]=useState<any[]>([]); const [loading,setLoading]=useState(true);
  const [expanded,setExpanded]=useState<string|null>(null);
  const [courseUsers,setCourseUsers]=useState<Record<string,any[]>>({});
  useEffect(()=>{
    api.get("/courses/lobby").then(({data})=>setCourses(data)).finally(()=>setLoading(false));
  },[]);
  const loadUsers=async(courseId:string)=>{
    if(courseUsers[courseId]) return;
    const {data}=await api.get("/users",{params:{role:"BENEFICIARIO",limit:100}});
    const enrolled=data.data.filter((u:any)=>u.enrollments?.some((e:any)=>e.courseId===courseId));
    setCourseUsers(prev=>({...prev,[courseId]:enrolled}));
  };
  const toggle=(courseId:string)=>{
    setExpanded(prev=>prev===courseId?null:courseId);
    loadUsers(courseId);
  };
  const courseColor:Record<string,string>={
    "Marketing Digital Turistico":"bg-orange-50 border-orange-200",
    "Ingles en el Turismo":"bg-blue-50 border-blue-200",
    "Gestion Empresarial":"bg-green-50 border-green-200",
    "Turismo Sostenible":"bg-teal-50 border-teal-200",
  };
  return (
    <AppShell allowedRoles={["ADMIN"]}>
      <div className="max-w-5xl mx-auto space-y-6">
        <div><h1 className="font-display text-3xl font-bold text-text-primary">Gestion de Cursos</h1>
          <p className="text-text-secondary mt-1">Administra contenido, inscritos y progreso de cada curso.</p>
        </div>
        {loading?<div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div>:(
          <div className="space-y-4">
            {courses.map((c:any)=>(
              <div key={c.id} className={"rounded-2xl border shadow-card overflow-hidden "+(courseColor[c.title]||"bg-white border-gray-200")}>
                <button onClick={()=>toggle(c.id)} className="w-full flex items-center gap-4 p-5 text-left hover:bg-white/50 transition-colors">
                  <div className="p-3 bg-white rounded-xl shadow-sm flex-shrink-0"><BookOpen className="w-6 h-6 text-primary"/></div>
                  <div className="flex-1">
                    <h3 className="font-bold text-text-primary text-lg">{c.title}</h3>
                    <div className="flex items-center gap-4 mt-1 text-sm text-text-muted">
                      <span className="flex items-center gap-1"><Users className="w-4 h-4"/> {c.totalEnrolled} inscritos</span>
                      <span>{c.modality==="VIRTUAL"?"Virtual":"Presencial"}</span>
                      <span>Formador: {c.formador}</span>
                    </div>
                  </div>
                  {expanded===c.id?<ChevronDown className="w-5 h-5 text-text-muted"/>:<ChevronRight className="w-5 h-5 text-text-muted"/>}
                </button>
                {expanded===c.id&&(
                  <div className="border-t border-white/60 bg-white p-5 space-y-4">
                    <div className="grid grid-cols-3 gap-3 text-center">
                      <div className="bg-gray-50 rounded-xl p-3"><p className="text-2xl font-bold text-primary">{c.totalEnrolled}</p><p className="text-xs text-text-muted">Inscritos</p></div>
                      <div className="bg-gray-50 rounded-xl p-3"><p className="text-2xl font-bold text-text-primary">{c.totalSessions}</p><p className="text-xs text-text-muted">Sesiones</p></div>
                      <div className="bg-gray-50 rounded-xl p-3"><p className="text-2xl font-bold text-green-600">{c.isEnrolled||0}</p><p className="text-xs text-text-muted">Completados</p></div>
                    </div>
                    <div>
                      <h4 className="font-semibold text-text-primary mb-3 flex items-center gap-2"><Users className="w-4 h-4"/> Beneficiarios inscritos</h4>
                      {!courseUsers[c.id]?<div className="flex justify-center py-4"><Loader2 className="w-5 h-5 text-primary animate-spin"/></div>:(
                        <div className="overflow-x-auto">
                          <table className="w-full text-sm">
                            <thead><tr className="bg-gray-50">
                              <th className="text-left py-2 px-3 text-text-secondary font-medium rounded-l-lg">Nombre</th>
                              <th className="text-left py-2 px-3 text-text-secondary font-medium">Cedula</th>
                              <th className="text-left py-2 px-3 text-text-secondary font-medium">Email</th>
                              <th className="text-left py-2 px-3 text-text-secondary font-medium rounded-r-lg">Estado</th>
                            </tr></thead>
                            <tbody className="divide-y divide-gray-50">
                              {courseUsers[c.id]?.map((u:any)=>(
                                <tr key={u.id} className="hover:bg-gray-50">
                                  <td className="py-2 px-3 font-medium">{u.firstName} {u.lastName}</td>
                                  <td className="py-2 px-3 text-text-muted font-mono text-xs">{u.cedula}</td>
                                  <td className="py-2 px-3 text-text-muted text-xs">{u.email}</td>
                                  <td className="py-2 px-3">
                                    <span className={u.enrollments?.[0]?.status==="COMPLETADO"?"badge-success":"badge-primary"}>
                                      {u.enrollments?.[0]?.status||"Activo"}
                                    </span>
                                  </td>
                                </tr>
                              ))}
                            </tbody>
                          </table>
                          {courseUsers[c.id]?.length===0&&<p className="text-text-muted text-sm py-4 text-center">Sin beneficiarios inscritos aun</p>}
                        </div>
                      )}
                    </div>
                    <div className="flex gap-3 pt-2">
                      <a href={"/formador/courses?id="+c.id} className="btn-primary flex items-center gap-2 text-sm"><Upload className="w-4 h-4"/> Gestionar contenido</a>
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </AppShell>
  );
}