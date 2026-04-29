"use client";
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
}