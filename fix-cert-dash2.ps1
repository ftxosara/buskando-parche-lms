Write-Host "=== FIX CERTIFICADO + DASHBOARD HOVER ===" -ForegroundColor Yellow

# ── CERTIFICADO: solo escribe nombre, curso y fecha sobre la plantilla
# Sin ningun otro texto ya que todo lo demas ya esta en la imagen
$certRoute = 'const router = require("express").Router();
const { authenticate, authorize } = require("../middleware/auth");
const { PrismaClient } = require("@prisma/client");
const PDFDocument = require("pdfkit");
const path = require("path");
const fs = require("fs");
const prisma = new PrismaClient();

async function generateCertPDF(enrollment, res) {
  const { user, course } = enrollment;
  const fullName = (user.firstName + " " + user.lastName).toUpperCase();
  const courseTitle = course.title.toUpperCase();
  const dateStr = enrollment.completedAt
    ? new Date(enrollment.completedAt).toLocaleDateString("es-CO", { year:"numeric", month:"long", day:"numeric" })
    : new Date().toLocaleDateString("es-CO", { year:"numeric", month:"long", day:"numeric" });

  const W = 841.89; const H = 595.28;
  const doc = new PDFDocument({ size: "A4", layout: "landscape", margin: 0 });
  res.setHeader("Content-Type", "application/pdf");
  res.setHeader("Content-Disposition", "attachment; filename=certificado-" + user.cedula + ".pdf");
  doc.pipe(res);

  const PUB = path.join(__dirname, "../../frontend/public/images");
  const tryPaths = [
    path.join(PUB, "certificado.jpeg"),
    path.join(PUB, "certificado.jpg"),
    path.join(PUB, "certificado.png"),
  ];

  let bgFound = false;
  for (const bp of tryPaths) {
    if (fs.existsSync(bp)) {
      // Usar la imagen completa como fondo - ya contiene todo el diseño y las firmas
      doc.image(bp, 0, 0, { width: W, height: H });
      bgFound = true;
      break;
    }
  }

  if (bgFound) {
    // CON PLANTILLA: solo escribir los 3 campos variables
    // La plantilla ya tiene: titulo, subtitulo, textos fijos y FIRMAS
    // Solo llenamos los espacios en blanco

    // 1. NOMBRE DEL BENEFICIARIO (linea en blanco debajo de "Este certificado se entrega a:")
    //    Ajusta el valor Y si el nombre no cae exactamente en la linea
    doc.font("Helvetica-Bold").fontSize(20).fillColor("#C0392B")
      .text(fullName, 80, 192, { width: W - 160, align: "center" });

    // 2. NOMBRE DEL CURSO (encima de "Realizado el:")
    //    Ajusta Y si el curso no cae en su espacio
    doc.font("Helvetica-Bold").fontSize(14).fillColor("#1a1a1a")
      .text(courseTitle, 80, 280, { width: W - 160, align: "center", characterSpacing: 2 });

    // 3. FECHA (en el espacio "Realizado el: ___")
    doc.font("Helvetica").fontSize(11).fillColor("#333")
      .text(dateStr, 80, 335, { width: W - 160, align: "center" });

  } else {
    // SIN PLANTILLA: construir certificado manualmente con diseno propio
    doc.rect(0,0,W,H).fill("#FFFFFF");
    doc.rect(0,0,W,12).fill("#C0392B");
    doc.rect(0,H-12,W,12).fill("#C0392B");
    doc.rect(0,12,W,6).fill("#F39C12");
    doc.rect(0,H-18,W,6).fill("#F39C12");
    const sq = 70;
    doc.rect(0,18,sq,sq).fill("#C0392B");
    doc.rect(W-sq,18,sq,sq).fill("#C0392B");
    doc.rect(0,H-18-sq,sq,sq).fill("#C0392B");
    doc.rect(W-sq,H-18-sq,sq,sq).fill("#C0392B");
    doc.rect(55,55,W-110,H-110).lineWidth(1.5).stroke("#C0392B");

    let y = 80;
    const logoPath = path.join(PUB, "logo.png");
    if (fs.existsSync(logoPath)) { doc.image(logoPath, W/2-30, y, { width: 60 }); y += 72; }

    doc.font("Helvetica-Bold").fontSize(36).fillColor("#1a1a1a").text("CERTIFICADO", 0, y, { align: "center" }); y += 44;
    doc.font("Helvetica").fontSize(13).fillColor("#777").text("DE PARTICIPACION", 0, y, { align: "center", characterSpacing: 4 }); y += 30;
    doc.font("Helvetica").fontSize(11).fillColor("#444").text("Este certificado se entrega a:", 0, y, { align: "center" }); y += 26;

    doc.moveTo(130, y+24).lineTo(W-130, y+24).lineWidth(0.8).stroke("#ccc");
    doc.font("Helvetica-Bold").fontSize(24).fillColor("#C0392B").text(fullName, 0, y, { align: "center" }); y += 42;

    doc.font("Helvetica").fontSize(11).fillColor("#444").text("Por haber asistido y aprobado satisfactoriamente el curso de capacitacion:", 0, y, { align: "center" }); y += 26;
    doc.font("Helvetica-Bold").fontSize(15).fillColor("#1a1a1a").text(courseTitle, 80, y, { align: "center", width: W-160, characterSpacing: 2 }); y += 36;
    doc.font("Helvetica-Bold").fontSize(10).fillColor("#555")
      .text("Realizado el:  " + dateStr + "          Duracion:  40 horas  |  Modalidad " + (course.modality === "VIRTUAL" ? "Virtual" : "Presencial"), 0, y, { align: "center" });
    y += 52;

    // Firmas en modo sin plantilla
    const fW = 200; const gap = 90;
    const x1 = W/2 - fW - gap/2; const x2 = W/2 + gap/2;
    doc.moveTo(x1,y).lineTo(x1+fW,y).lineWidth(0.8).stroke("#333");
    doc.font("Helvetica-Bold").fontSize(9.5).fillColor("#1a1a1a").text("KARLA TATHYANNA MARIN OSPINA", x1, y+6, { width: fW, align: "center" });
    doc.font("Helvetica").fontSize(8.5).fillColor("#666").text("ALCALDESA LOCAL DE KENNEDY", x1, y+18, { width: fW, align: "center" });
    doc.moveTo(x2,y).lineTo(x2+fW,y).lineWidth(0.8).stroke("#333");
    doc.font("Helvetica-Bold").fontSize(9.5).fillColor("#1a1a1a").text("GERARDO SANTAMARIA BORDA", x2, y+6, { width: fW, align: "center" });
    doc.font("Helvetica").fontSize(8.5).fillColor("#666").text("CEO - BOOST BUSINESS CONSULTING", x2, y+18, { width: fW, align: "center" });
  }

  doc.end();
}

router.get("/:courseId/:userId", authenticate, authorize("ADMIN"), async (req, res) => {
  try {
    const enrollment = await prisma.enrollment.findUnique({
      where: { userId_courseId: { userId: req.params.userId, courseId: req.params.courseId } },
      include: { user: true, course: true }
    });
    if (!enrollment) return res.status(404).json({ error: "Inscripcion no encontrada" });
    if (enrollment.status !== "COMPLETADO") return res.status(403).json({ error: "El participante no ha completado el curso" });
    await generateCertPDF(enrollment, res);
  } catch (err) {
    console.error(err);
    if (!res.headersSent) res.status(500).json({ error: "Error generando certificado" });
  }
});

router.post("/:courseId/unlock", authenticate, authorize("ADMIN"), async (req, res) => {
  try {
    const { userId } = req.body;
    const e = await prisma.enrollment.update({
      where: { userId_courseId: { userId, courseId: req.params.courseId } },
      data: { status: "COMPLETADO", completedAt: new Date() }
    });
    return res.json(e);
  } catch { return res.status(500).json({ error: "Error" }); }
});

module.exports = router;
'
[System.IO.File]::WriteAllText("$PWD\backend\src\routes\certificates.js", $certRoute, [System.Text.Encoding]::UTF8)
Write-Host "certificates.js corregido OK" -ForegroundColor Green

# ── DASHBOARD con hover detallado en KPIs y graficas ─────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\admin" | Out-Null
$dash = '"use client";
import { useEffect, useState } from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { Users, BookOpen, TrendingUp, Heart, Loader2, AlertTriangle, CheckCircle, Award } from "lucide-react";
import {
  BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, Cell,
  PieChart, Pie, CartesianGrid, ReferenceLine, Legend
} from "recharts";

const COLORS = ["#C0392B","#2563EB","#16A34A","#D97706","#7C3AED","#EC4899","#0891B2"];

function AnimatedNum({ target, suffix="" }: { target: number; suffix?: string }) {
  const [v, setV] = useState(0);
  useEffect(() => {
    if (!target) return;
    let n = 0; const step = Math.max(1, Math.ceil(target / 50));
    const t = setInterval(() => { n = Math.min(n + step, target); setV(n); if (n >= target) clearInterval(t); }, 20);
    return () => clearInterval(t);
  }, [target]);
  return <>{v}{suffix}</>;
}

function KpiCard({ label, value, suffix="", icon: Icon, gradient, hover }: any) {
  const [show, setShow] = useState(false);
  const num = parseFloat(String(value)) || 0;
  return (
    <div className="relative rounded-2xl p-5 overflow-hidden cursor-pointer group transition-all duration-300 hover:-translate-y-1.5 hover:shadow-2xl"
      style={{ background: gradient }}
      onMouseEnter={() => setShow(true)} onMouseLeave={() => setShow(false)}>
      <div className="absolute -right-5 -top-5 w-28 h-28 rounded-full bg-white/10" />
      <div className="absolute -right-2 bottom-0 w-20 h-20 rounded-full bg-white/5" />
      <div className="relative z-10 flex items-start justify-between">
        <div>
          <p className="text-white/70 text-xs font-semibold uppercase tracking-wider mb-2">{label}</p>
          <p className="text-4xl font-black text-white"><AnimatedNum target={num} suffix={suffix} /></p>
        </div>
        <div className="bg-white/20 backdrop-blur-sm p-3 rounded-2xl">
          <Icon className="w-6 h-6 text-white" />
        </div>
      </div>
      {show && hover && (
        <div className="absolute inset-x-0 bottom-full mb-2 mx-2 z-50">
          <div className="bg-gray-950 text-white rounded-2xl p-4 shadow-2xl border border-white/10">
            <p className="font-bold text-sm mb-2 text-white/90">{label}</p>
            {hover.map((h: any, i: number) => (
              <div key={i} className="flex items-center justify-between py-1 border-b border-white/5 last:border-0">
                <span className="text-xs text-white/60">{h.k}</span>
                <span className="text-xs font-bold text-white">{h.v}</span>
              </div>
            ))}
            <div className="absolute top-full left-1/2 -translate-x-1/2 border-4 border-transparent border-t-gray-950" />
          </div>
        </div>
      )}
    </div>
  );
}

const RechartTooltip = ({ active, payload, label }: any) => {
  if (!active || !payload?.length) return null;
  return (
    <div className="bg-white border border-gray-100 rounded-xl p-3 shadow-xl text-xs">
      <p className="font-bold text-gray-800 mb-2 pb-1 border-b border-gray-100">{payload[0]?.payload?.fullTitle || label}</p>
      {payload.map((p: any, i: number) => (
        <div key={i} className="flex items-center justify-between gap-4 mt-1">
          <span className="flex items-center gap-1.5 text-gray-500">
            <span className="w-2 h-2 rounded-full" style={{ background: p.fill || p.color }} />
            {p.name}
          </span>
          <span className="font-bold text-gray-900">{p.value}{p.unit || ""}</span>
        </div>
      ))}
    </div>
  );
};

export default function AdminDashboard() {
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  useEffect(() => {
    api.get("/admin/dashboard").then(({ data }) => setData(data)).catch(() => setError("Error")).finally(() => setLoading(false));
  }, []);
  if (loading) return <AppShell allowedRoles={["ADMIN"]}><div className="flex flex-col items-center gap-3 justify-center py-32"><Loader2 className="w-10 h-10 text-primary animate-spin" /><p className="text-text-muted text-sm animate-pulse">Cargando datos del programa...</p></div></AppShell>;
  if (error) return <AppShell allowedRoles={["ADMIN"]}><div className="card bg-red-50 text-red-700 flex items-center gap-3"><AlertTriangle className="w-5 h-5" />{error}</div></AppShell>;
  const metaOk = data?.kpis.metaMujeres === "Cumplida";
  const pMuj = parseFloat(data?.kpis.porcentajeMujeres) || 0;
  const pAsist = parseFloat(data?.kpis.porcentajeAsistencia) || 0;
  const donaData = [
    { name: "Mujeres", value: data?.kpis.mujeres || 0, fill: "#C0392B" },
    { name: "Hombres", value: data?.kpis.hombres || 0, fill: "#2563EB" },
  ];
  return (
    <AppShell allowedRoles={["ADMIN"]}>
      <div className="max-w-7xl mx-auto space-y-7">
        <div className="flex items-end justify-between">
          <div>
            <h1 className="font-display text-3xl font-bold text-text-primary">Dashboard Administrativo</h1>
            <p className="text-text-muted text-sm mt-1 flex items-center gap-2">
              <span className="inline-block w-2 h-2 rounded-full bg-green-500 animate-pulse" />
              Programa de Formacion Kennedy - Pasa el mouse sobre las cards para ver detalles
            </p>
          </div>
          <span className="text-xs text-text-muted bg-gray-100 px-3 py-1.5 rounded-full">
            {new Date().toLocaleDateString("es-CO",{weekday:"long",day:"numeric",month:"long",year:"numeric"})}
          </span>
        </div>

        {/* KPI Cards con hover detallado */}
        <div className="grid grid-cols-2 xl:grid-cols-4 gap-4">
          <KpiCard label="Beneficiarios" value={data?.kpis.totalBeneficiarios}
            icon={Users} gradient="linear-gradient(135deg,#C0392B 0%,#7B0000 100%)"
            hover={[
              {k:"Cupos objetivo",v:"80"},
              {k:"Activos",v:data?.kpis.totalBeneficiarios},
              {k:"Mujeres",v:data?.kpis.mujeres+" ("+data?.kpis.porcentajeMujeres+")"},
              {k:"Hombres",v:data?.kpis.hombres},
              {k:"Completados",v:data?.kpis.completados},
            ]} />
          <KpiCard label="Asistencia" value={pAsist} suffix="%" icon={TrendingUp}
            gradient="linear-gradient(135deg,#16A34A 0%,#064E3B 100%)"
            hover={[
              {k:"Porcentaje global",v:data?.kpis.porcentajeAsistencia},
              {k:"Calculado sobre",v:"todas las sesiones"},
              {k:"P=Presente A=Ausente",v:"E=Excusa"},
            ]} />
          <KpiCard label="Mujeres" value={data?.kpis.mujeres} icon={Heart}
            gradient="linear-gradient(135deg,#D97706 0%,#7C2D12 100%)"
            hover={[
              {k:"Total mujeres",v:data?.kpis.mujeres},
              {k:"Porcentaje",v:data?.kpis.porcentajeMujeres},
              {k:"Meta contractual",v:"minimo 50%"},
              {k:"Estado meta",v:data?.kpis.metaMujeres},
              {k:"Hombres inscritos",v:data?.kpis.hombres},
            ]} />
          <KpiCard label="Completados" value={data?.kpis.completados} icon={Award}
            gradient="linear-gradient(135deg,#7C3AED 0%,#3B0764 100%)"
            hover={[
              {k:"Certificados habilitados",v:data?.kpis.completados},
              {k:"Del total inscrito",v:data?.kpis.porcentajeCompletados},
              {k:"Pendientes",v:(data?.kpis.totalBeneficiarios - data?.kpis.completados)},
            ]} />
        </div>

        {/* Graficas fila 1 */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
          <div className="lg:col-span-2 bg-white rounded-2xl border border-gray-100 shadow-card p-6">
            <div className="flex items-center justify-between mb-5">
              <div><h3 className="font-bold text-text-primary">Inscripciones por curso</h3><p className="text-xs text-text-muted mt-0.5">Mujeres vs Hombres - pasa el mouse para detalles</p></div>
              <div className="flex gap-3 text-xs">
                <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-full bg-primary" />Mujeres</span>
                <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-full bg-blue-600" />Hombres</span>
              </div>
            </div>
            <ResponsiveContainer width="100%" height={220}>
              <BarChart data={data?.courseKpis} margin={{top:5,right:5,left:-20,bottom:5}} barGap={5}>
                <CartesianGrid strokeDasharray="2 4" stroke="#F3F4F6" vertical={false} />
                <XAxis dataKey="title" tick={{fill:"#9CA3AF",fontSize:10}} tickLine={false} axisLine={false} />
                <YAxis tick={{fill:"#9CA3AF",fontSize:10}} axisLine={false} tickLine={false} />
                <Tooltip content={<RechartTooltip />} cursor={{fill:"rgba(0,0,0,0.03)"}} />
                <Bar dataKey="mujeres" name="Mujeres" fill="#C0392B" radius={[5,5,0,0]} maxBarSize={28} />
                <Bar dataKey="hombres" name="Hombres" fill="#2563EB" radius={[5,5,0,0]} maxBarSize={28} />
              </BarChart>
            </ResponsiveContainer>
          </div>
          <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-6 flex flex-col">
            <h3 className="font-bold text-text-primary mb-1">Genero total</h3>
            <p className="text-xs text-text-muted mb-2">Distribucion del programa</p>
            <div className="flex-1 flex items-center justify-center">
              <ResponsiveContainer width="100%" height={170}>
                <PieChart margin={{top:0,right:0,bottom:0,left:0}}>
                  <Pie data={donaData} dataKey="value" nameKey="name" cx="50%" cy="50%"
                    innerRadius={50} outerRadius={72} paddingAngle={3} startAngle={90} endAngle={-270}>
                    {donaData.map((d,i)=><Cell key={i} fill={d.fill} />)}
                  </Pie>
                  <Tooltip formatter={(v:any,n:any)=>[v+" personas",n]} contentStyle={{borderRadius:12,fontSize:12}} />
                </PieChart>
              </ResponsiveContainer>
            </div>
            <div className="grid grid-cols-2 gap-2 mt-2">
              <div className="bg-red-50 rounded-xl p-3 text-center border border-red-100">
                <p className="text-xl font-bold text-primary">{data?.kpis.mujeres}</p>
                <p className="text-xs text-text-muted">Mujeres</p>
                <p className="text-xs font-semibold text-primary">{data?.kpis.porcentajeMujeres}</p>
              </div>
              <div className="bg-blue-50 rounded-xl p-3 text-center border border-blue-100">
                <p className="text-xl font-bold text-blue-600">{data?.kpis.hombres}</p>
                <p className="text-xs text-text-muted">Hombres</p>
                <p className="text-xs font-semibold text-blue-600">{data?.kpis.hombres>0?(100-pMuj).toFixed(1)+"%":"0%"}</p>
              </div>
            </div>
          </div>
        </div>

        {/* Graficas fila 2 */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
          <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-6">
            <h3 className="font-bold text-text-primary mb-1">Meta de genero por curso</h3>
            <p className="text-xs text-text-muted mb-5">Verde = cumplida (>=50%) - Rojo = en riesgo - Linea = meta 50%</p>
            <ResponsiveContainer width="100%" height={195}>
              <BarChart data={data?.courseKpis} margin={{top:5,right:20,left:-20,bottom:5}} barSize={36}>
                <CartesianGrid strokeDasharray="2 4" stroke="#F3F4F6" vertical={false} />
                <XAxis dataKey="title" tick={{fill:"#9CA3AF",fontSize:10}} tickLine={false} axisLine={false} />
                <YAxis domain={[0,100]} tick={{fill:"#9CA3AF",fontSize:10}} axisLine={false} tickLine={false} unit="%" />
                <Tooltip content={<RechartTooltip />} cursor={{fill:"rgba(0,0,0,0.03)"}} />
                <ReferenceLine y={50} stroke="#C0392B" strokeDasharray="5 3" strokeWidth={1.5}
                  label={{value:"Meta 50%",fill:"#C0392B",fontSize:9,position:"insideTopRight"}} />
                <Bar dataKey="porcentajeMujeres" name="% Mujeres" unit="%" radius={[6,6,0,0]}>
                  {data?.courseKpis?.map((c:any,i:number)=>(
                    <Cell key={i} fill={parseFloat(c.porcentajeMujeres)>=50?"#16A34A":"#C0392B"} />
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
                const pct=((p.cantidad/data.kpis.totalBeneficiarios)*100);
                return (
                  <div key={i} className="group cursor-default">
                    <div className="flex items-center justify-between mb-1">
                      <span className="text-xs font-medium text-text-secondary flex items-center gap-2">
                        <span className="w-2 h-2 rounded-full flex-shrink-0" style={{background:COLORS[i%COLORS.length]}} />
                        {p.grupo?.replace(/_/g," ")}
                      </span>
                      <span className="text-xs font-bold text-text-primary opacity-0 group-hover:opacity-100 transition-opacity">
                        {p.cantidad} personas ({pct.toFixed(0)}%)
                      </span>
                    </div>
                    <div className="h-2.5 bg-gray-100 rounded-full overflow-hidden">
                      <div className="h-full rounded-full transition-all duration-700 group-hover:opacity-80"
                        style={{width:Math.min(pct,100)+"%",background:COLORS[i%COLORS.length]}} />
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>

        {/* Tabla resumen + Indicadores */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
          <div className="lg:col-span-2 bg-white rounded-2xl border border-gray-100 shadow-card overflow-hidden">
            <div className="px-5 py-4 border-b border-gray-50 flex items-center justify-between">
              <h3 className="font-bold text-text-primary">Resumen por curso</h3>
              <span className="text-xs text-text-muted bg-gray-50 px-2.5 py-1 rounded-full">{data?.courseKpis?.length} cursos</span>
            </div>
            <div className="divide-y divide-gray-50">
              {data?.courseKpis?.map((c:any,i:number)=>(
                <div key={i} className="flex items-center gap-3 px-5 py-3.5 hover:bg-gray-50/80 transition-colors group">
                  <div className="w-1.5 h-10 rounded-full flex-shrink-0" style={{background:COLORS[i%COLORS.length]}} />
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-semibold text-text-primary truncate">{c.fullTitle}</p>
                    <p className="text-xs text-text-muted">{c.formador}</p>
                  </div>
                  <div className="flex items-center gap-3 flex-shrink-0">
                    <div className="text-right opacity-0 group-hover:opacity-100 transition-opacity">
                      <p className="text-xs text-pink-600 font-semibold">{c.mujeres} mujeres</p>
                      <p className="text-xs text-blue-600 font-semibold">{c.hombres} hombres</p>
                    </div>
                    <div className="text-right">
                      <p className="text-sm font-bold text-text-primary">{c.inscritos}</p>
                      <p className="text-xs text-text-muted">inscritos</p>
                    </div>
                    <span className={"badge text-xs "+(parseFloat(c.porcentajeMujeres)>=50?"badge-success":"badge-primary")}>
                      {c.porcentajeMujeres}%
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="space-y-4">
            {/* Meta genero */}
            <div className={"rounded-2xl p-5 border "+(metaOk?"bg-gradient-to-br from-green-50 to-white border-green-200":"bg-gradient-to-br from-red-50 to-white border-red-200")}>
              <div className="flex items-center gap-2 mb-3">
                {metaOk?<CheckCircle className="w-5 h-5 text-green-600"/>:<AlertTriangle className="w-5 h-5 text-red-600"/>}
                <p className={"font-bold text-sm "+(metaOk?"text-green-800":"text-red-800")}>Meta de genero - {data?.kpis.metaMujeres}</p>
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
                  <p className="text-xs text-text-muted">de {data?.kpis.totalBeneficiarios} inscritos</p>
                </div>
              </div>
            </div>

            {/* Asistencia */}
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
                  <p className="text-xs text-text-muted">P=Presente A=Ausente E=Excusa</p>
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
Write-Host "Dashboard con hover en KPIs y graficas OK" -ForegroundColor Green

# ── FIX ENCODING en course viewer ─────────────────────────────
$cvPath = "$PWD\frontend\src\app\(student)\courses\[id]\page.tsx"
if (Test-Path $cvPath) {
  $bytes = [System.IO.File]::ReadAllBytes($cvPath)
  $text = [System.Text.Encoding]::UTF8.GetString($bytes)
  $fixed = $text.Replace([char]8212,"-").Replace([char]8211,"-")
  [System.IO.File]::WriteAllText($cvPath, $fixed, [System.Text.Encoding]::UTF8)
  Write-Host "Course viewer encoding corregido OK" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Yellow
Write-Host "FIX COMPLETO" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "NOTA SOBRE CERTIFICADO:" -ForegroundColor Cyan
Write-Host "Si el nombre/curso no cae exactamente en los" -ForegroundColor White
Write-Host "espacios de la plantilla, ajusta estos valores" -ForegroundColor White
Write-Host "en backend\src\routes\certificates.js:" -ForegroundColor White
Write-Host "  y=192  -> donde cae el nombre" -ForegroundColor Gray
Write-Host "  y=280  -> donde cae el curso" -ForegroundColor Gray
Write-Host "  y=335  -> donde cae la fecha" -ForegroundColor Gray
Write-Host ""
Write-Host "Ejecuta:" -ForegroundColor Cyan
Write-Host "  docker-compose down" -ForegroundColor White
Write-Host "  docker-compose up --build" -ForegroundColor White
