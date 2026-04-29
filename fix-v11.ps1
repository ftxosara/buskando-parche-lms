Write-Host "=== FIX V11 - Dashboard + Reportes + Certificados + Fondo ===" -ForegroundColor Yellow

# ── 1. APP SHELL: logo de fondo traslucido en todas las paginas
New-Item -ItemType Directory -Force -Path "frontend\src\components\layout" | Out-Null
$appShell = '"use client";
import { useAuth } from "@/contexts/AuthContext";
import { useRouter } from "next/navigation";
import { useEffect } from "react";
import Sidebar from "./Sidebar";
import { Loader2 } from "lucide-react";
export default function AppShell({ children, allowedRoles }: { children: React.ReactNode; allowedRoles: string[] }) {
  const { user, isLoading } = useAuth();
  const router = useRouter();
  useEffect(() => {
    if (!isLoading && !user) router.push("/login");
    if (!isLoading && user && !allowedRoles.includes(user.role)) router.push("/login");
  }, [user, isLoading]);
  if (isLoading) return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <Loader2 className="w-8 h-8 text-primary animate-spin" />
    </div>
  );
  return (
    <div className="flex min-h-screen bg-gray-50 relative overflow-hidden">
      {/* Logo traslucido de fondo - no afecta el contenido */}
      <div className="fixed inset-0 pointer-events-none z-0 flex items-center justify-center" style={{ left: "256px" }}>
        <img
          src="/images/logo.png"
          alt=""
          className="w-96 h-96 object-contain select-none"
          style={{ opacity: 0.03, filter: "grayscale(100%)" }}
        />
      </div>
      <Sidebar />
      <main className="flex-1 overflow-y-auto animate-fade-in relative z-10">
        <div className="bg-white border-b border-gray-200 px-8 py-4 flex items-center justify-between shadow-sm">
          <div className="flex items-center gap-3">
            <img src="/images/logo.png" alt="Buskando Parche" className="h-8 w-auto object-contain"
              onError={(e) => { (e.target as HTMLImageElement).style.display = "none"; }} />
            <span className="font-display font-bold text-primary text-xl">Buskando <span className="text-secondary">Parche</span></span>
          </div>
          <span className="text-sm text-text-muted">Programa de Formacion - Kennedy, Bogota</span>
        </div>
        <div className="p-8">{children}</div>
      </main>
    </div>
  );
}'
[System.IO.File]::WriteAllText("$PWD\frontend\src\components\layout\AppShell.tsx", $appShell, [System.Text.Encoding]::UTF8)
Write-Host "AppShell con logo de fondo OK" -ForegroundColor Green

# ── 2. ADMIN DASHBOARD PROFESIONAL ───────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\admin" | Out-Null
$adminDash = '"use client";
import { useEffect, useState } from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { Users, BookOpen, TrendingUp, Heart, Loader2, AlertTriangle, CheckCircle, Award, UserCheck, Activity } from "lucide-react";
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, Cell, PieChart, Pie, CartesianGrid, ReferenceLine, Legend, RadialBarChart, RadialBar } from "recharts";

const COLORS = ["#C0392B","#2563EB","#16A34A","#D97706","#7C3AED","#EC4899","#0891B2"];

function KpiCard({ label, value, icon: Icon, color, subtitle, tooltip }: any) {
  const [show, setShow] = useState(false);
  const styles: any = {
    red:    { card: "border-red-100 bg-gradient-to-br from-red-50 to-white",    icon: "bg-red-100 text-red-600",    val: "text-red-600" },
    yellow: { card: "border-yellow-100 bg-gradient-to-br from-yellow-50 to-white", icon: "bg-yellow-100 text-yellow-600", val: "text-yellow-600" },
    green:  { card: "border-green-100 bg-gradient-to-br from-green-50 to-white",  icon: "bg-green-100 text-green-600",  val: "text-green-600" },
    blue:   { card: "border-blue-100 bg-gradient-to-br from-blue-50 to-white",    icon: "bg-blue-100 text-blue-600",    val: "text-blue-600" },
    purple: { card: "border-purple-100 bg-gradient-to-br from-purple-50 to-white", icon: "bg-purple-100 text-purple-600", val: "text-purple-600" },
  };
  const s = styles[color] || styles.red;
  return (
    <div className={"rounded-2xl border p-5 relative cursor-help hover:shadow-lg transition-all duration-300 hover:-translate-y-1 " + s.card}
      onMouseEnter={() => setShow(true)} onMouseLeave={() => setShow(false)}>
      <div className="flex items-start justify-between">
        <div>
          <p className="text-text-muted text-xs font-medium uppercase tracking-wide">{label}</p>
          <p className={"text-3xl font-bold font-display mt-1 " + s.val}>{value}</p>
          {subtitle && <p className="text-text-muted text-xs mt-1.5 flex items-center gap-1"><Activity className="w-3 h-3" />{subtitle}</p>}
        </div>
        <div className={"p-3 rounded-2xl " + s.icon}><Icon className="w-6 h-6" /></div>
      </div>
      {show && tooltip && (
        <div className="absolute bottom-full left-0 mb-2 w-64 bg-gray-900 text-white text-xs rounded-xl p-3 shadow-2xl z-50 leading-relaxed">
          {tooltip}<div className="absolute top-full left-6 border-4 border-transparent border-t-gray-900" />
        </div>
      )}
    </div>
  );
}

const CustomTooltip = ({ active, payload, label }: any) => {
  if (!active || !payload?.length) return null;
  return (
    <div className="bg-white border border-gray-200 rounded-xl p-3 shadow-xl text-sm">
      <p className="font-bold text-text-primary mb-2 border-b border-gray-100 pb-1">{payload[0]?.payload?.fullTitle || label}</p>
      {payload.map((p: any, i: number) => (
        <p key={i} className="flex items-center gap-2 mt-1">
          <span className="w-2 h-2 rounded-full flex-shrink-0" style={{ background: p.color }} />
          <span className="text-text-secondary">{p.name}:</span>
          <span className="font-bold text-text-primary">{p.value}</span>
        </p>
      ))}
    </div>
  );
};

export default function AdminDashboard() {
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  useEffect(() => { api.get("/admin/dashboard").then(({ data }) => setData(data)).catch(() => setError("Error cargando dashboard")).finally(() => setLoading(false)); }, []);
  if (loading) return <AppShell allowedRoles={["ADMIN"]}><div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div></AppShell>;
  if (error) return <AppShell allowedRoles={["ADMIN"]}><div className="card bg-red-50 text-red-700 flex items-center gap-3"><AlertTriangle className="w-5 h-5" />{error}</div></AppShell>;

  const genderData = [{ name: "Mujeres", value: data?.kpis.mujeres || 0 }, { name: "Hombres", value: data?.kpis.hombres || 0 }];
  const metaCumplida = data?.kpis.metaMujeres === "Cumplida";

  return (
    <AppShell allowedRoles={["ADMIN"]}>
      <div className="max-w-7xl mx-auto space-y-8">
        <div className="flex items-start justify-between">
          <div>
            <h1 className="font-display text-3xl font-bold text-text-primary">Dashboard Administrativo</h1>
            <p className="text-text-secondary mt-1 flex items-center gap-2">
              <span className="w-2 h-2 rounded-full bg-green-500 animate-pulse inline-block" />
              Programa de Formacion - Kennedy, Bogota
            </p>
          </div>
          <div className="text-right">
            <p className="text-xs text-text-muted">Ultima actualizacion</p>
            <p className="text-sm font-medium text-text-primary">{new Date().toLocaleDateString("es-CO", { day:"2-digit", month:"long", year:"numeric" })}</p>
          </div>
        </div>

        {/* KPIs */}
        <div className="grid grid-cols-2 xl:grid-cols-4 gap-4">
          <KpiCard label="Total beneficiarios" value={data?.kpis.totalBeneficiarios} icon={Users} color="red"
            subtitle={"de 80 cupos objetivo"}
            tooltip={"80 beneficiarios objetivo. Actualmente: " + data?.kpis.totalBeneficiarios + " activos."} />
          <KpiCard label="Asistencia global" value={data?.kpis.porcentajeAsistencia} icon={TrendingUp} color="green"
            subtitle="Promedio todas las sesiones"
            tooltip="Porcentaje de asistencias PRESENTE sobre el total registrado." />
          <KpiCard label="Mujeres inscritas" value={data?.kpis.mujeres} icon={Heart} color="yellow"
            subtitle={data?.kpis.porcentajeMujeres + " del total"}
            tooltip={"Meta contractual: minimo 50%. Actualmente " + data?.kpis.porcentajeMujeres + "."} />
          <KpiCard label="Cursos completados" value={data?.kpis.completados} icon={Award} color="purple"
            subtitle={data?.kpis.porcentajeCompletados + " de finalizacion"}
            tooltip="Beneficiarios con certificado habilitado." />
        </div>

        {/* Graficas fila 1 */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
          <div className="lg:col-span-2 bg-white rounded-2xl border border-gray-200 shadow-card p-6">
            <div className="flex items-center justify-between mb-1">
              <h3 className="font-bold text-text-primary">Inscripciones por curso</h3>
              <span className="badge-muted text-xs">Desglose por genero</span>
            </div>
            <p className="text-text-muted text-xs mb-5">Meta contractual: minimo 50% mujeres por curso</p>
            <ResponsiveContainer width="100%" height={220}>
              <BarChart data={data?.courseKpis} barGap={6}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f5f5f5" vertical={false} />
                <XAxis dataKey="title" tick={{ fill: "#9CA3AF", fontSize: 10 }} tickLine={false} axisLine={false} />
                <YAxis tick={{ fill: "#9CA3AF", fontSize: 10 }} axisLine={false} tickLine={false} />
                <Tooltip content={<CustomTooltip />} />
                <Legend wrapperStyle={{ fontSize: 11, paddingTop: 8 }} />
                <Bar dataKey="mujeres" name="Mujeres" fill="#C0392B" radius={[5, 5, 0, 0]} maxBarSize={28} />
                <Bar dataKey="hombres" name="Hombres" fill="#2563EB" radius={[5, 5, 0, 0]} maxBarSize={28} />
              </BarChart>
            </ResponsiveContainer>
          </div>

          <div className="bg-white rounded-2xl border border-gray-200 shadow-card p-6">
            <h3 className="font-bold text-text-primary mb-1">Distribucion por genero</h3>
            <p className="text-text-muted text-xs mb-3">Total del programa</p>
            <ResponsiveContainer width="100%" height={180}>
              <PieChart>
                <Pie data={genderData} dataKey="value" nameKey="name" cx="50%" cy="50%" innerRadius={50} outerRadius={75}
                  label={({ name, percent }: any) => name + " " + (percent * 100).toFixed(0) + "%"} labelLine={false}>
                  <Cell fill="#C0392B" /><Cell fill="#2563EB" />
                </Pie>
                <Tooltip formatter={(v: any, n: any) => [v + " personas", n]} />
              </PieChart>
            </ResponsiveContainer>
            <div className="flex justify-center gap-4 mt-2">
              <div className="text-center">
                <p className="text-2xl font-bold text-primary">{data?.kpis.mujeres}</p>
                <p className="text-xs text-text-muted flex items-center gap-1"><span className="w-2 h-2 rounded-full bg-primary" />Mujeres</p>
              </div>
              <div className="w-px bg-gray-200" />
              <div className="text-center">
                <p className="text-2xl font-bold text-blue-600">{data?.kpis.hombres}</p>
                <p className="text-xs text-text-muted flex items-center gap-1"><span className="w-2 h-2 rounded-full bg-blue-600" />Hombres</p>
              </div>
            </div>
          </div>
        </div>

        {/* Graficas fila 2 */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
          <div className="bg-white rounded-2xl border border-gray-200 shadow-card p-6">
            <h3 className="font-bold text-text-primary mb-1">Meta de genero por curso</h3>
            <p className="text-text-muted text-xs mb-5">Verde = meta cumplida (>=50%), Rojo = en riesgo</p>
            <ResponsiveContainer width="100%" height={200}>
              <BarChart data={data?.courseKpis} barSize={38}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f5f5f5" vertical={false} />
                <XAxis dataKey="title" tick={{ fill: "#9CA3AF", fontSize: 10 }} tickLine={false} axisLine={false} />
                <YAxis domain={[0, 100]} tick={{ fill: "#9CA3AF", fontSize: 10 }} axisLine={false} tickLine={false} unit="%" />
                <Tooltip formatter={(v: any) => [v + "%", "Mujeres"]} />
                <ReferenceLine y={50} stroke="#C0392B" strokeDasharray="6 3" label={{ value: "Meta 50%", fill: "#C0392B", fontSize: 10, position: "insideTopRight" }} />
                <Bar dataKey="porcentajeMujeres" name="% Mujeres" radius={[6, 6, 0, 0]}>
                  {data?.courseKpis?.map((c: any, i: number) => (
                    <Cell key={i} fill={parseFloat(c.porcentajeMujeres) >= 50 ? "#16A34A" : "#C0392B"} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>

          <div className="bg-white rounded-2xl border border-gray-200 shadow-card p-6">
            <h3 className="font-bold text-text-primary mb-1">Grupos poblacionales</h3>
            <p className="text-text-muted text-xs mb-4">Enfoque diferencial - cada beneficiario pertenece a un grupo</p>
            <div className="space-y-2.5">
              {data?.populationBreakdown?.map((p: any, i: number) => (
                <div key={i} className="flex items-center gap-3">
                  <div className="w-2.5 h-2.5 rounded-full flex-shrink-0" style={{ background: COLORS[i % COLORS.length] }} />
                  <span className="text-xs text-text-secondary w-44 truncate font-medium">{p.grupo?.replace(/_/g, " ")}</span>
                  <div className="flex-1 bg-gray-100 rounded-full h-2">
                    <div className="h-2 rounded-full transition-all duration-500"
                      style={{ width: Math.min((p.cantidad / data.kpis.totalBeneficiarios) * 100, 100) + "%", background: COLORS[i % COLORS.length] }} />
                  </div>
                  <span className="text-xs font-bold text-text-primary w-6 text-right">{p.cantidad}</span>
                  <span className="text-xs text-text-muted w-9 text-right">{((p.cantidad / data.kpis.totalBeneficiarios) * 100).toFixed(0)}%</span>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Resumen y alerta */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
          <div className="lg:col-span-2 bg-white rounded-2xl border border-gray-200 shadow-card overflow-hidden">
            <div className="px-5 py-4 border-b border-gray-100 flex items-center justify-between">
              <h3 className="font-bold text-text-primary">Resumen por curso</h3>
              <span className="text-xs text-text-muted">{data?.courseKpis?.length} cursos activos</span>
            </div>
            <div className="divide-y divide-gray-50">
              {data?.courseKpis?.map((c: any, i: number) => (
                <div key={i} className="flex items-center gap-4 px-5 py-3.5 hover:bg-gray-50 transition-colors">
                  <div className="w-2 h-8 rounded-full flex-shrink-0" style={{ background: COLORS[i % COLORS.length] }} />
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-semibold text-text-primary truncate">{c.fullTitle}</p>
                    <p className="text-xs text-text-muted">{c.formador}</p>
                  </div>
                  <div className="flex items-center gap-3 text-right flex-shrink-0">
                    <div>
                      <p className="text-sm font-bold text-text-primary">{c.inscritos}</p>
                      <p className="text-xs text-text-muted">inscritos</p>
                    </div>
                    <div>
                      <p className="text-xs text-pink-600 font-semibold">{c.mujeres}F</p>
                      <p className="text-xs text-blue-600 font-semibold">{c.hombres}M</p>
                    </div>
                    <span className={"badge text-xs " + (parseFloat(c.porcentajeMujeres) >= 50 ? "badge-success" : "badge-primary")}>
                      {c.porcentajeMujeres}%
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className={"rounded-2xl border p-5 flex flex-col gap-4 " + (metaCumplida ? "bg-gradient-to-br from-green-50 to-white border-green-200" : "bg-gradient-to-br from-red-50 to-white border-red-200")}>
            <div className="flex items-start gap-3">
              {metaCumplida ? <CheckCircle className="w-6 h-6 text-green-600 flex-shrink-0 mt-0.5" /> : <AlertTriangle className="w-6 h-6 text-red-600 flex-shrink-0 mt-0.5" />}
              <div>
                <p className={"font-bold " + (metaCumplida ? "text-green-800" : "text-red-800")}>Meta de genero</p>
                <p className={"text-xs mt-0.5 " + (metaCumplida ? "text-green-600" : "text-red-600")}>{data?.kpis.metaMujeres}</p>
              </div>
            </div>
            <p className={"text-sm " + (metaCumplida ? "text-green-700" : "text-red-700")}>
              Contrato exige minimo <strong>50% mujeres</strong>. Actualmente <strong>{data?.kpis.porcentajeMujeres}</strong> de {data?.kpis.totalBeneficiarios} inscritos.
            </p>
            <div className="grid grid-cols-2 gap-2">
              <div className={"rounded-xl p-3 text-center " + (metaCumplida ? "bg-green-100/60" : "bg-red-100/60")}>
                <p className={"text-2xl font-bold " + (metaCumplida ? "text-green-700" : "text-red-700")}>{data?.kpis.mujeres}</p>
                <p className="text-xs text-text-muted">Mujeres</p>
              </div>
              <div className="bg-blue-100/60 rounded-xl p-3 text-center">
                <p className="text-2xl font-bold text-blue-700">{data?.kpis.hombres}</p>
                <p className="text-xs text-text-muted">Hombres</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </AppShell>
  );
}'
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\admin\page.tsx", $adminDash, [System.Text.Encoding]::UTF8)
Write-Host "Admin dashboard profesional OK" -ForegroundColor Green

# ── 3. CERTIFICADO BACKEND: usa certificado.jpeg como fondo ──
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

  // Intentar usar certificado.jpeg como imagen de fondo
  const certBg = path.join(PUB, "certificado.jpeg");
  const certBgJpg = path.join(PUB, "certificado.jpg");
  const certBgPng = path.join(PUB, "certificado.png");

  let bgUsed = false;
  for (const bgPath of [certBg, certBgJpg, certBgPng]) {
    if (fs.existsSync(bgPath)) {
      doc.image(bgPath, 0, 0, { width: W, height: H });
      bgUsed = true;
      break;
    }
  }

  if (!bgUsed) {
    // Fondo manual si no hay imagen
    doc.rect(0, 0, W, H).fill("#FFFFFF");
    doc.rect(0, 0, W, 12).fill("#C0392B");
    doc.rect(0, H - 12, W, 12).fill("#C0392B");
    doc.rect(0, 12, W, 6).fill("#F39C12");
    doc.rect(0, H - 18, W, 6).fill("#F39C12");
    const sq = 70;
    doc.rect(0, 18, sq, sq).fill("#C0392B");
    doc.rect(W - sq, 18, sq, sq).fill("#C0392B");
    doc.rect(0, H - 18 - sq, sq, sq).fill("#C0392B");
    doc.rect(W - sq, H - 18 - sq, sq, sq).fill("#C0392B");
    doc.rect(55, 55, W - 110, H - 110).lineWidth(1.5).stroke("#C0392B");
  }

  // Texto sobre la imagen (coordenadas calibradas para la plantilla)
  let y = bgUsed ? 175 : 80;

  if (!bgUsed) {
    const logoPath = path.join(PUB, "logo.png");
    if (fs.existsSync(logoPath)) { doc.image(logoPath, W / 2 - 30, 72, { width: 60 }); y = 145; }
    doc.font("Helvetica-Bold").fontSize(36).fillColor("#1a1a1a").text("CERTIFICADO", 0, y, { align: "center" }); y += 44;
    doc.font("Helvetica").fontSize(13).fillColor("#777").text("DE PARTICIPACION", 0, y, { align: "center", characterSpacing: 4 }); y += 30;
    doc.font("Helvetica").fontSize(11).fillColor("#444").text("Este certificado se entrega a:", 0, y, { align: "center" }); y += 26;
  }

  // Nombre del beneficiario (sobre la linea en blanco de la plantilla)
  doc.font("Helvetica-Bold").fontSize(24).fillColor("#C0392B").text(fullName, 0, y, { align: "center" }); y += bgUsed ? 40 : 42;

  if (!bgUsed) {
    doc.moveTo(130, y - 6).lineTo(W - 130, y - 6).lineWidth(0.8).stroke("#ccc");
    doc.font("Helvetica").fontSize(11).fillColor("#444").text("Por haber asistido y aprobado satisfactoriamente el curso de capacitacion:", 0, y, { align: "center" }); y += 26;
  }

  // Nombre del curso
  doc.font("Helvetica-Bold").fontSize(bgUsed ? 16 : 15).fillColor("#1a1a1a")
    .text(courseTitle, 80, y, { align: "center", width: W - 160, characterSpacing: 2 }); y += bgUsed ? 38 : 36;

  // Fecha y duracion
  doc.font("Helvetica-Bold").fontSize(10).fillColor("#555")
    .text("Realizado el:  " + dateStr + "          Duracion:  40 horas  |  Modalidad " + (course.modality === "VIRTUAL" ? "Virtual" : "Presencial"), 0, y, { align: "center" });
  y += bgUsed ? 55 : 52;

  // Firmas (solo si no hay imagen de fondo - si hay imagen la firma ya esta impresa)
  if (!bgUsed) {
    const fW = 200; const gap = 90;
    const x1 = W / 2 - fW - gap / 2;
    const x2 = W / 2 + gap / 2;
    doc.moveTo(x1, y).lineTo(x1 + fW, y).lineWidth(0.8).stroke("#333");
    doc.font("Helvetica-Bold").fontSize(9.5).fillColor("#1a1a1a").text("KARLA TATHYANNA MARIN OSPINA", x1, y + 6, { width: fW, align: "center" });
    doc.font("Helvetica").fontSize(8.5).fillColor("#666").text("ALCALDESA LOCAL DE KENNEDY", x1, y + 18, { width: fW, align: "center" });
    doc.moveTo(x2, y).lineTo(x2 + fW, y).lineWidth(0.8).stroke("#333");
    doc.font("Helvetica-Bold").fontSize(9.5).fillColor("#1a1a1a").text("GERARDO SANTAMARIA BORDA", x2, y + 6, { width: fW, align: "center" });
    doc.font("Helvetica").fontSize(8.5).fillColor("#666").text("CEO - BOOST BUSINESS CONSULTING", x2, y + 18, { width: fW, align: "center" });
  }

  doc.end();
}

// Solo ADMIN puede descargar
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

// Habilitar
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
Write-Host "certificates.js con certificado.jpeg OK" -ForegroundColor Green

# ── 4. REPORTES PROFESIONALES ─────────────────────────────────
$adminReports = '"use client";
import { useEffect, useState } from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { Download, Loader2, BarChart3, Users, BookOpen, TrendingUp, Heart, FileText, CheckCircle, AlertTriangle } from "lucide-react";

export default function AdminReportsPage() {
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [downloading, setDownloading] = useState(false);
  useEffect(() => { api.get("/admin/dashboard").then(({ data }) => setData(data)).finally(() => setLoading(false)); }, []);

  const downloadPDF = async () => {
    setDownloading(true);
    try {
      const res = await api.get("/admin/report/pdf", { responseType: "blob" });
      const url = window.URL.createObjectURL(new Blob([res.data]));
      const a = document.createElement("a"); a.href = url; a.download = "reporte-buskando-parche.pdf"; a.click();
    } finally { setDownloading(false); }
  };

  return (
    <AppShell allowedRoles={["ADMIN"]}>
      <div className="max-w-5xl mx-auto space-y-8">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="font-display text-3xl font-bold text-text-primary">Reportes del Programa</h1>
            <p className="text-text-secondary mt-1">Informacion consolidada - Kennedy, Bogota</p>
          </div>
          <button onClick={downloadPDF} disabled={downloading || loading}
            className="btn-primary flex items-center gap-2 shadow-brand hover:shadow-lg transition-all">
            {downloading ? <Loader2 className="w-4 h-4 animate-spin" /> : <Download className="w-4 h-4" />}
            {downloading ? "Generando..." : "Descargar PDF"}
          </button>
        </div>

        {loading ? <div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div> : (
          <>
            {/* Resumen ejecutivo */}
            <div className="bg-gradient-brand rounded-2xl p-6 text-white">
              <div className="flex items-center gap-3 mb-4">
                <img src="/images/logo.png" alt="" className="h-10 w-auto object-contain"
                  onError={(e) => { (e.target as HTMLImageElement).style.display="none"; }} />
                <div>
                  <h2 className="font-display font-bold text-xl">Buskando Parche - Kennedy</h2>
                  <p className="text-white/70 text-sm">Resumen ejecutivo del programa de formacion</p>
                </div>
              </div>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                {[
                  { l: "Beneficiarios", v: data?.kpis.totalBeneficiarios },
                  { l: "Mujeres", v: data?.kpis.mujeres + " (" + data?.kpis.porcentajeMujeres + ")" },
                  { l: "Asistencia", v: data?.kpis.porcentajeAsistencia },
                  { l: "Completados", v: data?.kpis.completados },
                ].map((k, i) => (
                  <div key={i} className="bg-white/15 rounded-xl p-3 text-center backdrop-blur-sm">
                    <p className="text-2xl font-bold">{k.v}</p>
                    <p className="text-xs text-white/70 mt-0.5">{k.l}</p>
                  </div>
                ))}
              </div>
            </div>

            {/* Detalle por curso */}
            <div className="bg-white rounded-2xl border border-gray-200 shadow-card overflow-hidden">
              <div className="px-6 py-4 border-b border-gray-100 flex items-center gap-2">
                <BookOpen className="w-5 h-5 text-primary" />
                <h3 className="font-bold text-text-primary">Detalle por curso</h3>
              </div>
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="bg-gray-50">
                      <th className="text-left py-3 px-5 font-semibold text-text-secondary rounded-l-xl">Curso</th>
                      <th className="text-left py-3 px-4 font-semibold text-text-secondary">Formador</th>
                      <th className="text-left py-3 px-4 font-semibold text-text-secondary">Modalidad</th>
                      <th className="text-center py-3 px-4 font-semibold text-text-secondary">Inscritos</th>
                      <th className="text-center py-3 px-4 font-semibold text-text-secondary">Mujeres</th>
                      <th className="text-center py-3 px-4 font-semibold text-text-secondary">Hombres</th>
                      <th className="text-center py-3 px-4 font-semibold text-text-secondary rounded-r-xl">% Mujeres</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-50">
                    {data?.courseKpis?.map((c: any, i: number) => (
                      <tr key={i} className="hover:bg-gray-50 transition-colors">
                        <td className="py-3.5 px-5 font-semibold text-text-primary">{c.fullTitle}</td>
                        <td className="py-3.5 px-4 text-text-secondary text-xs">{c.formador}</td>
                        <td className="py-3.5 px-4">
                          <span className={c.modality === "VIRTUAL" ? "badge-info" : "badge-success"}>{c.modality === "VIRTUAL" ? "Virtual" : "Presencial"}</span>
                        </td>
                        <td className="py-3.5 px-4 text-center font-bold text-text-primary">{c.inscritos}</td>
                        <td className="py-3.5 px-4 text-center font-semibold text-pink-600">{c.mujeres}</td>
                        <td className="py-3.5 px-4 text-center font-semibold text-blue-600">{c.hombres}</td>
                        <td className="py-3.5 px-4 text-center">
                          <span className={"badge " + (parseFloat(c.porcentajeMujeres) >= 50 ? "badge-success" : "badge-primary")}>{c.porcentajeMujeres}%</span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>

            {/* Grupos poblacionales */}
            <div className="bg-white rounded-2xl border border-gray-200 shadow-card p-6">
              <div className="flex items-center gap-2 mb-5">
                <Users className="w-5 h-5 text-primary" />
                <h3 className="font-bold text-text-primary">Grupos poblacionales - Enfoque diferencial</h3>
              </div>
              <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
                {data?.populationBreakdown?.map((p: any, i: number) => (
                  <div key={i} className="bg-gray-50 rounded-xl p-4 border border-gray-100 hover:border-primary/30 transition-colors">
                    <p className="text-2xl font-bold text-text-primary">{p.cantidad}</p>
                    <p className="text-sm text-text-muted mt-0.5">{p.grupo?.replace(/_/g, " ")}</p>
                    <div className="mt-2 bg-gray-200 rounded-full h-1.5">
                      <div className="bg-primary h-1.5 rounded-full transition-all"
                        style={{ width: Math.min((p.cantidad / data.kpis.totalBeneficiarios) * 100, 100) + "%" }} />
                    </div>
                    <p className="text-xs text-text-muted mt-1">{((p.cantidad / data.kpis.totalBeneficiarios) * 100).toFixed(1)}% del total</p>
                  </div>
                ))}
              </div>
            </div>

            {/* Aviso PDF */}
            <div className="bg-blue-50 border border-blue-200 rounded-2xl p-5 flex items-start gap-4">
              <FileText className="w-6 h-6 text-blue-600 flex-shrink-0 mt-0.5" />
              <div className="flex-1">
                <p className="font-semibold text-blue-800">Reporte PDF completo con logo del programa</p>
                <p className="text-sm text-blue-600 mt-1">Incluye: resumen ejecutivo, detalle por curso, listado de 80 beneficiarios con cedula y estado. Listo para entregar a la Alcaldia de Kennedy.</p>
              </div>
              <button onClick={downloadPDF} disabled={downloading}
                className="btn-primary flex items-center gap-2 text-sm flex-shrink-0">
                {downloading ? <Loader2 className="w-4 h-4 animate-spin" /> : <Download className="w-4 h-4" />}
                {downloading ? "..." : "Descargar"}
              </button>
            </div>
          </>
        )}
      </div>
    </AppShell>
  );
}'
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\admin\reports" | Out-Null
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\admin\reports\page.tsx", $adminReports, [System.Text.Encoding]::UTF8)
Write-Host "Reportes profesionales OK" -ForegroundColor Green

# ── 5. REPORTE PDF con logo Buskando Parche ───────────────────
$adminCtrlPath = "$PWD\backend\src\controllers\adminController.js"
$adminCtrl = Get-Content $adminCtrlPath -Raw
$newGetReport = 'const getReport = async (req, res) => {
  try {
    const PDFDocument = require("pdfkit");
    const path = require("path");
    const fs = require("fs");
    const doc = new PDFDocument({ size: "A4", margin: 50 });
    res.setHeader("Content-Type", "application/pdf");
    res.setHeader("Content-Disposition", "attachment; filename=reporte-buskando-parche.pdf");
    doc.pipe(res);

    const PUB = path.join(__dirname, "../../frontend/public/images");
    const W = doc.page.width;

    // HEADER con logo
    doc.rect(0, 0, W, 90).fill("#C0392B");
    const logoPath = path.join(PUB, "logo.png");
    if (fs.existsSync(logoPath)) { doc.image(logoPath, 45, 15, { height: 60 }); }
    doc.font("Helvetica-Bold").fontSize(20).fillColor("white").text("BUSKANDO PARCHE - KENNEDY", 120, 22);
    doc.font("Helvetica").fontSize(11).fillColor("white").text("Reporte General del Programa de Formacion", 120, 46);
    doc.font("Helvetica").fontSize(9).fillColor("rgba(255,255,255,0.7)").text("Alcaldia Local de Kennedy - Bogota, Colombia", 120, 63);

    // Marca de agua logo en cuerpo
    if (fs.existsSync(logoPath)) {
      doc.save();
      doc.opacity(0.04);
      doc.image(logoPath, W/2 - 120, 300, { width: 240 });
      doc.restore();
    }

    let y = 110;
    doc.font("Helvetica").fontSize(9).fillColor("#888")
      .text("Generado el: " + new Date().toLocaleDateString("es-CO", { year:"numeric", month:"long", day:"numeric", hour:"2-digit", minute:"2-digit" }), 50, y);
    y += 25;

    const [bens, cursos, asistencias] = await Promise.all([
      prisma.user.findMany({ where: { role: "BENEFICIARIO", isActive: true }, include: { enrollments: { include: { course: { select: { title: true } } } } }, orderBy: { lastName: "asc" } }),
      prisma.course.findMany({ where: { isPublished: true }, include: { enrollments: { include: { user: { select: { gender: true, populationGroup: true } } } }, formador: { select: { firstName: true, lastName: true } } } }),
      prisma.attendance.groupBy({ by: ["status"], _count: { status: true } }),
    ]);

    const attMap = {};
    asistencias.forEach(a => { attMap[a.status] = a._count.status; });
    const totalAtt = Object.values(attMap).reduce((a, b) => a + b, 0);
    const pctAsist = totalAtt > 0 ? ((attMap["PRESENTE"] || 0) / totalAtt * 100).toFixed(1) : 0;
    const mujeres = bens.filter(b => b.gender === "FEMENINO").length;

    // RESUMEN
    doc.rect(50, y, W - 100, 20).fill("#F3F4F6");
    doc.font("Helvetica-Bold").fontSize(12).fillColor("#C0392B").text("RESUMEN EJECUTIVO", 60, y + 4); y += 28;

    const kpis = [
      ["Total beneficiarios", bens.length, "de 80 cupos"],
      ["Mujeres", mujeres, ((mujeres/bens.length)*100).toFixed(1) + "% del total"],
      ["Hombres", bens.length-mujeres, (((bens.length-mujeres)/bens.length)*100).toFixed(1) + "% del total"],
      ["Cursos activos", cursos.length, "programas"],
      ["% Asistencia global", pctAsist + "%", "sesiones registradas"],
    ];
    kpis.forEach(([l, v, s]) => {
      doc.font("Helvetica-Bold").fontSize(10).fillColor("#111").text(l + ": ", 60, y, { continued: true });
      doc.font("Helvetica").fillColor("#333").text(String(v) + "  ", { continued: true });
      doc.fillColor("#888").text("(" + s + ")");
      y += 16;
    });
    y += 12;

    // CURSOS
    doc.rect(50, y, W - 100, 20).fill("#F3F4F6");
    doc.font("Helvetica-Bold").fontSize(12).fillColor("#C0392B").text("DETALLE POR CURSO", 60, y + 4); y += 28;

    cursos.forEach(c => {
      const ins = c.enrollments.length;
      const muj = c.enrollments.filter(e => e.user?.gender === "FEMENINO").length;
      doc.fontSize(11).font("Helvetica-Bold").fillColor("#111").text(c.title, 60, y); y += 14;
      doc.fontSize(9).font("Helvetica").fillColor("#555")
        .text("Formador: " + (c.formador ? c.formador.firstName + " " + c.formador.lastName : "N/A") + "  |  Inscritos: " + ins + "  |  Mujeres: " + muj + " (" + (ins>0?((muj/ins)*100).toFixed(0):0) + "%)  |  " + c.modality, 70, y);
      y += 18;
    });
    y += 10;

    // LISTADO BENEFICIARIOS
    if (y > 650) { doc.addPage(); y = 50; }
    doc.rect(50, y, W - 100, 20).fill("#F3F4F6");
    doc.font("Helvetica-Bold").fontSize(12).fillColor("#C0392B").text("LISTADO COMPLETO DE BENEFICIARIOS", 60, y + 4); y += 28;

    doc.fontSize(8).font("Helvetica-Bold").fillColor("#555");
    doc.text("NOMBRE", 60, y); doc.text("CEDULA", 210, y); doc.text("GENERO", 300, y);
    doc.text("CURSO", 360, y); doc.text("ESTADO", 490, y);
    y += 12;
    doc.moveTo(50, y).lineTo(W - 50, y).lineWidth(0.5).stroke("#ddd");
    y += 6;

    bens.forEach(b => {
      if (y > 760) { doc.addPage(); y = 50; }
      const curso = b.enrollments[0]?.course?.title?.substring(0, 20) || "Sin curso";
      doc.fontSize(7.5).font("Helvetica").fillColor("#111");
      doc.text(b.firstName + " " + b.lastName, 60, y, { width: 140 });
      doc.text(b.cedula, 210, y);
      doc.text(b.gender || "-", 300, y);
      doc.text(curso, 360, y, { width: 125 });
      doc.text(b.enrollments[0]?.status || "-", 490, y);
      y += 14;
    });

    // FOOTER
    const pages = doc.bufferedPageRange();
    for (let i = 0; i < pages.count; i++) {
      doc.switchToPage(i);
      doc.rect(0, doc.page.height - 30, doc.page.width, 30).fill("#C0392B");
      doc.font("Helvetica").fontSize(8).fillColor("white")
        .text("Buskando Parche - Alcaldia Local de Kennedy - Bogota", 50, doc.page.height - 18);
      doc.text("Pag. " + (i + 1) + " de " + pages.count, doc.page.width - 100, doc.page.height - 18);
    }

    doc.end();
  } catch (err) {
    console.error(err);
    if (!res.headersSent) res.status(500).json({ error: "Error generando reporte" });
  }
};'

if ($adminCtrl -match "const getReport") {
  $adminCtrl = $adminCtrl -replace "const getReport = async.*?^};", "" -replace "(?s)const getReport.*?^};",""
}
# Agregar al final antes de module.exports
$adminCtrl = $adminCtrl -replace "module\.exports", ($newGetReport + "`nmodule.exports")
[System.IO.File]::WriteAllText($adminCtrlPath, $adminCtrl, [System.Text.Encoding]::UTF8)
Write-Host "adminController con reporte PDF y logo OK" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "FIX V11 COMPLETO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "P = Presente, A = Ausente, E = Excusa" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ejecuta:" -ForegroundColor Cyan
Write-Host "  docker-compose down" -ForegroundColor White
Write-Host "  docker-compose up --build" -ForegroundColor White
