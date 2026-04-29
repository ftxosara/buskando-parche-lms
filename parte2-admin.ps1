# ─── ADMIN DASHBOARD MEJORADO ─────────────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\admin" | Out-Null

$adminDash = @'
"use client";
import {useEffect,useState} from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import {Users,BookOpen,TrendingUp,Heart,Loader2,AlertTriangle,CheckCircle,GraduationCap,Award,UserCheck} from "lucide-react";
import {BarChart,Bar,XAxis,YAxis,Tooltip,ResponsiveContainer,Cell,PieChart,Pie,Legend,RadarChart,Radar,PolarGrid,PolarAngleAxis} from "recharts";

function KpiCard({label,value,icon:Icon,color,subtitle,tooltip}:any) {
  const [show,setShow]=useState(false);
  const c:any={red:"bg-red-50 text-red-600 border-red-200",yellow:"bg-yellow-50 text-yellow-600 border-yellow-200",
    green:"bg-green-50 text-green-600 border-green-200",blue:"bg-blue-50 text-blue-600 border-blue-200",
    purple:"bg-purple-50 text-purple-600 border-purple-200"};
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
          {tooltip}
          <div className="absolute top-full left-6 border-4 border-transparent border-t-gray-900"/>
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
  return (
    <AppShell allowedRoles={["ADMIN"]}>
      <div className="max-w-7xl mx-auto space-y-8">
        <div className="flex items-start justify-between">
          <div><h1 className="font-display text-3xl font-bold text-text-primary">Dashboard Administrativo</h1>
            <p className="text-text-secondary mt-1">Pasa el mouse sobre las tarjetas para ver detalles</p>
          </div>
        </div>

        {/* KPIs Row 1 */}
        <div className="grid grid-cols-2 xl:grid-cols-4 gap-4">
          <KpiCard label="Total beneficiarios" value={data?.kpis.totalBeneficiarios} icon={Users} color="red"
            subtitle="de 80 cupos objetivo"
            tooltip={"80 beneficiarios objetivo del contrato. Actualmente: "+data?.kpis.totalBeneficiarios+" inscritos activos. Falta completar: "+(80-data?.kpis.totalBeneficiarios)+" cupos."}/>
          <KpiCard label="% Asistencia global" value={data?.kpis.porcentajeAsistencia} icon={TrendingUp} color="green"
            subtitle="Todas las sesiones registradas"
            tooltip={"Porcentaje de asistencias marcadas como PRESENTE sobre el total de asistencias registradas en todas las sesiones y cursos."}/>
          <KpiCard label="Mujeres inscritas" value={data?.kpis.mujeres} icon={Heart} color="yellow"
            subtitle={data?.kpis.porcentajeMujeres+" del total - Meta: "+data?.kpis.metaMujeres}
            tooltip={"Meta contractual: minimo 50% de participantes deben ser mujeres. Actualmente "+data?.kpis.porcentajeMujeres+". Hombres: "+data?.kpis.hombres+"."}/>
          <KpiCard label="Cursos completados" value={data?.kpis.completados} icon={Award} color="purple"
            subtitle={data?.kpis.porcentajeCompletados+" de finalización"}
            tooltip={"Beneficiarios que han completado su curso asignado y tienen certificado habilitado. Total inscripciones activas: "+data?.kpis.totalEnrollments+"."}/>
        </div>

        {/* Charts Row 1 */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Inscritos + genero por curso */}
          <div className="card lg:col-span-2">
            <h3 className="font-bold text-text-primary mb-1">Inscripciones por curso</h3>
            <p className="text-text-muted text-xs mb-4">Desglose por genero — meta: 50% mujeres por curso</p>
            <ResponsiveContainer width="100%" height={240}>
              <BarChart data={data?.courseKpis} barGap={4}>
                <XAxis dataKey="title" tick={{fill:"#6B7280",fontSize:10}} tickLine={false} axisLine={false}/>
                <YAxis tick={{fill:"#6B7280",fontSize:10}} axisLine={false} tickLine={false}/>
                <Tooltip content={<CustomTooltip/>}/>
                <Legend wrapperStyle={{fontSize:12}}/>
                <Bar dataKey="mujeres" name="Mujeres" fill="#C0392B" radius={[4,4,0,0]} maxBarSize={28}/>
                <Bar dataKey="hombres" name="Hombres" fill="#2563EB" radius={[4,4,0,0]} maxBarSize={28}/>
              </BarChart>
            </ResponsiveContainer>
          </div>

          {/* Grupos poblacionales */}
          <div className="card">
            <h3 className="font-bold text-text-primary mb-1">Grupos poblacionales</h3>
            <p className="text-text-muted text-xs mb-3">Enfoque diferencial</p>
            <ResponsiveContainer width="100%" height={240}>
              <PieChart>
                <Pie data={data?.populationBreakdown} dataKey="cantidad" nameKey="grupo" cx="50%" cy="45%" outerRadius={75} label={({grupo,percent}:any)=>`${(percent*100).toFixed(0)}%`} labelLine={false}>
                  {data?.populationBreakdown?.map((_:any,i:number)=><Cell key={i} fill={PC[i%PC.length]}/>)}
                </Pie>
                <Tooltip formatter={(v:any,n:any)=>[v+" personas",n]}/>
                <Legend wrapperStyle={{fontSize:10}}/>
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Charts Row 2 */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* % Mujeres por curso */}
          <div className="card">
            <h3 className="font-bold text-text-primary mb-1">Meta genero por curso</h3>
            <p className="text-text-muted text-xs mb-4">Linea roja = meta 50%</p>
            <ResponsiveContainer width="100%" height={200}>
              <BarChart data={data?.courseKpis}>
                <XAxis dataKey="title" tick={{fill:"#6B7280",fontSize:10}} tickLine={false} axisLine={false}/>
                <YAxis domain={[0,100]} tick={{fill:"#6B7280",fontSize:10}} axisLine={false} tickLine={false} unit="%"/>
                <Tooltip formatter={(v:any)=>[v+"%","Mujeres"]} content={<CustomTooltip/>}/>
                <Bar dataKey="porcentajeMujeres" name="% Mujeres" radius={[6,6,0,0]} maxBarSize={40}>
                  {data?.courseKpis?.map((c:any,i:number)=>(
                    <Cell key={i} fill={parseFloat(c.porcentajeMujeres)>=50?"#16A34A":"#C0392B"}/>
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>

          {/* Tabla resumen de cursos */}
          <div className="card overflow-hidden p-0">
            <div className="p-5 border-b border-gray-100">
              <h3 className="font-bold text-text-primary">Resumen por curso</h3>
            </div>
            <div className="divide-y divide-gray-50">
              {data?.courseKpis?.map((c:any,i:number)=>(
                <div key={i} className="flex items-center gap-4 px-5 py-3 hover:bg-gray-50 transition-colors">
                  <div className="w-2 h-2 rounded-full flex-shrink-0" style={{background:PC[i%PC.length]}}/>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-text-primary truncate">{c.fullTitle}</p>
                    <p className="text-xs text-text-muted">{c.formador}</p>
                  </div>
                  <div className="text-right flex-shrink-0">
                    <p className="text-sm font-bold text-text-primary">{c.inscritos}</p>
                    <p className="text-xs text-text-muted">{c.porcentajeMujeres}% mujeres</p>
                  </div>
                  <div className={`badge flex-shrink-0 text-xs ${parseFloat(c.porcentajeMujeres)>=50?"badge-success":"badge-primary"}`}>
                    {parseFloat(c.porcentajeMujeres)>=50?"OK":"Riesgo"}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Alerta meta */}
        <div className={`flex items-start gap-4 p-4 rounded-xl border ${data?.kpis.metaMujeres==="Cumplida"?"bg-green-50 border-green-200 text-green-700":"bg-red-50 border-red-200 text-red-700"}`}>
          {data?.kpis.metaMujeres==="Cumplida"?<CheckCircle className="w-5 h-5 mt-0.5"/>:<AlertTriangle className="w-5 h-5 mt-0.5"/>}
          <div>
            <p className="font-semibold text-sm">Meta de paridad de genero — {data?.kpis.metaMujeres}</p>
            <p className="text-sm opacity-80 mt-0.5">
              Contrato exige minimo 50% mujeres. Total beneficiarias: <strong>{data?.kpis.mujeres} ({data?.kpis.porcentajeMujeres})</strong> de {data?.kpis.totalBeneficiarios} inscritos.
            </p>
          </div>
        </div>
      </div>
    </AppShell>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\admin\page.tsx", $adminDash, [System.Text.Encoding]::UTF8)
Write-Host "Admin dashboard mejorado OK" -ForegroundColor Green

# ─── ADMIN USUARIOS (con curso en lugar de grupo) ──────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\admin\users" | Out-Null
$adminUsers = @'
"use client";
import {useEffect,useState} from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import {Search,Download,Loader2,CheckCircle,XCircle,BookOpen,GraduationCap,Award} from "lucide-react";
import clsx from "clsx";
const COURSE_COLORS:Record<string,string>={
  "Marketing Digital Turistico":"bg-orange-100 text-orange-700",
  "Ingles en el Turismo":"bg-blue-100 text-blue-700",
  "Gestion Empresarial":"bg-green-100 text-green-700",
  "Turismo Sostenible":"bg-teal-100 text-teal-700",
};
const SHORT_NAMES:Record<string,string>={
  "Marketing Digital Turistico":"Marketing Digital",
  "Ingles en el Turismo":"Ingles",
  "Gestion Empresarial":"Gestion Empresarial",
  "Turismo Sostenible":"Turismo Sostenible",
};
export default function AdminUsersPage() {
  const [users,setUsers]=useState<any[]>([]); const [loading,setLoading]=useState(true);
  const [search,setSearch]=useState(""); const [roleFilter,setRoleFilter]=useState("BENEFICIARIO");
  const [page,setPage]=useState(1); const [total,setTotal]=useState(0);
  const [msg,setMsg]=useState("");
  const fetchUsers=()=>{ setLoading(true); api.get("/users",{params:{role:roleFilter,page,limit:20}}).then(({data})=>{setUsers(data.data);setTotal(data.total);}).finally(()=>setLoading(false)); };
  useEffect(()=>{ fetchUsers(); },[roleFilter,page]);
  const filtered=users.filter((u:any)=>(u.firstName+" "+u.lastName+" "+u.cedula+" "+u.email).toLowerCase().includes(search.toLowerCase()));
  const exportCSV=()=>{
    const header="Nombre,Cedula,Email,Contrasena,Genero,Curso,Estado\n";
    const rows=users.map((u:any)=>[
      u.firstName+" "+u.lastName,u.cedula,u.email,
      roleFilter==="BENEFICIARIO"?"BuskandoParche2024!":roleFilter==="FORMADOR"?"Formador2024!":"Admin2024!",
      u.gender||"",
      u.enrollments?.[0]?.course?.title||"Sin curso",
      u.isActive?"Activo":"Inactivo"
    ].join(",")).join("\n");
    const blob=new Blob(["\uFEFF"+header+rows],{type:"text/csv;charset=utf-8"});
    const a=document.createElement("a"); a.href=URL.createObjectURL(blob); a.download="usuarios-buskando-parche.csv"; a.click();
    setMsg("CSV exportado correctamente");
  };
  const markComplete=async(userId:string,courseId:string)=>{
    await api.post("/certificates/"+courseId+"/unlock",{userId});
    setMsg("Certificado habilitado"); fetchUsers();
  };
  return (
    <AppShell allowedRoles={["ADMIN"]}>
      <div className="max-w-7xl mx-auto space-y-6">
        <div className="flex items-center justify-between">
          <div><h1 className="font-display text-3xl font-bold text-text-primary">Gestion de Usuarios</h1>
            <p className="text-text-secondary mt-1">Total registrados: <strong>{total}</strong></p>
          </div>
          <button onClick={exportCSV} className="btn-outline flex items-center gap-2 text-sm"><Download className="w-4 h-4"/> Exportar CSV</button>
        </div>
        {msg&&<div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-xl text-sm flex items-center gap-2"><CheckCircle className="w-4 h-4"/>{msg}</div>}
        <div className="card">
          <div className="flex flex-col md:flex-row gap-4 mb-6">
            <div className="relative flex-1"><Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400"/>
              <input className="input pl-10" placeholder="Buscar por nombre, cedula o email..." value={search} onChange={e=>setSearch(e.target.value)}/>
            </div>
            <select className="input w-auto" value={roleFilter} onChange={e=>{setRoleFilter(e.target.value);setPage(1);}}>
              <option value="BENEFICIARIO">Beneficiarios (80)</option>
              <option value="FORMADOR">Formadores (4)</option>
              <option value="ADMIN">Administradores</option>
            </select>
          </div>
          {loading?<div className="flex justify-center py-12"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div>:(
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="bg-gray-50 rounded-xl">
                    <th className="text-left py-3 px-4 font-semibold text-text-secondary rounded-l-xl">Nombre completo</th>
                    <th className="text-left py-3 px-4 font-semibold text-text-secondary">Cedula</th>
                    <th className="text-left py-3 px-4 font-semibold text-text-secondary">Email / Contrasena</th>
                    <th className="text-left py-3 px-4 font-semibold text-text-secondary">Genero</th>
                    <th className="text-left py-3 px-4 font-semibold text-text-secondary">Curso asignado</th>
                    <th className="text-left py-3 px-4 font-semibold text-text-secondary">Estado</th>
                    {roleFilter==="BENEFICIARIO"&&<th className="text-left py-3 px-4 font-semibold text-text-secondary rounded-r-xl">Certificado</th>}
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-50">
                  {filtered.map((u:any)=>{
                    const courseTitle=u.enrollments?.[0]?.course?.title||"";
                    const shortName=SHORT_NAMES[courseTitle]||courseTitle||"Sin inscripcion";
                    const colorClass=COURSE_COLORS[courseTitle]||"bg-gray-100 text-gray-600";
                    return (
                      <tr key={u.id} className="hover:bg-gray-50 transition-colors">
                        <td className="py-3 px-4 font-medium text-text-primary">{u.firstName} {u.lastName}</td>
                        <td className="py-3 px-4 text-text-secondary font-mono text-xs">{u.cedula}</td>
                        <td className="py-3 px-4">
                          <p className="text-text-secondary text-xs">{u.email}</p>
                          <p className="text-text-muted text-xs font-mono">{roleFilter==="BENEFICIARIO"?"BuskandoParche2024!":roleFilter==="FORMADOR"?"Formador2024!":"Admin2024!"}</p>
                        </td>
                        <td className="py-3 px-4">
                          <span className={clsx("badge",u.gender==="FEMENINO"?"bg-pink-100 text-pink-700":u.gender==="MASCULINO"?"badge-info":"badge-muted")}>{u.gender||"N/A"}</span>
                        </td>
                        <td className="py-3 px-4">
                          {courseTitle
                            ?<span className={"badge "+colorClass}><BookOpen className="w-3 h-3"/> {shortName}</span>
                            :<span className="text-text-muted text-xs">Sin inscripcion</span>}
                        </td>
                        <td className="py-3 px-4">
                          {u.isActive
                            ?<span className="badge-success flex items-center gap-1"><CheckCircle className="w-3 h-3"/> Activo</span>
                            :<span className="badge-muted flex items-center gap-1"><XCircle className="w-3 h-3"/> Inactivo</span>}
                        </td>
                        {roleFilter==="BENEFICIARIO"&&(
                          <td className="py-3 px-4">
                            {u.enrollments?.[0]?.status==="COMPLETADO"
                              ?<span className="badge-success flex items-center gap-1"><Award className="w-3 h-3"/> Habilitado</span>
                              :u.enrollments?.[0]?.courseId
                              ?<button onClick={()=>markComplete(u.id,u.enrollments[0].courseId)}
                                  className="text-xs bg-primary text-white px-3 py-1.5 rounded-lg hover:bg-primary-dark transition-colors">
                                  Habilitar cert.
                                </button>
                              :<span className="text-text-muted text-xs">-</span>}
                          </td>
                        )}
                      </tr>
                    );
                  })}
                </tbody>
              </table>
              {filtered.length===0&&<p className="text-center text-text-muted py-8">No se encontraron usuarios</p>}
            </div>
          )}
          <div className="flex items-center justify-between mt-4 pt-4 border-t border-gray-100">
            <p className="text-sm text-text-muted">Mostrando {filtered.length} de {total}</p>
            <div className="flex gap-2">
              <button onClick={()=>setPage(p=>Math.max(1,p-1))} disabled={page===1} className="btn-ghost text-sm disabled:opacity-40">Anterior</button>
              <span className="px-3 py-1 text-sm bg-gray-100 rounded-lg text-text-secondary">Pagina {page}</span>
              <button onClick={()=>setPage(p=>p+1)} disabled={users.length<20} className="btn-ghost text-sm disabled:opacity-40">Siguiente</button>
            </div>
          </div>
        </div>
      </div>
    </AppShell>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\admin\users\page.tsx", $adminUsers, [System.Text.Encoding]::UTF8)
Write-Host "Admin users page OK" -ForegroundColor Green

# ─── ADMIN CURSOS ─────────────────────────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\admin\courses" | Out-Null
$adminCourses = @'
"use client";
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
'@
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\admin\courses\page.tsx", $adminCourses, [System.Text.Encoding]::UTF8)
Write-Host "Admin courses page OK" -ForegroundColor Green

# ─── ADMIN REPORTS ────────────────────────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\admin\reports" | Out-Null
$adminReports = @'
"use client";
import {useEffect,useState} from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import {Download,Loader2,BarChart3,Users,BookOpen,TrendingUp,Heart,FileText} from "lucide-react";
export default function AdminReportsPage() {
  const [data,setData]=useState<any>(null); const [loading,setLoading]=useState(true); const [downloading,setDownloading]=useState(false);
  useEffect(()=>{ api.get("/admin/dashboard").then(({data})=>setData(data)).finally(()=>setLoading(false)); },[]);
  const downloadPDF=async()=>{
    setDownloading(true);
    try {
      const res=await api.get("/admin/report/pdf",{responseType:"blob"});
      const url=window.URL.createObjectURL(new Blob([res.data]));
      const a=document.createElement("a"); a.href=url; a.download="reporte-buskando-parche.pdf"; a.click();
    } finally { setDownloading(false); }
  };
  return (
    <AppShell allowedRoles={["ADMIN"]}>
      <div className="max-w-5xl mx-auto space-y-8">
        <div className="flex items-center justify-between">
          <div><h1 className="font-display text-3xl font-bold text-text-primary">Reportes del Programa</h1>
            <p className="text-text-secondary mt-1">Informacion consolidada del programa de formacion Kennedy.</p>
          </div>
          <button onClick={downloadPDF} disabled={downloading} className="btn-primary flex items-center gap-2">
            {downloading?<Loader2 className="w-4 h-4 animate-spin"/>:<Download className="w-4 h-4"/>}
            {downloading?"Generando...":"Descargar PDF completo"}
          </button>
        </div>
        {loading?<div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div>:(
          <>
            {/* Resumen ejecutivo */}
            <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
              {[
                {label:"Total beneficiarios",value:data?.kpis.totalBeneficiarios,icon:Users,color:"text-primary",bg:"bg-red-50"},
                {label:"Mujeres inscritas",value:data?.kpis.mujeres,icon:Heart,color:"text-yellow-600",bg:"bg-yellow-50"},
                {label:"% Asistencia",value:data?.kpis.porcentajeAsistencia,icon:TrendingUp,color:"text-green-600",bg:"bg-green-50"},
                {label:"Cursos activos",value:data?.kpis.totalCourses,icon:BookOpen,color:"text-blue-600",bg:"bg-blue-50"},
                {label:"Completados",value:data?.kpis.completados,icon:BarChart3,color:"text-purple-600",bg:"bg-purple-50"},
                {label:"Meta genero",value:data?.kpis.porcentajeMujeres,icon:TrendingUp,color:"text-red-600",bg:"bg-red-50"},
              ].map((k,i)=>(
                <div key={i} className="card flex items-center gap-4">
                  <div className={"p-3 rounded-xl "+k.bg}><k.icon className={"w-5 h-5 "+k.color}/></div>
                  <div><p className="text-text-muted text-xs">{k.label}</p><p className="text-xl font-bold text-text-primary">{k.value}</p></div>
                </div>
              ))}
            </div>

            {/* Detalle por curso */}
            <div className="card">
              <h3 className="font-bold text-text-primary mb-4 flex items-center gap-2"><BookOpen className="w-5 h-5 text-primary"/> Detalle por curso</h3>
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead><tr className="bg-gray-50">
                    <th className="text-left py-3 px-4 font-semibold text-text-secondary rounded-l-xl">Curso</th>
                    <th className="text-left py-3 px-4 font-semibold text-text-secondary">Formador</th>
                    <th className="text-center py-3 px-4 font-semibold text-text-secondary">Inscritos</th>
                    <th className="text-center py-3 px-4 font-semibold text-text-secondary">Mujeres</th>
                    <th className="text-center py-3 px-4 font-semibold text-text-secondary">Hombres</th>
                    <th className="text-center py-3 px-4 font-semibold text-text-secondary rounded-r-xl">% Mujeres</th>
                  </tr></thead>
                  <tbody className="divide-y divide-gray-50">
                    {data?.courseKpis?.map((c:any,i:number)=>(
                      <tr key={i} className="hover:bg-gray-50">
                        <td className="py-3 px-4 font-medium text-text-primary">{c.fullTitle}</td>
                        <td className="py-3 px-4 text-text-secondary">{c.formador}</td>
                        <td className="py-3 px-4 text-center font-bold text-text-primary">{c.inscritos}</td>
                        <td className="py-3 px-4 text-center text-pink-600">{c.mujeres}</td>
                        <td className="py-3 px-4 text-center text-blue-600">{c.hombres}</td>
                        <td className="py-3 px-4 text-center">
                          <span className={`badge ${parseFloat(c.porcentajeMujeres)>=50?"badge-success":"badge-primary"}`}>{c.porcentajeMujeres}%</span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>

            {/* Grupos poblacionales */}
            <div className="card">
              <h3 className="font-bold text-text-primary mb-4 flex items-center gap-2"><Users className="w-5 h-5 text-primary"/> Grupos poblacionales (enfoque diferencial)</h3>
              <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
                {data?.populationBreakdown?.map((p:any,i:number)=>(
                  <div key={i} className="bg-gray-50 rounded-xl p-4">
                    <p className="text-xl font-bold text-text-primary">{p.cantidad}</p>
                    <p className="text-sm text-text-muted mt-0.5">{p.grupo}</p>
                    <div className="mt-2 bg-gray-200 rounded-full h-1.5">
                      <div className="bg-primary h-1.5 rounded-full" style={{width:`${Math.min((p.cantidad/data.kpis.totalBeneficiarios)*100,100)}%`}}/>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            <div className="card bg-blue-50 border-blue-200">
              <div className="flex items-start gap-3">
                <FileText className="w-5 h-5 text-blue-600 mt-0.5 flex-shrink-0"/>
                <div>
                  <p className="font-semibold text-blue-800">Descarga el reporte PDF completo</p>
                  <p className="text-sm text-blue-600 mt-1">Incluye: resumen ejecutivo, detalle por curso, listado completo de 80 beneficiarios con cedula, genero y estado. Listo para entregar a la Alcaldia de Kennedy.</p>
                  <button onClick={downloadPDF} disabled={downloading} className="mt-3 btn-primary flex items-center gap-2 text-sm">
                    {downloading?<Loader2 className="w-4 h-4 animate-spin"/>:<Download className="w-4 h-4"/>}
                    {downloading?"Generando PDF...":"Descargar reporte completo PDF"}
                  </button>
                </div>
              </div>
            </div>
          </>
        )}
      </div>
    </AppShell>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\admin\reports\page.tsx", $adminReports, [System.Text.Encoding]::UTF8)
Write-Host "Admin reports page OK" -ForegroundColor Green
