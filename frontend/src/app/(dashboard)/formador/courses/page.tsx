"use client";
import { useEffect, useState, Suspense } from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { useSearchParams } from "next/navigation";
import { Upload, Plus, FileText, Video, Link as LinkIcon, ChevronDown, ChevronRight, Loader2, CheckCircle, BookOpen, Star, ClipboardList, Trash2 } from "lucide-react";
import clsx from "clsx";

function FormadorCoursesPageInner() {
  const params = useSearchParams();
  const courseId = params.get("id");
  const [course, setCourse] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [resourceForm, setResourceForm] = useState<Record<string, { title: string; type: string; url: string }>>({});
  const [activityForm, setActivityForm] = useState<Record<string, { title: string; description: string }>>({});
  const [examForms, setExamForms] = useState<Record<string, any>>({});
  const [activeTab, setActiveTab] = useState<Record<string, string>>({});
  const [uploading, setUploading] = useState<string | null>(null);
  const [preview, setPreview] = useState<any>(null);

  const setActiveTab2 = (sessionId: string, tab: string) => {
    setActiveTab(p => ({ ...p, [sessionId]: tab }));
  };

  useEffect(() => {
    if (!courseId) return;
    api.get("/courses/" + courseId).then(({ data }) => { setCourse(data); setLoading(false); })
      .catch(() => setLoading(false));
  }, [courseId]);

  const addResource = async (sessionId: string) => {
    const f = resourceForm[sessionId];
    if (!f?.title) return;
    setUploading(sessionId);
    try {
      await api.post("/sessions/" + sessionId + "/resources", { title: f.title, type: f.type || "link", url: f.url || "#" });
      const res = await api.get("/courses/" + courseId);
      setCourse(res.data);
      setResourceForm((p) => ({ ...p, [sessionId]: { title: "", type: "link", url: "" } }));
    } catch { alert("Error al agregar recurso"); }
    finally { setUploading(null); }
  };

  const addActivity = async (sessionId: string) => {
    const f = activityForm[sessionId];
    if (!f?.title) return;
    setUploading(sessionId + "_act");
    try {
      await api.post("/sessions/" + sessionId + "/resources", {
        courseId, sessionId,
        title: f.title, description: f.description || "",
        type: "actividad", url: "#"
      });
      const res = await api.get("/courses/" + courseId);
      setCourse(res.data);
      setActivityForm((p) => ({ ...p, [sessionId]: { title: "", description: "" } }));
    } catch { alert("Error al agregar actividad"); }
    finally { setUploading(null); }
  };

  const publishExam = async (sessionId: string) => {
    const f = examForms[sessionId];
    if (!f?.title || !f?.qs?.length) return;
    setUploading(sessionId + "_exam");
    try {
      await api.post("/sessions/" + sessionId + "/resources", {
        courseId, sessionId,
        title: f.title, type: "examen",
        url: JSON.stringify({ pass: f.pass, questions: f.qs })
      });
      const res = await api.get("/courses/" + courseId);
      setCourse(res.data);
      setExamForms((p) => ({ ...p, [sessionId]: { title: "", pass: "60", qs: [{ text: "", options: ["", "", "", ""], correct: 0, points: 25 }] } }));
    } catch { alert("Error al publicar examen"); }
    finally { setUploading(null); }
  };

  const deleteResource = async (resourceId: string) => {
    if (!confirm("Eliminar este recurso?")) return;
    try {
      await api.delete("/sessions/resource/" + resourceId);
      const res = await api.get("/courses/" + courseId);
      setCourse(res.data);
    } catch { alert("Error al eliminar"); }
  };

  const uploadFile = (sessionId: string) => {
    const input = document.createElement("input");
    input.type = "file";
    input.accept = ".pdf,.doc,.docx,.ppt,.pptx,.xls,.xlsx,.mp4,.jpg,.png,.zip";
    input.onchange = async (e: any) => {
      const file = e.target.files[0];
      if (!file) return;
      const title = window.prompt("Nombre del material:", file.name) || file.name;
      const fd = new FormData();
      fd.append("file", file);
      fd.append("title", title);
      setUploading(sessionId + "_upload");
      try {
        await api.post("/sessions/" + sessionId + "/resources/file", fd, { headers: { "Content-Type": "multipart/form-data" } });
        const res = await api.get("/courses/" + courseId);
        setCourse(res.data);
        alert("Archivo subido correctamente");
      } catch { alert("Error al subir el archivo"); }
      finally { setUploading(null); }
    };
    input.click();
  };

  const getExamForm = (sessionId: string) => {
    if (!examForms[sessionId]) {
      const initial = { title: "", pass: "60", qs: [{ text: "", options: ["", "", "", ""], correct: 0, points: 25 }] };
      setExamForms(p => ({ ...p, [sessionId]: initial }));
      return initial;
    }
    return examForms[sessionId];
  };

  const updateQuestion = (sessionId: string, qi: number, field: string, value: any) => {
    setExamForms(p => {
      const form = p[sessionId] || { title: "", pass: "60", qs: [{ text: "", options: ["", "", "", ""], correct: 0, points: 25 }] };
      const qs = form.qs.map((q: any, i: number) => i === qi ? { ...q, [field]: value } : q);
      return { ...p, [sessionId]: { ...form, qs } };
    });
  };

  const updateOption = (sessionId: string, qi: number, oi: number, value: string) => {
    setExamForms(p => {
      const form = p[sessionId] || { title: "", pass: "60", qs: [{ text: "", options: ["", "", "", ""], correct: 0, points: 25 }] };
      const qs = form.qs.map((q: any, i: number) => {
        if (i !== qi) return q;
        const opts = [...q.options];
        opts[oi] = value;
        return { ...q, options: opts };
      });
      return { ...p, [sessionId]: { ...form, qs } };
    });
  };

  const addOption = (sessionId: string, qi: number) => {
    setExamForms(p => {
      const form = p[sessionId];
      if (!form) return p;
      const qs = form.qs.map((q: any, i: number) => {
        if (i !== qi) return q;
        return { ...q, options: [...q.options, ""] };
      });
      return { ...p, [sessionId]: { ...form, qs } };
    });
  };

  const removeOption = (sessionId: string, qi: number, oi: number) => {
    setExamForms(p => {
      const form = p[sessionId];
      if (!form) return p;
      const qs = form.qs.map((q: any, i: number) => {
        if (i !== qi) return q;
        if (q.options.length <= 2) return q;
        const opts = q.options.filter((_: any, idx: number) => idx !== oi);
        const correct = q.correct >= opts.length ? 0 : q.correct;
        return { ...q, options: opts, correct };
      });
      return { ...p, [sessionId]: { ...form, qs } };
    });
  };

  const addQuestion = (sessionId: string) => {
    setExamForms(p => {
      const form = p[sessionId] || { title: "", pass: "60", qs: [] };
      const qs = [...form.qs, { text: "", options: ["", "", "", ""], correct: 0, points: 25 }];
      return { ...p, [sessionId]: { ...form, qs } };
    });
  };

  const removeQuestion = (sessionId: string, qi: number) => {
    setExamForms(p => {
      const form = p[sessionId];
      if (!form || form.qs.length <= 1) return p;
      const qs = form.qs.filter((_: any, i: number) => i !== qi);
      return { ...p, [sessionId]: { ...form, qs } };
    });
  };
  if (loading) return (
    <AppShell allowedRoles={["FORMADOR"]}>
      <div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div>
    </AppShell>
  );

  if (!course) return (
    <AppShell allowedRoles={["FORMADOR"]}>
      <div className="max-w-4xl mx-auto text-center py-20">
        <BookOpen className="w-12 h-12 text-gray-300 mx-auto mb-3" />
        <p className="text-text-muted">No se encontro el curso. Selecciona un curso desde el Panel.</p>
      </div>
    </AppShell>
  );

  const modalidad = course.modality === "VIRTUAL" ? "Virtual" : "Presencial";

  return (
    <AppShell allowedRoles={["FORMADOR"]}>
      <div className="max-w-4xl mx-auto space-y-5">
        <div>
          <h1 className="font-display text-2xl font-bold text-text-primary">{course.title}</h1>
          <p className="text-text-secondary mt-1">{course.sessions?.length} sesiones - {modalidad}</p>
        </div>

        {course.sessions?.map((s: any) => (
          <div key={s.id} className="card overflow-hidden">
            {/* Header sesion */}
            <div className="flex items-center gap-3 cursor-pointer p-4 hover:bg-gray-50 transition-colors"
              onClick={() => setActiveTab2(s.id, activeTab[s.id] === "open" ? "" : "open")}>
              <div className="w-8 h-8 rounded-full bg-primary text-white flex items-center justify-center text-sm font-bold flex-shrink-0">{s.order}</div>
              <div className="flex-1 min-w-0">
                <p className="font-semibold text-text-primary">{s.title}</p>
                <p className="text-xs text-text-muted mt-0.5">{s.resources?.length || 0} recursos</p>
              </div>
              <ChevronRight className={clsx("w-4 h-4 text-text-muted transition-transform", activeTab[s.id] === "open" && "rotate-90")} />
            </div>

            {activeTab[s.id] === "open" && (
              <div className="border-t border-gray-100 p-4 space-y-4">

                {/* Materiales existentes */}
                {s.resources?.length > 0 && (
                  <div>
                    <p className="text-xs font-bold text-text-muted uppercase mb-2">Materiales actuales</p>
                    <div className="space-y-1.5">
                      {s.resources.map((r: any) => (
                        <div key={r.id} className="flex items-center gap-3 bg-white rounded-xl px-3 py-2.5 border border-gray-100">
                          {r.type === "video" ? <Video className="w-4 h-4 text-red-500 flex-shrink-0" />
                            : r.type === "pdf" || r.type === "doc" || r.type === "ppt" || r.type === "excel" ? <FileText className="w-4 h-4 text-blue-500 flex-shrink-0" />
                            : r.type === "examen" ? <Star className="w-4 h-4 text-yellow-500 flex-shrink-0" />
                            : r.type === "actividad" ? <ClipboardList className="w-4 h-4 text-purple-500 flex-shrink-0" />
                            : <LinkIcon className="w-4 h-4 text-green-500 flex-shrink-0" />}
                          <span className="text-sm text-text-primary flex-1">{r.title}</span>
                          {r.type === "examen" || r.type === "actividad" ? (
                            <button onClick={() => setPreview(r)} className="text-primary text-xs hover:underline font-medium">Ver</button>
                          ) : r.url && r.url !== "#" ? (
                            <a href={r.url.startsWith("/uploads") ? (process.env.NEXT_PUBLIC_API_URL || "") + r.url : r.url}
                              target="_blank" rel="noopener noreferrer"
                              className="text-primary text-xs hover:underline font-medium">
                              {r.url.startsWith("/uploads") ? "Descargar" : "Ver"}
                            </a>
                          ) : (
                            <span className="text-gray-300 text-xs">Sin URL</span>
                          )}
                          <button onClick={() => {
                            const newUrl = window.prompt("Nueva URL para: " + r.title, r.url === "#" ? "" : r.url);
                            if (newUrl !== null) {
                              api.put("/sessions/resource/" + r.id, { title: r.title, url: newUrl, type: r.type })
                                .then(() => api.get("/courses/" + courseId).then(({data}) => setCourse(data)))
                                .catch(() => alert("Error al actualizar"));
                            }
                          }} className="ml-1 text-blue-400 hover:text-blue-600" title="Editar URL">
                            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                          </button>
                          <button onClick={() => deleteResource(r.id)} className="ml-1 text-red-400 hover:text-red-600" title="Eliminar">
                            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg>
                          </button>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                {/* Tabs agregar */}
                <div>
                  <p className="text-xs font-bold text-text-muted uppercase mb-2">AGREGAR A ESTA SESION</p>
                  <div className="flex gap-2 flex-wrap mb-3">
                    <button
                      onClick={() => setActiveTab2(s.id + "_tab", "recurso")}
                      className={clsx("flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium transition-all border",
                        (activeTab[s.id + "_tab"] || "recurso") === "recurso" ? "bg-primary text-white border-primary shadow-sm" : "border-gray-200 text-text-secondary hover:border-primary hover:text-primary")}>
                      <Upload className="w-4 h-4" /> Material / Enlace
                    </button>
                    <button
                      onClick={() => setActiveTab2(s.id + "_tab", "actividad")}
                      className={clsx("flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium transition-all border",
                        activeTab[s.id + "_tab"] === "actividad" ? "bg-primary text-white border-primary shadow-sm" : "border-gray-200 text-text-secondary hover:border-primary hover:text-primary")}>
                      <ClipboardList className="w-4 h-4" /> Actividad
                    </button>
                    <button
                      onClick={() => setActiveTab2(s.id + "_tab", "examen")}
                      className={clsx("flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium transition-all border",
                        activeTab[s.id + "_tab"] === "examen" ? "bg-primary text-white border-primary shadow-sm" : "border-gray-200 text-text-secondary hover:border-primary hover:text-primary")}>
                      <Star className="w-4 h-4" /> Examen online
                    </button>
                    <button
                      onClick={() => uploadFile(s.id)}
                      className="flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium bg-blue-100 text-blue-700 border border-blue-200 hover:bg-blue-200 transition-all">
                      <Upload className="w-4 h-4" />
                      {uploading === s.id + "_upload" ? "Subiendo..." : "Subir archivo"}
                    </button>
                  </div>

                  {/* TAB: RECURSO */}
                  {(activeTab[s.id + "_tab"] || "recurso") === "recurso" && (
                    <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-3">
                      <p className="text-xs text-text-muted">Sube un enlace a video, PDF o cualquier recurso externo para esta sesion.</p>
                      <input className="input text-sm" placeholder="Titulo del recurso *"
                        value={resourceForm[s.id]?.title || ""}
                        onChange={e => setResourceForm(p => ({ ...p, [s.id]: { ...p[s.id], title: e.target.value } }))} />
                      <select className="input text-sm"
                        value={resourceForm[s.id]?.type || "link"}
                        onChange={e => setResourceForm(p => ({ ...p, [s.id]: { ...p[s.id], type: e.target.value } }))}>
                        <option value="link">Enlace</option>
                        <option value="video">Video</option>
                        <option value="pdf">PDF (enlace)</option>
                      </select>
                      <input className="input text-sm" placeholder="URL del recurso"
                        value={resourceForm[s.id]?.url || ""}
                        onChange={e => setResourceForm(p => ({ ...p, [s.id]: { ...p[s.id], url: e.target.value } }))} />
                      <button onClick={() => addResource(s.id)} disabled={uploading === s.id || !resourceForm[s.id]?.title}
                        className="btn-primary w-full flex items-center justify-center gap-2 disabled:opacity-50">
                        {uploading === s.id ? <Loader2 className="w-4 h-4 animate-spin" /> : <Plus className="w-4 h-4" />}
                        Agregar recurso
                      </button>
                    </div>
                  )}

                  {/* TAB: ACTIVIDAD */}
                  {activeTab[s.id + "_tab"] === "actividad" && (
                    <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-3">
                      <p className="text-xs text-text-muted">Crea una actividad que los estudiantes deberan entregar.</p>
                      <input className="input text-sm" placeholder="Titulo de la actividad *"
                        value={activityForm[s.id]?.title || ""}
                        onChange={e => setActivityForm(p => ({ ...p, [s.id]: { ...p[s.id], title: e.target.value } }))} />
                      <textarea className="input text-sm min-h-20 resize-none" placeholder="Descripcion o instrucciones..."
                        value={activityForm[s.id]?.description || ""}
                        onChange={e => setActivityForm(p => ({ ...p, [s.id]: { ...p[s.id], description: e.target.value } }))} />
                      <button onClick={() => addActivity(s.id)} disabled={uploading === s.id + "_act" || !activityForm[s.id]?.title}
                        className="btn-primary w-full flex items-center justify-center gap-2 disabled:opacity-50">
                        {uploading === s.id + "_act" ? <Loader2 className="w-4 h-4 animate-spin" /> : <ClipboardList className="w-4 h-4" />}
                        Crear actividad
                      </button>
                    </div>
                  )}

                  {/* TAB: EXAMEN */}
                  {activeTab[s.id + "_tab"] === "examen" && (
                    <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-4">
                      <p className="text-xs text-text-muted">Crea un examen de seleccion multiple. El estudiante lo responde en linea y recibe su nota automaticamente.</p>
                      <div className="grid grid-cols-2 gap-3">
                        <input className="input text-sm" placeholder="Titulo del examen *"
                          value={examForms[s.id]?.title || ""}
                          onChange={e => setExamForms(p => ({ ...p, [s.id]: { ...(p[s.id] || { title: "", pass: "60", qs: [{ text: "", options: ["","","",""], correct: 0, points: 25 }] }), title: e.target.value } }))} />
                        <div className="flex items-center gap-2">
                          <span className="text-xs text-text-muted whitespace-nowrap">Nota minima</span>
                          <input className="input text-sm w-20" type="number" min="0" max="100"
                            value={examForms[s.id]?.pass || "60"}
                            onChange={e => setExamForms(p => ({ ...p, [s.id]: { ...(p[s.id] || { title: "", pass: "60", qs: [{ text: "", options: ["","","",""], correct: 0, points: 25 }] }), pass: e.target.value } }))} />
                        </div>
                      </div>

                      {(examForms[s.id]?.qs || [{ text: "", options: ["", "", "", ""], correct: 0, points: 25 }]).map((q: any, qi: number) => (
                        <div key={qi} className="border border-gray-200 rounded-xl p-3 space-y-2">
                          <div className="flex items-center gap-2">
                            <span className="w-6 h-6 rounded-full bg-primary text-white text-xs flex items-center justify-center font-bold flex-shrink-0">{qi + 1}</span>
                            <input className="input text-sm flex-1" placeholder={`Pregunta ${qi + 1}`}
                              value={q.text}
                              onChange={e => updateQuestion(s.id, qi, "text", e.target.value)} />
                            <input className="input text-sm w-16" type="number" min="0" max="100" placeholder="pts"
                              value={q.points || 25}
                              onChange={e => updateQuestion(s.id, qi, "points", parseInt(e.target.value))} />
                            {(examForms[s.id]?.qs?.length || 1) > 1 && (
                              <button onClick={() => removeQuestion(s.id, qi)} className="text-red-400 hover:text-red-600 p-1" title="Eliminar pregunta">
                                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                              </button>
                            )}
                          </div>
                          <p className="text-xs text-text-muted">Marca el radio de la opcion correcta:</p>
                          {(q.options || ["", "", "", ""]).map((opt: string, oi: number) => (
                            <div key={oi} className={clsx("flex items-center gap-2 rounded-lg p-2 border transition-colors",
                              q.correct === oi ? "bg-green-50 border-green-300" : "border-gray-200")}>
                              <input type="radio" name={`q_${s.id}_${qi}`} checked={q.correct === oi}
                                onChange={() => updateQuestion(s.id, qi, "correct", oi)} />
                              <input className="flex-1 bg-transparent text-sm outline-none" placeholder={`Opcion ${oi + 1}`}
                                value={opt}
                                onChange={e => updateOption(s.id, qi, oi, e.target.value)} />
                              {q.correct === oi && <span className="text-green-600 text-xs font-semibold">Correcta</span>}
                              {(q.options?.length || 0) > 2 && (
                                <button onClick={() => removeOption(s.id, qi, oi)} className="text-red-300 hover:text-red-500" title="Quitar opcion">
                                  <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                                </button>
                              )}
                            </div>
                          ))}
                          <button onClick={() => addOption(s.id, qi)} className="text-xs text-primary hover:underline flex items-center gap-1 mt-1">
                            <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                            Agregar opcion
                          </button>
                        </div>
                      ))}

                      <div className="flex gap-2 flex-wrap">
                        <button onClick={() => addQuestion(s.id)} className="btn-outline flex items-center gap-1 text-sm">
                          <Plus className="w-4 h-4" /> Agregar pregunta
                        </button>
                        <button onClick={() => publishExam(s.id)} disabled={uploading === s.id + "_exam" || !examForms[s.id]?.title}
                          className="btn-primary flex items-center gap-2 text-sm disabled:opacity-50">
                          {uploading === s.id + "_exam" ? <Loader2 className="w-4 h-4 animate-spin" /> : <CheckCircle className="w-4 h-4" />}
                          Publicar examen
                        </button>
                      </div>
                    </div>
                  )}
                </div>
              </div>
            )}
          </div>
        ))}
      </div>
      {/* MODAL PREVIEW EXAMEN/ACTIVIDAD */}
      {preview && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4 overflow-y-auto"
          onClick={e => { if (e.target === e.currentTarget) setPreview(null); }}>
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl my-4">
            <div className="flex items-center justify-between p-5 border-b border-gray-100">
              <div>
                <h2 className="font-bold text-text-primary text-lg">{preview.title}</h2>
                <span className={clsx("text-xs font-semibold px-2 py-0.5 rounded-full mt-1 inline-block",
                  preview.type === "examen" ? "bg-yellow-100 text-yellow-700" : "bg-purple-100 text-purple-700")}>
                  {preview.type === "examen" ? "Examen online" : "Actividad"}
                </span>
              </div>
              <button onClick={() => setPreview(null)} className="p-2 hover:bg-gray-100 rounded-xl">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
              </button>
            </div>
            <div className="p-5">
              {preview.type === "actividad" && (
                <div className="bg-purple-50 rounded-xl p-4">
                  <p className="text-sm font-semibold text-purple-800 mb-2">Instrucciones para el estudiante:</p>
                  <p className="text-sm text-purple-700 whitespace-pre-wrap">{preview.url === "#" ? "Sin descripcion" : preview.url}</p>
                </div>
              )}
              {preview.type === "examen" && (() => {
                let examData: any = null;
                try { examData = JSON.parse(preview.url); } catch { return <p className="text-gray-500 text-sm">No se pudo cargar el examen</p>; }
                return (
                  <div className="space-y-4">
                    <div className="bg-yellow-50 rounded-xl p-3 flex items-center gap-3">
                      <Star className="w-5 h-5 text-yellow-600" />
                      <div>
                        <p className="text-sm font-semibold text-yellow-800">Nota minima para aprobar: {examData.pass || 60}/100</p>
                        <p className="text-xs text-yellow-600">{examData.questions?.length || 0} preguntas</p>
                      </div>
                    </div>
                    {examData.questions?.map((q: any, qi: number) => (
                      <div key={qi} className="border border-gray-200 rounded-xl p-4 space-y-2">
                        <div className="flex items-start gap-2">
                          <span className="w-6 h-6 rounded-full bg-primary text-white text-xs flex items-center justify-center font-bold flex-shrink-0 mt-0.5">{qi+1}</span>
                          <div className="flex-1">
                            <p className="text-sm font-semibold text-text-primary">{q.text || "Pregunta sin texto"}</p>
                            <p className="text-xs text-text-muted mt-0.5">{q.points || 0} puntos</p>
                          </div>
                        </div>
                        <div className="space-y-1 ml-8">
                          {(q.options || []).map((opt: string, oi: number) => (
                            <div key={oi} className={clsx("flex items-center gap-2 rounded-lg px-3 py-2 text-sm",
                              q.correct === oi ? "bg-green-50 border border-green-300 text-green-800 font-medium" : "bg-gray-50 text-gray-600")}>
                              {q.correct === oi ? (
                                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                              ) : (
                                <div className="w-3.5 h-3.5 rounded-full border border-gray-400"/>
                              )}
                              {opt || "Opcion vacia"}
                              {q.correct === oi && <span className="ml-auto text-green-600 text-xs font-bold">CORRECTA</span>}
                            </div>
                          ))}
                        </div>
                      </div>
                    ))}
                  </div>
                );
              })()}
            </div>
          </div>
        </div>
      )}

    </AppShell>
  );
}

export default function FormadorCoursesPage() {
  return (
    <Suspense fallback={<div className="flex justify-center py-20"><div className="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin"/></div>}>
      <FormadorCoursesPageInner />
    </Suspense>
  );
}