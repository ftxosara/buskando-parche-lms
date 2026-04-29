"use client";
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
    Promise.all([
      api.get("/courses/" + courseId),
      api.get("/courses/" + courseId + "/students"),
    ]).then(([cRes, sRes]) => {
      setCourse(cRes.data);
      setStudents(sRes.data || []);
    }).catch((err) => console.error("Error:", err))
    .finally(() => setLoading(false));
  }, [courseId]);

  const selectSession = async (s: any) => {
    setSelSession(s); setMsg("");
    try {
      const { data: attData } = await api.get("/attendance/session/" + s.id);
      const map: Record<string, string> = {};
      attData.forEach((a: any) => { map[a.userId] = a.status; });
      students.forEach((u: any) => { if (!map[u.id]) map[u.id] = "PRESENTE"; });
      setAtt(map);
    } catch {
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
        userId: u.id, status: att[u.id] || "PRESENTE", notes: ""
      }));
      await api.post("/attendance", { sessionId: selSession.id, attendances });
      setMsg("Asistencia guardada - " + selSession.title + " (" + students.length + " estudiantes)");
    } catch { setMsg("Error al guardar"); }
    finally { setSaving(false); }
  };

  const p = Object.values(att).filter((v) => v === "PRESENTE").length;
  const a = Object.values(att).filter((v) => v === "AUSENTE").length;
  const e = Object.values(att).filter((v) => v === "EXCUSA").length;

  if (loading) return (
    <div className="flex flex-col items-center justify-center py-20 gap-3">
      <Loader2 className="w-8 h-8 text-primary animate-spin" />
      <p className="text-text-muted text-sm">Cargando estudiantes del curso...</p>
    </div>
  );

  if (!courseId) return (
    <div className="card text-center py-12">
      <ClipboardList className="w-10 h-10 text-gray-300 mx-auto mb-3" />
      <p className="text-text-muted">Accede desde el menu lateral.</p>
    </div>
  );

  return (
    <div className="max-w-5xl mx-auto space-y-5">
      <div>
        <h1 className="font-display text-2xl font-bold text-text-primary">Registro de Asistencia</h1>
        <p className="text-text-secondary mt-1">{course?.title} - {students.length} estudiantes inscritos</p>
      </div>

      {msg && (
        <div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-xl text-sm flex items-center gap-2">
          <CheckCircle className="w-4 h-4" />{msg}
          <button onClick={() => setMsg("")} className="ml-auto font-bold">x</button>
        </div>
      )}

      <div className="grid md:grid-cols-3 gap-5">
        <div className="bg-white rounded-2xl border border-gray-200 shadow-card overflow-hidden">
          <div className="p-4 bg-gray-50 border-b">
            <p className="font-semibold text-text-primary text-sm">Sesiones ({course?.sessions?.length || 0})</p>
          </div>
          <div className="divide-y divide-gray-50 max-h-[500px] overflow-y-auto">
            {course?.sessions?.map((s: any) => (
              <button key={s.id} onClick={() => selectSession(s)}
                className={clsx("w-full text-left px-4 py-3 text-sm transition-colors flex items-center gap-3",
                  selSession?.id === s.id ? "bg-red-50 border-r-2 border-primary text-primary font-semibold" : "hover:bg-gray-50 text-text-secondary")}>
                <span className={clsx("w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0",
                  selSession?.id === s.id ? "bg-primary text-white" : "bg-gray-100 text-gray-600")}>
                  {s.order}
                </span>
                {s.title}
              </button>
            ))}
          </div>
        </div>

        <div className="md:col-span-2">
          {!selSession ? (
            <div className="bg-white rounded-2xl border border-gray-200 shadow-card text-center py-12">
              <ClipboardList className="w-10 h-10 text-gray-300 mx-auto mb-3" />
              <p className="text-text-muted text-sm">Selecciona una sesion para registrar asistencia</p>
              <p className="text-text-muted text-xs mt-1">{students.length} estudiantes listos</p>
            </div>
          ) : (
            <div className="bg-white rounded-2xl border border-gray-200 shadow-card p-5">
              <div className="flex items-center justify-between mb-4">
                <h3 className="font-bold text-text-primary">{selSession.title}</h3>
                <div className="flex gap-2">
                  <span className="badge-success text-xs">P: {p}</span>
                  <span className="badge-primary text-xs">A: {a}</span>
                  <span className="badge-warning text-xs">E: {e}</span>
                </div>
              </div>
              <div className="space-y-2 max-h-80 overflow-y-auto pr-1">
                {students.map((u: any) => (
                  <div key={u.id} className={clsx("flex items-center gap-3 px-3 py-2.5 rounded-xl transition-colors",
                    att[u.id] === "PRESENTE" ? "bg-green-50" : att[u.id] === "AUSENTE" ? "bg-red-50" : att[u.id] === "EXCUSA" ? "bg-yellow-50" : "bg-gray-50")}>
                    <div className="w-8 h-8 bg-gradient-brand rounded-full flex items-center justify-center text-white text-xs font-bold flex-shrink-0">
                      {u.firstName[0]}
                    </div>
                    <div className="flex-1">
                      <p className="text-sm font-medium text-text-primary">{u.firstName} {u.lastName}</p>
                      <p className="text-xs text-text-muted">{u.cedula}</p>
                    </div>
                    <div className="flex gap-1.5">
                      {(["PRESENTE","AUSENTE","EXCUSA"] as const).map((st) => (
                        <button key={st} onClick={() => setAtt((prev) => ({ ...prev, [u.id]: st }))}
                          className={clsx("w-9 h-8 rounded-lg text-xs font-bold transition-colors",
                            att[u.id] === st
                              ? (st === "PRESENTE" ? "bg-green-500 text-white" : st === "AUSENTE" ? "bg-red-500 text-white" : "bg-yellow-500 text-white")
                              : "bg-white border border-gray-200 text-gray-400 hover:border-gray-400")}>
                          {st === "PRESENTE" ? "P" : st === "AUSENTE" ? "A" : "E"}
                        </button>
                      ))}
                    </div>
                  </div>
                ))}
              </div>
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
    <AppShell allowedRoles={["FORMADOR","ADMIN"]}>
      <Suspense fallback={<div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div>}>
        <AttContent />
      </Suspense>
    </AppShell>
  );
}