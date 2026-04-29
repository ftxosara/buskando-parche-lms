Write-Host "=== DASHBOARD PROFESIONAL + CERTIFICADO ===" -ForegroundColor Yellow

# ── CERTIFICADO: usa la imagen de plantilla como fondo completo
# La firma de Gerardo ya esta en la imagen certificado.jpeg
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

  // Buscar la imagen de plantilla con firma incluida
  const tryPaths = [
    path.join(PUB, "certificado.jpeg"),
    path.join(PUB, "certificado.jpg"),
    path.join(PUB, "certificado.png"),
  ];

  let bgFound = false;
  for (const bp of tryPaths) {
    if (fs.existsSync(bp)) {
      // Usar la imagen de plantilla COMPLETA como fondo (ya incluye la firma de Gerardo)
      doc.image(bp, 0, 0, { width: W, height: H });
      bgFound = true;
      break;
    }
  }

  if (!bgFound) {
    // Fondo alternativo si no existe la imagen
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
  }

  // ── TEXTO SOBRE LA PLANTILLA ──────────────────────────────────
  // Calibrado para que el nombre caiga en la linea en blanco de la plantilla
  // y el titulo del curso en el espacio correspondiente.
  // Ajusta estos valores si tu plantilla tiene diferente espaciado.

  // Nombre del beneficiario (encima de la linea de nombre)
  doc.font("Helvetica-Bold").fontSize(22).fillColor("#C0392B")
    .text(fullName, 100, bgFound ? 195 : 175, { width: W - 200, align: "center" });

  // Nombre del curso
  doc.font("Helvetica-Bold").fontSize(bgFound ? 13 : 15).fillColor("#1a1a1a")
    .text(courseTitle, 80, bgFound ? 280 : 255, { width: W - 160, align: "center", characterSpacing: 1 });

  // Fecha y duracion
  const modalidad = course.modality === "VIRTUAL" ? "Virtual" : "Presencial";
  doc.font("Helvetica").fontSize(11).fillColor("#333")
    .text(dateStr, 100, bgFound ? 330 : 308, { width: W - 200, align: "center" });

  if (!bgFound) {
    doc.font("Helvetica-Bold").fontSize(10).fillColor("#555")
      .text("Duracion: 40 horas  |  Modalidad " + modalidad, 0, 350, { align: "center" });

    // Firmas solo si no hay imagen (si hay imagen la firma ya esta impresa en la plantilla)
    const fW = 200; const gap = 90;
    const x1 = W / 2 - fW - gap / 2; const x2 = W / 2 + gap / 2;
    const fy = 415;
    doc.moveTo(x1,fy).lineTo(x1+fW,fy).lineWidth(0.8).stroke("#333");
    doc.font("Helvetica-Bold").fontSize(9).fillColor("#1a1a1a")
      .text("KARLA TATHYANNA MARIN OSPINA", x1, fy+6, { width: fW, align: "center" });
    doc.font("Helvetica").fontSize(8).fillColor("#666")
      .text("ALCALDESA LOCAL DE KENNEDY", x1, fy+18, { width: fW, align: "center" });
    doc.moveTo(x2,fy).lineTo(x2+fW,fy).lineWidth(0.8).stroke("#333");
    doc.font("Helvetica-Bold").fontSize(9).fillColor("#1a1a1a")
      .text("GERARDO SANTAMARIA BORDA", x2, fy+6, { width: fW, align: "center" });
    doc.font("Helvetica").fontSize(8).fillColor("#666")
      .text("CEO - BOOST BUSINESS CONSULTING", x2, fy+18, { width: fW, align: "center" });
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
Write-Host "certificates.js - usa plantilla con firma de Gerardo OK" -ForegroundColor Green

# ── DASHBOARD PROFESIONAL CON RECHARTS SIN TEXTO DESFASADO ───
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\admin" | Out-Null
$dash = '"use client";
import { useEffect, useState, useRef } from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import {
  Users, BookOpen, TrendingUp, Heart, Loader2,
  AlertTriangle, CheckCircle, Award, ArrowUpRight, ArrowDownRight
} from "lucide-react";
import {
  BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, Cell,
  PieChart, Pie, Legend, CartesianGrid, ReferenceLine,
  RadialBarChart, RadialBar
} from "recharts";

const COLORS = ["#C0392B","#2563EB","#16A34A","#D97706","#7C3AED","#EC4899","#0891B2"];

/* ── Contador animado ── */
function AnimatedNumber({ value, suffix = "" }: { value: number; suffix?: string }) {
  const [display, setDisplay] = useState(0);
  useEffect(() => {
    let start = 0;
    const end = typeof value === "number" ? value : parseFloat(value) || 0;
    if (end === 0) return;
    const step = Math.ceil(end / 40);
    const timer = setInterval(() => {
      start += step;
      if (start >= end) { setDisplay(end); clearInterval(timer); }
      else setDisplay(start);
    }, 25);
    return () => clearInterval(timer);
  }, [value]);
  return <span>{display}{suffix}</span>;
}

/* ── KPI Card con gradiente y animacion ── */
function KpiCard({ label, value, icon: Icon, gradient, suffix = "", tooltip, trend }: any) {
  const [show, setShow] = useState(false);
  const num = parseFloat(String(value)) || 0;
  return (
    <div
      className="relative rounded-2xl p-5 overflow-hidden cursor-help group transition-all duration-300 hover:-translate-y-1 hover:shadow-2xl"
      style={{ background: gradient }}
      onMouseEnter={() => setShow(true)} onMouseLeave={() => setShow(false)}>
      {/* Circulo decorativo */}
      <div className="absolute -right-4 -top-4 w-24 h-24 rounded-full opacity-20 bg-white" />
      <div className="absolute -right-2 -bottom-6 w-32 h-32 rounded-full opacity-10 bg-white" />
      <div className="relative z-10">
        <div className="flex items-start justify-between mb-3">
          <div className="bg-white/20 backdrop-blur-sm p-2.5 rounded-xl">
            <Icon className="w-5 h-5 text-white" />
          </div>
          {trend !== undefined && (
            <span className="text-xs font-semibold text-white/80 flex items-center gap-0.5">
              {trend >= 0 ? <ArrowUpRight className="w-3.5 h-3.5" /> : <ArrowDownRight className="w-3.5 h-3.5" />}
              {Math.abs(trend)}%
            </span>
          )}
        </div>
        <p className="text-white/70 text-xs font-medium uppercase tracking-wide mb-1">{label}</p>
        <p className="text-3xl font-bold text-white">
          <AnimatedNumber value={num} suffix={suffix} />
        </p>
      </div>
      {show && tooltip && (
        <div className="absolute bottom-full left-0 mb-2 w-56 bg-gray-900 text-white text-xs rounded-xl p-3 shadow-2xl z-50 leading-relaxed">
          {tooltip}
          <div className="absolute top-full left-5 border-4 border-transparent border-t-gray-900" />
        </div>
      )}
    </div>
  );
}

/* ── Tooltip personalizado ── */
const CustomTooltip = ({ active, payload, label }: any) => {
  if (!active || !payload?.length) return null;
  return (
    <div className="bg-white border border-gray-100 rounded-xl p-3 shadow-xl text-xs min-w-32">
      <p className="font-bold text-gray-800 mb-1.5 pb-1.5 border-b border-gray-100">{payload[0]?.payload?.fullTitle || label}</p>
      {payload.map((p: any, i: number) => (
        <div key={i} className="flex items-center justify-between gap-3 mt-1">
          <span className="flex items-center gap-1.5">
            <span className="w-2 h-2 rounded-full" style={{ background: p.fill || p.color }} />
            <span className="text-gray-600">{p.name}</span>
          </span>
          <span className="font-bold text-gray-900">{p.value}</span>
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
    api.get("/admin/dashboard")
      .then(({ data }) => setData(data))
      .catch(() => setError("Error al cargar el dashboard"))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return (
    <AppShell allowedRoles={["ADMIN"]}>
      <div className="flex flex-col items-center justify-center py-32 gap-4">
        <Loader2 className="w-10 h-10 text-primary animate-spin" />
        <p className="text-text-muted text-sm animate-pulse">Cargando datos del programa...</p>
      </div>
    </AppShell>
  );

  if (error) return (
    <AppShell allowedRoles={["ADMIN"]}>
      <div className="card bg-red-50 text-red-700 flex items-center gap-3">
        <AlertTriangle className="w-5 h-5" />{error}
      </div>
    </AppShell>
  );

  const metaOk = data?.kpis.metaMujeres === "Cumplida";
  const porcMuj = parseFloat(data?.kpis.porcentajeMujeres) || 0;
  const porcAsist = parseFloat(data?.kpis.porcentajeAsistencia) || 0;

  // Datos para radial (completados)
  const radialData = [{ name: "Completados", value: data?.kpis.completados || 0, fill: "#7C3AED" }];

  // Datos genero dona
  const donaData = [
    { name: "Mujeres", value: data?.kpis.mujeres || 0, fill: "#C0392B" },
    { name: "Hombres", value: data?.kpis.hombres || 0, fill: "#2563EB" },
  ];

  return (
    <AppShell allowedRoles={["ADMIN"]}>
      <div className="max-w-7xl mx-auto space-y-7">

        {/* Header */}
        <div className="flex items-end justify-between">
          <div>
            <h1 className="font-display text-3xl font-bold text-text-primary">Dashboard</h1>
            <p className="text-text-muted text-sm mt-1 flex items-center gap-2">
              <span className="inline-block w-2 h-2 rounded-full bg-green-500 animate-pulse" />
              Programa de Formacion - Kennedy, Bogota
            </p>
          </div>
          <p className="text-xs text-text-muted bg-gray-100 px-3 py-1.5 rounded-full">
            {new Date().toLocaleDateString("es-CO", { weekday:"long", day:"numeric", month:"long", year:"numeric" })}
          </p>
        </div>

        {/* KPIs */}
        <div className="grid grid-cols-2 xl:grid-cols-4 gap-4">
          <KpiCard label="Beneficiarios" value={data?.kpis.totalBeneficiarios} icon={Users}
            gradient="linear-gradient(135deg,#C0392B,#8B0000)"
            tooltip={"80 cupos objetivo. Actualmente " + data?.kpis.totalBeneficiarios + " activos."} />
          <KpiCard label="Asistencia" value={porcAsist} suffix="%" icon={TrendingUp}
            gradient="linear-gradient(135deg,#16A34A,#064E3B)"
            tooltip="Porcentaje de asistencias PRESENTE sobre el total registrado." />
          <KpiCard label="Mujeres inscritas" value={data?.kpis.mujeres} icon={Heart}
            gradient="linear-gradient(135deg,#D97706,#92400E)"
            tooltip={"Meta: min 50% mujeres. Actualmente " + data?.kpis.porcentajeMujeres + "."} />
          <KpiCard label="Completados" value={data?.kpis.completados} icon={Award}
            gradient="linear-gradient(135deg,#7C3AED,#3B0764)"
            tooltip="Beneficiarios con certificado habilitado." />
        </div>

        {/* Fila 1: Barras inscripciones + Dona genero */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
          <div className="lg:col-span-2 bg-white rounded-2xl border border-gray-100 shadow-card p-6">
            <div className="flex items-center justify-between mb-5">
              <div>
                <h3 className="font-bold text-text-primary">Inscripciones por curso</h3>
                <p className="text-xs text-text-muted mt-0.5">Desglose mujeres vs hombres</p>
              </div>
              <div className="flex items-center gap-3 text-xs">
                <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-full bg-primary" />Mujeres</span>
                <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-full bg-blue-600" />Hombres</span>
              </div>
            </div>
            <ResponsiveContainer width="100%" height={220}>
              <BarChart data={data?.courseKpis} margin={{ top: 5, right: 10, left: -20, bottom: 5 }} barGap={4}>
                <CartesianGrid strokeDasharray="2 4" stroke="#F3F4F6" vertical={false} />
                <XAxis dataKey="title" tick={{ fill: "#9CA3AF", fontSize: 10 }} tickLine={false} axisLine={false} />
                <YAxis tick={{ fill: "#9CA3AF", fontSize: 10 }} axisLine={false} tickLine={false} />
                <Tooltip content={<CustomTooltip />} cursor={{ fill: "rgba(0,0,0,0.03)" }} />
                <Bar dataKey="mujeres" name="Mujeres" fill="#C0392B" radius={[4,4,0,0]} maxBarSize={26} />
                <Bar dataKey="hombres" name="Hombres" fill="#2563EB" radius={[4,4,0,0]} maxBarSize={26} />
              </BarChart>
            </ResponsiveContainer>
          </div>

          <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-6 flex flex-col">
            <h3 className="font-bold text-text-primary mb-1">Genero total</h3>
            <p className="text-xs text-text-muted mb-2">Distribucion del programa</p>
            <div className="flex-1 flex items-center justify-center">
              <ResponsiveContainer width="100%" height={180}>
                <PieChart margin={{ top: 0, right: 0, bottom: 0, left: 0 }}>
                  <Pie data={donaData} dataKey="value" nameKey="name"
                    cx="50%" cy="50%" innerRadius={52} outerRadius={75}
                    paddingAngle={3} startAngle={90} endAngle={-270}>
                    {donaData.map((d, i) => <Cell key={i} fill={d.fill} />)}
                  </Pie>
                  <Tooltip formatter={(v: any, n: any) => [v + " personas", n]} contentStyle={{ borderRadius: 12, fontSize: 12 }} />
                </PieChart>
              </ResponsiveContainer>
            </div>
            <div className="grid grid-cols-2 gap-2 mt-1">
              <div className="bg-red-50 rounded-xl p-3 text-center">
                <p className="text-xl font-bold text-primary">{data?.kpis.mujeres}</p>
                <p className="text-xs text-text-muted mt-0.5">Mujeres</p>
                <p className="text-xs font-semibold text-primary">{data?.kpis.porcentajeMujeres}</p>
              </div>
              <div className="bg-blue-50 rounded-xl p-3 text-center">
                <p className="text-xl font-bold text-blue-600">{data?.kpis.hombres}</p>
                <p className="text-xs text-text-muted mt-0.5">Hombres</p>
                <p className="text-xs font-semibold text-blue-600">{data?.kpis.hombres > 0 ? (100 - porcMuj).toFixed(1) + "%" : "0%"}</p>
              </div>
            </div>
          </div>
        </div>

        {/* Fila 2: Meta genero + Grupos poblacionales */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
          <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-6">
            <h3 className="font-bold text-text-primary mb-1">Meta de genero por curso</h3>
            <p className="text-xs text-text-muted mb-5">Verde = cumplida (>=50%), Rojo = en riesgo</p>
            <ResponsiveContainer width="100%" height={195}>
              <BarChart data={data?.courseKpis} margin={{ top: 5, right: 10, left: -20, bottom: 5 }} barSize={36}>
                <CartesianGrid strokeDasharray="2 4" stroke="#F3F4F6" vertical={false} />
                <XAxis dataKey="title" tick={{ fill: "#9CA3AF", fontSize: 10 }} tickLine={false} axisLine={false} />
                <YAxis domain={[0, 100]} tick={{ fill: "#9CA3AF", fontSize: 10 }} axisLine={false} tickLine={false} unit="%" />
                <Tooltip formatter={(v: any) => [v + "%", "Mujeres"]} contentStyle={{ borderRadius: 12, fontSize: 12 }} />
                <ReferenceLine y={50} stroke="#C0392B" strokeDasharray="5 3" strokeWidth={1.5}
                  label={{ value: "50%", fill: "#C0392B", fontSize: 10, position: "right" }} />
                <Bar dataKey="porcentajeMujeres" name="% Mujeres" radius={[6,6,0,0]}>
                  {data?.courseKpis?.map((c: any, i: number) => (
                    <Cell key={i} fill={parseFloat(c.porcentajeMujeres) >= 50 ? "#16A34A" : "#C0392B"} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>

          <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-6">
            <h3 className="font-bold text-text-primary mb-1">Grupos poblacionales</h3>
            <p className="text-xs text-text-muted mb-4">Enfoque diferencial por beneficiario</p>
            <div className="space-y-3 overflow-y-auto max-h-52">
              {data?.populationBreakdown?.map((p: any, i: number) => {
                const pct = ((p.cantidad / data.kpis.totalBeneficiarios) * 100);
                return (
                  <div key={i}>
                    <div className="flex items-center justify-between mb-1">
                      <span className="text-xs font-medium text-text-secondary flex items-center gap-2">
                        <span className="w-2 h-2 rounded-full flex-shrink-0" style={{ background: COLORS[i % COLORS.length] }} />
                        {p.grupo?.replace(/_/g, " ")}
                      </span>
                      <span className="text-xs font-bold text-text-primary">{p.cantidad} <span className="text-text-muted font-normal">({pct.toFixed(0)}%)</span></span>
                    </div>
                    <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
                      <div className="h-full rounded-full transition-all duration-700"
                        style={{ width: Math.min(pct, 100) + "%", background: COLORS[i % COLORS.length] }} />
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>

        {/* Fila 3: Resumen tabla + Alerta meta */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
          <div className="lg:col-span-2 bg-white rounded-2xl border border-gray-100 shadow-card overflow-hidden">
            <div className="px-5 py-4 border-b border-gray-50 flex items-center justify-between">
              <h3 className="font-bold text-text-primary">Resumen por curso</h3>
              <span className="text-xs text-text-muted bg-gray-50 px-2.5 py-1 rounded-full">{data?.courseKpis?.length} cursos</span>
            </div>
            <div className="divide-y divide-gray-50">
              {data?.courseKpis?.map((c: any, i: number) => (
                <div key={i} className="flex items-center gap-3 px-5 py-3.5 hover:bg-gray-50/70 transition-colors">
                  <div className="w-1.5 h-10 rounded-full flex-shrink-0" style={{ background: COLORS[i % COLORS.length] }} />
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-semibold text-text-primary truncate">{c.fullTitle}</p>
                    <p className="text-xs text-text-muted">{c.formador} - {c.modality === "VIRTUAL" ? "Virtual" : "Presencial"}</p>
                  </div>
                  <div className="flex items-center gap-3 flex-shrink-0">
                    <div className="text-right">
                      <p className="text-sm font-bold text-text-primary">{c.inscritos}</p>
                      <p className="text-xs text-text-muted">inscritos</p>
                    </div>
                    <div className="text-right">
                      <p className="text-xs font-semibold text-pink-600">{c.mujeres}F</p>
                      <p className="text-xs font-semibold text-blue-600">{c.hombres}M</p>
                    </div>
                    <span className={"badge text-xs " + (parseFloat(c.porcentajeMujeres) >= 50 ? "badge-success" : "badge-primary")}>
                      {c.porcentajeMujeres}%
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="space-y-4">
            <div className={"rounded-2xl p-5 border " + (metaOk ? "bg-gradient-to-br from-green-50 to-emerald-50 border-green-200" : "bg-gradient-to-br from-red-50 to-orange-50 border-red-200")}>
              <div className="flex items-center gap-2 mb-3">
                {metaOk ? <CheckCircle className="w-5 h-5 text-green-600" /> : <AlertTriangle className="w-5 h-5 text-red-600" />}
                <p className={"font-bold text-sm " + (metaOk ? "text-green-800" : "text-red-800")}>
                  Meta de genero - {data?.kpis.metaMujeres}
                </p>
              </div>
              <p className={"text-xs mb-3 " + (metaOk ? "text-green-700" : "text-red-700")}>
                Contrato exige minimo <strong>50% mujeres</strong>. Actualmente <strong>{data?.kpis.porcentajeMujeres}</strong> de {data?.kpis.totalBeneficiarios} inscritos.
              </p>
              {/* Barra de progreso circular simplificada */}
              <div className="flex items-center gap-3">
                <div className="relative w-14 h-14 flex-shrink-0">
                  <svg viewBox="0 0 36 36" className="w-14 h-14 -rotate-90">
                    <circle cx="18" cy="18" r="15.9" fill="none" stroke="#E5E7EB" strokeWidth="2.5" />
                    <circle cx="18" cy="18" r="15.9" fill="none"
                      stroke={metaOk ? "#16A34A" : "#C0392B"} strokeWidth="2.5"
                      strokeDasharray={porcMuj + " 100"} strokeLinecap="round" />
                  </svg>
                  <span className={"absolute inset-0 flex items-center justify-center text-xs font-bold " + (metaOk ? "text-green-700" : "text-red-700")}>{porcMuj.toFixed(0)}%</span>
                </div>
                <div>
                  <p className="text-xs text-text-muted">Meta: 50%</p>
                  <p className={"text-sm font-bold " + (metaOk ? "text-green-700" : "text-red-600")}>{metaOk ? "Cumplida" : "En riesgo"}</p>
                  <p className="text-xs text-text-muted mt-0.5">Faltan: {Math.max(0, Math.ceil(data?.kpis.totalBeneficiarios * 0.5) - data?.kpis.mujeres)} mujeres</p>
                </div>
              </div>
            </div>

            <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-4">
              <h4 className="text-xs font-bold text-text-muted uppercase mb-3">Asistencia global</h4>
              <div className="flex items-center gap-3">
                <div className="relative w-14 h-14 flex-shrink-0">
                  <svg viewBox="0 0 36 36" className="w-14 h-14 -rotate-90">
                    <circle cx="18" cy="18" r="15.9" fill="none" stroke="#E5E7EB" strokeWidth="2.5" />
                    <circle cx="18" cy="18" r="15.9" fill="none" stroke="#16A34A" strokeWidth="2.5"
                      strokeDasharray={Math.min(porcAsist, 100) + " 100"} strokeLinecap="round" />
                  </svg>
                  <span className="absolute inset-0 flex items-center justify-center text-xs font-bold text-green-700">{porcAsist.toFixed(0)}%</span>
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
Write-Host "Dashboard profesional con graficas limpias OK" -ForegroundColor Green

Write-Host ""
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host "FIX DASHBOARD + CERTIFICADO COMPLETO" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "La firma de Gerardo Santamaria ya esta en" -ForegroundColor Cyan
Write-Host "la imagen certificado.jpeg - no se toca." -ForegroundColor Cyan
Write-Host ""
Write-Host "Ejecuta:" -ForegroundColor Cyan
Write-Host "  docker-compose down" -ForegroundColor White
Write-Host "  docker-compose up --build" -ForegroundColor White
