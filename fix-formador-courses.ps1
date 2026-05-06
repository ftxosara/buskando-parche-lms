Write-Host "=== FIX FORMADOR: EDITAR/ELIMINAR CONTENIDO ===" -ForegroundColor Yellow

# ── 1. BACKEND: rutas para editar/eliminar sesiones y recursos ─
$sessionsRoute = 'const router = require("express").Router();
const { authenticate, authorize } = require("../middleware/auth");
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

// GET sesiones de un curso
router.get("/course/:courseId", authenticate, async (req, res) => {
  try {
    const sessions = await prisma.session.findMany({
      where: { courseId: req.params.courseId },
      include: { resources: true },
      orderBy: { order: "asc" },
    });
    return res.json(sessions);
  } catch { return res.status(500).json({ error: "Error" }); }
});

// PUT editar sesion
router.put("/:id", authenticate, authorize("FORMADOR","ADMIN"), async (req, res) => {
  try {
    const { title, description, liveUrl } = req.body;
    const s = await prisma.session.update({ where: { id: req.params.id }, data: { title, description, liveUrl } });
    return res.json(s);
  } catch { return res.status(500).json({ error: "Error" }); }
});

// DELETE eliminar sesion
router.delete("/:id", authenticate, authorize("FORMADOR","ADMIN"), async (req, res) => {
  try {
    await prisma.resource.deleteMany({ where: { sessionId: req.params.id } });
    await prisma.submission.deleteMany({ where: { sessionId: req.params.id } });
    await prisma.attendance.deleteMany({ where: { sessionId: req.params.id } });
    await prisma.session.delete({ where: { id: req.params.id } });
    return res.json({ message: "Sesion eliminada" });
  } catch(e) { return res.status(500).json({ error: "Error: "+e.message }); }
});

// DELETE eliminar recurso/material
router.delete("/resource/:id", authenticate, authorize("FORMADOR","ADMIN"), async (req, res) => {
  try {
    await prisma.resource.delete({ where: { id: req.params.id } });
    return res.json({ message: "Recurso eliminado" });
  } catch { return res.status(500).json({ error: "Error" }); }
});

// PUT editar recurso
router.put("/resource/:id", authenticate, authorize("FORMADOR","ADMIN"), async (req, res) => {
  try {
    const { title, description, url, type } = req.body;
    const r = await prisma.resource.update({ where: { id: req.params.id }, data: { title, description, url, type } });
    return res.json(r);
  } catch { return res.status(500).json({ error: "Error" }); }
});

module.exports = router;
'
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("$PWD\backend\src\routes\sessions.js", $sessionsRoute, $utf8NoBom)
Write-Host "sessions.js con editar/eliminar OK" -ForegroundColor Green

# ── 2. FORMADOR CURSOS PAGE: con editar/eliminar ─────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\formador\courses" | Out-Null
$formCourses = '"use client";
import { useEffect, useState } from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { useSearchParams } from "next/navigation";
import { Plus, Trash2, Edit2, Link, FileText, BookOpen, X, CheckCircle, Loader2, ChevronDown, ChevronUp, Lock, Save, AlertCircle } from "lucide-react";
import clsx from "clsx";

export default function FormadorCoursesPage() {
  const params = useSearchParams();
  const courseId = params.get("id");
  const [courses, setCourses] = useState<any[]>([]);
  const [sessions, setSessions] = useState<any[]>([]);
  const [selCourse, setSelCourse] = useState<any>(null);
  const [openSess, setOpenSess] = useState<string|null>(null);
  const [tab, setTab] = useState<Record<string,string>>({});
  const [loading, setLoading] = useState(true);
  const [msg, setMsg] = useState({ text:"", type:"" });
  const [saving, setSaving] = useState(false);
  // Modales
  const [editSess, setEditSess] = useState<any>(null);
  const [editRes, setEditRes] = useState<any>(null);
  const [newRes, setNewRes] = useState<{sessId:string,type:string}|null>(null);
  const [resForm, setResForm] = useState({ title:"", description:"", url:"", type:"LINK" });
  const [sessForm, setSessForm] = useState({ title:"", description:"", liveUrl:"" });

  useEffect(() => {
    api.get("/courses/lobby").then(({ data }) => {
      setCourses(data);
      const mine = data.find((c:any) => c.isMyCourseFomador || c.isEnrolled === false);
      if (courseId) {
        const found = data.find((c:any) => c.id === courseId);
        if (found) { setSelCourse(found); loadSessions(found.id); }
      } else if (mine) { setSelCourse(mine); loadSessions(mine.id); }
      setLoading(false);
    });
  }, []);

  const loadSessions = (cid: string) => {
    api.get("/sessions/course/" + cid).then(({ data }) => setSessions(data));
  };

  const ok = (t: string) => { setMsg({text:t,type:"ok"}); setTimeout(()=>setMsg({text:"",type:""}),3500); };
  const err = (t: string) => setMsg({text:t,type:"err"});

  const addSession = async () => {
    if (!selCourse) return;
    setSaving(true);
    try {
      await api.post("/courses/" + selCourse.id + "/sessions", {
        title: "Sesion " + (sessions.length + 1),
        description: "Descripcion de la sesion",
        order: sessions.length + 1,
      });
      loadSessions(selCourse.id); ok("Sesion creada");
    } catch { err("Error al crear sesion"); }
    finally { setSaving(false); }
  };

  const saveSession = async () => {
    setSaving(true);
    try {
      await api.put("/sessions/" + editSess.id, sessForm);
      loadSessions(selCourse.id); ok("Sesion actualizada"); setEditSess(null);
    } catch { err("Error"); }
    finally { setSaving(false); }
  };

  const deleteSession = async (id: string) => {
    if (!confirm("Eliminar esta sesion y todo su contenido?")) return;
    try {
      await api.delete("/sessions/" + id);
      loadSessions(selCourse.id); ok("Sesion eliminada");
    } catch { err("Error al eliminar"); }
  };

  const addResource = async () => {
    if (!newRes || !resForm.title) return err("El titulo es obligatorio");
    setSaving(true);
    try {
      await api.post("/sessions/" + newRes.sessId + "/resources", { ...resForm, type: newRes.type });
      loadSessions(selCourse.id); ok("Recurso agregado"); setNewRes(null); setResForm({title:"",description:"",url:"",type:"LINK"});
    } catch { err("Error"); }
    finally { setSaving(false); }
  };

  const saveResource = async () => {
    setSaving(true);
    try {
      await api.put("/sessions/resource/" + editRes.id, resForm);
      loadSessions(selCourse.id); ok("Recurso actualizado"); setEditRes(null);
    } catch { err("Error"); }
    finally { setSaving(false); }
  };

  const deleteResource = async (id: string) => {
    if (!confirm("Eliminar este recurso?")) return;
    try {
      await api.delete("/sessions/resource/" + id);
      loadSessions(selCourse.id); ok("Recurso eliminado");
    } catch { err("Error"); }
  };

  const openEditSess = (s: any) => { setSessForm({title:s.title,description:s.description||"",liveUrl:s.liveUrl||""}); setEditSess(s); };
  const openEditRes = (r: any) => { setResForm({title:r.title,description:r.description||"",url:r.url||"",type:r.type}); setEditRes(r); };

  if (loading) return <AppShell allowedRoles={["FORMADOR"]}><div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div></AppShell>;

  return (
    <AppShell allowedRoles={["FORMADOR"]}>
      <div className="max-w-5xl mx-auto space-y-6">
        <div className="flex items-center justify-between">
          <div><h1 className="font-display text-3xl font-bold text-text-primary">Mis Cursos</h1><p className="text-text-secondary mt-1">Gestiona el contenido de tu curso</p></div>
        </div>

        {msg.text&&<div className={clsx("flex items-center gap-3 px-4 py-3 rounded-2xl text-sm font-medium border",msg.type==="err"?"bg-red-50 border-red-200 text-red-700":"bg-green-50 border-green-200 text-green-700")}>
          {msg.type==="err"?<AlertCircle className="w-4 h-4"/>:<CheckCircle className="w-4 h-4"/>}{msg.text}
        </div>}

        {/* Selector de cursos */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          {courses.map((c:any) => {
            const isMine = selCourse?.id === c.id;
            return (
              <button key={c.id} onClick={()=>{ if(!c.isMyCourseFomador && selCourse?.id!==c.id) return; setSelCourse(c); loadSessions(c.id); }}
                className={clsx("rounded-2xl p-4 text-left transition-all border",
                  isMine?"bg-primary text-white border-primary shadow-brand":"bg-white border-gray-200 opacity-60 cursor-not-allowed")}>
                {!isMine&&<Lock className="w-4 h-4 mb-1"/>}
                <p className="font-semibold text-sm">{c.title}</p>
                <p className="text-xs mt-1 opacity-70">{c.modality}</p>
              </button>
            );
          })}
        </div>

        {/* Sesiones */}
        {selCourse && (
          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <h2 className="font-bold text-text-primary text-xl">{selCourse.title}</h2>
              <button onClick={addSession} disabled={saving} className="btn-primary flex items-center gap-2 text-sm">
                <Plus className="w-4 h-4"/> Agregar sesion
              </button>
            </div>

            {sessions.length===0&&<div className="card text-center py-12 text-text-muted">No hay sesiones. Agrega la primera sesion.</div>}

            {sessions.map((s:any) => (
              <div key={s.id} className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
                <div className="flex items-center gap-3 p-4 cursor-pointer hover:bg-gray-50 transition-colors"
                  onClick={()=>setOpenSess(openSess===s.id?null:s.id)}>
                  <div className="w-9 h-9 rounded-xl bg-primary/10 flex items-center justify-center text-primary font-bold text-sm flex-shrink-0">{s.order}</div>
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-text-primary truncate">{s.title}</p>
                    <p className="text-xs text-text-muted truncate">{s.description}</p>
                  </div>
                  <div className="flex items-center gap-1 flex-shrink-0">
                    <button onClick={e=>{e.stopPropagation();openEditSess(s);}} className="w-8 h-8 rounded-xl hover:bg-blue-50 text-blue-600 flex items-center justify-center transition-colors"><Edit2 className="w-3.5 h-3.5"/></button>
                    <button onClick={e=>{e.stopPropagation();deleteSession(s.id);}} className="w-8 h-8 rounded-xl hover:bg-red-50 text-red-500 flex items-center justify-center transition-colors"><Trash2 className="w-3.5 h-3.5"/></button>
                    {openSess===s.id?<ChevronUp className="w-4 h-4 text-gray-400"/>:<ChevronDown className="w-4 h-4 text-gray-400"/>}
                  </div>
                </div>

                {openSess===s.id&&(
                  <div className="border-t border-gray-100 p-4 space-y-4">
                    {/* Tabs */}
                    <div className="flex gap-2">
                      {["material","actividad","examen"].map(t=>(
                        <button key={t} onClick={()=>setTab(p=>({...p,[s.id]:t}))}
                          className={clsx("px-4 py-1.5 rounded-full text-xs font-semibold capitalize transition-colors",
                            (tab[s.id]||"material")===t?"bg-primary text-white":"bg-gray-100 text-text-muted hover:bg-gray-200")}>
                          {t==="material"?"Material / Enlace":t==="actividad"?"Actividad":"Examen"}
                        </button>
                      ))}
                    </div>

                    {/* Recursos existentes */}
                    {s.resources?.filter((r:any)=>{
                      const t=tab[s.id]||"material";
                      if(t==="material") return r.type==="LINK"||r.type==="FILE"||r.type==="MATERIAL";
                      if(t==="actividad") return r.type==="ACTIVIDAD"||r.type==="ASSIGNMENT";
                      return r.type==="EXAMEN"||r.type==="QUIZ";
                    }).map((r:any)=>(
                      <div key={r.id} className="flex items-center gap-3 bg-gray-50 rounded-xl p-3">
                        <FileText className="w-4 h-4 text-primary flex-shrink-0"/>
                        <div className="flex-1 min-w-0">
                          <p className="text-sm font-medium truncate">{r.title}</p>
                          {r.url&&<a href={r.url} target="_blank" className="text-xs text-blue-600 hover:underline truncate block">{r.url}</a>}
                        </div>
                        <button onClick={()=>openEditRes(r)} className="w-7 h-7 rounded-lg hover:bg-blue-100 text-blue-600 flex items-center justify-center"><Edit2 className="w-3 h-3"/></button>
                        <button onClick={()=>deleteResource(r.id)} className="w-7 h-7 rounded-lg hover:bg-red-100 text-red-500 flex items-center justify-center"><Trash2 className="w-3 h-3"/></button>
                      </div>
                    ))}

                    {/* Agregar recurso */}
                    <button onClick={()=>setNewRes({sessId:s.id,type:tab[s.id]==="actividad"?"ACTIVIDAD":tab[s.id]==="examen"?"EXAMEN":"LINK"})}
                      className="flex items-center gap-2 text-sm text-primary hover:text-primary-dark font-medium">
                      <Plus className="w-4 h-4"/> Agregar {tab[s.id]==="actividad"?"actividad":tab[s.id]==="examen"?"examen":"material"}
                    </button>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>

      {/* MODAL EDITAR SESION */}
      {editSess&&(
        <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4" onClick={e=>{if(e.target===e.currentTarget)setEditSess(null);}}>
          <div className="bg-white rounded-3xl shadow-2xl w-full max-w-md p-6 space-y-4">
            <div className="flex items-center justify-between"><h2 className="font-bold text-text-primary">Editar sesion</h2><button onClick={()=>setEditSess(null)}><X className="w-5 h-5 text-gray-400"/></button></div>
            <div><label className="block text-xs font-bold text-text-muted mb-1.5">Titulo</label><input className="input" value={sessForm.title} onChange={e=>setSessForm(p=>({...p,title:e.target.value}))}/></div>
            <div><label className="block text-xs font-bold text-text-muted mb-1.5">Descripcion</label><textarea className="input min-h-20 resize-none" value={sessForm.description} onChange={e=>setSessForm(p=>({...p,description:e.target.value}))}/></div>
            <div><label className="block text-xs font-bold text-text-muted mb-1.5">Enlace de clase virtual (opcional)</label><input className="input" placeholder="https://meet.google.com/..." value={sessForm.liveUrl} onChange={e=>setSessForm(p=>({...p,liveUrl:e.target.value}))}/></div>
            <button onClick={saveSession} disabled={saving} className="btn-primary w-full flex items-center justify-center gap-2 h-11">
              {saving?<Loader2 className="w-4 h-4 animate-spin"/>:<Save className="w-4 h-4"/>} Guardar cambios
            </button>
          </div>
        </div>
      )}

      {/* MODAL NUEVO/EDITAR RECURSO */}
      {(newRes||editRes)&&(
        <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4" onClick={e=>{if(e.target===e.currentTarget){setNewRes(null);setEditRes(null);}}}>
          <div className="bg-white rounded-3xl shadow-2xl w-full max-w-md p-6 space-y-4">
            <div className="flex items-center justify-between">
              <h2 className="font-bold text-text-primary">{editRes?"Editar recurso":"Agregar "+ (newRes?.type==="ACTIVIDAD"?"actividad":newRes?.type==="EXAMEN"?"examen":"material")}</h2>
              <button onClick={()=>{setNewRes(null);setEditRes(null);}}><X className="w-5 h-5 text-gray-400"/></button>
            </div>
            <div><label className="block text-xs font-bold text-text-muted mb-1.5">Titulo *</label><input className="input" value={resForm.title} onChange={e=>setResForm(p=>({...p,title:e.target.value}))}/></div>
            <div><label className="block text-xs font-bold text-text-muted mb-1.5">Descripcion</label><textarea className="input min-h-16 resize-none" value={resForm.description} onChange={e=>setResForm(p=>({...p,description:e.target.value}))}/></div>
            <div><label className="block text-xs font-bold text-text-muted mb-1.5">URL / Enlace</label><input className="input" placeholder="https://..." value={resForm.url} onChange={e=>setResForm(p=>({...p,url:e.target.value}))}/></div>
            <button onClick={editRes?saveResource:addResource} disabled={saving||!resForm.title} className="btn-primary w-full flex items-center justify-center gap-2 h-11 disabled:opacity-40">
              {saving?<Loader2 className="w-4 h-4 animate-spin"/>:<CheckCircle className="w-4 h-4"/>} {editRes?"Guardar cambios":"Agregar"}
            </button>
          </div>
        </div>
      )}
    </AppShell>
  );
}'
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText("$PWD\frontend\src\app\(dashboard)\formador\courses\page.tsx", $formCourses, $utf8NoBom)
Write-Host "Formador courses con editar/eliminar OK" -ForegroundColor Green

Write-Host ""
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host "FIX FORMADOR CURSOS COMPLETO" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. GitHub Desktop -> Commit 'Fix formador editar cursos' -> Push" -ForegroundColor Cyan
Write-Host "2. En VPS:" -ForegroundColor Cyan
Write-Host "   cd /home/proyectos/buskandoparche-LMS" -ForegroundColor White
Write-Host "   git pull" -ForegroundColor White
Write-Host "   docker compose -f docker-compose.prod.yml --env-file .env up -d --build" -ForegroundColor White
