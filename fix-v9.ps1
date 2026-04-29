Write-Host "=== FIX V9 - Asistencia + Calificaciones + Encoding ===" -ForegroundColor Yellow

# ── 1. ASISTENCIA CORREGIDA ───────────────────────────────────
# El problema: filtraba enrollments por courseId pero el campo no venia completo
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\formador\attendance" | Out-Null
$attContent = '"use client";
import { useEffect, useState, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { Loader2, CheckCircle, ClipboardList } from "lucide-react";
import clsx from "clsx";

function AttContent() {
  const params = useSearchParams();
  const courseId = params.get("courseId");
  const [course, setCourse] = useState<any>(null);
  const [selSession, setSelSession] = useState<any>(null);
  const [students, setStudents] = useState<any[]>([]);
  const [att, setAtt] = useState<Record<string, string>>({});
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [msg, setMsg] = useState("");

  useEffect(() => {
    if (!courseId) { setLoading(false); return; }
    // Cargar curso y TODOS los inscritos de una vez
    Promise.all([
      api.get("/courses/" + courseId),
      api.get("/users", { params: { role: "BENEFICIARIO", limit: 100, page: 1 } }),
    ]).then(([cRes, uRes]) => {
      setCourse(cRes.data);
      // Filtrar solo los que tienen enrollments activos en este curso
      const allUsers = uRes.data.data || [];
      const enrolled = allUsers.filter((u: any) => {
        if (!u.enrollments || u.enrollments.length === 0) return false;
        return u.enrollments.some((e: any) => {
          // El enrollment puede tener courseId directamente o dentro de course
          const cid = e.courseId || e.course?.id;
          return cid === courseId;
        });
      });
      setStudents(enrolled);
    }).catch((err) => {
      console.error("Error cargando datos:", err);
    }).finally(() => setLoading(false));
  }, [courseId]);

  const selectSession = async (s: any) => {
    setSelSession(s); setMsg("");
    // Cargar asistencias existentes para esta sesion
    try {
      const { data: attData } = await api.get("/attendance/session/" + s.id);
      const map: Record<string, string> = {};
      attData.forEach((a: any) => { map[a.userId] = a.status; });
      // Para estudiantes sin asistencia registrada, poner PRESENTE por defecto
      students.forEach((u: any) => { if (!map[u.id]) map[u.id] = "PRESENTE"; });
      setAtt(map);
    } catch (e) {
      console.error(e);
      // Si falla, inicializar todos como PRESENTE
      const map: Record<string, string> = {};
      students.forEach((u: any) => { map[u.id] = "PRESENTE"; });
      setAtt(map);
    }
  };

  const save = async () => {
    if (!selSession || students.length === 0) return;
    setSaving(true);
    try {
      const attendances = students.map((u: any) => ({
        userId: u.id,
        status: att[u.id] || "PRESENTE",
        notes: ""
      }));
      await api.post("/attendance", { sessionId: selSession.id, attendances });
      setMsg("Asistencia guardada para " + selSession.title + " (" + students.length + " estudiantes)");
    } catch (e) {
      setMsg("Error al guardar asistencia");
    } finally { setSaving(false); }
  };

  const present = Object.values(att).filter((v) => v === "PRESENTE").length;
  const absent = Object.values(att).filter((v) => v === "AUSENTE").length;
  const excuse = Object.values(att).filter((v) => v === "EXCUSA").length;

  if (loading) return (
    <div className="flex flex-col items-center justify-center py-20 gap-3">
      <Loader2 className="w-8 h-8 text-primary animate-spin" />
      <p className="text-text-muted text-sm">Cargando curso y estudiantes...</p>
    </div>
  );

  if (!courseId) return (
    <div className="card text-center py-12">
      <ClipboardList className="w-10 h-10 text-gray-300 mx-auto mb-3" />
      <p className="text-text-muted">Accede desde el panel del formador o el menu lateral.</p>
    </div>
  );

  return (
    <div className="max-w-5xl mx-auto space-y-6">
      <div>
        <h1 className="font-display text-2xl font-bold text-text-primary">Registro de Asistencia</h1>
        <p className="text-text-secondary mt-1">{course?.title} - {students.length} estudiantes inscritos</p>
      </div>

      {students.length === 0 && !loading && (
        <div className="card bg-yellow-50 border-yellow-200 text-yellow-700 text-sm p-4">
          No se encontraron estudiantes inscritos en este curso. Verifica que el seed se haya ejecutado correctamente.
        </div>
      )}

      {msg && (
        <div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-xl text-sm flex items-center gap-2">
          <CheckCircle className="w-4 h-4" />{msg}
          <button onClick={() => setMsg("")} className="ml-auto font-bold">x</button>
        </div>
      )}

      <div className="grid md:grid-cols-3 gap-6">
        {/* Lista sesiones */}
        <div className="bg-white rounded-2xl border border-gray-200 shadow-card overflow-hidden">
          <div className="p-4 bg-gray-50 border-b">
            <p className="font-semibold text-text-primary text-sm">Selecciona la sesion</p>
          </div>
          <div className="divide-y divide-gray-50 max-h-[480px] overflow-y-auto">
            {course?.sessions?.map((s: any) => (
              <button key={s.id} onClick={() => selectSession(s)}
                className={clsx("w-full text-left px-4 py-3 text-sm transition-colors flex items-center gap-3",
                  selSession?.id === s.id
                    ? "bg-red-50 border-r-2 border-primary text-primary font-semibold"
                    : "hover:bg-gray-50 text-text-secondary")}>
                <span className={clsx("w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0",
                  selSession?.id === s.id ? "bg-primary text-white" : "bg-gray-100 text-gray-600")}>
                  {s.order}
                </span>
                {s.title}
              </button>
            ))}
          </div>
        </div>

        {/* Panel asistencia */}
        <div className="md:col-span-2 space-y-4">
          {!selSession ? (
            <div className="bg-white rounded-2xl border border-gray-200 shadow-card text-center py-12">
              <ClipboardList className="w-10 h-10 text-gray-300 mx-auto mb-3" />
              <p className="text-text-muted text-sm">Selecciona una sesion para registrar asistencia</p>
            </div>
          ) : (
            <div className="bg-white rounded-2xl border border-gray-200 shadow-card p-5">
              <div className="flex items-center justify-between mb-4">
                <h3 className="font-bold text-text-primary">{selSession.title}</h3>
                <div className="flex gap-2">
                  <span className="badge-success text-xs">P: {present}</span>
                  <span className="badge-primary text-xs">A: {absent}</span>
                  <span className="badge-warning text-xs">E: {excuse}</span>
                </div>
              </div>

              {students.length === 0 ? (
                <p className="text-text-muted text-sm text-center py-4">Sin estudiantes inscritos</p>
              ) : (
                <div className="space-y-2 max-h-80 overflow-y-auto pr-1">
                  {students.map((u: any) => (
                    <div key={u.id} className={clsx(
                      "flex items-center gap-3 px-3 py-2.5 rounded-xl transition-colors",
                      att[u.id] === "PRESENTE" ? "bg-green-50"
                      : att[u.id] === "AUSENTE" ? "bg-red-50"
                      : att[u.id] === "EXCUSA" ? "bg-yellow-50"
                      : "bg-gray-50"
                    )}>
                      <div className="flex-1">
                        <p className="text-sm font-medium text-text-primary">{u.firstName} {u.lastName}</p>
                        <p className="text-xs text-text-muted">{u.cedula}</p>
                      </div>
                      <div className="flex gap-1.5">
                        {(["PRESENTE", "AUSENTE", "EXCUSA"] as const).map((st) => (
                          <button key={st} onClick={() => setAtt((prev) => ({ ...prev, [u.id]: st }))}
                            className={clsx("w-9 h-8 rounded-lg text-xs font-bold transition-colors",
                              att[u.id] === st
                                ? (st === "PRESENTE" ? "bg-green-500 text-white"
                                  : st === "AUSENTE" ? "bg-red-500 text-white"
                                  : "bg-yellow-500 text-white")
                                : "bg-white border border-gray-200 text-gray-400 hover:border-gray-400")}>
                            {st === "PRESENTE" ? "P" : st === "AUSENTE" ? "A" : "E"}
                          </button>
                        ))}
                      </div>
                    </div>
                  ))}
                </div>
              )}

              <button onClick={save} disabled={saving || students.length === 0}
                className="btn-primary w-full mt-4 flex items-center justify-center gap-2 disabled:opacity-40">
                {saving ? <Loader2 className="w-4 h-4 animate-spin" /> : <CheckCircle className="w-4 h-4" />}
                {saving ? "Guardando..." : "Guardar asistencia (" + students.length + " estudiantes)"}
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default function FormadorAttendancePage() {
  return (
    <AppShell allowedRoles={["FORMADOR", "ADMIN"]}>
      <Suspense fallback={
        <div className="flex flex-col items-center justify-center py-20 gap-3">
          <Loader2 className="w-8 h-8 text-primary animate-spin" />
          <p className="text-text-muted text-sm">Cargando...</p>
        </div>
      }>
        <AttContent />
      </Suspense>
    </AppShell>
  );
}'
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\formador\attendance\page.tsx", $attContent, [System.Text.Encoding]::UTF8)
Write-Host "Asistencia corregida - carga todos los inscritos" -ForegroundColor Green

# ── 2. CALIFICACIONES: fix del null check + loading state ─────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\formador\grades" | Out-Null
$gradesContent = '"use client";
import { useEffect, useState, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { Loader2, CheckCircle, Star, Plus, Trash2, TrendingUp, AlertCircle } from "lucide-react";
import clsx from "clsx";

function GradesContent() {
  const params = useSearchParams();
  const courseId = params.get("courseId");
  const [course, setCourse] = useState<any>(null);
  const [students, setStudents] = useState<any[]>([]);
  const [selStudent, setSelStudent] = useState<any>(null);
  const [selSession, setSelSession] = useState<any>(null);
  const [grades, setGrades] = useState<any[]>([]);
  const [grading, setGrading] = useState({ score: "", feedback: "" });
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [msg, setMsg] = useState("");
  const [tab, setTab] = useState<"calificar" | "examen">("calificar");
  const [examTitle, setExamTitle] = useState("");
  const [examPass, setExamPass] = useState("60");
  const [qs, setQs] = useState([{ text: "", options: ["", "", "", ""], correct: 0, points: 25 }]);

  useEffect(() => {
    if (!courseId) { setLoading(false); return; }
    Promise.all([
      api.get("/courses/" + courseId),
      api.get("/users", { params: { role: "BENEFICIARIO", limit: 100, page: 1 } }),
    ]).then(([cRes, uRes]) => {
      setCourse(cRes.data);
      const allUsers = uRes.data.data || [];
      const enrolled = allUsers.filter((u: any) => {
        if (!u.enrollments || u.enrollments.length === 0) return false;
        return u.enrollments.some((e: any) => {
          const cid = e.courseId || e.course?.id;
          return cid === courseId;
        });
      });
      setStudents(enrolled);
    }).catch((err) => console.error(err))
    .finally(() => setLoading(false));
  }, [courseId]);

  const pickStudent = async (s: any) => {
    setSelStudent(s); setSelSession(null); setGrading({ score: "", feedback: "" }); setMsg("");
    try {
      const { data } = await api.get("/assignments/grades/" + courseId + "?userId=" + s.id);
      setGrades(data);
    } catch { setGrades([]); }
  };

  const pickSession = (s: any) => {
    setSelSession(s);
    const g = grades.find((gr: any) => gr.id === s.id);
    setGrading({ score: g?.score?.toString() || "", feedback: g?.feedback || "" });
  };

  const saveGrade = async () => {
    if (!selSession || !selStudent || !grading.score) return;
    setSaving(true);
    try {
      const { data: subs } = await api.get("/assignments/session/" + selSession.id);
      const mySub = subs.find((s: any) => s.userId === selStudent.id);
      if (mySub) {
        await api.put("/assignments/" + mySub.id + "/grade", { score: grading.score, feedback: grading.feedback });
      } else {
        const ev = await api.post("/evaluations", {
          courseId, sessionId: selSession.id,
          title: "Nota - " + selSession.title,
          questions: [], passingScore: 60, maxScore: 100
        });
        const fd = new FormData();
        fd.append("sessionId", selSession.id);
        fd.append("courseId", courseId!);
        fd.append("textContent", "Nota manual");
        fd.append("evaluationId", ev.data.id);
        const nr = await api.post("/assignments", fd);
        if (nr.data?.id) {
          await api.put("/assignments/" + nr.data.id + "/grade", { score: grading.score, feedback: grading.feedback });
        }
      }
      setMsg("Nota guardada: " + selStudent.firstName + " / " + selSession.title);
      const { data } = await api.get("/assignments/grades/" + courseId + "?userId=" + selStudent.id);
      setGrades(data);
    } catch (e: any) {
      setMsg("Error: " + (e?.response?.data?.error || "intenta de nuevo"));
    } finally { setSaving(false); }
  };

  const saveExam = async () => {
    if (!examTitle.trim() || !selSession) return;
    try {
      await api.post("/evaluations", {
        courseId, sessionId: selSession.id,
        title: examTitle, questions: qs,
        passingScore: parseInt(examPass), maxScore: 100
      });
      setMsg("Examen publicado para " + selSession.title);
      setExamTitle(""); setExamPass("60");
      setQs([{ text: "", options: ["", "", "", ""], correct: 0, points: 25 }]);
    } catch { setMsg("Error al crear examen"); }
  };

  const calcProm = () => {
    const g = grades.filter((gr: any) => gr.score !== null && gr.score !== undefined);
    if (!g.length) return null;
    return (g.reduce((s: number, gr: any) => s + gr.score, 0) / g.length).toFixed(1);
  };

  // LOADING STATE
  if (loading) return (
    <div className="flex flex-col items-center justify-center py-20 gap-3">
      <Loader2 className="w-8 h-8 text-primary animate-spin" />
      <p className="text-text-muted text-sm">Cargando curso y estudiantes...</p>
    </div>
  );

  // SIN courseId - mostrar aviso pero no error duro
  if (!courseId) return (
    <div className="card bg-yellow-50 border-yellow-200 text-yellow-700 p-5 flex items-start gap-3">
      <AlertCircle className="w-5 h-5 flex-shrink-0 mt-0.5" />
      <div>
        <p className="font-semibold text-sm">No se detecto el curso</p>
        <p className="text-xs mt-1">Usa el menu lateral para acceder a calificaciones. El enlace incluira el curso automaticamente cuando el formador tenga uno asignado.</p>
      </div>
    </div>
  );

  const promedio = calcProm();

  return (
    <div className="max-w-6xl mx-auto space-y-5">
      <div>
        <h1 className="font-display text-2xl font-bold text-text-primary">Calificaciones</h1>
        <p className="text-text-secondary mt-1">{course?.title || "Cargando..."} - {students.length} estudiantes</p>
      </div>

      {msg && (
        <div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-xl text-sm flex items-center gap-2">
          <CheckCircle className="w-4 h-4" />{msg}
          <button onClick={() => setMsg("")} className="ml-auto font-bold">x</button>
        </div>
      )}

      {students.length === 0 && !loading && (
        <div className="card bg-yellow-50 border-yellow-200 text-yellow-700 text-sm p-4 flex items-start gap-3">
          <AlertCircle className="w-4 h-4 flex-shrink-0 mt-0.5" />
          No se encontraron estudiantes inscritos. Verifica que el seed se ejecuto correctamente con docker-compose down -v y docker-compose up --build.
        </div>
      )}

      {/* TABS */}
      <div className="flex gap-2 border-b border-gray-200 pb-0">
        {(["calificar", "examen"] as const).map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={clsx("px-5 py-2.5 text-sm font-semibold border-b-2 transition-colors -mb-px",
              tab === t ? "border-primary text-primary" : "border-transparent text-text-muted hover:text-text-primary")}>
            {t === "calificar" ? "Calificar estudiantes" : "Crear examen online"}
          </button>
        ))}
      </div>

      {tab === "calificar" && (
        <div className="grid grid-cols-4 gap-4">
          {/* COL 1: Estudiantes */}
          <div className="col-span-1 bg-white rounded-2xl border border-gray-200 shadow-card overflow-hidden">
            <div className="px-3 py-3 bg-gray-50 border-b">
              <p className="text-xs font-bold text-text-muted uppercase tracking-wide">Estudiantes ({students.length})</p>
            </div>
            <div className="overflow-y-auto max-h-[520px] divide-y divide-gray-50">
              {students.length === 0 ? (
                <p className="text-text-muted text-xs text-center py-8 px-3">Sin estudiantes inscritos</p>
              ) : (
                students.map((s: any) => (
                  <button key={s.id} onClick={() => pickStudent(s)}
                    className={clsx("w-full text-left px-3 py-3 flex items-center gap-2 transition-colors",
                      selStudent?.id === s.id ? "bg-red-50 border-r-2 border-primary" : "hover:bg-gray-50")}>
                    <div className="w-7 h-7 bg-gradient-brand rounded-full flex items-center justify-center text-white text-xs font-bold flex-shrink-0">
                      {s.firstName[0]}
                    </div>
                    <div className="min-w-0 flex-1">
                      <p className={clsx("text-xs font-semibold truncate",
                        selStudent?.id === s.id ? "text-primary" : "text-text-primary")}>
                        {s.firstName} {s.lastName}
                      </p>
                      <p className="text-xs text-text-muted truncate">{s.cedula}</p>
                    </div>
                  </button>
                ))
              )}
            </div>
          </div>

          {/* COL 2: Sesiones */}
          <div className="col-span-1 bg-white rounded-2xl border border-gray-200 shadow-card overflow-hidden">
            <div className="px-3 py-3 bg-gray-50 border-b">
              <p className="text-xs font-bold text-text-muted uppercase tracking-wide">
                {selStudent ? "Sesiones" : "Elige estudiante"}
              </p>
            </div>
            {!selStudent ? (
              <div className="flex flex-col items-center justify-center py-12 px-3">
                <Star className="w-8 h-8 text-gray-200 mb-2" />
                <p className="text-text-muted text-xs text-center">Selecciona un estudiante para ver sus sesiones</p>
              </div>
            ) : (
              <div className="overflow-y-auto max-h-[520px] divide-y divide-gray-50">
                {course?.sessions?.map((s: any) => {
                  const g = grades.find((gr: any) => gr.id === s.id);
                  const hasNote = g?.score !== null && g?.score !== undefined;
                  return (
                    <button key={s.id} onClick={() => pickSession(s)}
                      className={clsx("w-full text-left px-3 py-2.5 flex items-center gap-2 text-xs transition-colors",
                        selSession?.id === s.id
                          ? "bg-red-50 border-r-2 border-primary text-primary font-semibold"
                          : "hover:bg-gray-50 text-text-secondary")}>
                      <span className={clsx("w-6 h-6 rounded-full flex items-center justify-center font-bold flex-shrink-0",
                        selSession?.id === s.id ? "bg-primary text-white"
                        : hasNote ? "bg-green-100 text-green-700"
                        : "bg-gray-100 text-gray-500")}>
                        {hasNote ? <CheckCircle className="w-3 h-3" /> : s.order}
                      </span>
                      <span className="flex-1 truncate">{s.title}</span>
                      {hasNote && (
                        <span className={clsx("font-bold flex-shrink-0 text-xs",
                          g.score >= 60 ? "text-green-600" : "text-red-500")}>
                          {g.score}
                        </span>
                      )}
                    </button>
                  );
                })}
              </div>
            )}
          </div>

          {/* COL 3-4: Panel */}
          <div className="col-span-2 space-y-4">
            {!selStudent ? (
              <div className="bg-white rounded-2xl border border-gray-200 shadow-card text-center py-16">
                <Star className="w-12 h-12 text-gray-200 mx-auto mb-3" />
                <p className="text-text-muted">Selecciona un estudiante para calificar</p>
              </div>
            ) : !selSession ? (
              <div className="bg-white rounded-2xl border border-gray-200 shadow-card p-5 space-y-4">
                <div className="flex items-start gap-3">
                  <div className="w-11 h-11 bg-gradient-brand rounded-full flex items-center justify-center text-white font-bold flex-shrink-0">
                    {selStudent.firstName[0]}
                  </div>
                  <div className="flex-1">
                    <h3 className="font-bold text-text-primary">{selStudent.firstName} {selStudent.lastName}</h3>
                    <p className="text-text-muted text-xs">{selStudent.cedula}</p>
                  </div>
                  {promedio !== null && (
                    <div className={clsx("text-center px-4 py-2 rounded-xl flex-shrink-0",
                      parseFloat(promedio) >= 60 ? "bg-green-50" : "bg-red-50")}>
                      <p className={clsx("text-2xl font-bold",
                        parseFloat(promedio) >= 60 ? "text-green-600" : "text-red-500")}>{promedio}</p>
                      <p className="text-xs text-text-muted">Promedio</p>
                    </div>
                  )}
                </div>
                <p className="text-text-muted text-sm">Selecciona una sesion para ingresar o editar la nota.</p>
                {grades.length > 0 && (
                  <div>
                    <p className="text-xs font-bold text-text-muted uppercase mb-2">Sabana de notas</p>
                    <div className="space-y-1.5 max-h-64 overflow-y-auto pr-1">
                      {grades.map((g: any) => (
                        <div key={g.id} className="flex items-center gap-2 bg-gray-50 rounded-lg px-3 py-2">
                          <span className="text-xs text-text-muted w-16 truncate">{g.title}</span>
                          <div className="flex-1 bg-gray-200 rounded-full h-1.5">
                            {g.score !== null && g.score !== undefined && (
                              <div className="h-1.5 rounded-full transition-all"
                                style={{ width: Math.min(g.score, 100) + "%", background: g.score >= 60 ? "#16A34A" : "#C0392B" }} />
                            )}
                          </div>
                          {g.score !== null && g.score !== undefined
                            ? <span className={clsx("text-xs font-bold w-14 text-right flex-shrink-0",
                                g.score >= 60 ? "text-green-600" : "text-red-500")}>{g.score}/100</span>
                            : <span className="text-xs text-text-muted w-14 text-right flex-shrink-0">Sin nota</span>
                          }
                        </div>
                      ))}
                    </div>
                    {promedio !== null && (
                      <div className="mt-3 pt-3 border-t border-gray-100 flex items-center justify-between">
                        <span className="text-sm font-bold text-text-primary flex items-center gap-1.5">
                          <TrendingUp className="w-4 h-4 text-primary" /> Promedio final
                        </span>
                        <div className="text-right">
                          <span className={clsx("text-xl font-bold",
                            parseFloat(promedio) >= 60 ? "text-green-600" : "text-red-500")}>{promedio}/100</span>
                          <p className={clsx("text-xs font-semibold",
                            parseFloat(promedio) >= 60 ? "text-green-600" : "text-red-500")}>
                            {parseFloat(promedio) >= 60 ? "Aprobado" : "Reprobado"}
                          </p>
                        </div>
                      </div>
                    )}
                  </div>
                )}
              </div>
            ) : (
              <div className="bg-white rounded-2xl border border-gray-200 shadow-card p-5 space-y-4">
                <div className="flex items-center justify-between pb-3 border-b border-gray-100">
                  <div className="flex items-center gap-3">
                    <div className="w-9 h-9 bg-gradient-brand rounded-full flex items-center justify-center text-white text-sm font-bold flex-shrink-0">
                      {selStudent.firstName[0]}
                    </div>
                    <div>
                      <p className="font-bold text-text-primary text-sm">{selStudent.firstName} {selStudent.lastName}</p>
                      <p className="text-xs text-text-muted">{selSession.title}</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    {promedio !== null && (
                      <div className={clsx("text-center px-3 py-1.5 rounded-lg",
                        parseFloat(promedio) >= 60 ? "bg-green-50" : "bg-red-50")}>
                        <p className={clsx("text-base font-bold",
                          parseFloat(promedio) >= 60 ? "text-green-600" : "text-red-500")}>{promedio}</p>
                        <p className="text-xs text-text-muted">Prom.</p>
                      </div>
                    )}
                    <button onClick={() => setSelSession(null)}
                      className="text-xs border border-gray-200 rounded-lg px-3 py-2 text-text-muted hover:bg-gray-50">
                      Ver sabana
                    </button>
                  </div>
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs font-bold text-text-muted mb-1.5">Nota (0 a 100)</label>
                    <input type="number" min="0" max="100"
                      className="input text-2xl font-bold text-center" placeholder="0"
                      value={grading.score}
                      onChange={(e) => setGrading((p) => ({ ...p, score: e.target.value }))} />
                    {grading.score && (
                      <p className={clsx("text-xs mt-1 font-semibold text-center",
                        parseFloat(grading.score) >= 60 ? "text-green-600" : "text-red-500")}>
                        {parseFloat(grading.score) >= 60 ? "Aprobado" : "Reprobado"} (minimo 60)
                      </p>
                    )}
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-text-muted mb-1.5">Retroalimentacion</label>
                    <textarea className="input text-sm resize-none" rows={3}
                      placeholder="Comentario para el estudiante..."
                      value={grading.feedback}
                      onChange={(e) => setGrading((p) => ({ ...p, feedback: e.target.value }))} />
                  </div>
                </div>
                <button onClick={saveGrade} disabled={saving || !grading.score}
                  className="btn-primary w-full flex items-center justify-center gap-2 disabled:opacity-40">
                  {saving ? <Loader2 className="w-4 h-4 animate-spin" /> : <CheckCircle className="w-4 h-4" />}
                  {saving ? "Guardando..." : "Guardar nota"}
                </button>
              </div>
            )}
          </div>
        </div>
      )}

      {tab === "examen" && (
        <div className="max-w-3xl space-y-4">
          {!selSession && (
            <div className="bg-yellow-50 border border-yellow-200 text-yellow-700 text-sm p-3 rounded-xl">
              Ve a Calificar, selecciona un estudiante y una sesion para asociar el examen a esa sesion.
            </div>
          )}
          <div className="bg-white rounded-2xl border border-gray-200 shadow-card p-5 space-y-4">
            <h3 className="font-bold text-text-primary flex items-center gap-2">
              <Star className="w-4 h-4 text-primary" /> Crear examen online con resultado inmediato
            </h3>
            {selSession && (
              <div className="bg-blue-50 text-blue-700 text-xs px-3 py-2 rounded-lg">
                Sesion seleccionada: <strong>{selSession.title}</strong>
              </div>
            )}
            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-bold text-text-muted mb-1.5">Titulo del examen</label>
                <input className="input text-sm" placeholder="Ej: Evaluacion sesion 1"
                  value={examTitle} onChange={(e) => setExamTitle(e.target.value)} />
              </div>
              <div>
                <label className="block text-xs font-bold text-text-muted mb-1.5">Nota minima para aprobar</label>
                <input className="input text-sm" type="number" placeholder="60"
                  value={examPass} onChange={(e) => setExamPass(e.target.value)} />
              </div>
            </div>
            {qs.map((q, qi) => (
              <div key={qi} className="border border-gray-200 rounded-xl p-4 space-y-2">
                <div className="flex items-center gap-2">
                  <span className="bg-primary text-white text-xs w-7 h-7 rounded-full flex items-center justify-center font-bold flex-shrink-0">{qi + 1}</span>
                  <input className="input text-sm flex-1" placeholder={"Pregunta " + (qi + 1)} value={q.text}
                    onChange={(e) => { const n = [...qs]; n[qi] = { ...n[qi], text: e.target.value }; setQs(n); }} />
                  <input className="input text-sm w-16" type="number" placeholder="Pts" value={q.points}
                    onChange={(e) => { const n = [...qs]; n[qi] = { ...n[qi], points: parseInt(e.target.value) || 0 }; setQs(n); }} />
                  {qi > 0 && (
                    <button onClick={() => setQs((p) => p.filter((_, i) => i !== qi))} className="text-red-400 hover:text-red-600">
                      <Trash2 className="w-4 h-4" />
                    </button>
                  )}
                </div>
                {q.options.map((opt, oi) => (
                  <div key={oi} className={clsx("flex items-center gap-2 rounded-lg px-3 py-2",
                    q.correct === oi ? "bg-green-50 border border-green-200" : "bg-gray-50")}>
                    <input type="radio" name={"c" + qi} checked={q.correct === oi}
                      onChange={() => { const n = [...qs]; n[qi] = { ...n[qi], correct: oi }; setQs(n); }}
                      className="accent-primary flex-shrink-0" />
                    <input className="bg-transparent border-none outline-none text-sm flex-1"
                      placeholder={"Opcion " + (oi + 1) + (q.correct === oi ? " (correcta)" : "")} value={opt}
                      onChange={(e) => { const n = [...qs]; n[qi].options[oi] = e.target.value; setQs(n); }} />
                    {q.correct === oi && <span className="text-xs text-green-600 font-bold flex-shrink-0">Correcta</span>}
                  </div>
                ))}
              </div>
            ))}
            <div className="flex gap-3">
              <button onClick={() => setQs((p) => [...p, { text: "", options: ["", "", "", ""], correct: 0, points: Math.floor(100 / (p.length + 1)) }])}
                className="btn-outline flex items-center gap-2 text-sm">
                <Plus className="w-4 h-4" /> Agregar pregunta
              </button>
              <button onClick={saveExam} disabled={!examTitle.trim() || !selSession}
                className="btn-primary flex items-center gap-2 text-sm disabled:opacity-40">
                <CheckCircle className="w-4 h-4" /> Publicar examen
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default function FormadorGradesPage() {
  return (
    <AppShell allowedRoles={["FORMADOR", "ADMIN"]}>
      <Suspense fallback={
        <div className="flex flex-col items-center justify-center py-20 gap-3">
          <Loader2 className="w-8 h-8 text-primary animate-spin" />
          <p className="text-text-muted text-sm">Cargando calificaciones...</p>
        </div>
      }>
        <GradesContent />
      </Suspense>
    </AppShell>
  );
}'
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\formador\grades\page.tsx", $gradesContent, [System.Text.Encoding]::UTF8)
Write-Host "Calificaciones con fix de null OK" -ForegroundColor Green

# ── 3. BACKEND: userController - incluir course en enrollments
$userCtrl = 'const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcryptjs");
const prisma = new PrismaClient();

const listUsers = async (req, res) => {
  const { role, page = 1, limit = 20 } = req.query;
  const where = role ? { role } : {};
  const [users, total] = await Promise.all([
    prisma.user.findMany({
      where,
      skip: (page - 1) * Number(limit),
      take: Number(limit),
      select: {
        id: true, email: true, firstName: true, lastName: true,
        cedula: true, phone: true, role: true, gender: true,
        populationGroup: true, locality: true, isActive: true, createdAt: true,
        enrollments: {
          select: {
            courseId: true,
            status: true,
            course: { select: { id: true, title: true } }
          }
        },
      },
      orderBy: { firstName: "asc" },
    }),
    prisma.user.count({ where }),
  ]);
  return res.json({ data: users, total, page: Number(page), limit: Number(limit) });
};

const createUser = async (req, res) => {
  try {
    const { email, password, role, firstName, lastName, cedula, phone, gender, populationGroup, upz, locality } = req.body;
    const hash = await bcrypt.hash(password || "Temporal2024!", 12);
    const user = await prisma.user.create({
      data: { email: email.toLowerCase(), passwordHash: hash, role, firstName, lastName, cedula, phone, gender, populationGroup, upz, locality },
    });
    const { passwordHash, ...safe } = user;
    return res.status(201).json(safe);
  } catch (err) {
    if (err.code === "P2002") return res.status(409).json({ error: "Email o cedula ya registrado" });
    return res.status(500).json({ error: "Error al crear usuario" });
  }
};

const updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const data = { ...req.body };
    delete data.passwordHash;
    const user = await prisma.user.update({ where: { id }, data });
    const { passwordHash, ...safe } = user;
    return res.json(safe);
  } catch { return res.status(500).json({ error: "Error al actualizar usuario" }); }
};

const deactivateUser = async (req, res) => {
  const { id } = req.params;
  await prisma.user.update({ where: { id }, data: { isActive: false } });
  return res.json({ message: "Usuario desactivado" });
};

module.exports = { listUsers, createUser, updateUser, deactivateUser };
'
[System.IO.File]::WriteAllText("$PWD\backend\src\controllers\userController.js", $userCtrl, [System.Text.Encoding]::UTF8)
Write-Host "userController con course en enrollments OK" -ForegroundColor Green

# ── 4. ENCODING: fix en todos los archivos con em-dash ────────
Write-Host "Corrigiendo encoding en todos los archivos..." -ForegroundColor Cyan
$toFix = @(
  "frontend\src\app\(dashboard)\formador\courses\page.tsx",
  "frontend\src\app\(dashboard)\formador\page.tsx",
  "frontend\src\app\(student)\courses\[id]\page.tsx",
  "frontend\src\app\(student)\lobby\page.tsx",
  "frontend\src\app\(dashboard)\admin\page.tsx",
  "frontend\src\app\(dashboard)\admin\courses\page.tsx"
)
foreach ($fp in $toFix) {
  if (Test-Path "$PWD\$fp") {
    $bytes = [System.IO.File]::ReadAllBytes("$PWD\$fp")
    $text = [System.Text.Encoding]::UTF8.GetString($bytes)
    $fixed = $text.Replace([char]8212, "-").Replace([char]8211, "-")
    if ($fixed -ne $text) {
      [System.IO.File]::WriteAllText("$PWD\$fp", $fixed, [System.Text.Encoding]::UTF8)
      Write-Host "  Encoding corregido: $fp" -ForegroundColor Gray
    }
  }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "FIX V9 COMPLETO" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "IMPORTANTE: Los datos de estudiantes ya existen." -ForegroundColor Cyan
Write-Host "Solo reconstruye el frontend:" -ForegroundColor Cyan
Write-Host "  docker-compose down" -ForegroundColor White
Write-Host "  docker-compose up --build" -ForegroundColor White
