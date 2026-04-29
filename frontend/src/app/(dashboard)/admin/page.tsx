"use client";
import { useEffect, useState } from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { Users, TrendingUp, Heart, Loader2, AlertTriangle, CheckCircle, Award, Rainbow } from "lucide-react";
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, Cell, PieChart, Pie, CartesianGrid, ReferenceLine, Legend } from "recharts";

const COLORS = ["#C0392B","#2563EB","#16A34A","#D97706","#7C3AED","#EC4899","#0891B2"];

function AnimatedNum({ target, suffix="" }: { target:number; suffix?:string }) {
  const [v, setV] = useState(0);
  useEffect(() => {
    if (!target) return;
    let n = 0; const step = Math.max(1, Math.ceil(target/50));
    const t = setInterval(() => { n = Math.min(n+step, target); setV(n); if (n>=target) clearInterval(t); }, 20);
    return () => clearInterval(t);
  }, [target]);
  return <>{v}{suffix}</>;
}

function KpiCard({ label, value, suffix="", icon:Icon, gradient, hover }: any) {
  const [show, setShow] = useState(false);
  const num = parseFloat(String(value)) || 0;
  return (
    <div className="relative rounded-2xl p-5 overflow-hidden cursor-pointer transition-all duration-300 hover:-translate-y-1.5 hover:shadow-2xl"
      style={{ background: gradient }}
      onMouseEnter={() => setShow(true)} onMouseLeave={() => setShow(false)}>
      <div className="absolute -right-5 -top-5 w-28 h-28 rounded-full bg-white/10" />
      <div className="absolute -right-2 bottom-0 w-20 h-20 rounded-full bg-white/5" />
      <div className="relative z-10 flex items-start justify-between">
        <div>
          <p className="text-white/70 text-xs font-semibold uppercase tracking-wider mb-2">{label}</p>
          <p className="text-4xl font-black text-white"><AnimatedNum target={num} suffix={suffix} /></p>
        </div>
        <div className="bg-white/20 backdrop-blur-sm p-3 rounded-2xl"><Icon className="w-6 h-6 text-white" /></div>
      </div>
      {show && hover && (
        <div className="absolute inset-x-0 bottom-full mb-2 mx-2 z-50">
          <div className="bg-gray-950 text-white rounded-2xl p-4 shadow-2xl border border-white/10">
            <p className="font-bold text-sm mb-2 text-white/90 border-b border-white/10 pb-2">{label}</p>
            {hover.map((h:any,i:number) => (
              <div key={i} className="flex items-center justify-between py-1 border-b border-white/5 last:border-0">
                <span className="text-xs text-white/60">{h.k}</span>
                <span className="text-xs font-bold text-white">{h.v}</span>
              </div>
            ))}
          </div>
          <div className="absolute top-full left-1/2 -translate-x-1/2 border-4 border-transparent border-t-gray-950" />
        </div>
      )}
    </div>
  );
}

const RechartTooltip = ({ active, payload, label }: any) => {
  if (!active||!payload?.length) return null;
  return (
    <div className="bg-white border border-gray-100 rounded-xl p-3 shadow-xl text-xs min-w-36">
      <p className="font-bold text-gray-800 mb-2 pb-1 border-b border-gray-100">{payload[0]?.payload?.fullTitle||label}</p>
      {payload.map((p:any,i:number) => (
        <div key={i} className="flex items-center justify-between gap-4 mt-1">
          <span className="flex items-center gap-1.5 text-gray-500">
            <span className="w-2 h-2 rounded-full" style={{background:p.fill||p.color}}/>
            {p.name}
          </span>
          <span className="font-bold text-gray-900">{p.value}{p.unit||""}</span>
        </div>
      ))}
    </div>
  );
};

export default function AdminDashboard() {
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => { api.get("/admin/dashboard").then(({data})=>setData(data)).finally(()=>setLoading(false)); }, []);

  if (loading) return (
    <AppShell allowedRoles={["ADMIN"]}>
      <div className="flex flex-col items-center gap-3 justify-center py-32">
        <Loader2 className="w-10 h-10 text-primary animate-spin"/>
        <p className="text-text-muted text-sm animate-pulse">Cargando datos del programa...</p>
      </div>
    </AppShell>
  );

  const metaOk = data?.kpis.metaMujeres === "Cumplida";
  const pMuj = parseFloat(data?.kpis.porcentajeMujeres) || 0;
  const pAsist = parseFloat(data?.kpis.porcentajeAsistencia) || 0;
  const total = data?.kpis.totalBeneficiarios || 1;

  // Datos dona genero (3 categorias)
  const donaData = [
    { name:"Mujeres",  value: data?.kpis.mujeres||0,  fill:"#C0392B" },
    { name:"Hombres",  value: data?.kpis.hombres||0,  fill:"#2563EB" },
    { name:"LGBTIQ+",  value: data?.kpis.lgbtiq||0,   fill:"#7C3AED" },
  ].filter(d=>d.value>0);

  return (
    <AppShell allowedRoles={["ADMIN"]}>
      <div className="max-w-7xl mx-auto space-y-7">
        <div className="flex items-end justify-between">
          <div>
            <h1 className="font-display text-3xl font-bold text-text-primary">Dashboard Administrativo</h1>
            <p className="text-text-muted text-sm mt-1 flex items-center gap-2">
              <span className="inline-block w-2 h-2 rounded-full bg-green-500 animate-pulse"/>
              Pasa el mouse sobre las cards para ver detalles
            </p>
          </div>
          <span className="text-xs text-text-muted bg-gray-100 px-3 py-1.5 rounded-full">
            {new Date().toLocaleDateString("es-CO",{weekday:"long",day:"numeric",month:"long",year:"numeric"})}
          </span>
        </div>

        {/* KPIs */}
        <div className="grid grid-cols-2 xl:grid-cols-4 gap-4">
          <KpiCard label="Beneficiarios" value={data?.kpis.totalBeneficiarios} icon={Users}
            gradient="linear-gradient(135deg,#C0392B,#7B0000)"
            hover={[
              {k:"Meta del programa",v:"50 personas"},
              {k:"Activos",v:data?.kpis.totalBeneficiarios},
              {k:"Mujeres",v:data?.kpis.mujeres+" ("+data?.kpis.porcentajeMujeres+")"},
              {k:"Hombres",v:data?.kpis.hombres},
              {k:"LGBTIQ+",v:data?.kpis.lgbtiq},
            ]}/>
          <KpiCard label="Asistencia" value={pAsist} suffix="%" icon={TrendingUp}
            gradient="linear-gradient(135deg,#16A34A,#064E3B)"
            hover={[
              {k:"Porcentaje global",v:data?.kpis.porcentajeAsistencia},
              {k:"P=Presente",v:"A=Ausente  E=Excusa"},
            ]}/>
          <KpiCard label="Mujeres inscritas" value={data?.kpis.mujeres} icon={Heart}
            gradient="linear-gradient(135deg,#D97706,#7C2D12)"
            hover={[
              {k:"Total mujeres",v:data?.kpis.mujeres},
              {k:"Porcentaje",v:data?.kpis.porcentajeMujeres},
              {k:"Meta contractual",v:"minimo 50%"},
              {k:"Estado meta",v:data?.kpis.metaMujeres},
            ]}/>
          <KpiCard label="LGBTIQ+" value={data?.kpis.lgbtiq} icon={Rainbow}
            gradient="linear-gradient(135deg,#7C3AED,#3B0764)"
            hover={[
              {k:"No binario / Otro genero",v:data?.kpis.lgbtiq},
              {k:"Del total inscritos",v:data?.kpis.lgbtiq>0?(data?.kpis.lgbtiq/total*100).toFixed(1)+"%":"0%"},
              {k:"Enfoque diferencial",v:"Incluido en metas"},
            ]}/>
        </div>

        {/* Fila 1: Barras + Dona */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
          <div className="lg:col-span-2 bg-white rounded-2xl border border-gray-100 shadow-card p-6">
            <div className="flex items-center justify-between mb-5">
              <div>
                <h3 className="font-bold text-text-primary">Inscripciones por curso</h3>
                <p className="text-xs text-text-muted mt-0.5">Mujeres / Hombres / LGBTIQ+</p>
              </div>
              <div className="flex gap-3 text-xs flex-wrap justify-end">
                <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-full bg-primary"/>Mujeres</span>
                <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-full bg-blue-600"/>Hombres</span>
                <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-full bg-purple-600"/>LGBTIQ+</span>
              </div>
            </div>
            <ResponsiveContainer width="100%" height={220}>
              <BarChart data={data?.courseKpis} margin={{top:5,right:5,left:-20,bottom:5}} barGap={3}>
                <CartesianGrid strokeDasharray="2 4" stroke="#F3F4F6" vertical={false}/>
                <XAxis dataKey="title" tick={{fill:"#9CA3AF",fontSize:10}} tickLine={false} axisLine={false}/>
                <YAxis tick={{fill:"#9CA3AF",fontSize:10}} axisLine={false} tickLine={false}/>
                <Tooltip content={<RechartTooltip/>} cursor={{fill:"rgba(0,0,0,0.03)"}}/>
                <Bar dataKey="mujeres" name="Mujeres" fill="#C0392B" radius={[4,4,0,0]} maxBarSize={22}/>
                <Bar dataKey="hombres" name="Hombres" fill="#2563EB" radius={[4,4,0,0]} maxBarSize={22}/>
                <Bar dataKey="lgbtiq"  name="LGBTIQ+" fill="#7C3AED" radius={[4,4,0,0]} maxBarSize={22}/>
              </BarChart>
            </ResponsiveContainer>
          </div>

          <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-6 flex flex-col">
            <h3 className="font-bold text-text-primary mb-1">Identidad de genero</h3>
            <p className="text-xs text-text-muted mb-2">Total del programa</p>
            <div className="flex-1 flex items-center justify-center">
              <ResponsiveContainer width="100%" height={170}>
                <PieChart margin={{top:0,right:0,bottom:0,left:0}}>
                  <Pie data={donaData} dataKey="value" nameKey="name" cx="50%" cy="50%"
                    innerRadius={50} outerRadius={72} paddingAngle={3} startAngle={90} endAngle={-270}>
                    {donaData.map((d,i)=><Cell key={i} fill={d.fill}/>)}
                  </Pie>
                  <Tooltip formatter={(v:any,n:any)=>[v+" personas",n]} contentStyle={{borderRadius:12,fontSize:12}}/>
                </PieChart>
              </ResponsiveContainer>
            </div>
            <div className="grid grid-cols-3 gap-1.5 mt-1">
              {[
                {label:"Mujeres",value:data?.kpis.mujeres,color:"bg-primary",textColor:"text-primary",bg:"bg-red-50"},
                {label:"Hombres",value:data?.kpis.hombres,color:"bg-blue-600",textColor:"text-blue-600",bg:"bg-blue-50"},
                {label:"LGBTIQ+",value:data?.kpis.lgbtiq,color:"bg-purple-600",textColor:"text-purple-600",bg:"bg-purple-50"},
              ].map((g,i)=>(
                <div key={i} className={"rounded-xl p-2 text-center border "+g.bg}>
                  <p className={"text-lg font-bold "+g.textColor}>{g.value}</p>
                  <p className="text-xs text-text-muted leading-tight">{g.label}</p>
                  <p className={"text-xs font-semibold "+g.textColor}>{total>0?(g.value/total*100).toFixed(0)+"%":"0%"}</p>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Fila 2: Meta genero + Grupos */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
          <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-6">
            <h3 className="font-bold text-text-primary mb-1">Meta de genero por curso</h3>
            <p className="text-xs text-text-muted mb-5">Verde = cumplida (>=50%) - Rojo = en riesgo - Incluye LGBTIQ+</p>
            <ResponsiveContainer width="100%" height={195}>
              <BarChart data={data?.courseKpis} margin={{top:5,right:20,left:-20,bottom:5}} barSize={36}>
                <CartesianGrid strokeDasharray="2 4" stroke="#F3F4F6" vertical={false}/>
                <XAxis dataKey="title" tick={{fill:"#9CA3AF",fontSize:10}} tickLine={false} axisLine={false}/>
                <YAxis domain={[0,100]} tick={{fill:"#9CA3AF",fontSize:10}} axisLine={false} tickLine={false} unit="%"/>
                <Tooltip formatter={(v:any,n:any)=>[v+"%",n]} contentStyle={{borderRadius:12,fontSize:12}}/>
                <ReferenceLine y={50} stroke="#C0392B" strokeDasharray="5 3" strokeWidth={1.5}
                  label={{value:"Meta 50%",fill:"#C0392B",fontSize:9,position:"insideTopRight"}}/>
                <Bar dataKey="porcentajeInclusivo" name="Mujeres + LGBTIQ+" unit="%" radius={[6,6,0,0]}>
                  {data?.courseKpis?.map((c:any,i:number)=>(
                    <Cell key={i} fill={parseFloat(c.porcentajeInclusivo)>=50?"#16A34A":"#C0392B"}/>
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>

          <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-6">
            <h3 className="font-bold text-text-primary mb-1">Grupos poblacionales</h3>
            <p className="text-xs text-text-muted mb-4">Enfoque diferencial por beneficiario</p>
            <div className="space-y-3 max-h-52 overflow-y-auto pr-1">
              {data?.populationBreakdown?.map((p:any,i:number)=>{
                const pct=(p.cantidad/total*100);
                return (
                  <div key={i} className="group cursor-default">
                    <div className="flex items-center justify-between mb-1">
                      <span className="text-xs font-medium text-text-secondary flex items-center gap-2">
                        <span className="w-2 h-2 rounded-full flex-shrink-0" style={{background:COLORS[i%COLORS.length]}}/>
                        {p.grupo?.replace(/_/g," ")}
                      </span>
                      <span className="text-xs font-bold text-text-primary">
                        {p.cantidad} <span className="text-text-muted font-normal">({pct.toFixed(0)}%)</span>
                      </span>
                    </div>
                    <div className="h-2.5 bg-gray-100 rounded-full overflow-hidden">
                      <div className="h-full rounded-full transition-all duration-700"
                        style={{width:Math.min(pct,100)+"%",background:COLORS[i%COLORS.length]}}/>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>

        {/* Tabla resumen + indicadores */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
          <div className="lg:col-span-2 bg-white rounded-2xl border border-gray-100 shadow-card overflow-hidden">
            <div className="px-5 py-4 border-b border-gray-50 flex items-center justify-between">
              <h3 className="font-bold text-text-primary">Resumen por curso</h3>
              <span className="text-xs text-text-muted bg-gray-50 px-2.5 py-1 rounded-full">{data?.courseKpis?.length} cursos</span>
            </div>
            <div className="divide-y divide-gray-50">
              {data?.courseKpis?.map((c:any,i:number)=>(
                <div key={i} className="flex items-center gap-3 px-5 py-3.5 hover:bg-gray-50/80 transition-colors group">
                  <div className="w-1.5 h-10 rounded-full flex-shrink-0" style={{background:COLORS[i%COLORS.length]}}/>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-semibold text-text-primary truncate">{c.fullTitle}</p>
                    <p className="text-xs text-text-muted">{c.formador}</p>
                  </div>
                  <div className="flex items-center gap-3 flex-shrink-0">
                    <div className="text-right">
                      <p className="text-sm font-bold text-text-primary">{c.inscritos}</p>
                      <p className="text-xs text-text-muted">inscritos</p>
                    </div>
                    <div className="text-right opacity-0 group-hover:opacity-100 transition-opacity">
                      <p className="text-xs text-pink-600 font-semibold">{c.mujeres}F {c.lgbtiq>0&&<span className="text-purple-600">{c.lgbtiq}L</span>}</p>
                      <p className="text-xs text-blue-600 font-semibold">{c.hombres}M</p>
                    </div>
                    <span className={"badge text-xs "+(parseFloat(c.porcentajeInclusivo)>=50?"badge-success":"badge-primary")}>
                      {c.porcentajeInclusivo}%
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="space-y-4">
            <div className={"rounded-2xl p-5 border "+(metaOk?"bg-gradient-to-br from-green-50 to-white border-green-200":"bg-gradient-to-br from-red-50 to-white border-red-200")}>
              <div className="flex items-center gap-2 mb-3">
                {metaOk?<CheckCircle className="w-5 h-5 text-green-600"/>:<AlertTriangle className="w-5 h-5 text-red-600"/>}
                <p className={"font-bold text-sm "+(metaOk?"text-green-800":"text-red-800")}>Meta de inclusion - {data?.kpis.metaMujeres}</p>
              </div>
              <div className="flex items-center gap-3">
                <div className="relative w-14 h-14 flex-shrink-0">
                  <svg viewBox="0 0 36 36" className="w-14 h-14 -rotate-90">
                    <circle cx="18" cy="18" r="15.9" fill="none" stroke="#E5E7EB" strokeWidth="2.5"/>
                    <circle cx="18" cy="18" r="15.9" fill="none" stroke={metaOk?"#16A34A":"#C0392B"} strokeWidth="2.5"
                      strokeDasharray={Math.min(pMuj,100)+" 100"} strokeLinecap="round"/>
                  </svg>
                  <span className={"absolute inset-0 flex items-center justify-center text-xs font-bold "+(metaOk?"text-green-700":"text-red-700")}>{pMuj.toFixed(0)}%</span>
                </div>
                <div>
                  <p className="text-xs text-text-muted">Meta: minimo 50%</p>
                  <p className={"text-sm font-bold "+(metaOk?"text-green-600":"text-red-600")}>{data?.kpis.mujeres} mujeres</p>
                  <p className="text-xs text-text-muted">{data?.kpis.lgbtiq} LGBTIQ+ inscritos</p>
                </div>
              </div>
            </div>
            <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-4">
              <h4 className="text-xs font-bold text-text-muted uppercase mb-3 tracking-wide">Asistencia global</h4>
              <div className="flex items-center gap-3">
                <div className="relative w-14 h-14 flex-shrink-0">
                  <svg viewBox="0 0 36 36" className="w-14 h-14 -rotate-90">
                    <circle cx="18" cy="18" r="15.9" fill="none" stroke="#E5E7EB" strokeWidth="2.5"/>
                    <circle cx="18" cy="18" r="15.9" fill="none" stroke="#16A34A" strokeWidth="2.5"
                      strokeDasharray={Math.min(pAsist,100)+" 100"} strokeLinecap="round"/>
                  </svg>
                  <span className="absolute inset-0 flex items-center justify-center text-xs font-bold text-green-700">{pAsist.toFixed(0)}%</span>
                </div>
                <div>
                  <p className="text-xs text-text-muted">Promedio todas las sesiones</p>
                  <p className="text-lg font-bold text-green-600">{data?.kpis.porcentajeAsistencia}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </AppShell>
  );
}