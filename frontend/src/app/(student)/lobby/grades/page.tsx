"use client";
import { useEffect, useState } from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { useAuth } from "@/contexts/AuthContext";
import { GraduationCap, TrendingUp, CheckCircle, Loader2, BookOpen } from "lucide-react";
import clsx from "clsx";
export default function BenGradesPage() {
  const { user } = useAuth();
  const [courses, setCourses] = useState<any[]>([]);
  const [selCourse, setSelCourse] = useState<any>(null);
  const [grades, setGrades] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadingGrades, setLoadingGrades] = useState(false);
  useEffect(() => {
    api.get("/courses/lobby").then(({ data }) => {
      const en = data.filter((c: any) => c.isEnrolled);
      setCourses(en);
      if (en.length > 0) loadGrades(en[0]);
    }).finally(() => setLoading(false));
  }, []);
  const loadGrades = async (course: any) => {
    setSelCourse(course); setLoadingGrades(true);
    try {
      const { data } = await api.get("/assignments/grades/" + course.id);
      setGrades(data);
    } catch { setGrades([]); }
    finally { setLoadingGrades(false); }
  };
  const graded = grades.filter((g: any) => g.score !== null);
  const promedio = graded.length ? (graded.reduce((s: number, g: any) => s + g.score, 0) / graded.length).toFixed(1) : null;
  const presente = grades.filter((g: any) => g.attendance === "PRESENTE").length;
  const pctAsis = grades.length ? ((presente / grades.length) * 100).toFixed(0) : 0;
  return (
    <AppShell allowedRoles={["BENEFICIARIO"]}>
      <div className="max-w-4xl mx-auto space-y-6">
        <div><h1 className="font-display text-2xl font-bold text-text-primary">Mis Calificaciones</h1><p className="text-text-secondary mt-1">Sabana de notas y asistencia por sesion.</p></div>
        {loading ? <div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div> : (
          <>
            {courses.length > 1 && (
              <div className="flex gap-2 flex-wrap">
                {courses.map((c: any) => (
                  <button key={c.id} onClick={() => loadGrades(c)}
                    className={`px-4 py-2 rounded-full text-sm font-medium transition-colors ${selCourse?.id === c.id ? "bg-primary text-white" : "bg-gray-100 text-text-secondary hover:bg-gray-200"}`}>
                    {c.title}
                  </button>
                ))}
              </div>
            )}
            {selCourse && (
              <>
                {/* KPIs */}
                <div className="grid grid-cols-3 gap-4">
                  <div className="card text-center">
                    <p className={clsx("text-3xl font-bold font-display", promedio && parseFloat(promedio) >= 60 ? "text-green-600" : "text-red-500")}>{promedio || "-"}</p>
                    <p className="text-text-muted text-sm mt-1">Promedio general</p>
                    {promedio && <p className={clsx("text-xs font-semibold mt-1", parseFloat(promedio) >= 60 ? "text-green-600" : "text-red-500")}>{parseFloat(promedio) >= 60 ? "Aprobado" : "Reprobado"}</p>}
                  </div>
                  <div className="card text-center">
                    <p className="text-3xl font-bold font-display text-blue-600">{pctAsis}%</p>
                    <p className="text-text-muted text-sm mt-1">Asistencia</p>
                    <p className="text-xs text-text-muted mt-1">{presente} de {grades.length} sesiones</p>
                  </div>
                  <div className="card text-center">
                    <p className="text-3xl font-bold font-display text-text-primary">{graded.length}</p>
                    <p className="text-text-muted text-sm mt-1">Sesiones calificadas</p>
                    <p className="text-xs text-text-muted mt-1">de {grades.length} totales</p>
                  </div>
                </div>
                {/* Tabla de notas */}
                {loadingGrades ? (
                  <div className="flex justify-center py-8"><Loader2 className="w-6 h-6 text-primary animate-spin" /></div>
                ) : (
                  <div className="card overflow-hidden p-0">
                    <div className="p-4 bg-gray-50 border-b flex items-center gap-2">
                      <GraduationCap className="w-5 h-5 text-primary" />
                      <h3 className="font-bold text-text-primary">Sabana de notas - {selCourse.title}</h3>
                    </div>
                    <div className="overflow-x-auto">
                      <table className="w-full text-sm">
                        <thead>
                          <tr className="bg-gray-50 border-b border-gray-100">
                            <th className="text-left py-3 px-4 font-semibold text-text-secondary">Sesion</th>
                            <th className="text-center py-3 px-4 font-semibold text-text-secondary">Asistencia</th>
                            <th className="text-center py-3 px-4 font-semibold text-text-secondary">Nota</th>
                            <th className="text-center py-3 px-4 font-semibold text-text-secondary">Estado</th>
                            <th className="text-left py-3 px-4 font-semibold text-text-secondary">Retroalimentacion</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-50">
                          {grades.map((g: any) => (
                            <tr key={g.id} className="hover:bg-gray-50 transition-colors">
                              <td className="py-3 px-4 font-medium text-text-primary">{g.title}</td>
                              <td className="py-3 px-4 text-center">
                                <span className={clsx("badge text-xs", g.attendance === "PRESENTE" ? "badge-success" : g.attendance === "AUSENTE" ? "badge-primary" : g.attendance === "EXCUSA" ? "badge-warning" : "badge-muted")}>
                                  {g.attendance || "Sin registro"}
                                </span>
                              </td>
                              <td className="py-3 px-4 text-center">
                                {g.score !== null ? (
                                  <div className="flex flex-col items-center">
                                    <span className={clsx("text-lg font-bold", g.score >= 60 ? "text-green-600" : "text-red-500")}>{g.score}</span>
                                    <div className="w-16 bg-gray-200 rounded-full h-1.5 mt-1">
                                      <div className="h-1.5 rounded-full" style={{ width: Math.min(g.score, 100) + "%", background: g.score >= 60 ? "#16A34A" : "#C0392B" }} />
                                    </div>
                                  </div>
                                ) : (
                                  <span className="text-text-muted text-xs">Pendiente</span>
                                )}
                              </td>
                              <td className="py-3 px-4 text-center">
                                {g.score !== null ? (
                                  <span className={clsx("badge text-xs", g.score >= 60 ? "badge-success" : "badge-primary")}>{g.score >= 60 ? "Aprobado" : "Reprobado"}</span>
                                ) : <span className="text-text-muted text-xs">-</span>}
                              </td>
                              <td className="py-3 px-4 text-text-secondary text-xs italic">{g.feedback || "-"}</td>
                            </tr>
                          ))}
                        </tbody>
                        {promedio && (
                          <tfoot>
                            <tr className="border-t-2 border-gray-200 bg-gray-50">
                              <td className="py-3 px-4 font-bold text-text-primary" colSpan={2}>PROMEDIO FINAL</td>
                              <td className="py-3 px-4 text-center">
                                <span className={clsx("text-xl font-bold", parseFloat(promedio) >= 60 ? "text-green-600" : "text-red-500")}>{promedio}</span>
                              </td>
                              <td className="py-3 px-4 text-center">
                                <span className={clsx("badge", parseFloat(promedio) >= 60 ? "badge-success" : "badge-primary")}>{parseFloat(promedio) >= 60 ? "Aprobado" : "Reprobado"}</span>
                              </td>
                              <td className="py-3 px-4 text-xs text-text-muted">{graded.length} sesiones calificadas</td>
                            </tr>
                          </tfoot>
                        )}
                      </table>
                      {grades.length === 0 && (
                        <div className="text-center py-10"><p className="text-text-muted text-sm">El formador aun no ha registrado calificaciones.</p></div>
                      )}
                    </div>
                  </div>
                )}
              </>
            )}
          </>
        )}
      </div>
    </AppShell>
  );
}