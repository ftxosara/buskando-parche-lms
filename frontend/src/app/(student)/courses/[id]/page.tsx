"use client";
import {useEffect,useState} from "react";
import {useParams} from "next/navigation";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import {BookOpen,PlayCircle,FileText,Link as LinkIcon,CheckCircle,Upload,Send,Star,ChevronRight,Loader2,Video,Lock,Award} from "lucide-react";
import clsx from "clsx";
export default function CourseViewer() {
  const {id}=useParams();
  const [course,setCourse]=useState<any>(null); const [loading,setLoading]=useState(true);
  const [selSession,setSelSession]=useState<any>(null);
  const [submitText,setSubmitText]=useState(""); const [submitFile,setSubmitFile]=useState<File|null>(null);
  const [submitting,setSubmitting]=useState(false); const [submitMsg,setSubmitMsg]=useState("");
  const [grades,setGrades]=useState<any[]>([]);
  useEffect(()=>{
    api.get("/courses/"+id).then(({data})=>{setCourse(data);if(data.sessions?.length>0)setSelSession(data.sessions[0]);}).finally(()=>setLoading(false));
    api.get("/assignments/grades/"+id).then(({data})=>setGrades(data)).catch(()=>{});
  },[id]);
  const handleSubmit=async()=>{
    setSubmitting(true); setSubmitMsg("");
    try {
      const fd=new FormData();
      fd.append("sessionId",selSession.id); fd.append("courseId",String(id));
      fd.append("textContent",submitText);
      if(submitFile) fd.append("file",submitFile);
      await api.post("/assignments",fd,{headers:{"Content-Type":"multipart/form-data"}});
      setSubmitMsg("Actividad enviada correctamente"); setSubmitText(""); setSubmitFile(null);
      api.get("/assignments/grades/"+id).then(({data})=>setGrades(data)).catch(()=>{});
    } catch { setSubmitMsg("Error al enviar. Intenta de nuevo."); }
    finally { setSubmitting(false); }
  };
  const gradeMap=grades.reduce((m:any,g:any)=>({...m,[g.id]:g}),{});
  const totalScore=grades.filter(g=>g.score!=null).reduce((a,g)=>a+g.score,0);
  const graded=grades.filter(g=>g.score!=null).length;
  const promedio=graded>0?(totalScore/graded).toFixed(1):"N/A";
  if(loading) return <AppShell allowedRoles={["BENEFICIARIO","FORMADOR","ADMIN"]}><div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div></AppShell>;
  if(!course) return <AppShell allowedRoles={["BENEFICIARIO","FORMADOR","ADMIN"]}><div className="card text-center py-12"><p className="text-text-muted">Curso no encontrado o sin acceso.</p></div></AppShell>;
  return (
    <AppShell allowedRoles={["BENEFICIARIO","FORMADOR","ADMIN"]}>
      <div className="max-w-6xl mx-auto space-y-6">
        {/* Header */}
        <div className="bg-gradient-brand rounded-2xl p-6 text-white">
          <h1 className="font-display text-2xl font-bold">{course.title}</h1>
          <p className="text-white/80 mt-1 text-sm">{course.sessions?.length} sesiones â€” {course.modality}</p>
          <div className="flex items-center gap-4 mt-3 text-sm">
            <span className="flex items-center gap-1.5 bg-white/20 px-3 py-1 rounded-full">
              <BookOpen className="w-4 h-4"/> {course.sessions?.length} sesiones
            </span>
            <span className="flex items-center gap-1.5 bg-white/20 px-3 py-1 rounded-full">
              <Star className="w-4 h-4"/> Promedio: {promedio}
            </span>
          </div>
        </div>
        <div className="grid md:grid-cols-3 gap-6">
          {/* Lista de sesiones */}
          <div className="card p-0 overflow-hidden">
            <div className="p-4 bg-gray-50 border-b border-gray-100">
              <p className="font-bold text-text-primary">Contenido del curso</p>
              <p className="text-xs text-text-muted mt-0.5">{course.sessions?.length} sesiones</p>
            </div>
            <div className="divide-y divide-gray-50 max-h-[600px] overflow-y-auto">
              {course.sessions?.map((s:any)=>{
                const g=gradeMap[s.id];
                const attended=g?.attendance==="PRESENTE";
                const hasGrade=g?.score!=null;
                const hasSubmission=g?.submission!=null;
                return (
                  <button key={s.id} onClick={()=>setSelSession(s)}
                    className={clsx("w-full text-left px-4 py-3 transition-colors flex items-start gap-3",
                      selSession?.id===s.id?"bg-red-50 border-r-2 border-primary":"hover:bg-gray-50")}>
                    <span className={clsx("w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold flex-shrink-0 mt-0.5",
                      selSession?.id===s.id?"bg-primary text-white":hasGrade?"bg-green-100 text-green-700":"bg-gray-100 text-gray-600")}>
                      {hasGrade?<CheckCircle className="w-4 h-4"/>:s.order}
                    </span>
                    <div className="flex-1 min-w-0">
                      <p className={clsx("text-sm font-medium",selSession?.id===s.id?"text-primary":"text-text-primary")}>{s.title}</p>
                      <div className="flex items-center gap-2 mt-0.5">
                        {attended&&<span className="text-xs text-green-600">Asistio</span>}
                        {hasGrade&&<span className="text-xs font-bold text-blue-600">{g.score}/100</span>}
                        {hasSubmission&&!hasGrade&&<span className="text-xs text-orange-500">Pendiente calificar</span>}
                      </div>
                    </div>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Contenido de la sesion */}
          <div className="md:col-span-2 space-y-4">
            {selSession&&(
              <>
                <div className="card">
                  <div className="flex items-center justify-between mb-4">
                    <div>
                      <h2 className="font-bold text-xl text-text-primary">{selSession.title}</h2>
                      <p className="text-text-muted text-sm mt-0.5">{selSession.description}</p>
                    </div>
                    {gradeMap[selSession.id]?.score!=null&&(
                      <div className={clsx("text-center px-4 py-2 rounded-xl",gradeMap[selSession.id].score>=60?"bg-green-100":"bg-red-100")}>
                        <p className={clsx("text-2xl font-bold",gradeMap[selSession.id].score>=60?"text-green-700":"text-red-700")}>{gradeMap[selSession.id].score}</p>
                        <p className="text-xs text-text-muted">/ 100</p>
                      </div>
                    )}
                  </div>
                  {/* Asistencia */}
                  <div className={clsx("flex items-center gap-2 px-3 py-2 rounded-lg text-sm mb-3",
                    gradeMap[selSession.id]?.attendance==="PRESENTE"?"bg-green-50 text-green-700":gradeMap[selSession.id]?.attendance==="AUSENTE"?"bg-red-50 text-red-700":"bg-gray-50 text-gray-500")}>
                    <CheckCircle className="w-4 h-4"/>
                    Asistencia: {gradeMap[selSession.id]?.attendance||"No registrada"}
                  </div>
                  {/* Recursos */}
                  {selSession.resources?.length>0?(
                    <div>
                      <p className="text-xs font-semibold text-text-muted uppercase mb-2">Materiales</p>
                      <div className="space-y-2">
                        {selSession.resources.map((r:any)=>(
                          <a key={r.id} href={r.url} target="_blank" rel="noopener noreferrer"
                            className="flex items-center gap-3 p-3 bg-gray-50 rounded-xl hover:bg-red-50 transition-colors group">
                            {r.type==="video"?<Video className="w-5 h-5 text-red-500 flex-shrink-0"/>
                              :r.type==="pdf"?<FileText className="w-5 h-5 text-blue-500 flex-shrink-0"/>
                              :<LinkIcon className="w-5 h-5 text-green-500 flex-shrink-0"/>}
                            <span className="text-sm text-text-primary group-hover:text-primary font-medium">{r.title}</span>
                            <ChevronRight className="w-4 h-4 text-gray-400 ml-auto group-hover:text-primary"/>
                          </a>
                        ))}
                      </div>
                    </div>
                  ):<div className="bg-gray-50 rounded-xl p-4 text-center text-sm text-text-muted">El formador aun no ha subido materiales para esta sesion.</div>}
                </div>

                {/* Retroalimentacion */}
                {gradeMap[selSession.id]?.feedback&&(
                  <div className="card bg-blue-50 border-blue-200">
                    <p className="text-xs font-semibold text-blue-600 uppercase mb-2">Retroalimentacion del formador</p>
                    <p className="text-sm text-blue-800">{gradeMap[selSession.id].feedback}</p>
                  </div>
                )}

                {/* Envio de actividad */}
                <div className="card">
                  <p className="font-bold text-text-primary mb-1 flex items-center gap-2"><Send className="w-4 h-4 text-primary"/> Entregar actividad</p>
                  <p className="text-text-muted text-xs mb-4">Escribe tu respuesta o sube un archivo para esta sesion.</p>
                  {submitMsg&&<div className={clsx("px-3 py-2 rounded-lg text-sm mb-3",submitMsg.includes("Error")?"bg-red-50 text-red-700":"bg-green-50 text-green-700")}>{submitMsg}</div>}
                  {gradeMap[selSession.id]?.submission&&(
                    <div className="bg-yellow-50 border border-yellow-200 rounded-xl p-3 text-sm text-yellow-800 mb-3 flex items-center gap-2">
                      <CheckCircle className="w-4 h-4 flex-shrink-0"/> Ya enviaste una entrega para esta sesion.
                    </div>
                  )}
                  <textarea className="input text-sm resize-none" rows={3} placeholder="Escribe tu respuesta aqui..."
                    value={submitText} onChange={e=>setSubmitText(e.target.value)}/>
                  <div className="flex items-center gap-3 mt-3">
                    <label className="flex items-center gap-2 cursor-pointer bg-gray-50 border border-gray-200 rounded-lg px-3 py-2 text-sm text-text-secondary hover:bg-gray-100 transition-colors flex-1">
                      <Upload className="w-4 h-4 text-primary"/>
                      {submitFile?submitFile.name:"Adjuntar archivo (PDF, imagen...)"}
                      <input type="file" className="hidden" onChange={e=>setSubmitFile(e.target.files?.[0]||null)} accept=".pdf,.doc,.docx,.jpg,.png,.zip"/>
                    </label>
                    <button onClick={handleSubmit} disabled={submitting||(!submitText&&!submitFile)}
                      className="btn-primary flex items-center gap-2 py-2 text-sm flex-shrink-0 disabled:opacity-40">
                      {submitting?<Loader2 className="w-4 h-4 animate-spin"/>:<Send className="w-4 h-4"/>}
                      {submitting?"Enviando...":"Enviar"}
                    </button>
                  </div>
                </div>
              </>
            )}
          </div>
        </div>

        {/* Sabana de notas */}
        <div className="card">
          <h3 className="font-bold text-text-primary mb-1 flex items-center gap-2"><Award className="w-5 h-5 text-primary"/> Sabana de notas</h3>
          <p className="text-text-muted text-xs mb-4">Historial de calificaciones y asistencia por sesion</p>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead><tr className="bg-gray-50">
                <th className="text-left py-2 px-3 font-semibold text-text-secondary rounded-l-xl">Sesion</th>
                <th className="text-center py-2 px-3 font-semibold text-text-secondary">Asistencia</th>
                <th className="text-center py-2 px-3 font-semibold text-text-secondary">Nota</th>
                <th className="text-left py-2 px-3 font-semibold text-text-secondary rounded-r-xl">Retroalimentacion</th>
              </tr></thead>
              <tbody className="divide-y divide-gray-50">
                {grades.map((g:any)=>(
                  <tr key={g.id} className="hover:bg-gray-50">
                    <td className="py-2 px-3 font-medium">{g.title}</td>
                    <td className="py-2 px-3 text-center">
                      <span className={clsx("badge text-xs",g.attendance==="PRESENTE"?"badge-success":g.attendance==="AUSENTE"?"badge-primary":g.attendance==="EXCUSA"?"badge-warning":"badge-muted")}>
                        {g.attendance||"â€”"}
                      </span>
                    </td>
                    <td className="py-2 px-3 text-center">
                      {g.score!=null
                        ?<span className={clsx("font-bold text-lg",g.score>=60?"text-green-600":"text-red-600")}>{g.score}</span>
                        :g.submission?<span className="badge-warning text-xs">Pendiente</span>:<span className="text-text-muted">â€”</span>}
                    </td>
                    <td className="py-2 px-3 text-text-secondary text-xs">{g.feedback||"â€”"}</td>
                  </tr>
                ))}
              </tbody>
              <tfoot><tr className="border-t-2 border-gray-200 bg-gray-50">
                <td className="py-3 px-3 font-bold text-text-primary" colSpan={2}>PROMEDIO GENERAL</td>
                <td className="py-3 px-3 text-center">
                  <span className={clsx("text-xl font-bold",parseFloat(promedio)>=60?"text-green-600":"text-red-600")}>{promedio}</span>
                </td>
                <td className="py-3 px-3 text-xs text-text-muted">{graded} sesiones calificadas</td>
              </tr></tfoot>
            </table>
          </div>
        </div>
      </div>
    </AppShell>
  );
}