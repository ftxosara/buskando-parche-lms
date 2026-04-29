"use client";
import { useEffect, useState, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { Upload, Plus, FileText, Video, Link as LinkIcon, ChevronDown, ChevronRight, Loader2, CheckCircle, BookOpen, Star, ClipboardList, Trash2 } from "lucide-react";
import clsx from "clsx";

function CoursesContent() {
  const params = useSearchParams();
  const courseId = params.get("id");
  const [course, setCourse] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [expanded, setExpanded] = useState<string | null>(null);
  const [uploading, setUploading] = useState<string | null>(null);
  const [msg, setMsg] = useState("");
  const [activeTab, setActiveTab] = useState<Record<string, "recurso" | "actividad" | "examen">>({});
  const [resourceForm, setResourceForm] = useState<Record<string, { title: string; type: string; url: string }>>({});
  const [activityForm, setActivityForm] = useState<Record<string, { title: string; description: string }>>({});
  const [examForms, setExamForms] = useState<Record<string, { title: string; pass: string; qs: { text: string; options: string[]; correct: number; points: number }[] }>>({});

  const loadCourse = () => {
    if (!courseId) { setLoading(false); return; }
    api.get("/courses/" + courseId)
      .then(({ data }) => setCourse(data))
      .finally(() => setLoading(false));
  };
  useEffect(() => { loadCourse(); }, [courseId]);

  const initExamForm = (sid: string) => {
    if (!examForms[sid]) {
      setExamForms((p) => ({ ...p, [sid]: { title: "", pass: "60", qs: [{ text: "", options: ["", "", "", ""], correct: 0, points: 25 }] } }));
    }
  };

  const handleTab = (sid: string, tab: "recurso" | "actividad" | "examen") => {
    setActiveTab((p) => ({ ...p, [sid]: tab }));
    if (tab === "examen") initExamForm(sid);
  };

  const addResource = async (sessionId: string) => {
    const f = resourceForm[sessionId];
    if (!f?.title) return;
    setUploading(sessionId);
    try {
      await api.post("/sessions/" + sessionId + "/resources", { title: f.title, type: f.type || "link", url: f.url || "#" });
      setMsg("Recurso agregado correctamente");
      setResourceForm((p) => ({ ...p, [sessionId]: { title: "", type: "link", url: "" } }));
      loadCourse();
    } catch { setMsg("Error al agregar recurso"); }
    finally { setUploading(null); }
  };

  const addActivity = async (sessionId: string) => {
    const f = activityForm[sessionId];
    if (!f?.title) return;
    setUploading(sessionId + "_act");
    try {
      await api.post("/evaluations", {
        courseId, sessionId,
        title: f.title,
        description: f.description || "",
        questions: [],
        passingScore: 60,
        maxScore: 100,
      });
      setMsg("Actividad creada. Los estudiantes podran subir archivos y texto.");
      setActivityForm((p) => ({ ...p, [sessionId]: { title: "", description: "" } }));
    } catch { setMsg("Error al crear actividad"); }
    finally { setUploading(null); }
  };

  const publishExam = async (sessionId: string) => {
    const f = examForms[sessionId];
    if (!f?.title) return;
    setUploading(sessionId + "_exam");
    try {
      await api.post("/evaluations", {
        courseId, sessionId,
        title: f.title,
        questions: f.qs,
        passingScore: parseInt(f.pass) || 60,
        maxScore: 100,
      });
      setMsg("Examen publicado. Los estudiantes lo veran en su visor del curso.");
      setExamForms((p) => ({ ...p, [sessionId]: { title: "", pass: "60", qs: [{ text: "", options: ["", "", "", ""], correct: 0, points: 25 }] } }));
    } catch { setMsg("Error al publicar examen"); }
    finally { setUploading(null); }
  };

  if (loading) return <div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div>;
  if (!courseId || !course) return (
    <div className="card text-center py-12">
      <BookOpen className="w-12 h-12 text-gray-300 mx-auto mb-3" />
      <p className="text-text-muted">Accede desde el menu lateral o el panel del formador.</p>
    </div>
  );

  const modalidad = course.modality === "VIRTUAL" ? "Virtual" : "Presencial";

  return (
    <div className="max-w-4xl mx-auto space-y-5">
      <div>
        <h1 className="font-display text-2xl font-bold text-text-primary">{course.title}</h1>
        <p className="text-text-secondary mt-1">{course.sessions?.length} sesiones - {modalidad}</p>
      </div>

      {msg && (
        <div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-xl text-sm flex items-center gap-2">
          <CheckCircle className="w-4 h-4" />{msg}
          <button onClick={() => setMsg("")} className="ml-auto font-bold">x</button>
        </div>
      )}

      <div className="space-y-3">
        {course.sessions?.map((s: any) => (
          <div key={s.id} className="bg-white rounded-2xl border border-gray-200 shadow-card overflow-hidden">
            <button
              onClick={() => setExpanded((p) => p === s.id ? null : s.id)}
              className="w-full flex items-center gap-4 p-4 text-left hover:bg-gray-50 transition-colors">
              <span className={clsx("w-9 h-9 rounded-full flex items-center justify-center font-bold text-sm flex-shrink-0",
                expanded === s.id ? "bg-primary text-white" : "bg-red-50 text-primary")}>
                {s.order}
              </span>
              <div className="flex-1">
                <p className="font-semibold text-text-primary">{s.title}</p>
                <p className="text-xs text-text-muted mt-0.5">{s.resources?.length || 0} recursos</p>
              </div>
              {expanded === s.id
                ? <ChevronDown className="w-5 h-5 text-text-muted" />
                : <ChevronRight className="w-5 h-5 text-text-muted" />}
            </button>

            {expanded === s.id && (
              <div className="border-t border-gray-100 p-5 space-y-5 bg-gray-50">

                {/* Recursos existentes */}
                {s.resources?.length > 0 && (
                  <div>
                    <p className="text-xs font-bold text-text-muted uppercase mb-2">Materiales actuales</p>
                    <div className="space-y-1.5">
                      {s.resources.map((r: any) => (
                        <div key={r.id} className="flex items-center gap-3 bg-white rounded-xl px-3 py-2.5 border border-gray-100">
                          {r.type === "video" ? <Video className="w-4 h-4 text-red-500 flex-shrink-0" />
                            : r.type === "pdf" ? <FileText className="w-4 h-4 text-blue-500 flex-shrink-0" />
                            : <LinkIcon className="w-4 h-4 text-green-500 flex-shrink-0" />}
                          <span className="text-sm text-text-primary flex-1">{r.title}</span>
                          <a href={r.url} target="_blank" rel="noopener noreferrer"
                            className="text-primary text-xs hover:underline">Ver</a>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                {/* Tabs de accion */}
                <div>
                  <p className="text-xs font-bold text-text-muted uppercase mb-3">Agregar a esta sesion</p>
                  <div className="flex gap-2 mb-4">
                    {(["recurso", "actividad", "examen"] as const).map((t) => (
                      <button key={t} onClick={() => handleTab(s.id, t)}
                        className={clsx("px-4 py-2 rounded-lg text-sm font-semibold transition-colors flex items-center gap-2",
                          (activeTab[s.id] || "recurso") === t
                            ? "bg-primary text-white"
                            : "bg-white border border-gray-200 text-text-secondary hover:border-primary hover:text-primary")}>
                        {t === "recurso" ? <><Upload className="w-4 h-4" /> Material / Enlace</>
                          : t === "actividad" ? <><ClipboardList className="w-4 h-4" /> Actividad</>
                          : <><Star className="w-4 h-4" /> Examen online</>}
                      </button>
                    ))}
                  </div>

                  {/* TAB: RECURSO */}
                  {(activeTab[s.id] || "recurso") === "recurso" && (
                    <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-3">
                      <p className="text-xs text-text-muted">Sube un enlace a video, PDF o cualquier recurso externo para esta sesion.</p>
                      <div className="grid grid-cols-2 gap-2">
                        <input className="input text-sm" placeholder="Titulo del recurso"
                          value={resourceForm[s.id]?.title || ""}
                          onChange={(e) => setResourceForm((p) => ({ ...p, [s.id]: { ...p[s.id], title: e.target.value } }))} />
                        <select className="input text-sm"
                          value={resourceForm[s.id]?.type || "link"}
                          onChange={(e) => setResourceForm((p) => ({ ...p, [s.id]: { ...p[s.id], type: e.target.value } }))}>
                          <option value="link">Enlace web</option>
                          <option value="video">Video (YouTube, Drive...)</option>
                          <option value="pdf">PDF (Drive, Dropbox...)</option>
                        </select>
                      </div>
                      <input className="input text-sm" placeholder="URL del recurso (https://...)"
                        value={resourceForm[s.id]?.url || ""}
                        onChange={(e) => setResourceForm((p) => ({ ...p, [s.id]: { ...p[s.id], url: e.target.value } }))} />
                      <button onClick={() => addResource(s.id)}
                        disabled={uploading === s.id || !resourceForm[s.id]?.title}
                        className="btn-primary w-full flex items-center justify-center gap-2 text-sm disabled:opacity-40">
                        {uploading === s.id ? <Loader2 className="w-4 h-4 animate-spin" /> : <Plus className="w-4 h-4" />}
                        Agregar recurso
                      </button>
                    </div>
                  )}

                  {/* TAB: ACTIVIDAD */}
                  {activeTab[s.id] === "actividad" && (
                    <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-3">
                      <p className="text-xs text-text-muted">Crea una actividad para que los estudiantes suban archivos o escriban su respuesta. El formador la califica manualmente despues.</p>
                      <input className="input text-sm" placeholder="Titulo de la actividad (Ej: Tarea sesion 1)"
                        value={activityForm[s.id]?.title || ""}
                        onChange={(e) => setActivityForm((p) => ({ ...p, [s.id]: { ...p[s.id], title: e.target.value } }))} />
                      <textarea className="input text-sm resize-none" rows={3}
                        placeholder="Descripcion o instrucciones para el estudiante..."
                        value={activityForm[s.id]?.description || ""}
                        onChange={(e) => setActivityForm((p) => ({ ...p, [s.id]: { ...p[s.id], description: e.target.value } }))} />
                      <button onClick={() => addActivity(s.id)}
                        disabled={uploading === s.id + "_act" || !activityForm[s.id]?.title}
                        className="btn-primary w-full flex items-center justify-center gap-2 text-sm disabled:opacity-40">
                        {uploading === s.id + "_act" ? <Loader2 className="w-4 h-4 animate-spin" /> : <ClipboardList className="w-4 h-4" />}
                        Publicar actividad
                      </button>
                    </div>
                  )}

                  {/* TAB: EXAMEN */}
                  {activeTab[s.id] === "examen" && examForms[s.id] && (
                    <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-4">
                      <p className="text-xs text-text-muted">Crea un examen de seleccion multiple. El estudiante lo responde en linea y recibe su nota automaticamente.</p>
                      <div className="grid grid-cols-2 gap-3">
                        <div>
                          <label className="block text-xs font-semibold text-text-muted mb-1">Titulo del examen</label>
                          <input className="input text-sm" placeholder="Ej: Evaluacion sesion 1"
                            value={examForms[s.id].title}
                            onChange={(e) => setExamForms((p) => ({ ...p, [s.id]: { ...p[s.id], title: e.target.value } }))} />
                        </div>
                        <div>
                          <label className="block text-xs font-semibold text-text-muted mb-1">Nota minima para aprobar</label>
                          <input className="input text-sm" type="number" placeholder="60"
                            value={examForms[s.id].pass}
                            onChange={(e) => setExamForms((p) => ({ ...p, [s.id]: { ...p[s.id], pass: e.target.value } }))} />
                        </div>
                      </div>

                      {examForms[s.id].qs.map((q, qi) => (
                        <div key={qi} className="border border-gray-100 rounded-xl p-3 space-y-2 bg-gray-50">
                          <div className="flex items-center gap-2">
                            <span className="bg-primary text-white text-xs w-6 h-6 rounded-full flex items-center justify-center font-bold flex-shrink-0">{qi + 1}</span>
                            <input className="input text-sm flex-1 bg-white" placeholder={"Pregunta " + (qi + 1)}
                              value={q.text}
                              onChange={(e) => {
                                const nq = [...examForms[s.id].qs];
                                nq[qi] = { ...nq[qi], text: e.target.value };
                                setExamForms((p) => ({ ...p, [s.id]: { ...p[s.id], qs: nq } }));
                              }} />
                            <input className="input text-sm w-16 bg-white text-center" type="number" placeholder="Pts"
                              value={q.points}
                              onChange={(e) => {
                                const nq = [...examForms[s.id].qs];
                                nq[qi] = { ...nq[qi], points: parseInt(e.target.value) || 0 };
                                setExamForms((p) => ({ ...p, [s.id]: { ...p[s.id], qs: nq } }));
                              }} />
                            {qi > 0 && (
                              <button onClick={() => setExamForms((p) => ({ ...p, [s.id]: { ...p[s.id], qs: p[s.id].qs.filter((_, i) => i !== qi) } }))}
                                className="text-red-400 hover:text-red-600 flex-shrink-0">
                                <Trash2 className="w-4 h-4" />
                              </button>
                            )}
                          </div>
                          <p className="text-xs text-text-muted pl-8">Marca el radio de la opcion correcta:</p>
                          {q.options.map((opt, oi) => (
                            <div key={oi} className={clsx("flex items-center gap-2 rounded-lg px-3 py-2 ml-8",
                              q.correct === oi ? "bg-green-50 border border-green-200" : "bg-white border border-gray-100")}>
                              <input type="radio" name={"q" + s.id + qi} checked={q.correct === oi}
                                onChange={() => {
                                  const nq = [...examForms[s.id].qs];
                                  nq[qi] = { ...nq[qi], correct: oi };
                                  setExamForms((p) => ({ ...p, [s.id]: { ...p[s.id], qs: nq } }));
                                }} className="accent-primary flex-shrink-0" />
                              <input className="bg-transparent border-none outline-none text-sm flex-1 text-text-primary"
                                placeholder={"Opcion " + (oi + 1) + (q.correct === oi ? " (respuesta correcta)" : "")}
                                value={opt}
                                onChange={(e) => {
                                  const nq = [...examForms[s.id].qs];
                                  nq[qi].options[oi] = e.target.value;
                                  setExamForms((p) => ({ ...p, [s.id]: { ...p[s.id], qs: nq } }));
                                }} />
                              {q.correct === oi && <span className="text-xs text-green-600 font-bold flex-shrink-0">Correcta</span>}
                            </div>
                          ))}
                        </div>
                      ))}

                      <div className="flex gap-3">
                        <button
                          onClick={() => setExamForms((p) => ({
                            ...p,
                            [s.id]: {
                              ...p[s.id],
                              qs: [...p[s.id].qs, { text: "", options: ["", "", "", ""], correct: 0, points: Math.floor(100 / (p[s.id].qs.length + 1)) }]
                            }
                          }))}
                          className="btn-outline flex items-center gap-2 text-sm">
                          <Plus className="w-4 h-4" /> Agregar pregunta
                        </button>
                        <button onClick={() => publishExam(s.id)}
                          disabled={uploading === s.id + "_exam" || !examForms[s.id].title}
                          className="btn-primary flex items-center gap-2 text-sm flex-1 justify-center disabled:opacity-40">
                          {uploading === s.id + "_exam" ? <Loader2 className="w-4 h-4 animate-spin" /> : <Star className="w-4 h-4" />}
                          Publicar examen
                        </button>
                      </div>
                      <div className="bg-blue-50 rounded-xl p-3 text-xs text-blue-700">
                        Una vez publicado, el examen aparece en el visor del curso. El estudiante responde y obtiene su calificacion inmediatamente.
                      </div>
                    </div>
                  )}
                </div>
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}

export default function FormadorCoursesPage() {
  return (
    <AppShell allowedRoles={["FORMADOR", "ADMIN"]}>
      <Suspense fallback={<div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div>}>
        <CoursesContent />
      </Suspense>
    </AppShell>
  );
}