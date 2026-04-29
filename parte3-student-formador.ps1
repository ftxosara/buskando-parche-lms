# ─── FORMADOR: pagina principal ──────────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\formador" | Out-Null
$formadorMain = @'
"use client";
import {useEffect,useState} from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import {BookOpen,Users,ClipboardList,Loader2,ArrowRight} from "lucide-react";
import Link from "next/link";
import {useAuth} from "@/contexts/AuthContext";
export default function FormadorPanel() {
  const {user}=useAuth();
  const [courses,setCourses]=useState<any[]>([]); const [loading,setLoading]=useState(true);
  useEffect(()=>{ api.get("/courses/lobby").then(({data})=>setCourses(data)).finally(()=>setLoading(false)); },[]);
  return (
    <AppShell allowedRoles={["FORMADOR"]}>
      <div className="max-w-4xl mx-auto space-y-8">
        <div><h1 className="font-display text-3xl font-bold text-text-primary">Bienvenido, {user?.firstName}</h1>
          <p className="text-text-secondary mt-1">Panel del formador — gestiona tu curso, asistencia y calificaciones.</p>
        </div>
        {loading?<div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div>:(
          <>
            {courses.length===0&&<div className="card text-center py-12"><BookOpen className="w-12 h-12 text-gray-300 mx-auto mb-3"/><p className="text-text-muted">No tienes cursos asignados aun.</p></div>}
            <div className="grid md:grid-cols-2 gap-5">
              {courses.map((c:any)=>(
                <div key={c.id} className="card hover:shadow-lg transition-shadow border-l-4 border-l-primary">
                  <h3 className="font-bold text-text-primary text-lg mb-1">{c.title}</h3>
                  <p className="text-text-muted text-sm mb-4">{c.modality==="VIRTUAL"?"Virtual":"Presencial"} — {c.totalSessions} sesiones — {c.totalEnrolled} estudiantes</p>
                  <div className="grid grid-cols-2 gap-2">
                    <Link href={"/formador/courses?id="+c.id} className="btn-primary flex items-center justify-center gap-2 py-2 text-sm"><BookOpen className="w-4 h-4"/> Gestionar curso</Link>
                    <Link href={"/formador/attendance?courseId="+c.id} className="btn-outline flex items-center justify-center gap-2 py-2 text-sm"><ClipboardList className="w-4 h-4"/> Asistencia</Link>
                    <Link href={"/formador/grades?courseId="+c.id} className="btn-ghost flex items-center justify-center gap-2 py-2 text-sm col-span-2 border border-gray-200 rounded-lg"><Users className="w-4 h-4"/> Ver calificaciones</Link>
                  </div>
                </div>
              ))}
            </div>
          </>
        )}
      </div>
    </AppShell>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\formador\page.tsx", $formadorMain, [System.Text.Encoding]::UTF8)

# ─── FORMADOR: gestion de curso (subir sesiones/recursos) ────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\formador\courses" | Out-Null
$formadorCourses = @'
"use client";
import {useEffect,useState,Suspense} from "react";
import {useSearchParams} from "next/navigation";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import {Upload,Plus,FileText,Video,Link as LinkIcon,ChevronDown,ChevronRight,Loader2,CheckCircle,BookOpen} from "lucide-react";
function CoursesContent() {
  const params=useSearchParams(); const courseId=params.get("id");
  const [course,setCourse]=useState<any>(null); const [loading,setLoading]=useState(true);
  const [expanded,setExpanded]=useState<string|null>(null);
  const [uploading,setUploading]=useState<string|null>(null);
  const [msg,setMsg]=useState("");
  const [resourceForm,setResourceForm]=useState<Record<string,{title:string;type:string;url:string}>>({});
  useEffect(()=>{
    if(courseId) api.get("/courses/"+courseId).then(({data})=>setCourse(data)).finally(()=>setLoading(false));
    else setLoading(false);
  },[courseId]);
  const handleUploadResource=async(sessionId:string)=>{
    const f=resourceForm[sessionId]; if(!f?.title) return;
    setUploading(sessionId);
    try {
      await api.post("/sessions/"+sessionId+"/resources",{title:f.title,type:f.type||"link",url:f.url||"#"});
      setMsg("Recurso agregado a la sesion");
      const {data}=await api.get("/courses/"+courseId);
      setCourse(data);
      setResourceForm(prev=>({...prev,[sessionId]:{title:"",type:"link",url:""}}));
    } catch { setMsg("Error al agregar recurso"); }
    finally { setUploading(null); }
  };
  if(loading) return <div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div>;
  if(!course) return <div className="card text-center py-12"><BookOpen className="w-12 h-12 text-gray-300 mx-auto mb-3"/><p className="text-text-muted">Selecciona un curso desde el panel del formador.</p></div>;
  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div><h1 className="font-display text-2xl font-bold text-text-primary">{course.title}</h1>
        <p className="text-text-secondary mt-1">{course.sessions?.length} sesiones — {course.modality}</p>
      </div>
      {msg&&<div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-xl text-sm flex items-center gap-2"><CheckCircle className="w-4 h-4"/>{msg}</div>}
      <div className="space-y-3">
        {course.sessions?.map((s:any)=>(
          <div key={s.id} className="card p-0 overflow-hidden">
            <button onClick={()=>setExpanded(prev=>prev===s.id?null:s.id)}
              className="w-full flex items-center gap-4 p-4 text-left hover:bg-gray-50 transition-colors">
              <span className="w-8 h-8 bg-primary/10 rounded-full flex items-center justify-center text-primary font-bold text-sm flex-shrink-0">{s.order}</span>
              <div className="flex-1"><p className="font-semibold text-text-primary">{s.title}</p>
                <p className="text-xs text-text-muted">{s.resources?.length||0} recursos</p>
              </div>
              {expanded===s.id?<ChevronDown className="w-5 h-5 text-text-muted"/>:<ChevronRight className="w-5 h-5 text-text-muted"/>}
            </button>
            {expanded===s.id&&(
              <div className="border-t border-gray-100 p-4 space-y-4 bg-gray-50">
                {s.resources?.length>0&&(
                  <div><p className="text-xs font-semibold text-text-muted uppercase mb-2">Recursos actuales</p>
                    <div className="space-y-1.5">
                      {s.resources.map((r:any)=>(
                        <div key={r.id} className="flex items-center gap-3 bg-white rounded-lg px-3 py-2 text-sm">
                          {r.type==="video"?<Video className="w-4 h-4 text-red-500"/>:r.type==="pdf"?<FileText className="w-4 h-4 text-blue-500"/>:<LinkIcon className="w-4 h-4 text-green-500"/>}
                          <span className="flex-1 text-text-primary">{r.title}</span>
                          <a href={r.url} target="_blank" rel="noopener noreferrer" className="text-primary text-xs hover:underline">Ver</a>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
                <div><p className="text-xs font-semibold text-text-muted uppercase mb-2">Agregar recurso</p>
                  <div className="bg-white rounded-xl p-3 space-y-2 border border-gray-200">
                    <div className="grid grid-cols-2 gap-2">
                      <input className="input text-sm" placeholder="Titulo del recurso"
                        value={resourceForm[s.id]?.title||""} onChange={e=>setResourceForm(prev=>({...prev,[s.id]:{...prev[s.id],title:e.target.value}}))}/>
                      <select className="input text-sm" value={resourceForm[s.id]?.type||"link"}
                        onChange={e=>setResourceForm(prev=>({...prev,[s.id]:{...prev[s.id],type:e.target.value}}))}>
                        <option value="link">Enlace</option>
                        <option value="video">Video (URL)</option>
                        <option value="pdf">PDF (URL)</option>
                      </select>
                    </div>
                    <input className="input text-sm" placeholder="URL del recurso (https://...)"
                      value={resourceForm[s.id]?.url||""} onChange={e=>setResourceForm(prev=>({...prev,[s.id]:{...prev[s.id],url:e.target.value}}))}/>
                    <button onClick={()=>handleUploadResource(s.id)} disabled={uploading===s.id}
                      className="btn-primary w-full flex items-center justify-center gap-2 py-2 text-sm">
                      {uploading===s.id?<Loader2 className="w-4 h-4 animate-spin"/>:<Plus className="w-4 h-4"/>}
                      Agregar recurso
                    </button>
                  </div>
                </div>
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
export default function FormadorCoursesPage() {
  return (
    <AppShell allowedRoles={["FORMADOR","ADMIN"]}>
      <Suspense fallback={<div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div>}>
        <CoursesContent/>
      </Suspense>
    </AppShell>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\formador\courses\page.tsx", $formadorCourses, [System.Text.Encoding]::UTF8)
Write-Host "Formador courses page OK" -ForegroundColor Green

# ─── FORMADOR: asistencia ─────────────────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\formador\attendance" | Out-Null
$formAttendance = @'
"use client";
import {useEffect,useState,Suspense} from "react";
import {useSearchParams} from "next/navigation";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import {Loader2,CheckCircle,Users,ClipboardList} from "lucide-react";
function AttContent() {
  const params=useSearchParams(); const courseId=params.get("courseId");
  const [course,setCourse]=useState<any>(null); const [selSession,setSelSession]=useState<any>(null);
  const [students,setStudents]=useState<any[]>([]); const [att,setAtt]=useState<Record<string,string>>({});
  const [loading,setLoading]=useState(true); const [saving,setSaving]=useState(false); const [msg,setMsg]=useState("");
  useEffect(()=>{ if(courseId) api.get("/courses/"+courseId).then(({data})=>{setCourse(data);setLoading(false);}); },[courseId]);
  const selectSession=async(s:any)=>{
    setSelSession(s);
    const {data}=await api.get("/users",{params:{role:"BENEFICIARIO",limit:100}});
    const enrolled=data.data.filter((u:any)=>u.enrollments?.some((e:any)=>e.courseId===courseId));
    setStudents(enrolled);
    const {data:attData}=await api.get("/attendance/session/"+s.id);
    const map:Record<string,string>={};
    attData.forEach((a:any)=>{map[a.userId]=a.status;});
    enrolled.forEach((u:any)=>{ if(!map[u.id]) map[u.id]="PRESENTE"; });
    setAtt(map);
  };
  const save=async()=>{
    setSaving(true);
    const attendances=students.map(u=>({userId:u.id,status:att[u.id]||"PRESENTE",notes:""}));
    await api.post("/attendance",{sessionId:selSession.id,attendances});
    setMsg("Asistencia guardada correctamente");
    setSaving(false);
  };
  if(loading) return <div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div>;
  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div><h1 className="font-display text-2xl font-bold text-text-primary">Registro de Asistencia</h1>
        <p className="text-text-secondary mt-1">{course?.title}</p>
      </div>
      {msg&&<div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-xl text-sm flex items-center gap-2"><CheckCircle className="w-4 h-4"/>{msg}</div>}
      <div className="grid md:grid-cols-3 gap-6">
        <div className="card p-0 overflow-hidden">
          <div className="p-4 bg-gray-50 border-b border-gray-100"><p className="font-semibold text-text-primary text-sm">Seleccionar sesion</p></div>
          <div className="divide-y divide-gray-50 max-h-96 overflow-y-auto">
            {course?.sessions?.map((s:any)=>(
              <button key={s.id} onClick={()=>selectSession(s)}
                className={"w-full text-left px-4 py-3 text-sm transition-colors flex items-center gap-3 "+(selSession?.id===s.id?"bg-red-50 text-primary font-semibold":"hover:bg-gray-50 text-text-secondary")}>
                <span className="w-6 h-6 rounded-full bg-gray-100 flex items-center justify-center text-xs font-bold flex-shrink-0">{s.order}</span>
                {s.title}
              </button>
            ))}
          </div>
        </div>
        <div className="md:col-span-2 space-y-4">
          {!selSession?<div className="card text-center py-12"><ClipboardList className="w-10 h-10 text-gray-300 mx-auto mb-3"/><p className="text-text-muted">Selecciona una sesion</p></div>:(
            <div className="card">
              <div className="flex items-center justify-between mb-4">
                <h3 className="font-bold text-text-primary">{selSession.title}</h3>
                <span className="badge-muted">{students.length} estudiantes</span>
              </div>
              <div className="space-y-2 max-h-80 overflow-y-auto">
                {students.map((u:any)=>(
                  <div key={u.id} className="flex items-center gap-3 py-2 border-b border-gray-50">
                    <div className="flex-1"><p className="text-sm font-medium text-text-primary">{u.firstName} {u.lastName}</p><p className="text-xs text-text-muted">{u.cedula}</p></div>
                    <div className="flex gap-1">
                      {["PRESENTE","AUSENTE","EXCUSA"].map(st=>(
                        <button key={st} onClick={()=>setAtt(prev=>({...prev,[u.id]:st}))}
                          className={`text-xs px-2.5 py-1.5 rounded-lg font-medium transition-colors ${att[u.id]===st
                            ?(st==="PRESENTE"?"bg-green-500 text-white":st==="AUSENTE"?"bg-red-500 text-white":"bg-yellow-500 text-white")
                            :"bg-gray-100 text-gray-500 hover:bg-gray-200"}`}>
                          {st==="PRESENTE"?"P":st==="AUSENTE"?"A":"E"}
                        </button>
                      ))}
                    </div>
                  </div>
                ))}
              </div>
              <button onClick={save} disabled={saving} className="btn-primary w-full mt-4 flex items-center justify-center gap-2">
                {saving?<Loader2 className="w-4 h-4 animate-spin"/>:<CheckCircle className="w-4 h-4"/>}
                {saving?"Guardando...":"Guardar asistencia"}
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
export default function FormadorAttendancePage() {
  return <AppShell allowedRoles={["FORMADOR","ADMIN"]}><Suspense fallback={<div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div>}><AttContent/></Suspense></AppShell>;
}
'@
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\formador\attendance\page.tsx", $formAttendance, [System.Text.Encoding]::UTF8)
Write-Host "Formador attendance page OK" -ForegroundColor Green

# ─── FORMADOR: calificaciones ─────────────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\formador\grades" | Out-Null
$formGrades = @'
"use client";
import {useEffect,useState,Suspense} from "react";
import {useSearchParams} from "next/navigation";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import {Loader2,CheckCircle,Star,MessageSquare,Download} from "lucide-react";
function GradesContent() {
  const params=useSearchParams(); const courseId=params.get("courseId");
  const [course,setCourse]=useState<any>(null); const [selSession,setSelSession]=useState<any>(null);
  const [submissions,setSubmissions]=useState<any[]>([]); const [grading,setGrading]=useState<Record<string,{score:string;feedback:string}>>({});
  const [loading,setLoading]=useState(true); const [saving,setSaving]=useState<string|null>(null); const [msg,setMsg]=useState("");
  useEffect(()=>{ if(courseId) api.get("/courses/"+courseId).then(({data})=>{setCourse(data);setLoading(false);}); },[courseId]);
  const loadSubmissions=async(s:any)=>{
    setSelSession(s); setSubmissions([]);
    const {data}=await api.get("/assignments/session/"+s.id);
    setSubmissions(data);
    const map:Record<string,{score:string;feedback:string}>={};
    data.forEach((sub:any)=>{map[sub.id]={score:sub.score?.toString()||"",feedback:sub.feedback||""};});
    setGrading(map);
  };
  const saveGrade=async(subId:string)=>{
    setSaving(subId);
    await api.put("/assignments/"+subId+"/grade",{score:grading[subId]?.score,feedback:grading[subId]?.feedback});
    setMsg("Calificacion guardada"); setSaving(null);
  };
  if(loading) return <div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div>;
  return (
    <div className="max-w-5xl mx-auto space-y-6">
      <div><h1 className="font-display text-2xl font-bold text-text-primary">Calificaciones</h1>
        <p className="text-text-secondary mt-1">{course?.title}</p>
      </div>
      {msg&&<div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-xl text-sm flex items-center gap-2"><CheckCircle className="w-4 h-4"/>{msg}</div>}
      <div className="grid md:grid-cols-3 gap-6">
        <div className="card p-0 overflow-hidden">
          <div className="p-4 bg-gray-50 border-b"><p className="font-semibold text-text-primary text-sm">Sesiones</p></div>
          <div className="divide-y divide-gray-50 max-h-96 overflow-y-auto">
            {course?.sessions?.map((s:any)=>(
              <button key={s.id} onClick={()=>loadSubmissions(s)}
                className={"w-full text-left px-4 py-3 text-sm transition-colors flex items-center gap-3 "+(selSession?.id===s.id?"bg-red-50 text-primary font-semibold":"hover:bg-gray-50 text-text-secondary")}>
                <span className="w-6 h-6 rounded-full bg-gray-100 flex items-center justify-center text-xs font-bold flex-shrink-0">{s.order}</span>
                {s.title}
              </button>
            ))}
          </div>
        </div>
        <div className="md:col-span-2">
          {!selSession?<div className="card text-center py-12"><Star className="w-10 h-10 text-gray-300 mx-auto mb-3"/><p className="text-text-muted">Selecciona una sesion para ver entregas</p></div>:(
            <div className="space-y-3">
              <p className="font-semibold text-text-primary">{selSession.title} — {submissions.length} entregas</p>
              {submissions.length===0&&<div className="card text-center py-8"><p className="text-text-muted text-sm">Sin entregas aun para esta sesion</p></div>}
              {submissions.map((sub:any)=>(
                <div key={sub.id} className="card space-y-3">
                  <div className="flex items-start justify-between gap-3">
                    <div>
                      <p className="font-semibold text-text-primary">{sub.user?.firstName} {sub.user?.lastName}</p>
                      <p className="text-xs text-text-muted">{sub.user?.cedula} — Enviado: {new Date(sub.submittedAt).toLocaleDateString("es-CO")}</p>
                    </div>
                    {sub.score!=null&&<span className={`badge text-lg font-bold px-3 py-1 ${sub.score>=60?"badge-success":"badge-primary"}`}>{sub.score}/100</span>}
                  </div>
                  {sub.answers?.text&&<div className="bg-gray-50 rounded-xl p-3 text-sm text-text-secondary">{sub.answers.text}</div>}
                  {sub.answers?.fileUrl&&<a href={sub.answers.fileUrl} target="_blank" rel="noopener noreferrer" className="text-primary text-sm hover:underline flex items-center gap-1"><Download className="w-4 h-4"/> Descargar archivo adjunto</a>}
                  <div className="grid grid-cols-2 gap-2">
                    <div>
                      <label className="block text-xs font-medium text-text-muted mb-1">Nota (0-100)</label>
                      <input type="number" min="0" max="100" className="input text-sm" placeholder="Ej: 85"
                        value={grading[sub.id]?.score||""} onChange={e=>setGrading(prev=>({...prev,[sub.id]:{...prev[sub.id],score:e.target.value}}))}/>
                    </div>
                    <div>
                      <label className="block text-xs font-medium text-text-muted mb-1">Retroalimentacion</label>
                      <input type="text" className="input text-sm" placeholder="Comentario al estudiante"
                        value={grading[sub.id]?.feedback||""} onChange={e=>setGrading(prev=>({...prev,[sub.id]:{...prev[sub.id],feedback:e.target.value}}))}/>
                    </div>
                  </div>
                  <button onClick={()=>saveGrade(sub.id)} disabled={saving===sub.id} className="btn-primary w-full flex items-center justify-center gap-2 py-2 text-sm">
                    {saving===sub.id?<Loader2 className="w-4 h-4 animate-spin"/>:<CheckCircle className="w-4 h-4"/>}
                    Guardar calificacion
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
export default function FormadorGradesPage() {
  return <AppShell allowedRoles={["FORMADOR","ADMIN"]}><Suspense fallback={<div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div>}><GradesContent/></Suspense></AppShell>;
}
'@
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\formador\grades" | Out-Null
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\formador\grades\page.tsx", $formGrades, [System.Text.Encoding]::UTF8)
Write-Host "Formador grades page OK" -ForegroundColor Green

# ─── SIDEBAR: agregar "Calificaciones" al formador ────────────
$sidebar = @'
"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useAuth } from "@/contexts/AuthContext";
import { LayoutDashboard,BookOpen,Users,ClipboardList,MessageSquare,Award,LogOut,ChevronRight,BarChart3,GraduationCap,Star } from "lucide-react";
import clsx from "clsx";
const navByRole: Record<string,{href:string;icon:any;label:string}[]> = {
  ADMIN: [
    {href:"/admin",         icon:LayoutDashboard, label:"Dashboard"},
    {href:"/admin/users",   icon:Users,           label:"Usuarios"},
    {href:"/admin/courses", icon:BookOpen,        label:"Cursos"},
    {href:"/admin/reports", icon:BarChart3,       label:"Reportes"},
  ],
  FORMADOR: [
    {href:"/formador",             icon:LayoutDashboard, label:"Panel"},
    {href:"/formador/courses",     icon:BookOpen,        label:"Mis Cursos"},
    {href:"/formador/attendance",  icon:ClipboardList,   label:"Asistencia"},
    {href:"/formador/grades",      icon:Star,            label:"Calificaciones"},
  ],
  BENEFICIARIO: [
    {href:"/lobby",              icon:BookOpen,        label:"Mis Cursos"},
    {href:"/lobby/forum",        icon:MessageSquare,   label:"Foro"},
    {href:"/lobby/certificates", icon:GraduationCap,   label:"Certificados"},
  ],
};
export default function Sidebar() {
  const {user,logout}=useAuth(); const pathname=usePathname();
  const nav=user?(navByRole[user.role]||[]):[];
  return (
    <aside className="w-64 min-h-screen bg-white border-r border-gray-200 flex flex-col shadow-sm">
      <div className="bg-gradient-brand p-5 flex items-center gap-3">
        <img src="/images/logo.png" alt="Logo" className="h-10 w-auto object-contain"
          onError={(e)=>{(e.target as HTMLImageElement).style.display="none";}}/>
        <div><p className="font-display font-bold text-white text-sm">Buskando Parche</p><p className="text-white/70 text-xs">LMS - Kennedy</p></div>
      </div>
      <div className="p-4 border-b border-gray-100 bg-gray-50">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-gradient-brand rounded-full flex items-center justify-center font-bold text-white text-sm flex-shrink-0">{user?.firstName?.[0]}{user?.lastName?.[0]}</div>
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
          const isActive=pathname===href||pathname.startsWith(href+"/");
          return (
            <Link key={href} href={href} className={clsx("flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all duration-200 group",
              isActive?"bg-red-50 text-primary border border-red-100":"text-text-secondary hover:bg-gray-50 hover:text-primary")}>
              <Icon className={clsx("w-5 h-5",isActive?"text-primary":"text-gray-400 group-hover:text-primary")}/>
              {label}
              {isActive&&<ChevronRight className="w-4 h-4 ml-auto text-primary"/>}
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
'@
[System.IO.File]::WriteAllText("$PWD\frontend\src\components\layout\Sidebar.tsx", $sidebar, [System.Text.Encoding]::UTF8)
Write-Host "Sidebar con calificaciones OK" -ForegroundColor Green

# ─── STUDENT: visor de curso estilo Moodle ───────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(student)\courses\[id]" | Out-Null
$courseViewer = @'
"use client";
import {useEffect,useState} from "react";
import {useParams} from "next/navigation";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import {BookOpen,PlayCircle,FileText,Link as LinkIcon,CheckCircle,Upload,Send,Star,ChevronRight,Loader2,Video,Lock,Award} from "lucide-react";
import clsx from "clsx";
export default function CourseViewer() {
  const {id}=useParams();
  const [course,setCourse]=useState<any>(null); const [loading,setLoading]=useState(true);
  const [selSession,setSelSession]=useState<any>(null);
  const [submitText,setSubmitText]=useState(""); const [submitFile,setSubmitFile]=useState<File|null>(null);
  const [submitting,setSubmitting]=useState(false); const [submitMsg,setSubmitMsg]=useState("");
  const [grades,setGrades]=useState<any[]>([]);
  useEffect(()=>{
    api.get("/courses/"+id).then(({data})=>{setCourse(data);if(data.sessions?.length>0)setSelSession(data.sessions[0]);}).finally(()=>setLoading(false));
    api.get("/assignments/grades/"+id).then(({data})=>setGrades(data)).catch(()=>{});
  },[id]);
  const handleSubmit=async()=>{
    setSubmitting(true); setSubmitMsg("");
    try {
      const fd=new FormData();
      fd.append("sessionId",selSession.id); fd.append("courseId",String(id));
      fd.append("textContent",submitText);
      if(submitFile) fd.append("file",submitFile);
      await api.post("/assignments",fd,{headers:{"Content-Type":"multipart/form-data"}});
      setSubmitMsg("Actividad enviada correctamente"); setSubmitText(""); setSubmitFile(null);
      api.get("/assignments/grades/"+id).then(({data})=>setGrades(data)).catch(()=>{});
    } catch { setSubmitMsg("Error al enviar. Intenta de nuevo."); }
    finally { setSubmitting(false); }
  };
  const gradeMap=grades.reduce((m:any,g:any)=>({...m,[g.id]:g}),{});
  const totalScore=grades.filter(g=>g.score!=null).reduce((a,g)=>a+g.score,0);
  const graded=grades.filter(g=>g.score!=null).length;
  const promedio=graded>0?(totalScore/graded).toFixed(1):"N/A";
  if(loading) return <AppShell allowedRoles={["BENEFICIARIO","FORMADOR","ADMIN"]}><div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div></AppShell>;
  if(!course) return <AppShell allowedRoles={["BENEFICIARIO","FORMADOR","ADMIN"]}><div className="card text-center py-12"><p className="text-text-muted">Curso no encontrado o sin acceso.</p></div></AppShell>;
  return (
    <AppShell allowedRoles={["BENEFICIARIO","FORMADOR","ADMIN"]}>
      <div className="max-w-6xl mx-auto space-y-6">
        {/* Header */}
        <div className="bg-gradient-brand rounded-2xl p-6 text-white">
          <h1 className="font-display text-2xl font-bold">{course.title}</h1>
          <p className="text-white/80 mt-1 text-sm">{course.sessions?.length} sesiones — {course.modality}</p>
          <div className="flex items-center gap-4 mt-3 text-sm">
            <span className="flex items-center gap-1.5 bg-white/20 px-3 py-1 rounded-full">
              <BookOpen className="w-4 h-4"/> {course.sessions?.length} sesiones
            </span>
            <span className="flex items-center gap-1.5 bg-white/20 px-3 py-1 rounded-full">
              <Star className="w-4 h-4"/> Promedio: {promedio}
            </span>
          </div>
        </div>
        <div className="grid md:grid-cols-3 gap-6">
          {/* Lista de sesiones */}
          <div className="card p-0 overflow-hidden">
            <div className="p-4 bg-gray-50 border-b border-gray-100">
              <p className="font-bold text-text-primary">Contenido del curso</p>
              <p className="text-xs text-text-muted mt-0.5">{course.sessions?.length} sesiones</p>
            </div>
            <div className="divide-y divide-gray-50 max-h-[600px] overflow-y-auto">
              {course.sessions?.map((s:any)=>{
                const g=gradeMap[s.id];
                const attended=g?.attendance==="PRESENTE";
                const hasGrade=g?.score!=null;
                const hasSubmission=g?.submission!=null;
                return (
                  <button key={s.id} onClick={()=>setSelSession(s)}
                    className={clsx("w-full text-left px-4 py-3 transition-colors flex items-start gap-3",
                      selSession?.id===s.id?"bg-red-50 border-r-2 border-primary":"hover:bg-gray-50")}>
                    <span className={clsx("w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0 mt-0.5",
                      selSession?.id===s.id?"bg-primary text-white":hasGrade?"bg-green-100 text-green-700":"bg-gray-100 text-gray-600")}>
                      {hasGrade?<CheckCircle className="w-4 h-4"/>:s.order}
                    </span>
                    <div className="flex-1 min-w-0">
                      <p className={clsx("text-sm font-medium",selSession?.id===s.id?"text-primary":"text-text-primary")}>{s.title}</p>
                      <div className="flex items-center gap-2 mt-0.5">
                        {attended&&<span className="text-xs text-green-600">Asistio</span>}
                        {hasGrade&&<span className="text-xs font-bold text-blue-600">{g.score}/100</span>}
                        {hasSubmission&&!hasGrade&&<span className="text-xs text-orange-500">Pendiente calificar</span>}
                      </div>
                    </div>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Contenido de la sesion */}
          <div className="md:col-span-2 space-y-4">
            {selSession&&(
              <>
                <div className="card">
                  <div className="flex items-center justify-between mb-4">
                    <div>
                      <h2 className="font-bold text-xl text-text-primary">{selSession.title}</h2>
                      <p className="text-text-muted text-sm mt-0.5">{selSession.description}</p>
                    </div>
                    {gradeMap[selSession.id]?.score!=null&&(
                      <div className={clsx("text-center px-4 py-2 rounded-xl",gradeMap[selSession.id].score>=60?"bg-green-100":"bg-red-100")}>
                        <p className={clsx("text-2xl font-bold",gradeMap[selSession.id].score>=60?"text-green-700":"text-red-700")}>{gradeMap[selSession.id].score}</p>
                        <p className="text-xs text-text-muted">/ 100</p>
                      </div>
                    )}
                  </div>
                  {/* Asistencia */}
                  <div className={clsx("flex items-center gap-2 px-3 py-2 rounded-lg text-sm mb-3",
                    gradeMap[selSession.id]?.attendance==="PRESENTE"?"bg-green-50 text-green-700":gradeMap[selSession.id]?.attendance==="AUSENTE"?"bg-red-50 text-red-700":"bg-gray-50 text-gray-500")}>
                    <CheckCircle className="w-4 h-4"/>
                    Asistencia: {gradeMap[selSession.id]?.attendance||"No registrada"}
                  </div>
                  {/* Recursos */}
                  {selSession.resources?.length>0?(
                    <div>
                      <p className="text-xs font-semibold text-text-muted uppercase mb-2">Materiales</p>
                      <div className="space-y-2">
                        {selSession.resources.map((r:any)=>(
                          <a key={r.id} href={r.url} target="_blank" rel="noopener noreferrer"
                            className="flex items-center gap-3 p-3 bg-gray-50 rounded-xl hover:bg-red-50 transition-colors group">
                            {r.type==="video"?<Video className="w-5 h-5 text-red-500 flex-shrink-0"/>
                              :r.type==="pdf"?<FileText className="w-5 h-5 text-blue-500 flex-shrink-0"/>
                              :<LinkIcon className="w-5 h-5 text-green-500 flex-shrink-0"/>}
                            <span className="text-sm text-text-primary group-hover:text-primary font-medium">{r.title}</span>
                            <ChevronRight className="w-4 h-4 text-gray-400 ml-auto group-hover:text-primary"/>
                          </a>
                        ))}
                      </div>
                    </div>
                  ):<div className="bg-gray-50 rounded-xl p-4 text-center text-sm text-text-muted">El formador aun no ha subido materiales para esta sesion.</div>}
                </div>

                {/* Retroalimentacion */}
                {gradeMap[selSession.id]?.feedback&&(
                  <div className="card bg-blue-50 border-blue-200">
                    <p className="text-xs font-semibold text-blue-600 uppercase mb-2">Retroalimentacion del formador</p>
                    <p className="text-sm text-blue-800">{gradeMap[selSession.id].feedback}</p>
                  </div>
                )}

                {/* Envio de actividad */}
                <div className="card">
                  <p className="font-bold text-text-primary mb-1 flex items-center gap-2"><Send className="w-4 h-4 text-primary"/> Entregar actividad</p>
                  <p className="text-text-muted text-xs mb-4">Escribe tu respuesta o sube un archivo para esta sesion.</p>
                  {submitMsg&&<div className={clsx("px-3 py-2 rounded-lg text-sm mb-3",submitMsg.includes("Error")?"bg-red-50 text-red-700":"bg-green-50 text-green-700")}>{submitMsg}</div>}
                  {gradeMap[selSession.id]?.submission&&(
                    <div className="bg-yellow-50 border border-yellow-200 rounded-xl p-3 text-sm text-yellow-800 mb-3 flex items-center gap-2">
                      <CheckCircle className="w-4 h-4 flex-shrink-0"/> Ya enviaste una entrega para esta sesion.
                    </div>
                  )}
                  <textarea className="input text-sm resize-none" rows={3} placeholder="Escribe tu respuesta aqui..."
                    value={submitText} onChange={e=>setSubmitText(e.target.value)}/>
                  <div className="flex items-center gap-3 mt-3">
                    <label className="flex items-center gap-2 cursor-pointer bg-gray-50 border border-gray-200 rounded-lg px-3 py-2 text-sm text-text-secondary hover:bg-gray-100 transition-colors flex-1">
                      <Upload className="w-4 h-4 text-primary"/>
                      {submitFile?submitFile.name:"Adjuntar archivo (PDF, imagen...)"}
                      <input type="file" className="hidden" onChange={e=>setSubmitFile(e.target.files?.[0]||null)} accept=".pdf,.doc,.docx,.jpg,.png,.zip"/>
                    </label>
                    <button onClick={handleSubmit} disabled={submitting||(!submitText&&!submitFile)}
                      className="btn-primary flex items-center gap-2 py-2 text-sm flex-shrink-0 disabled:opacity-40">
                      {submitting?<Loader2 className="w-4 h-4 animate-spin"/>:<Send className="w-4 h-4"/>}
                      {submitting?"Enviando...":"Enviar"}
                    </button>
                  </div>
                </div>
              </>
            )}
          </div>
        </div>

        {/* Sabana de notas */}
        <div className="card">
          <h3 className="font-bold text-text-primary mb-1 flex items-center gap-2"><Award className="w-5 h-5 text-primary"/> Sabana de notas</h3>
          <p className="text-text-muted text-xs mb-4">Historial de calificaciones y asistencia por sesion</p>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead><tr className="bg-gray-50">
                <th className="text-left py-2 px-3 font-semibold text-text-secondary rounded-l-xl">Sesion</th>
                <th className="text-center py-2 px-3 font-semibold text-text-secondary">Asistencia</th>
                <th className="text-center py-2 px-3 font-semibold text-text-secondary">Nota</th>
                <th className="text-left py-2 px-3 font-semibold text-text-secondary rounded-r-xl">Retroalimentacion</th>
              </tr></thead>
              <tbody className="divide-y divide-gray-50">
                {grades.map((g:any)=>(
                  <tr key={g.id} className="hover:bg-gray-50">
                    <td className="py-2 px-3 font-medium">{g.title}</td>
                    <td className="py-2 px-3 text-center">
                      <span className={clsx("badge text-xs",g.attendance==="PRESENTE"?"badge-success":g.attendance==="AUSENTE"?"badge-primary":g.attendance==="EXCUSA"?"badge-warning":"badge-muted")}>
                        {g.attendance||"—"}
                      </span>
                    </td>
                    <td className="py-2 px-3 text-center">
                      {g.score!=null
                        ?<span className={clsx("font-bold text-lg",g.score>=60?"text-green-600":"text-red-600")}>{g.score}</span>
                        :g.submission?<span className="badge-warning text-xs">Pendiente</span>:<span className="text-text-muted">—</span>}
                    </td>
                    <td className="py-2 px-3 text-text-secondary text-xs">{g.feedback||"—"}</td>
                  </tr>
                ))}
              </tbody>
              <tfoot><tr className="border-t-2 border-gray-200 bg-gray-50">
                <td className="py-3 px-3 font-bold text-text-primary" colSpan={2}>PROMEDIO GENERAL</td>
                <td className="py-3 px-3 text-center">
                  <span className={clsx("text-xl font-bold",parseFloat(promedio)>=60?"text-green-600":"text-red-600")}>{promedio}</span>
                </td>
                <td className="py-3 px-3 text-xs text-text-muted">{graded} sesiones calificadas</td>
              </tr></tfoot>
            </table>
          </div>
        </div>
      </div>
    </AppShell>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(student)\courses\[id]\page.tsx", $courseViewer, [System.Text.Encoding]::UTF8)
Write-Host "Course viewer (Moodle-style) OK" -ForegroundColor Green

# ─── STUDENT: FORO ───────────────────────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(student)\lobby\forum" | Out-Null
$forum = @'
"use client";
import {useEffect,useState} from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import {useAuth} from "@/contexts/AuthContext";
import {MessageSquare,Send,Plus,ChevronDown,ChevronRight,Loader2,Pin} from "lucide-react";
import clsx from "clsx";
export default function ForumPage() {
  const {user}=useAuth();
  const [courses,setCourses]=useState<any[]>([]); const [selCourse,setSelCourse]=useState<any>(null);
  const [posts,setPosts]=useState<any[]>([]); const [loading,setLoading]=useState(false);
  const [expanded,setExpanded]=useState<string|null>(null);
  const [newPost,setNewPost]=useState({title:"",body:""}); const [replyBody,setReplyBody]=useState<Record<string,string>>({});
  const [posting,setPosting]=useState(false);
  useEffect(()=>{ api.get("/courses/lobby").then(({data})=>{setCourses(data.filter((c:any)=>c.isEnrolled));if(data.filter((c:any)=>c.isEnrolled).length>0)setSelCourse(data.filter((c:any)=>c.isEnrolled)[0]);}); },[]);
  useEffect(()=>{ if(selCourse){setLoading(true);api.get("/forum/course/"+selCourse.id).then(({data})=>setPosts(data)).finally(()=>setLoading(false));} },[selCourse]);
  const submitPost=async()=>{
    if(!newPost.title.trim()) return; setPosting(true);
    await api.post("/forum",{courseId:selCourse.id,...newPost});
    setNewPost({title:"",body:""}); api.get("/forum/course/"+selCourse.id).then(({data})=>setPosts(data)); setPosting(false);
  };
  const submitReply=async(postId:string)=>{
    if(!replyBody[postId]?.trim()) return;
    await api.post("/forum/"+postId+"/replies",{body:replyBody[postId]});
    setReplyBody(prev=>({...prev,[postId]:""}));
    api.get("/forum/course/"+selCourse.id).then(({data})=>setPosts(data));
  };
  const roleLabel=(role:string)=>role==="ADMIN"?"Admin":role==="FORMADOR"?"Formador":"Estudiante";
  const roleBadge=(role:string)=>role==="ADMIN"?"badge-primary":role==="FORMADOR"?"badge-secondary":"badge-muted";
  return (
    <AppShell allowedRoles={["BENEFICIARIO","FORMADOR","ADMIN"]}>
      <div className="max-w-4xl mx-auto space-y-6">
        <div><h1 className="font-display text-3xl font-bold text-text-primary">Foro de discusion</h1>
          <p className="text-text-secondary mt-1">Espacio de participacion para estudiantes, formadores y coordinadores.</p>
        </div>
        {/* Selector de curso */}
        <div className="flex gap-2 flex-wrap">
          {courses.map((c:any)=>(
            <button key={c.id} onClick={()=>setSelCourse(c)}
              className={clsx("px-4 py-2 rounded-full text-sm font-medium transition-colors",
                selCourse?.id===c.id?"bg-primary text-white":"bg-gray-100 text-text-secondary hover:bg-gray-200")}>
              {c.title}
            </button>
          ))}
        </div>
        {selCourse&&(
          <>
            {/* Nuevo post */}
            <div className="card">
              <p className="font-bold text-text-primary mb-3 flex items-center gap-2"><Plus className="w-4 h-4 text-primary"/> Nueva publicacion</p>
              <input className="input mb-2" placeholder="Titulo de tu publicacion..." value={newPost.title} onChange={e=>setNewPost(p=>({...p,title:e.target.value}))}/>
              <textarea className="input resize-none mb-3" rows={3} placeholder="Escribe tu mensaje..." value={newPost.body} onChange={e=>setNewPost(p=>({...p,body:e.target.value}))}/>
              <button onClick={submitPost} disabled={posting||!newPost.title.trim()} className="btn-primary flex items-center gap-2 text-sm disabled:opacity-40">
                {posting?<Loader2 className="w-4 h-4 animate-spin"/>:<Send className="w-4 h-4"/>} Publicar
              </button>
            </div>
            {/* Lista de posts */}
            {loading?<div className="flex justify-center py-10"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div>:(
              <div className="space-y-3">
                {posts.length===0&&<div className="card text-center py-12"><MessageSquare className="w-10 h-10 text-gray-300 mx-auto mb-3"/><p className="text-text-muted">Sin publicaciones aun. Se el primero en participar.</p></div>}
                {posts.map((p:any)=>(
                  <div key={p.id} className="card p-0 overflow-hidden">
                    <button onClick={()=>setExpanded(prev=>prev===p.id?null:p.id)} className="w-full text-left p-4 hover:bg-gray-50 transition-colors flex items-start gap-3">
                      {p.isPinned&&<Pin className="w-4 h-4 text-primary flex-shrink-0 mt-0.5"/>}
                      <div className="flex-1">
                        <div className="flex items-start justify-between gap-2">
                          <p className="font-semibold text-text-primary">{p.title}</p>
                          <span className={clsx("badge text-xs flex-shrink-0",roleBadge(p.author?.role))}>{roleLabel(p.author?.role)}</span>
                        </div>
                        <p className="text-text-secondary text-sm mt-1 line-clamp-2">{p.body}</p>
                        <div className="flex items-center gap-3 mt-2 text-xs text-text-muted">
                          <span>{p.author?.firstName} {p.author?.lastName}</span>
                          <span>{new Date(p.createdAt).toLocaleDateString("es-CO")}</span>
                          <span className="flex items-center gap-1"><MessageSquare className="w-3 h-3"/> {p.replies?.length||0} respuestas</span>
                        </div>
                      </div>
                      {expanded===p.id?<ChevronDown className="w-5 h-5 text-text-muted flex-shrink-0 mt-1"/>:<ChevronRight className="w-5 h-5 text-text-muted flex-shrink-0 mt-1"/>}
                    </button>
                    {expanded===p.id&&(
                      <div className="border-t border-gray-100 bg-gray-50 p-4 space-y-3">
                        {p.replies?.map((r:any)=>(
                          <div key={r.id} className="bg-white rounded-xl p-3 border border-gray-100">
                            <div className="flex items-center gap-2 mb-1">
                              <span className="font-medium text-sm text-text-primary">{r.author?.firstName} {r.author?.lastName}</span>
                              <span className={clsx("badge text-xs",roleBadge(r.author?.role))}>{roleLabel(r.author?.role)}</span>
                              <span className="text-xs text-text-muted ml-auto">{new Date(r.createdAt).toLocaleDateString("es-CO")}</span>
                            </div>
                            <p className="text-sm text-text-secondary">{r.body}</p>
                          </div>
                        ))}
                        <div className="flex gap-2 mt-2">
                          <input className="input text-sm flex-1" placeholder="Escribe una respuesta..."
                            value={replyBody[p.id]||""} onChange={e=>setReplyBody(prev=>({...prev,[p.id]:e.target.value}))}
                            onKeyDown={e=>e.key==="Enter"&&submitReply(p.id)}/>
                          <button onClick={()=>submitReply(p.id)} className="btn-primary px-4 py-2"><Send className="w-4 h-4"/></button>
                        </div>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}
          </>
        )}
      </div>
    </AppShell>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(student)\lobby\forum\page.tsx", $forum, [System.Text.Encoding]::UTF8)
Write-Host "Forum page OK" -ForegroundColor Green

Write-Host ""
Write-Host "============================================" -ForegroundColor Yellow
Write-Host "PARTE 3 COMPLETADA" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Yellow
