# ── ADMIN DASHBOARD: grafica grupos corregida + nueva grafica ──
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\admin" | Out-Null

$adminDash = @'
"use client";
import {useEffect,useState} from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import {Users,BookOpen,TrendingUp,Heart,Loader2,AlertTriangle,CheckCircle,Award} from "lucide-react";
import {BarChart,Bar,XAxis,YAxis,Tooltip,ResponsiveContainer,Cell,PieChart,Pie,Legend,LineChart,Line,CartesianGrid,ReferenceLine} from "recharts";

function KpiCard({label,value,icon:Icon,color,subtitle,tooltip}:any) {
  const [show,setShow]=useState(false);
  const c:any={red:"bg-red-50 text-red-600 border-red-200",yellow:"bg-yellow-50 text-yellow-600 border-yellow-200",green:"bg-green-50 text-green-600 border-green-200",blue:"bg-blue-50 text-blue-600 border-blue-200",purple:"bg-purple-50 text-purple-600 border-purple-200"};
  return (
    <div className="card flex items-start gap-4 relative cursor-help hover:shadow-lg transition-all duration-200 hover:-translate-y-0.5"
      onMouseEnter={()=>setShow(true)} onMouseLeave={()=>setShow(false)}>
      <div className={"p-3 rounded-xl border flex-shrink-0 "+c[color]}><Icon className="w-6 h-6"/></div>
      <div className="flex-1">
        <p className="text-text-muted text-sm">{label}</p>
        <p className="text-2xl font-bold font-display text-text-primary mt-0.5">{value}</p>
        {subtitle&&<p className="text-text-muted text-xs mt-1">{subtitle}</p>}
      </div>
      {show&&tooltip&&(
        <div className="absolute bottom-full left-0 mb-2 w-64 bg-gray-900 text-white text-xs rounded-xl p-3 shadow-xl z-50 leading-relaxed">
          {tooltip}<div className="absolute top-full left-6 border-4 border-transparent border-t-gray-900"/>
        </div>
      )}
    </div>
  );
}

const PC=["#C0392B","#2563EB","#16A34A","#D97706","#7C3AED","#EC4899","#0891B2"];

const CustomTooltip=({active,payload,label}:any)=>{
  if(!active||!payload?.length) return null;
  return (
    <div className="bg-white border border-gray-200 rounded-xl p-3 shadow-xl text-sm">
      <p className="font-bold text-text-primary mb-1">{payload[0]?.payload?.fullTitle||label}</p>
      {payload.map((p:any,i:number)=>(
        <p key={i} style={{color:p.color}}>{p.name}: <strong>{p.value}</strong></p>
      ))}
    </div>
  );
};

export default function AdminDashboard() {
  const [data,setData]=useState<any>(null); const [loading,setLoading]=useState(true); const [error,setError]=useState("");
  useEffect(()=>{ api.get("/admin/dashboard").then(({data})=>setData(data)).catch(()=>setError("Error cargando dashboard")).finally(()=>setLoading(false)); },[]);
  if(loading) return <AppShell allowedRoles={["ADMIN"]}><div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div></AppShell>;
  if(error) return <AppShell allowedRoles={["ADMIN"]}><div className="card bg-red-50 border-red-200 text-red-700 flex items-center gap-3"><AlertTriangle className="w-5 h-5"/>{error}</div></AppShell>;

  // Genero: datos para grafica de dona
  const genderData=[
    {name:"Mujeres", value: data?.kpis.mujeres, color:"#C0392B"},
    {name:"Hombres", value: data?.kpis.hombres, color:"#2563EB"},
  ];

  return (
    <AppShell allowedRoles={["ADMIN"]}>
      <div className="max-w-7xl mx-auto space-y-8">
        <div>
          <h1 className="font-display text-3xl font-bold text-text-primary">Dashboard Administrativo</h1>
          <p className="text-text-secondary mt-1">Pasa el mouse sobre las tarjetas para ver detalles</p>
        </div>

        {/* KPIs */}
        <div className="grid grid-cols-2 xl:grid-cols-4 gap-4">
          <KpiCard label="Total beneficiarios" value={data?.kpis.totalBeneficiarios} icon={Users} color="red"
            subtitle="de 80 cupos objetivo"
            tooltip={"80 beneficiarios objetivo. Actualmente: "+data?.kpis.totalBeneficiarios+" activos. Faltan: "+(80-data?.kpis.totalBeneficiarios)+" cupos."}/>
          <KpiCard label="% Asistencia global" value={data?.kpis.porcentajeAsistencia} icon={TrendingUp} color="green"
            subtitle="Todas las sesiones"
            tooltip="Porcentaje de asistencias PRESENTE sobre el total registrado en todas las sesiones."/>
          <KpiCard label="Mujeres inscritas" value={data?.kpis.mujeres} icon={Heart} color="yellow"
            subtitle={data?.kpis.porcentajeMujeres+" — Meta: "+data?.kpis.metaMujeres}
            tooltip={"Meta: minimo 50% mujeres. Actualmente "+data?.kpis.porcentajeMujeres+". Hombres: "+data?.kpis.hombres+"."}/>
          <KpiCard label="Cursos completados" value={data?.kpis.completados} icon={Award} color="purple"
            subtitle={data?.kpis.porcentajeCompletados+" de finalizacion"}
            tooltip={"Beneficiarios con curso completado y certificado habilitado."}/>
        </div>

        {/* Fila 1: Inscritos por curso + Genero global */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="card lg:col-span-2">
            <h3 className="font-bold text-text-primary mb-1">Inscripciones por curso — desglose por genero</h3>
            <p className="text-text-muted text-xs mb-4">Meta: minimo 50% mujeres por curso</p>
            <ResponsiveContainer width="100%" height={230}>
              <BarChart data={data?.courseKpis} barGap={4}>
                <XAxis dataKey="title" tick={{fill:"#6B7280",fontSize:10}} tickLine={false} axisLine={false}/>
                <YAxis tick={{fill:"#6B7280",fontSize:10}} axisLine={false} tickLine={false}/>
                <Tooltip content={<CustomTooltip/>}/>
                <Legend wrapperStyle={{fontSize:11}}/>
                <Bar dataKey="mujeres" name="Mujeres" fill="#C0392B" radius={[4,4,0,0]} maxBarSize={30}/>
                <Bar dataKey="hombres" name="Hombres" fill="#2563EB" radius={[4,4,0,0]} maxBarSize={30}/>
              </BarChart>
            </ResponsiveContainer>
          </div>

          <div className="card">
            <h3 className="font-bold text-text-primary mb-1">Distribucion por genero</h3>
            <p className="text-text-muted text-xs mb-2">Total programa</p>
            <ResponsiveContainer width="100%" height={230}>
              <PieChart>
                <Pie data={genderData} dataKey="value" nameKey="name" cx="50%" cy="45%" innerRadius={55} outerRadius={85} label={({name,percent}:any)=>`${name} ${(percent*100).toFixed(0)}%`} labelLine={false}>
                  {genderData.map((g,i)=><Cell key={i} fill={g.color}/>)}
                </Pie>
                <Tooltip formatter={(v:any,n:any)=>[v+" personas",n]}/>
              </PieChart>
            </ResponsiveContainer>
            <div className="flex justify-center gap-4 mt-2 text-xs">
              <span className="flex items-center gap-1"><span className="w-3 h-3 rounded-full bg-primary inline-block"/> Mujeres: {data?.kpis.mujeres}</span>
              <span className="flex items-center gap-1"><span className="w-3 h-3 rounded-full bg-blue-600 inline-block"/> Hombres: {data?.kpis.hombres}</span>
            </div>
          </div>
        </div>

        {/* Fila 2: % mujeres por curso + grupos poblacionales CORRECTOS */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* % mujeres por curso con barra de referencia */}
          <div className="card">
            <h3 className="font-bold text-text-primary mb-1">Meta de genero por curso</h3>
            <p className="text-text-muted text-xs mb-4">Linea roja = meta 50% — verde = cumplida, rojo = en riesgo</p>
            <ResponsiveContainer width="100%" height={200}>
              <BarChart data={data?.courseKpis} barSize={40}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" vertical={false}/>
                <XAxis dataKey="title" tick={{fill:"#6B7280",fontSize:10}} tickLine={false} axisLine={false}/>
                <YAxis domain={[0,100]} tick={{fill:"#6B7280",fontSize:10}} axisLine={false} tickLine={false} unit="%"/>
                <Tooltip formatter={(v:any)=>[v+"%","Mujeres"]}/>
                <ReferenceLine y={50} stroke="#C0392B" strokeDasharray="5 5" label={{value:"Meta 50%",fill:"#C0392B",fontSize:10}}/>
                <Bar dataKey="porcentajeMujeres" name="% Mujeres" radius={[6,6,0,0]}>
                  {data?.courseKpis?.map((c:any,i:number)=>(
                    <Cell key={i} fill={parseFloat(c.porcentajeMujeres)>=50?"#16A34A":"#C0392B"}/>
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>

          {/* Grupos poblacionales: UNA persona puede tener UN grupo */}
          <div className="card">
            <h3 className="font-bold text-text-primary mb-1">Grupos poblacionales</h3>
            <p className="text-text-muted text-xs mb-3">Enfoque diferencial — cada beneficiario pertenece a un grupo</p>
            <div className="space-y-2.5">
              {data?.populationBreakdown?.map((p:any,i:number)=>(
                <div key={i} className="flex items-center gap-3">
                  <div className="w-3 h-3 rounded-full flex-shrink-0" style={{background:PC[i%PC.length]}}/>
                  <span className="text-sm text-text-secondary w-44 truncate">{p.grupo?.replace(/_/g," ")}</span>
                  <div className="flex-1 bg-gray-100 rounded-full h-2">
                    <div className="h-2 rounded-full transition-all" style={{width:`${Math.min((p.cantidad/data.kpis.totalBeneficiarios)*100,100)}%`,background:PC[i%PC.length]}}/>
                  </div>
                  <span className="text-sm font-bold text-text-primary w-8 text-right">{p.cantidad}</span>
                  <span className="text-xs text-text-muted w-10 text-right">{((p.cantidad/data.kpis.totalBeneficiarios)*100).toFixed(0)}%</span>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Tabla resumen + alerta */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="card overflow-hidden p-0">
            <div className="p-5 border-b border-gray-100"><h3 className="font-bold text-text-primary">Resumen por curso</h3></div>
            <div className="divide-y divide-gray-50">
              {data?.courseKpis?.map((c:any,i:number)=>(
                <div key={i} className="flex items-center gap-4 px-5 py-3 hover:bg-gray-50 transition-colors">
                  <div className="w-2 h-2 rounded-full flex-shrink-0" style={{background:PC[i%PC.length]}}/>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-text-primary truncate">{c.fullTitle}</p>
                    <p className="text-xs text-text-muted">{c.formador}</p>
                  </div>
                  <div className="text-right flex-shrink-0">
                    <p className="text-sm font-bold text-text-primary">{c.inscritos} inscritos</p>
                    <p className="text-xs text-text-muted">{c.mujeres}M / {c.hombres}H</p>
                  </div>
                  <span className={`badge flex-shrink-0 text-xs ${parseFloat(c.porcentajeMujeres)>=50?"badge-success":"badge-primary"}`}>
                    {c.porcentajeMujeres}% M
                  </span>
                </div>
              ))}
            </div>
          </div>

          <div className={`card flex items-start gap-4 ${data?.kpis.metaMujeres==="Cumplida"?"bg-green-50 border-green-200":"bg-red-50 border-red-200"}`}>
            {data?.kpis.metaMujeres==="Cumplida"?<CheckCircle className="w-6 h-6 text-green-600 mt-0.5 flex-shrink-0"/>:<AlertTriangle className="w-6 h-6 text-red-600 mt-0.5 flex-shrink-0"/>}
            <div>
              <p className={`font-bold ${data?.kpis.metaMujeres==="Cumplida"?"text-green-800":"text-red-800"}`}>
                Meta paridad de genero — {data?.kpis.metaMujeres}
              </p>
              <p className={`text-sm mt-1 ${data?.kpis.metaMujeres==="Cumplida"?"text-green-700":"text-red-700"}`}>
                Contrato exige minimo 50% mujeres beneficiarias.<br/>
                Actualmente: <strong>{data?.kpis.mujeres} mujeres ({data?.kpis.porcentajeMujeres})</strong> de {data?.kpis.totalBeneficiarios} inscritos.
              </p>
              <div className="mt-3 grid grid-cols-2 gap-2 text-sm">
                <div className="bg-white/60 rounded-lg p-2 text-center"><p className="font-bold text-lg text-primary">{data?.kpis.mujeres}</p><p className="text-xs text-text-muted">Mujeres</p></div>
                <div className="bg-white/60 rounded-lg p-2 text-center"><p className="font-bold text-lg text-blue-600">{data?.kpis.hombres}</p><p className="text-xs text-text-muted">Hombres</p></div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </AppShell>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\admin\page.tsx", $adminDash, [System.Text.Encoding]::UTF8)
Write-Host "Admin dashboard corregido (grupos + nueva grafica)" -ForegroundColor Green

# ── FORMADOR: panel con cursos bloqueados ─────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\formador" | Out-Null
$formadorMain = @'
"use client";
import {useEffect,useState} from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import {BookOpen,ClipboardList,Lock,Star,Loader2} from "lucide-react";
import Link from "next/link";
import {useAuth} from "@/contexts/AuthContext";
import clsx from "clsx";
export default function FormadorPanel() {
  const {user}=useAuth();
  const [courses,setCourses]=useState<any[]>([]); const [loading,setLoading]=useState(true);
  useEffect(()=>{ api.get("/courses/lobby").then(({data})=>setCourses(data)).finally(()=>setLoading(false)); },[]);
  const myCourse=courses.find((c:any)=>c.isMyCourseFomador);
  const otherCourses=courses.filter((c:any)=>!c.isMyCourseFomador);
  return (
    <AppShell allowedRoles={["FORMADOR"]}>
      <div className="max-w-4xl mx-auto space-y-8">
        <div>
          <h1 className="font-display text-3xl font-bold text-text-primary">Bienvenido, {user?.firstName}</h1>
          <p className="text-text-secondary mt-1">Panel del formador — gestiona tu curso asignado.</p>
        </div>
        {loading?<div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div>:(
          <>
            {/* MI CURSO */}
            {myCourse&&(
              <div>
                <div className="flex items-center gap-2 mb-4"><div className="w-1 h-6 bg-primary rounded-full"/>
                  <h2 className="text-lg font-bold text-text-primary">Mi curso asignado</h2>
                </div>
                <div className="card border-l-4 border-l-primary hover:shadow-lg transition-shadow">
                  <div className="flex items-start gap-4 mb-4">
                    <div className="p-3 bg-red-50 rounded-xl"><BookOpen className="w-7 h-7 text-primary"/></div>
                    <div>
                      <h3 className="font-bold text-xl text-text-primary">{myCourse.title}</h3>
                      <p className="text-text-muted text-sm mt-1">{myCourse.modality==="VIRTUAL"?"Virtual":"Presencial"} — {myCourse.totalSessions} sesiones — {myCourse.totalEnrolled} estudiantes inscritos</p>
                    </div>
                  </div>
                  <div className="grid grid-cols-3 gap-3">
                    <Link href={"/formador/courses?id="+myCourse.id} className="btn-primary flex items-center justify-center gap-2 py-2.5 text-sm"><BookOpen className="w-4 h-4"/> Contenido</Link>
                    <Link href={"/formador/attendance?courseId="+myCourse.id} className="btn-outline flex items-center justify-center gap-2 py-2.5 text-sm"><ClipboardList className="w-4 h-4"/> Asistencia</Link>
                    <Link href={"/formador/grades?courseId="+myCourse.id} className="btn-ghost flex items-center justify-center gap-2 py-2.5 text-sm border border-gray-200 rounded-lg"><Star className="w-4 h-4"/> Calificaciones</Link>
                  </div>
                </div>
              </div>
            )}
            {!myCourse&&!loading&&(
              <div className="card text-center py-12"><BookOpen className="w-12 h-12 text-gray-300 mx-auto mb-3"/><p className="text-text-muted">No tienes un curso asignado. Contacta al administrador.</p></div>
            )}

            {/* OTROS CURSOS BLOQUEADOS */}
            {otherCourses.length>0&&(
              <div>
                <div className="flex items-center gap-2 mb-4"><div className="w-1 h-6 bg-gray-300 rounded-full"/>
                  <h2 className="text-lg font-bold text-text-primary">Otros cursos</h2>
                  <span className="badge-muted">{otherCourses.length} bloqueados</span>
                </div>
                <div className="grid md:grid-cols-3 gap-4">
                  {otherCourses.map((c:any)=>(
                    <div key={c.id} className="card opacity-50 cursor-not-allowed relative overflow-hidden">
                      <div className="absolute inset-0 flex items-center justify-center bg-gray-50/80">
                        <div className="flex flex-col items-center gap-2"><Lock className="w-8 h-8 text-gray-400"/><p className="text-xs text-gray-500 font-medium">Acceso restringido</p></div>
                      </div>
                      <div className="p-3 bg-gray-100 rounded-xl w-fit mb-3"><BookOpen className="w-5 h-5 text-gray-400"/></div>
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
}
'@
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\formador\page.tsx", $formadorMain, [System.Text.Encoding]::UTF8)
Write-Host "Formador panel con cursos bloqueados OK" -ForegroundColor Green

# ── FORMADOR: asistencia corregida ────────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\formador\attendance" | Out-Null
$formAttendance = @'
"use client";
import {useEffect,useState,Suspense} from "react";
import {useSearchParams} from "next/navigation";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import {Loader2,CheckCircle,ClipboardList} from "lucide-react";
import clsx from "clsx";
function AttContent() {
  const params=useSearchParams(); const courseId=params.get("courseId");
  const [course,setCourse]=useState<any>(null); const [selSession,setSelSession]=useState<any>(null);
  const [students,setStudents]=useState<any[]>([]); const [att,setAtt]=useState<Record<string,string>>({});
  const [loading,setLoading]=useState(true); const [saving,setSaving]=useState(false); const [msg,setMsg]=useState("");
  useEffect(()=>{
    if(courseId) api.get("/courses/"+courseId).then(({data})=>{setCourse(data);setLoading(false);}).catch(()=>setLoading(false));
    else setLoading(false);
  },[courseId]);
  const selectSession=async(s:any)=>{
    setSelSession(s); setMsg("");
    try {
      // Obtener inscritos del curso
      const {data:usersData}=await api.get("/users",{params:{role:"BENEFICIARIO",limit:100}});
      const enrolled=usersData.data.filter((u:any)=>u.enrollments?.some((e:any)=>e.courseId===courseId));
      setStudents(enrolled);
      // Cargar asistencia existente
      const {data:attData}=await api.get("/attendance/session/"+s.id);
      const map:Record<string,string>={};
      attData.forEach((a:any)=>{map[a.userId]=a.status;});
      enrolled.forEach((u:any)=>{ if(!map[u.id]) map[u.id]="PRESENTE"; });
      setAtt(map);
    } catch(e) { console.error(e); }
  };
  const save=async()=>{
    setSaving(true);
    try {
      const attendances=students.map(u=>({userId:u.id,status:att[u.id]||"PRESENTE",notes:""}));
      await api.post("/attendance",{sessionId:selSession.id,attendances});
      setMsg("Asistencia guardada correctamente para "+selSession.title);
    } catch { setMsg("Error al guardar"); }
    finally { setSaving(false); }
  };
  if(loading) return <div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div>;
  if(!courseId||!course) return <div className="card text-center py-12"><p className="text-text-muted">Accede desde el panel del formador seleccionando un curso.</p></div>;
  const present=Object.values(att).filter(v=>v==="PRESENTE").length;
  const absent=Object.values(att).filter(v=>v==="AUSENTE").length;
  return (
    <div className="max-w-5xl mx-auto space-y-6">
      <div>
        <h1 className="font-display text-2xl font-bold text-text-primary">Registro de Asistencia</h1>
        <p className="text-text-secondary mt-1">{course?.title}</p>
      </div>
      {msg&&<div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-xl text-sm flex items-center gap-2"><CheckCircle className="w-4 h-4"/>{msg}</div>}
      <div className="grid md:grid-cols-3 gap-6">
        {/* Lista sesiones */}
        <div className="card p-0 overflow-hidden">
          <div className="p-4 bg-gray-50 border-b"><p className="font-semibold text-text-primary text-sm">Selecciona la sesion</p></div>
          <div className="divide-y divide-gray-50 max-h-[480px] overflow-y-auto">
            {course?.sessions?.map((s:any)=>(
              <button key={s.id} onClick={()=>selectSession(s)}
                className={clsx("w-full text-left px-4 py-3 text-sm transition-colors flex items-center gap-3",
                  selSession?.id===s.id?"bg-red-50 border-r-2 border-primary text-primary font-semibold":"hover:bg-gray-50 text-text-secondary")}>
                <span className={clsx("w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0",
                  selSession?.id===s.id?"bg-primary text-white":"bg-gray-100 text-gray-600")}>{s.order}</span>
                {s.title}
              </button>
            ))}
          </div>
        </div>
        {/* Tabla asistencia */}
        <div className="md:col-span-2 space-y-4">
          {!selSession?(
            <div className="card text-center py-12"><ClipboardList className="w-10 h-10 text-gray-300 mx-auto mb-3"/><p className="text-text-muted">Selecciona una sesion para registrar asistencia</p></div>
          ):(
            <div className="card">
              <div className="flex items-center justify-between mb-4">
                <h3 className="font-bold text-text-primary">{selSession.title}</h3>
                <div className="flex gap-2 text-xs">
                  <span className="badge-success">P: {present}</span>
                  <span className="badge-primary">A: {absent}</span>
                  <span className="badge-warning">E: {Object.values(att).filter(v=>v==="EXCUSA").length}</span>
                </div>
              </div>
              {students.length===0&&<p className="text-text-muted text-sm text-center py-4">Cargando estudiantes...</p>}
              <div className="space-y-2 max-h-96 overflow-y-auto">
                {students.map((u:any)=>(
                  <div key={u.id} className={clsx("flex items-center gap-3 py-2.5 px-3 rounded-xl transition-colors",
                    att[u.id]==="PRESENTE"?"bg-green-50":att[u.id]==="AUSENTE"?"bg-red-50":att[u.id]==="EXCUSA"?"bg-yellow-50":"bg-gray-50")}>
                    <div className="flex-1">
                      <p className="text-sm font-medium text-text-primary">{u.firstName} {u.lastName}</p>
                      <p className="text-xs text-text-muted">{u.cedula}</p>
                    </div>
                    <div className="flex gap-1.5">
                      {(["PRESENTE","AUSENTE","EXCUSA"] as const).map(st=>(
                        <button key={st} onClick={()=>setAtt(prev=>({...prev,[u.id]:st}))}
                          className={clsx("w-9 h-8 rounded-lg text-xs font-bold transition-colors",
                            att[u.id]===st
                              ?(st==="PRESENTE"?"bg-green-500 text-white":st==="AUSENTE"?"bg-red-500 text-white":"bg-yellow-500 text-white")
                              :"bg-white border border-gray-200 text-gray-400 hover:border-gray-400")}>
                          {st==="PRESENTE"?"P":st==="AUSENTE"?"A":"E"}
                        </button>
                      ))}
                    </div>
                  </div>
                ))}
              </div>
              <button onClick={save} disabled={saving||students.length===0} className="btn-primary w-full mt-4 flex items-center justify-center gap-2 disabled:opacity-40">
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
Write-Host "Formador attendance corregida" -ForegroundColor Green

# ── FORMADOR: calificaciones corregida ────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\formador\grades" | Out-Null
$formGrades = @'
"use client";
import {useEffect,useState,Suspense} from "react";
import {useSearchParams} from "next/navigation";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import {Loader2,CheckCircle,Star,Download,Plus,Trash2} from "lucide-react";
import clsx from "clsx";

function GradesContent() {
  const params=useSearchParams(); const courseId=params.get("courseId");
  const [course,setCourse]=useState<any>(null); const [selSession,setSelSession]=useState<any>(null);
  const [submissions,setSubmissions]=useState<any[]>([]);
  const [grading,setGrading]=useState<Record<string,{score:string;feedback:string}>>({});
  const [loading,setLoading]=useState(true); const [saving,setSaving]=useState<string|null>(null); const [msg,setMsg]=useState("");
  // Crear examen
  const [showExam,setShowExam]=useState(false);
  const [examTitle,setExamTitle]=useState(""); const [examPass,setExamPass]=useState("60");
  const [questions,setQuestions]=useState<{text:string;options:string[];correct:number;points:number}[]>([
    {text:"",options:["","","",""],correct:0,points:25}
  ]);
  useEffect(()=>{
    if(courseId) api.get("/courses/"+courseId).then(({data})=>{setCourse(data);setLoading(false);}).catch(()=>setLoading(false));
    else setLoading(false);
  },[courseId]);
  const loadSubmissions=async(s:any)=>{
    setSelSession(s); setSubmissions([]);
    try {
      const {data}=await api.get("/assignments/session/"+s.id);
      setSubmissions(data);
      const map:Record<string,{score:string;feedback:string}>={};
      data.forEach((sub:any)=>{map[sub.id]={score:sub.score?.toString()||"",feedback:sub.feedback||""};});
      setGrading(map);
    } catch(e){console.error(e);}
  };
  const saveGrade=async(subId:string)=>{
    setSaving(subId);
    try {
      await api.put("/assignments/"+subId+"/grade",{score:grading[subId]?.score,feedback:grading[subId]?.feedback});
      setMsg("Calificacion guardada");
    } catch { setMsg("Error al calificar"); }
    finally { setSaving(null); }
  };
  const saveExam=async()=>{
    if(!examTitle.trim()||!selSession) return;
    try {
      await api.post("/evaluations",{courseId,sessionId:selSession.id,title:examTitle,questions,passingScore:parseInt(examPass),maxScore:100});
      setMsg("Examen creado correctamente"); setShowExam(false); setExamTitle(""); setExamPass("60");
      setQuestions([{text:"",options:["","","",""],correct:0,points:25}]);
    } catch { setMsg("Error al crear examen"); }
  };
  const addQuestion=()=>setQuestions(prev=>[...prev,{text:"",options:["","","",""],correct:0,points:Math.floor(100/((prev.length+1)))}]);
  const removeQuestion=(i:number)=>setQuestions(prev=>prev.filter((_,idx)=>idx!==i));
  if(loading) return <div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div>;
  if(!courseId||!course) return <div className="card text-center py-12"><p className="text-text-muted">Accede desde el panel del formador.</p></div>;
  return (
    <div className="max-w-5xl mx-auto space-y-6">
      <div><h1 className="font-display text-2xl font-bold text-text-primary">Calificaciones y Examenes</h1><p className="text-text-secondary mt-1">{course?.title}</p></div>
      {msg&&<div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-xl text-sm flex items-center gap-2"><CheckCircle className="w-4 h-4"/>{msg}</div>}
      <div className="grid md:grid-cols-3 gap-6">
        {/* Sesiones */}
        <div className="card p-0 overflow-hidden">
          <div className="p-4 bg-gray-50 border-b"><p className="font-semibold text-text-primary text-sm">Sesiones</p></div>
          <div className="divide-y divide-gray-50 max-h-[500px] overflow-y-auto">
            {course?.sessions?.map((s:any)=>(
              <button key={s.id} onClick={()=>loadSubmissions(s)}
                className={clsx("w-full text-left px-4 py-3 text-sm transition-colors flex items-center gap-3",
                  selSession?.id===s.id?"bg-red-50 border-r-2 border-primary text-primary font-semibold":"hover:bg-gray-50 text-text-secondary")}>
                <span className={clsx("w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0",
                  selSession?.id===s.id?"bg-primary text-white":"bg-gray-100 text-gray-600")}>{s.order}</span>
                {s.title}
              </button>
            ))}
          </div>
        </div>
        {/* Contenido sesion */}
        <div className="md:col-span-2 space-y-4">
          {!selSession?(
            <div className="card text-center py-12"><Star className="w-10 h-10 text-gray-300 mx-auto mb-3"/><p className="text-text-muted">Selecciona una sesion</p></div>
          ):(
            <>
              <div className="flex items-center justify-between">
                <p className="font-semibold text-text-primary">{selSession.title} — {submissions.length} entregas</p>
                <button onClick={()=>setShowExam(!showExam)} className="btn-primary flex items-center gap-2 text-sm py-2">
                  <Plus className="w-4 h-4"/> {showExam?"Cancelar":"Crear examen"}
                </button>
              </div>
              {/* Formulario crear examen */}
              {showExam&&(
                <div className="card space-y-4 border-primary">
                  <h3 className="font-bold text-text-primary flex items-center gap-2"><Star className="w-4 h-4 text-primary"/> Crear examen online</h3>
                  <div className="grid grid-cols-2 gap-3">
                    <input className="input text-sm" placeholder="Titulo del examen" value={examTitle} onChange={e=>setExamTitle(e.target.value)}/>
                    <input className="input text-sm" type="number" placeholder="Nota para aprobar (ej: 60)" value={examPass} onChange={e=>setExamPass(e.target.value)}/>
                  </div>
                  {questions.map((q,qi)=>(
                    <div key={qi} className="border border-gray-200 rounded-xl p-3 space-y-2">
                      <div className="flex items-center gap-2">
                        <span className="badge-primary text-xs">P{qi+1}</span>
                        <input className="input text-sm flex-1" placeholder={"Pregunta "+(qi+1)} value={q.text} onChange={e=>{const nq=[...questions];nq[qi]={...nq[qi],text:e.target.value};setQuestions(nq);}}/>
                        <input className="input text-sm w-20" type="number" placeholder="Pts" value={q.points} onChange={e=>{const nq=[...questions];nq[qi]={...nq[qi],points:parseInt(e.target.value)||0};setQuestions(nq);}}/>
                        {qi>0&&<button onClick={()=>removeQuestion(qi)} className="text-red-400 hover:text-red-600"><Trash2 className="w-4 h-4"/></button>}
                      </div>
                      {q.options.map((opt,oi)=>(
                        <div key={oi} className="flex items-center gap-2 pl-4">
                          <input type="radio" name={"correct-"+qi} checked={q.correct===oi} onChange={()=>{const nq=[...questions];nq[qi]={...nq[qi],correct:oi};setQuestions(nq);}} className="accent-primary"/>
                          <input className="input text-sm flex-1" placeholder={"Opcion "+(oi+1)+" "+(q.correct===oi?"(correcta)":"")} value={opt} onChange={e=>{const nq=[...questions];nq[qi].options[oi]=e.target.value;setQuestions(nq);}}/>
                        </div>
                      ))}
                    </div>
                  ))}
                  <div className="flex gap-3">
                    <button onClick={addQuestion} className="btn-outline flex items-center gap-2 text-sm"><Plus className="w-4 h-4"/> Agregar pregunta</button>
                    <button onClick={saveExam} className="btn-primary flex items-center gap-2 text-sm"><CheckCircle className="w-4 h-4"/> Guardar examen</button>
                  </div>
                </div>
              )}
              {/* Entregas */}
              {submissions.length===0&&<div className="card text-center py-8"><p className="text-text-muted text-sm">Sin entregas para esta sesion</p></div>}
              {submissions.map((sub:any)=>(
                <div key={sub.id} className="card space-y-3">
                  <div className="flex items-start justify-between gap-3">
                    <div>
                      <p className="font-semibold text-text-primary">{sub.user?.firstName} {sub.user?.lastName}</p>
                      <p className="text-xs text-text-muted">{sub.user?.cedula} — {new Date(sub.submittedAt).toLocaleDateString("es-CO")}</p>
                    </div>
                    {sub.score!=null&&<span className={clsx("badge text-base font-bold px-3 py-1",sub.score>=60?"badge-success":"badge-primary")}>{sub.score}/100</span>}
                  </div>
                  {sub.answers?.text&&<div className="bg-gray-50 rounded-xl p-3 text-sm text-text-secondary">{sub.answers.text}</div>}
                  {sub.answers?.fileUrl&&<a href={sub.answers.fileUrl} target="_blank" rel="noopener noreferrer" className="text-primary text-sm flex items-center gap-1"><Download className="w-4 h-4"/> Descargar archivo</a>}
                  <div className="grid grid-cols-2 gap-2">
                    <div><label className="text-xs font-medium text-text-muted mb-1 block">Nota (0-100)</label>
                      <input type="number" min="0" max="100" className="input text-sm" value={grading[sub.id]?.score||""} onChange={e=>setGrading(prev=>({...prev,[sub.id]:{...prev[sub.id],score:e.target.value}}))}/></div>
                    <div><label className="text-xs font-medium text-text-muted mb-1 block">Retroalimentacion</label>
                      <input type="text" className="input text-sm" placeholder="Comentario" value={grading[sub.id]?.feedback||""} onChange={e=>setGrading(prev=>({...prev,[sub.id]:{...prev[sub.id],feedback:e.target.value}}))}/></div>
                  </div>
                  <button onClick={()=>saveGrade(sub.id)} disabled={saving===sub.id} className="btn-primary w-full flex items-center justify-center gap-2 py-2 text-sm">
                    {saving===sub.id?<Loader2 className="w-4 h-4 animate-spin"/>:<CheckCircle className="w-4 h-4"/>} Guardar calificacion
                  </button>
                </div>
              ))}
            </>
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
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\formador\grades\page.tsx", $formGrades, [System.Text.Encoding]::UTF8)
Write-Host "Formador grades corregida con crear examenes" -ForegroundColor Green

# ── IMAGEN MAPEO CURSOS (solo 4 cursos correctos) ─────────────
# Actualizar lobby con nombres correctos de cursos
$lobbyFix = (Get-Content "$PWD\frontend\src\app\(student)\lobby\page.tsx" -Raw)
$lobbyFix = $lobbyFix -replace '"Marketing Digital Turistico"', '"Marketing Digital"'
$lobbyFix = $lobbyFix -replace '"Ingles en el Turismo"', '"Ingles en el Turismo"'
$lobbyFix = $lobbyFix -replace '"Gestion Empresarial"', '"Gestion Empresarial"'
$lobbyFix = $lobbyFix -replace '"Turismo Sostenible"', '"Gestion Turistica"'
# Fix image map
$lobbyFix = $lobbyFix -replace 'const imgs[^=]+=.*?;', @'
const imgs: Record<string,string> = {
  "Marketing Digital":     "/images/marketing.jpg",
  "Ingles en el Turismo":  "/images/ingles.jpg",
  "Gestion Empresarial":   "/images/gestion.jpg",
  "Gestion Turistica":     "/images/turismo.jpg",
};
'@
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(student)\lobby\page.tsx", $lobbyFix, [System.Text.Encoding]::UTF8)
Write-Host "Lobby imagenes corregidas" -ForegroundColor Green

# ── NEXT.CONFIG: quitar appDir obsoleto ───────────────────────
$nextCfg = @'
/** @type {import("next").NextConfig} */
const nextConfig = {
  images: { domains: ["localhost"] },
};
module.exports = nextConfig;
'@
[System.IO.File]::WriteAllText("$PWD\frontend\next.config.js", $nextCfg, [System.Text.Encoding]::UTF8)
Write-Host "next.config.js corregido (sin appDir obsoleto)" -ForegroundColor Green

Write-Host ""
Write-Host "============================================================" -ForegroundColor Yellow
Write-Host "PARTE 2 COMPLETA" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Yellow
