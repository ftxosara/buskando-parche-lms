Write-Host "=== FIX GENERO LGBTIQ+ + PERFIL USUARIOS ===" -ForegroundColor Yellow

# ── 1. ADMIN CONTROLLER: incluir LGBTIQ+ en dashboard ────────
$adminCtrl = 'const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

const getDashboard = async (req, res) => {
  try {
    const [totalBeneficiarios, totalCourses] = await Promise.all([
      prisma.user.count({ where: { role: "BENEFICIARIO", isActive: true } }),
      prisma.course.count({ where: { isPublished: true } }),
    ]);

    // Genero: contar FEMENINO, MASCULINO, LGBTIQ+ (NO_BINARIO + otros)
    const genderRaw = await prisma.user.groupBy({
      by: ["gender"],
      where: { role: "BENEFICIARIO", isActive: true },
      _count: { gender: true },
    });

    let mujeres = 0; let hombres = 0; let lgbtiq = 0;
    genderRaw.forEach(g => {
      const v = g._count.gender;
      const gen = (g.gender || "").toUpperCase();
      if (gen === "FEMENINO") mujeres += v;
      else if (gen === "MASCULINO") hombres += v;
      else lgbtiq += v; // NO_BINARIO, null, otros
    });

    const courseKpis = await prisma.course.findMany({
      where: { isPublished: true },
      select: {
        id: true, title: true, modality: true,
        formador: { select: { firstName: true, lastName: true } },
        enrollments: {
          where: { status: { not: "INACTIVO" } },
          select: { userId: true, user: { select: { gender: true, populationGroup: true } } }
        },
      },
    });

    const attendanceSummary = await prisma.attendance.groupBy({ by: ["status"], _count: { status: true } });
    const attMap = {};
    attendanceSummary.forEach(a => { attMap[a.status] = a._count.status; });
    const totalAtt = Object.values(attMap).reduce((a, b) => a + b, 0);
    const porcentajeAsistencia = totalAtt > 0 ? ((attMap["PRESENTE"] || 0) / totalAtt * 100).toFixed(1) : 0;

    const completados = await prisma.enrollment.count({ where: { status: "COMPLETADO" } });

    const populationBreakdown = await prisma.user.groupBy({
      by: ["populationGroup"],
      where: { role: "BENEFICIARIO", isActive: true },
      _count: { populationGroup: true },
      orderBy: { _count: { populationGroup: "desc" } },
    });

    const pMuj = totalBeneficiarios > 0 ? ((mujeres / totalBeneficiarios) * 100).toFixed(1) : 0;

    const courseData = courseKpis.map(c => {
      const inscritos = c.enrollments.length;
      let muj = 0; let hom = 0; let lbt = 0;
      c.enrollments.forEach(e => {
        const g = (e.user?.gender || "").toUpperCase();
        if (g === "FEMENINO") muj++;
        else if (g === "MASCULINO") hom++;
        else lbt++;
      });
      return {
        id: c.id,
        title: c.title.length > 18 ? c.title.substring(0,16)+".." : c.title,
        fullTitle: c.title,
        modality: c.modality,
        formador: c.formador ? c.formador.firstName+" "+c.formador.lastName : "Sin asignar",
        inscritos,
        mujeres: muj,
        hombres: hom,
        lgbtiq: lbt,
        porcentajeMujeres: inscritos > 0 ? ((muj / inscritos) * 100).toFixed(0) : "0",
        porcentajeInclusivo: inscritos > 0 ? (((muj + lbt) / inscritos) * 100).toFixed(0) : "0",
      };
    });

    return res.json({
      kpis: {
        totalBeneficiarios, mujeres, hombres, lgbtiq,
        porcentajeMujeres: pMuj + "%",
        metaMujeres: parseFloat(pMuj) >= 50 ? "Cumplida" : "En riesgo",
        totalCourses,
        completados,
        porcentajeAsistencia: porcentajeAsistencia + "%",
        porcentajeCompletados: totalBeneficiarios > 0 ? ((completados / totalBeneficiarios) * 100).toFixed(1) + "%" : "0%",
      },
      courseKpis: courseData,
      populationBreakdown: populationBreakdown.map(p => ({
        grupo: p.populationGroup || "Sin clasificar",
        cantidad: p._count.populationGroup,
      })),
    });
  } catch (err) { console.error(err); return res.status(500).json({ error: "Error" }); }
};

const getReport = async (req, res) => {
  try {
    const PDFDocument = require("pdfkit");
    const path = require("path");
    const fs = require("fs");
    const doc = new PDFDocument({ size:"A4", margin:50, bufferPages:true });
    res.setHeader("Content-Type","application/pdf");
    res.setHeader("Content-Disposition","attachment; filename=reporte-buskando-parche.pdf");
    doc.pipe(res);
    const PUB = path.join(__dirname,"../../frontend/public/images");
    const W = doc.page.width;
    doc.rect(0,0,W+100,90).fill("#C0392B");
    const lp = path.join(PUB,"logo.png");
    if (fs.existsSync(lp)) doc.image(lp,45,15,{height:60});
    doc.font("Helvetica-Bold").fontSize(20).fillColor("white").text("BUSKANDO PARCHE - KENNEDY",120,22);
    doc.font("Helvetica").fontSize(11).fillColor("white").text("Reporte General del Programa de Formacion",120,46);
    doc.font("Helvetica").fontSize(9).fillColor("rgba(255,255,255,0.7)").text("Alcaldia Local de Kennedy - Bogota, Colombia",120,63);
    let y = 110;
    doc.font("Helvetica").fontSize(9).fillColor("#888").text("Generado el: "+new Date().toLocaleDateString("es-CO",{year:"numeric",month:"long",day:"numeric"}),50,y); y+=25;
    const [bens,cursos,asist] = await Promise.all([
      prisma.user.findMany({where:{role:"BENEFICIARIO",isActive:true},include:{enrollments:{include:{course:{select:{title:true}}}}},orderBy:{lastName:"asc"}}),
      prisma.course.findMany({where:{isPublished:true},include:{enrollments:{include:{user:{select:{gender:true}}}},formador:{select:{firstName:true,lastName:true}}}}),
      prisma.attendance.groupBy({by:["status"],_count:{status:true}}),
    ]);
    const am={}; asist.forEach(a=>{am[a.status]=a._count.status;});
    const ta=Object.values(am).reduce((a,b)=>a+b,0);
    const pa=ta>0?((am["PRESENTE"]||0)/ta*100).toFixed(1):0;
    const muj=bens.filter(b=>b.gender==="FEMENINO").length;
    const hom=bens.filter(b=>b.gender==="MASCULINO").length;
    const lbt=bens.filter(b=>b.gender!=="FEMENINO"&&b.gender!=="MASCULINO").length;
    doc.rect(50,y,W-100,22).fill("#F3F4F6");
    doc.font("Helvetica-Bold").fontSize(12).fillColor("#C0392B").text("RESUMEN EJECUTIVO",60,y+5); y+=30;
    [[" Total beneficiarios",bens.length,"de 50 cupos"],[" Mujeres",muj,((muj/Math.max(bens.length,1))*100).toFixed(1)+"%"],[" Hombres",hom,((hom/Math.max(bens.length,1))*100).toFixed(1)+"%"],[" LGBTIQ+",lbt,((lbt/Math.max(bens.length,1))*100).toFixed(1)+"%"],[" Asistencia global",pa+"%",ta+" registros"]].forEach(([l,v,s])=>{
      doc.font("Helvetica-Bold").fontSize(10).fillColor("#111").text(l+": ",60,y,{continued:true});
      doc.font("Helvetica").fillColor("#333").text(String(v)+"   ",{continued:true});
      doc.fillColor("#888").text("("+s+")"); y+=17;
    }); y+=15;
    doc.rect(50,y,W-100,22).fill("#F3F4F6");
    doc.font("Helvetica-Bold").fontSize(12).fillColor("#C0392B").text("DETALLE POR CURSO",60,y+5); y+=30;
    cursos.forEach(c=>{
      if(y>700){doc.addPage();y=50;}
      const ins=c.enrollments.length;const mj=c.enrollments.filter(e=>e.user?.gender==="FEMENINO").length;
      doc.fontSize(11).font("Helvetica-Bold").fillColor("#111").text(c.title,60,y);y+=15;
      doc.fontSize(9).font("Helvetica").fillColor("#555").text("Formador: "+(c.formador?c.formador.firstName+" "+c.formador.lastName:"N/A")+"  |  Inscritos: "+ins+"  |  Mujeres: "+mj+" ("+((ins>0?(mj/ins*100).toFixed(0):0))+"%)",70,y);y+=20;
    }); y+=10;
    if(y>650){doc.addPage();y=50;}
    doc.rect(50,y,W-100,22).fill("#F3F4F6");
    doc.font("Helvetica-Bold").fontSize(12).fillColor("#C0392B").text("LISTADO BENEFICIARIOS",60,y+5);y+=30;
    doc.fontSize(8).font("Helvetica-Bold").fillColor("#666");
    doc.text("NOMBRE",60,y);doc.text("CEDULA",210,y);doc.text("GENERO",300,y);doc.text("CURSO",365,y);doc.text("ESTADO",495,y);y+=13;
    doc.moveTo(50,y).lineTo(W-50,y).lineWidth(0.5).stroke("#ddd");y+=7;
    bens.forEach(b=>{
      if(y>760){doc.addPage();y=50;}
      const curso=b.enrollments[0]?.course?.title?.substring(0,20)||"Sin curso";
      doc.fontSize(7.5).font("Helvetica").fillColor("#111");
      doc.text(b.firstName+" "+b.lastName,60,y,{width:142});
      doc.text(b.cedula,210,y);doc.text(b.gender||"-",300,y);
      doc.text(curso,365,y,{width:122});doc.text(b.enrollments[0]?.status||"-",495,y);y+=14;
    });
    const rg=doc.bufferedPageRange();
    for(let i=0;i<rg.count;i++){
      doc.switchToPage(i);
      doc.rect(0,doc.page.height-28,doc.page.width+100,28).fill("#C0392B");
      doc.font("Helvetica").fontSize(8).fillColor("white").text("Buskando Parche - Alcaldia Local de Kennedy",50,doc.page.height-16);
      doc.text("Pagina "+(i+1)+" de "+rg.count,doc.page.width-100,doc.page.height-16,{align:"right"});
    }
    doc.end();
  } catch(err){ console.error(err); if(!res.headersSent) res.status(500).json({error:"Error"}); }
};

module.exports = { getDashboard, getReport };
'
[System.IO.File]::WriteAllText("$PWD\backend\src\controllers\adminController.js", $adminCtrl, [System.Text.Encoding]::UTF8)
Write-Host "adminController con LGBTIQ+ OK" -ForegroundColor Green

# ── 2. DASHBOARD: graficas con LGBTIQ+ ───────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\admin" | Out-Null
$dash = '"use client";
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
}'
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\admin\page.tsx", $dash, [System.Text.Encoding]::UTF8)
Write-Host "Dashboard con LGBTIQ+ OK" -ForegroundColor Green

# ── 3. ENDPOINT: actualizar foto y contrasena de perfil ──────
$profileRoute = 'const router = require("express").Router();
const { authenticate } = require("../middleware/auth");
const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcryptjs");
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const prisma = new PrismaClient();

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = path.join(__dirname,"../../uploads/avatars");
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive:true });
    cb(null, dir);
  },
  filename: (req, file, cb) => cb(null, req.user.id + "-" + Date.now() + path.extname(file.originalname)),
});
const upload = multer({ storage, limits:{fileSize:5*1024*1024}, fileFilter:(req,file,cb)=>{
  if (file.mimetype.startsWith("image/")) cb(null,true);
  else cb(new Error("Solo imagenes"));
}});

// GET /api/profile - ver mi perfil
router.get("/", authenticate, async (req, res) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      select: { id:true, firstName:true, lastName:true, email:true, phone:true, role:true, gender:true, populationGroup:true, locality:true, upz:true, avatarUrl:true, createdAt:true,
        enrollments:{ select:{ status:true, course:{ select:{ title:true, modality:true } } } }
      }
    });
    return res.json(user);
  } catch { return res.status(500).json({ error:"Error" }); }
});

// PUT /api/profile/password - cambiar solo la contrasena
router.put("/password", authenticate, async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;
    if (!newPassword || newPassword.length < 6) return res.status(400).json({ error:"La nueva contrasena debe tener al menos 6 caracteres" });
    const user = await prisma.user.findUnique({ where:{ id:req.user.id } });
    const ok = await bcrypt.compare(currentPassword, user.passwordHash);
    if (!ok) return res.status(401).json({ error:"La contrasena actual es incorrecta" });
    await prisma.user.update({ where:{id:req.user.id}, data:{ passwordHash: await bcrypt.hash(newPassword,12) } });
    return res.json({ message:"Contrasena actualizada" });
  } catch { return res.status(500).json({ error:"Error" }); }
});

// POST /api/profile/avatar - subir foto de perfil
router.post("/avatar", authenticate, upload.single("avatar"), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error:"No se recibio imagen" });
    const avatarUrl = "/uploads/avatars/" + req.file.filename;
    await prisma.user.update({ where:{id:req.user.id}, data:{ avatarUrl } });
    return res.json({ avatarUrl });
  } catch { return res.status(500).json({ error:"Error al subir foto" }); }
});

module.exports = router;
'
[System.IO.File]::WriteAllText("$PWD\backend\src\routes\profile.js", $profileRoute, [System.Text.Encoding]::UTF8)
Write-Host "profile.js OK" -ForegroundColor Green

# Agregar ruta de perfil al index.js
$idx = Get-Content "$PWD\backend\src\index.js" -Raw
if ($idx -notmatch "/api/profile") {
  $idx = $idx -replace "const certRoutes", "const profileRoutes = require('./routes/profile');`nconst certRoutes"
  $idx = $idx -replace "app.use\('/api/certificates'", "app.use('/api/profile', profileRoutes);`napp.use('/api/certificates'"
  [System.IO.File]::WriteAllText("$PWD\backend\src\index.js", $idx, [System.Text.Encoding]::UTF8)
}
Write-Host "index.js con /api/profile OK" -ForegroundColor Green

# ── 4. PAGINA DE PERFIL (beneficiarios y formadores) ─────────
$profilePage = '"use client";
import { useEffect, useState, useRef } from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { useAuth } from "@/contexts/AuthContext";
import { Camera, Lock, CheckCircle, XCircle, Loader2, User, Mail, Phone, BookOpen, MapPin, Eye, EyeOff } from "lucide-react";

export default function ProfilePage() {
  const { user: authUser } = useAuth();
  const [profile, setProfile] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [msg, setMsg] = useState({ text:"", type:"" });
  const [showPwd, setShowPwd] = useState(false);
  const [pwdForm, setPwdForm] = useState({ current:"", new:"", confirm:"" });
  const [savingPwd, setSavingPwd] = useState(false);
  const [uploadingAvatar, setUploadingAvatar] = useState(false);
  const fileRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    api.get("/profile").then(({ data }) => setProfile(data)).finally(() => setLoading(false));
  }, []);

  const ok = (text: string) => { setMsg({text,type:"ok"}); setTimeout(()=>setMsg({text:"",type:""}),4000); };
  const err = (text: string) => setMsg({text,type:"err"});

  const handleAvatar = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setUploadingAvatar(true);
    try {
      const fd = new FormData(); fd.append("avatar", file);
      const { data } = await api.post("/profile/avatar", fd, { headers: { "Content-Type":"multipart/form-data" } });
      setProfile((p: any) => ({ ...p, avatarUrl: data.avatarUrl }));
      ok("Foto de perfil actualizada");
    } catch { err("Error al subir la foto"); }
    finally { setUploadingAvatar(false); }
  };

  const handlePassword = async () => {
    if (pwdForm.new !== pwdForm.confirm) return err("Las contrasenas no coinciden");
    if (pwdForm.new.length < 6) return err("Minimo 6 caracteres");
    setSavingPwd(true);
    try {
      await api.put("/profile/password", { currentPassword: pwdForm.current, newPassword: pwdForm.new });
      ok("Contrasena actualizada correctamente");
      setPwdForm({ current:"", new:"", confirm:"" });
      setShowPwd(false);
    } catch (e: any) { err(e.response?.data?.error || "Error al cambiar contrasena"); }
    finally { setSavingPwd(false); }
  };

  const role = authUser?.role;
  const allowedRoles = role === "FORMADOR" ? ["FORMADOR"] : ["BENEFICIARIO"];

  if (loading) return (
    <AppShell allowedRoles={allowedRoles}>
      <div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div>
    </AppShell>
  );

  const initials = profile ? (profile.firstName[0] + (profile.lastName[0]||"")).toUpperCase() : "?";
  const enrollment = profile?.enrollments?.[0];

  return (
    <AppShell allowedRoles={allowedRoles}>
      <div className="max-w-2xl mx-auto space-y-6">
        <div>
          <h1 className="font-display text-3xl font-bold text-text-primary">Mi Perfil</h1>
          <p className="text-text-secondary mt-1">Gestiona tu foto y contrasena</p>
        </div>

        {msg.text && (
          <div className={`flex items-center gap-3 px-4 py-3 rounded-2xl text-sm font-medium border ${msg.type==="err"?"bg-red-50 border-red-200 text-red-700":"bg-green-50 border-green-200 text-green-700"}`}>
            {msg.type==="err"?<XCircle className="w-4 h-4 flex-shrink-0"/>:<CheckCircle className="w-4 h-4 flex-shrink-0"/>}
            {msg.text}
          </div>
        )}

        {/* Card de perfil */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-6">
          <div className="flex items-start gap-6">
            {/* Avatar */}
            <div className="relative flex-shrink-0">
              <div className="w-24 h-24 rounded-2xl bg-gradient-brand flex items-center justify-center text-white text-3xl font-bold overflow-hidden">
                {profile?.avatarUrl
                  ? <img src={`${process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000"}${profile.avatarUrl}`} alt="Avatar" className="w-full h-full object-cover"/>
                  : initials}
              </div>
              <button onClick={() => fileRef.current?.click()} disabled={uploadingAvatar}
                className="absolute -bottom-2 -right-2 w-8 h-8 bg-primary rounded-full flex items-center justify-center shadow-lg hover:bg-primary-dark transition-colors disabled:opacity-50">
                {uploadingAvatar ? <Loader2 className="w-4 h-4 text-white animate-spin"/> : <Camera className="w-4 h-4 text-white"/>}
              </button>
              <input ref={fileRef} type="file" accept="image/*" className="hidden" onChange={handleAvatar}/>
            </div>

            {/* Info */}
            <div className="flex-1 space-y-3">
              <div>
                <h2 className="text-xl font-bold text-text-primary">{profile?.firstName} {profile?.lastName}</h2>
                <span className={`inline-block mt-1 px-3 py-1 rounded-full text-xs font-semibold ${role==="FORMADOR"?"bg-yellow-100 text-yellow-700":"bg-blue-100 text-blue-700"}`}>
                  {role==="FORMADOR"?"Formador":"Beneficiario"}
                </span>
              </div>

              <div className="grid grid-cols-1 gap-2">
                <div className="flex items-center gap-2 text-sm text-text-secondary">
                  <Mail className="w-4 h-4 text-gray-400 flex-shrink-0"/>
                  <span>{profile?.email}</span>
                </div>
                {profile?.phone && (
                  <div className="flex items-center gap-2 text-sm text-text-secondary">
                    <Phone className="w-4 h-4 text-gray-400 flex-shrink-0"/>
                    <span>{profile.phone}</span>
                  </div>
                )}
                {profile?.locality && (
                  <div className="flex items-center gap-2 text-sm text-text-secondary">
                    <MapPin className="w-4 h-4 text-gray-400 flex-shrink-0"/>
                    <span>{profile.locality}{profile.upz && " - " + profile.upz}</span>
                  </div>
                )}
                {enrollment?.course && (
                  <div className="flex items-center gap-2 text-sm text-text-secondary">
                    <BookOpen className="w-4 h-4 text-gray-400 flex-shrink-0"/>
                    <span>{enrollment.course.title} <span className="text-text-muted">({enrollment.course.modality})</span></span>
                  </div>
                )}
              </div>

              {profile?.gender && (
                <div className="flex items-center gap-2">
                  <span className={`px-2.5 py-1 rounded-full text-xs font-medium ${profile.gender==="FEMENINO"?"bg-pink-50 text-pink-700":profile.gender==="MASCULINO"?"bg-blue-50 text-blue-700":"bg-purple-50 text-purple-700"}`}>
                    {profile.gender==="FEMENINO"?"Mujer":profile.gender==="MASCULINO"?"Hombre":"LGBTIQ+"}
                  </span>
                  {profile.populationGroup && (
                    <span className="px-2.5 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-600">
                      {profile.populationGroup.replace(/_/g," ")}
                    </span>
                  )}
                </div>
              )}
            </div>
          </div>

          <div className="mt-4 pt-4 border-t border-gray-100 flex items-center gap-2 text-xs text-text-muted">
            <Camera className="w-3.5 h-3.5"/>
            Haz clic en la foto para cambiarla. Formatos: JPG, PNG, WebP. Max 5MB.
          </div>
        </div>

        {/* Cambiar contrasena */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-card overflow-hidden">
          <button onClick={() => setShowPwd(!showPwd)}
            className="w-full flex items-center justify-between px-6 py-4 hover:bg-gray-50 transition-colors">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 bg-yellow-100 rounded-xl flex items-center justify-center">
                <Lock className="w-4 h-4 text-yellow-600"/>
              </div>
              <div className="text-left">
                <p className="font-semibold text-text-primary text-sm">Cambiar contrasena</p>
                <p className="text-xs text-text-muted">Actualiza tu clave de acceso</p>
              </div>
            </div>
            <span className={`text-xs font-medium px-3 py-1 rounded-full transition-colors ${showPwd?"bg-primary text-white":"bg-gray-100 text-text-muted"}`}>
              {showPwd?"Cerrar":"Abrir"}
            </span>
          </button>

          {showPwd && (
            <div className="px-6 pb-6 space-y-3 border-t border-gray-100 pt-4">
              <div>
                <label className="block text-xs font-bold text-text-muted mb-1.5">Contrasena actual</label>
                <div className="relative">
                  <input type="password" className="input pr-10" placeholder="Tu contrasena actual"
                    value={pwdForm.current} onChange={e=>setPwdForm(p=>({...p,current:e.target.value}))}/>
                </div>
              </div>
              <div>
                <label className="block text-xs font-bold text-text-muted mb-1.5">Nueva contrasena</label>
                <input type="password" className="input" placeholder="Minimo 6 caracteres"
                  value={pwdForm.new} onChange={e=>setPwdForm(p=>({...p,new:e.target.value}))}/>
              </div>
              <div>
                <label className="block text-xs font-bold text-text-muted mb-1.5">Confirmar nueva contrasena</label>
                <input type="password" className="input" placeholder="Repite la nueva contrasena"
                  value={pwdForm.confirm} onChange={e=>setPwdForm(p=>({...p,confirm:e.target.value}))}/>
                {pwdForm.new && pwdForm.confirm && pwdForm.new !== pwdForm.confirm && (
                  <p className="text-red-500 text-xs mt-1">Las contrasenas no coinciden</p>
                )}
              </div>
              <button onClick={handlePassword}
                disabled={savingPwd || !pwdForm.current || !pwdForm.new || pwdForm.new !== pwdForm.confirm}
                className="btn-primary w-full flex items-center justify-center gap-2 h-11 disabled:opacity-40">
                {savingPwd?<Loader2 className="w-4 h-4 animate-spin"/>:<CheckCircle className="w-4 h-4"/>}
                {savingPwd?"Guardando...":"Actualizar contrasena"}
              </button>
            </div>
          )}
        </div>
      </div>
    </AppShell>
  );
}'

New-Item -ItemType Directory -Force -Path "frontend\src\app\(student)\lobby\profile" | Out-Null
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(student)\lobby\profile\page.tsx", $profilePage, [System.Text.Encoding]::UTF8)
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\formador\profile" | Out-Null
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\formador\profile\page.tsx", $profilePage, [System.Text.Encoding]::UTF8)
Write-Host "Paginas de perfil OK" -ForegroundColor Green

# ── 5. SIDEBAR: agregar Perfil al menu ───────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\components\layout" | Out-Null
$sidebarContent = '"use client";
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
}'
[System.IO.File]::WriteAllText("$PWD\frontend\src\components\layout\Sidebar.tsx", $sidebarContent, [System.Text.Encoding]::UTF8)
Write-Host "Sidebar con Mi Perfil OK" -ForegroundColor Green

# ── 6. SCHEMA: agregar avatarUrl al modelo User ──────────────
$schema = Get-Content "$PWD\backend\prisma\schema.prisma" -Raw
if ($schema -notmatch "avatarUrl") {
  $schema = $schema -replace "isActive\s+Boolean\s+@default\(true\)", "isActive      Boolean   @default(true)`n  avatarUrl     String?"
  [System.IO.File]::WriteAllText("$PWD\backend\prisma\schema.prisma", $schema, [System.Text.Encoding]::UTF8)
  Write-Host "schema.prisma con avatarUrl OK" -ForegroundColor Green
} else { Write-Host "avatarUrl ya existe en schema" -ForegroundColor Gray }

Write-Host ""
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host "FIX GENERO + PERFIL COMPLETO" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Ejecuta (con -v para recrear BD con el nuevo campo avatarUrl):" -ForegroundColor Cyan
Write-Host "  docker-compose down -v" -ForegroundColor White
Write-Host "  docker-compose up --build" -ForegroundColor White
