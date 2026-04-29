"use client";
import { useEffect, useState } from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { Search, Download, Loader2, CheckCircle, XCircle, BookOpen, Award, Plus, Edit2, Trash2, Key, X, User, Mail, Phone, ChevronLeft, ChevronRight } from "lucide-react";
import clsx from "clsx";

const COURSE_COLOR: Record<string,{bg:string,text:string,dot:string}> = {
  "Ingles":              {bg:"bg-blue-50",text:"text-blue-700",dot:"bg-blue-500"},
  "Gestion Empresarial": {bg:"bg-emerald-50",text:"text-emerald-700",dot:"bg-emerald-500"},
  "Gestion Turistica":   {bg:"bg-teal-50",text:"text-teal-700",dot:"bg-teal-500"},
  "Marketing Digital":   {bg:"bg-orange-50",text:"text-orange-700",dot:"bg-orange-500"},
};
const DEFAULT_COLOR = {bg:"bg-gray-100",text:"text-gray-600",dot:"bg-gray-400"};
const EMPTY = { firstName:"",lastName:"",cedula:"",email:"",phone:"",gender:"FEMENINO",populationGroup:"EMPRENDEDOR",locality:"Kennedy",role:"BENEFICIARIO",courseId:"",password:"" };

function Avatar({ name, color }: { name: string; color: string }) {
  const initials = name.split(" ").slice(0,2).map(n=>n[0]||"").join("").toUpperCase();
  return (
    <div className={"w-10 h-10 rounded-full flex items-center justify-center text-white text-sm font-bold flex-shrink-0 " + color}>
      {initials}
    </div>
  );
}

const AVATAR_COLORS = ["bg-red-500","bg-blue-500","bg-emerald-500","bg-orange-500","bg-purple-500","bg-pink-500","bg-teal-500","bg-indigo-500"];

export default function AdminUsersPage() {
  const [users, setUsers] = useState<any[]>([]);
  const [courses, setCourses] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [roleFilter, setRoleFilter] = useState("BENEFICIARIO");
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [total, setTotal] = useState(0);
  const [msg, setMsg] = useState({ text:"",type:"" });
  const [modal, setModal] = useState<"create"|"edit"|"delete"|"password"|"course"|null>(null);
  const [selUser, setSelUser] = useState<any>(null);
  const [form, setForm] = useState<any>(EMPTY);
  const [saving, setSaving] = useState(false);

  const fetch = () => {
    setLoading(true);
    api.get("/users", { params:{role:roleFilter,page,limit:20,search} })
      .then(({data}) => { setUsers(data.data); setTotal(data.total); })
      .finally(() => setLoading(false));
  };
  useEffect(() => { fetch(); }, [roleFilter, page, search]);
  useEffect(() => { api.get("/courses/lobby").then(({data}) => setCourses(data)); }, []);

  const ok = (text: string) => { setMsg({text,type:"ok"}); setTimeout(()=>setMsg({text:"",type:""}),3500); };
  const err = (text: string) => setMsg({text,type:"err"});
  const F = (k: string, v: any) => setForm((p:any) => ({...p,[k]:v}));

  const openCreate = () => { setForm({...EMPTY}); setModal("create"); };
  const openEdit = (u:any) => { setSelUser(u); setForm({...u,password:"",courseId:u.enrollments?.[0]?.courseId||""}); setModal("edit"); };
  const openDelete = (u:any) => { setSelUser(u); setModal("delete"); };
  const openPwd = (u:any) => { setSelUser(u); setForm({password:"",confirm:""}); setModal("password"); };
  const openCourse = (u:any) => { setSelUser(u); setForm({courseId:u.enrollments?.[0]?.courseId||""}); setModal("course"); };

  const doCreate = async() => {
    if(!form.firstName||!form.lastName||!form.cedula||!form.email) return err("Completa los campos requeridos");
    setSaving(true);
    try { await api.post("/users",form); ok("Usuario creado"); setModal(null); fetch(); }
    catch(e:any){ err(e.response?.data?.error||"Error al crear"); }
    finally{ setSaving(false); }
  };
  const doEdit = async() => {
    setSaving(true);
    try {
      const p:any={...form}; if(!p.password) delete p.password;
      p.currentCourseId=selUser?.enrollments?.[0]?.courseId;
      await api.put("/users/"+selUser.id,p); ok("Usuario actualizado"); setModal(null); fetch();
    } catch(e:any){ err(e.response?.data?.error||"Error"); }
    finally{ setSaving(false); }
  };
  const doDelete = async(hard=false) => {
    setSaving(true);
    try { await api.delete("/users/"+selUser.id+(hard?"/hard":"")); ok(hard?"Eliminado":"Desactivado"); setModal(null); fetch(); }
    catch{ err("Error"); } finally{ setSaving(false); }
  };
  const doPwd = async() => {
    if(!form.password||form.password!==form.confirm) return err("Las contrasenas no coinciden");
    setSaving(true);
    try { await api.put("/users/"+selUser.id,{password:form.password}); ok("Contrasena actualizada"); setModal(null); }
    catch{ err("Error"); } finally{ setSaving(false); }
  };
  const doCourse = async() => {
    setSaving(true);
    try { await api.put("/users/"+selUser.id,{courseId:form.courseId,currentCourseId:selUser?.enrollments?.[0]?.courseId}); ok("Curso asignado"); setModal(null); fetch(); }
    catch{ err("Error"); } finally{ setSaving(false); }
  };
  const enableCert = async(userId:string,courseId:string) => { await api.post("/certificates/"+courseId+"/unlock",{userId}); ok("Certificado habilitado"); fetch(); };
  const revokeCert = async(userId:string,courseId:string) => { await api.post("/certificates/"+courseId+"/revoke",{userId}); ok("Certificado revocado"); fetch(); };
  const dlCert = async(userId:string,courseId:string,cedula:string) => {
    try {
      const res=await api.get("/certificates/"+courseId+"/"+userId,{responseType:"blob"});
      const a=document.createElement("a"); a.href=URL.createObjectURL(new Blob([res.data])); a.download="certificado-"+cedula+".pdf"; a.click();
    } catch(e:any){ err(e.response?.data?.error||"Error al descargar"); }
  };
  const exportCSV = () => {
    const h="Nombre,Cedula,Email,Clave,Genero,Curso,Estado\n";
    const rows=users.map((u:any)=>[u.firstName+" "+u.lastName,u.cedula,u.email,roleFilter==="BENEFICIARIO"?"BuskandoParche2024!":roleFilter==="FORMADOR"?"Formador2024!":"Admin2024!",u.gender||"",u.enrollments?.[0]?.course?.title||"",u.isActive?"Activo":"Inactivo"].join(",")).join("\n");
    const b=new Blob(["\uFEFF"+h+rows],{type:"text/csv;charset=utf-8"});
    const a=document.createElement("a"); a.href=URL.createObjectURL(b); a.download="usuarios.csv"; a.click();
  };

  const totalPages = Math.ceil(total/20);

  return (
    <AppShell allowedRoles={["ADMIN"]}>
      <div className="max-w-7xl mx-auto space-y-6">

        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="font-display text-3xl font-bold text-text-primary">Gestion de Usuarios</h1>
            <p className="text-text-secondary mt-1">{total} usuarios registrados en el programa</p>
          </div>
          <div className="flex gap-3">
            <button onClick={openCreate} className="btn-primary flex items-center gap-2">
              <Plus className="w-4 h-4"/> Nuevo usuario
            </button>
            <button onClick={exportCSV} className="btn-outline flex items-center gap-2 text-sm">
              <Download className="w-4 h-4"/> CSV
            </button>
          </div>
        </div>

        {/* Mensaje */}
        {msg.text&&(
          <div className={clsx("flex items-center gap-3 px-4 py-3 rounded-2xl text-sm font-medium border",
            msg.type==="err"?"bg-red-50 border-red-200 text-red-700":"bg-green-50 border-green-200 text-green-700")}>
            {msg.type==="err"?<XCircle className="w-4 h-4 flex-shrink-0"/>:<CheckCircle className="w-4 h-4 flex-shrink-0"/>}
            {msg.text}
            <button onClick={()=>setMsg({text:"",type:""})} className="ml-auto"><X className="w-4 h-4"/></button>
          </div>
        )}

        {/* Filtros */}
        <div className="flex flex-col md:flex-row gap-3">
          <div className="relative flex-1">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400"/>
            <input className="input pl-12 h-12 text-sm rounded-2xl" placeholder="Buscar por nombre, cedula o email..."
              value={search} onChange={e=>{setSearch(e.target.value);setPage(1);}}/>
          </div>
          <div className="flex gap-2">
            {["BENEFICIARIO","FORMADOR","ADMIN"].map(r=>(
              <button key={r} onClick={()=>{setRoleFilter(r);setPage(1);}}
                className={clsx("px-5 py-2.5 rounded-2xl text-sm font-semibold transition-all",
                  roleFilter===r?"bg-primary text-white shadow-brand":"bg-white border border-gray-200 text-text-secondary hover:border-primary hover:text-primary")}>
                {r==="BENEFICIARIO"?"Beneficiarios":r==="FORMADOR"?"Formadores":"Admins"}
              </button>
            ))}
          </div>
        </div>

        {/* Lista de usuarios */}
        {loading?(
          <div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div>
        ):(
          <div className="space-y-2">
            {users.length===0&&<div className="card text-center py-12"><User className="w-10 h-10 text-gray-300 mx-auto mb-3"/><p className="text-text-muted">Sin resultados</p></div>}
            {users.map((u:any, i:number) => {
              const ct = u.enrollments?.[0]?.course?.title||"";
              const cid = u.enrollments?.[0]?.courseId||u.enrollments?.[0]?.course?.id||"";
              const completed = u.enrollments?.[0]?.status==="COMPLETADO";
              const cc = COURSE_COLOR[ct]||DEFAULT_COLOR;
              const avatarColor = AVATAR_COLORS[i % AVATAR_COLORS.length];
              return (
                <div key={u.id} className="bg-white rounded-2xl border border-gray-100 shadow-sm hover:shadow-md hover:border-gray-200 transition-all duration-200 p-4">
                  <div className="flex items-center gap-4">
                    {/* Avatar */}
                    <Avatar name={u.firstName+" "+u.lastName} color={avatarColor}/>

                    {/* Info principal */}
                    <div className="flex-1 min-w-0 grid grid-cols-1 md:grid-cols-4 gap-2 md:gap-4 items-center">
                      <div className="min-w-0">
                        <p className="font-semibold text-text-primary text-sm truncate">{u.firstName} {u.lastName}</p>
                        <p className="text-xs text-text-muted font-mono">{u.cedula}</p>
                      </div>
                      <div className="min-w-0">
                        <p className="text-xs text-text-secondary truncate flex items-center gap-1"><Mail className="w-3 h-3 flex-shrink-0"/>{u.email}</p>
                        {u.phone&&<p className="text-xs text-text-muted flex items-center gap-1 mt-0.5"><Phone className="w-3 h-3 flex-shrink-0"/>{u.phone}</p>}
                      </div>
                      <div className="flex items-center gap-2 flex-wrap">
                        {u.gender&&(
                          <span className={clsx("inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium",
                            u.gender==="FEMENINO"?"bg-pink-50 text-pink-700":"bg-blue-50 text-blue-700")}>
                            {u.gender==="FEMENINO"?"Mujer":"Hombre"}
                          </span>
                        )}
                        {ct?(
                          <span className={"inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium "+cc.bg+" "+cc.text}>
                            <span className={"w-1.5 h-1.5 rounded-full "+cc.dot}/>
                            {ct}
                          </span>
                        ):(
                          <span className="text-xs text-gray-400 italic">Sin curso</span>
                        )}
                      </div>
                      <div className="flex items-center gap-2">
                        {u.isActive
                          ?<span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-medium bg-green-50 text-green-700"><span className="w-1.5 h-1.5 rounded-full bg-green-500"/>Activo</span>
                          :<span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-500"><span className="w-1.5 h-1.5 rounded-full bg-gray-400"/>Inactivo</span>}
                        {completed&&<span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-medium bg-yellow-50 text-yellow-700"><Award className="w-3 h-3"/>Cert. listo</span>}
                      </div>
                    </div>

                    {/* Acciones */}
                    <div className="flex items-center gap-1 flex-shrink-0">
                      <button onClick={()=>openEdit(u)} title="Editar" className="w-9 h-9 rounded-xl hover:bg-blue-50 text-blue-600 flex items-center justify-center transition-colors"><Edit2 className="w-4 h-4"/></button>
                      <button onClick={()=>openPwd(u)} title="Cambiar clave" className="w-9 h-9 rounded-xl hover:bg-yellow-50 text-yellow-600 flex items-center justify-center transition-colors"><Key className="w-4 h-4"/></button>
                      {roleFilter==="BENEFICIARIO"&&<button onClick={()=>openCourse(u)} title="Cambiar curso" className="w-9 h-9 rounded-xl hover:bg-green-50 text-green-600 flex items-center justify-center transition-colors"><BookOpen className="w-4 h-4"/></button>}
                      <button onClick={()=>openDelete(u)} title="Eliminar" className="w-9 h-9 rounded-xl hover:bg-red-50 text-red-500 flex items-center justify-center transition-colors"><Trash2 className="w-4 h-4"/></button>
                      {roleFilter==="BENEFICIARIO"&&cid&&(
                        completed?(
                          <>
                            <button onClick={()=>dlCert(u.id,cid,u.cedula)} title="Descargar PDF"
                              className="flex items-center gap-1 bg-primary text-white px-3 py-1.5 rounded-xl text-xs font-semibold hover:bg-primary-dark transition-colors">
                              <Award className="w-3.5 h-3.5"/>PDF
                            </button>
                            <button onClick={()=>revokeCert(u.id,cid)} title="Revocar"
                              className="flex items-center gap-1 bg-orange-100 text-orange-700 px-2 py-1.5 rounded-xl text-xs font-semibold hover:bg-orange-200 transition-colors">
                              Revocar
                            </button>
                          </>
                        ):(
                          <button onClick={()=>enableCert(u.id,cid)}
                            className="flex items-center gap-1 bg-green-100 text-green-700 px-3 py-1.5 rounded-xl text-xs font-semibold hover:bg-green-200 transition-colors">
                            <CheckCircle className="w-3.5 h-3.5"/>Habilitar
                          </button>
                        )
                      )}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}

        {/* Paginacion */}
        {total>20&&(
          <div className="flex items-center justify-between">
            <p className="text-sm text-text-muted">Mostrando {((page-1)*20)+1}-{Math.min(page*20,total)} de {total}</p>
            <div className="flex items-center gap-2">
              <button onClick={()=>setPage(p=>Math.max(1,p-1))} disabled={page===1}
                className="w-9 h-9 rounded-xl border border-gray-200 flex items-center justify-center hover:bg-gray-50 disabled:opacity-40 transition-colors">
                <ChevronLeft className="w-4 h-4"/>
              </button>
              <div className="flex gap-1">
                {Array.from({length:Math.min(5,totalPages)},(_,i)=>{
                  const p=Math.max(1,Math.min(page-2,totalPages-4))+i;
                  if(p<1||p>totalPages) return null;
                  return (
                    <button key={p} onClick={()=>setPage(p)}
                      className={clsx("w-9 h-9 rounded-xl text-sm font-semibold transition-colors",
                        page===p?"bg-primary text-white":"border border-gray-200 text-text-secondary hover:bg-gray-50")}>
                      {p}
                    </button>
                  );
                })}
              </div>
              <button onClick={()=>setPage(p=>Math.min(totalPages,p+1))} disabled={page>=totalPages}
                className="w-9 h-9 rounded-xl border border-gray-200 flex items-center justify-center hover:bg-gray-50 disabled:opacity-40 transition-colors">
                <ChevronRight className="w-4 h-4"/>
              </button>
            </div>
          </div>
        )}
      </div>

      {/* MODAL */}
      {modal&&(
        <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4"
          onClick={e=>{if(e.target===e.currentTarget)setModal(null);}}>
          <div className="bg-white rounded-3xl shadow-2xl w-full max-w-lg max-h-[90vh] overflow-y-auto">
            <div className="sticky top-0 bg-white flex items-center justify-between px-6 py-4 border-b border-gray-100 rounded-t-3xl">
              <h2 className="font-bold text-text-primary text-lg">
                {modal==="create"?"Crear usuario":modal==="edit"?"Editar datos":modal==="delete"?"Confirmar accion":modal==="password"?"Cambiar contrasena":"Asignar curso"}
              </h2>
              <button onClick={()=>setModal(null)} className="w-8 h-8 rounded-xl hover:bg-gray-100 flex items-center justify-center transition-colors"><X className="w-4 h-4"/></button>
            </div>
            <div className="p-6 space-y-4">
              {(modal==="create"||modal==="edit")&&(
                <>
                  <div className="grid grid-cols-2 gap-3">
                    <div><label className="block text-xs font-bold text-text-muted mb-1.5">Nombre *</label><input className="input text-sm" value={form.firstName||""} onChange={e=>F("firstName",e.target.value)} placeholder="Nombre"/></div>
                    <div><label className="block text-xs font-bold text-text-muted mb-1.5">Apellido *</label><input className="input text-sm" value={form.lastName||""} onChange={e=>F("lastName",e.target.value)} placeholder="Apellido"/></div>
                  </div>
                  <div className="grid grid-cols-2 gap-3">
                    <div><label className="block text-xs font-bold text-text-muted mb-1.5">Cedula *</label><input className="input text-sm" value={form.cedula||""} onChange={e=>F("cedula",e.target.value)} placeholder="1020301001"/></div>
                    <div><label className="block text-xs font-bold text-text-muted mb-1.5">Telefono</label><input className="input text-sm" value={form.phone||""} onChange={e=>F("phone",e.target.value)} placeholder="3001234567"/></div>
                  </div>
                  <div><label className="block text-xs font-bold text-text-muted mb-1.5">Email *</label><input className="input text-sm" type="email" value={form.email||""} onChange={e=>F("email",e.target.value)} placeholder="correo@ejemplo.com"/></div>
                  {modal==="create"&&<div><label className="block text-xs font-bold text-text-muted mb-1.5">Contrasena (vacio = BuskandoParche2024!)</label><input className="input text-sm" type="password" value={form.password||""} onChange={e=>F("password",e.target.value)} placeholder="Opcional"/></div>}
                  <div className="grid grid-cols-2 gap-3">
                    <div><label className="block text-xs font-bold text-text-muted mb-1.5">Genero</label>
                      <select className="input text-sm" value={form.gender||"FEMENINO"} onChange={e=>F("gender",e.target.value)}>
                        <option value="FEMENINO">Femenino</option><option value="MASCULINO">Masculino</option><option value="NO_BINARIO">No binario</option>
                      </select>
                    </div>
                    <div><label className="block text-xs font-bold text-text-muted mb-1.5">Rol</label>
                      <select className="input text-sm" value={form.role||"BENEFICIARIO"} onChange={e=>F("role",e.target.value)}>
                        <option value="BENEFICIARIO">Beneficiario</option><option value="FORMADOR">Formador</option><option value="ADMIN">Admin</option>
                      </select>
                    </div>
                  </div>
                  <div><label className="block text-xs font-bold text-text-muted mb-1.5">Grupo poblacional</label>
                    <select className="input text-sm" value={form.populationGroup||"EMPRENDEDOR"} onChange={e=>F("populationGroup",e.target.value)}>
                      {["EMPRENDEDOR","MIPYME","PRESTADOR_TURISTICO","VICTIMA_CONFLICTO","AFRODESCENDIENTE","INDIGENA","DISCAPACIDAD","ADULTO_MAYOR"].map(g=>(
                        <option key={g} value={g}>{g.replace(/_/g," ")}</option>
                      ))}
                    </select>
                  </div>
                  {(form.role==="BENEFICIARIO")&&(
                    <div><label className="block text-xs font-bold text-text-muted mb-1.5">Curso</label>
                      <select className="input text-sm" value={form.courseId||""} onChange={e=>F("courseId",e.target.value)}>
                        <option value="">Sin curso</option>
                        {courses.map((c:any)=><option key={c.id} value={c.id}>{c.title}</option>)}
                      </select>
                    </div>
                  )}
                  <button onClick={modal==="create"?doCreate:doEdit} disabled={saving} className="btn-primary w-full flex items-center justify-center gap-2 h-12 text-base">
                    {saving?<Loader2 className="w-4 h-4 animate-spin"/>:<CheckCircle className="w-4 h-4"/>}
                    {saving?"Guardando...":modal==="create"?"Crear usuario":"Guardar cambios"}
                  </button>
                </>
              )}
              {modal==="password"&&(
                <>
                  <div className="bg-yellow-50 border border-yellow-200 rounded-2xl p-3 text-sm text-yellow-700">
                    Cambiando contrasena de <strong>{selUser?.firstName} {selUser?.lastName}</strong>
                  </div>
                  <div><label className="block text-xs font-bold text-text-muted mb-1.5">Nueva contrasena</label><input className="input" type="password" value={form.password||""} onChange={e=>F("password",e.target.value)} placeholder="Min. 8 caracteres"/></div>
                  <div><label className="block text-xs font-bold text-text-muted mb-1.5">Confirmar</label><input className="input" type="password" value={form.confirm||""} onChange={e=>F("confirm",e.target.value)} placeholder="Repite la contrasena"/></div>
                  {form.password&&form.confirm&&form.password!==form.confirm&&<p className="text-red-500 text-xs font-medium">Las contrasenas no coinciden</p>}
                  <button onClick={doPwd} disabled={saving||!form.password||form.password!==form.confirm} className="btn-primary w-full flex items-center justify-center gap-2 h-12 disabled:opacity-40">
                    {saving?<Loader2 className="w-4 h-4 animate-spin"/>:<Key className="w-4 h-4"/>} Cambiar contrasena
                  </button>
                </>
              )}
              {modal==="course"&&(
                <>
                  <div className="bg-blue-50 border border-blue-200 rounded-2xl p-3 text-sm text-blue-700">
                    Asignar curso a <strong>{selUser?.firstName} {selUser?.lastName}</strong>
                    {selUser?.enrollments?.[0]?.course?.title&&<><br/>Curso actual: <strong>{selUser.enrollments[0].course.title}</strong></>}
                  </div>
                  <div><label className="block text-xs font-bold text-text-muted mb-1.5">Nuevo curso</label>
                    <select className="input" value={form.courseId||""} onChange={e=>F("courseId",e.target.value)}>
                      <option value="">Sin curso</option>
                      {courses.map((c:any)=><option key={c.id} value={c.id}>{c.title}</option>)}
                    </select>
                  </div>
                  <button onClick={doCourse} disabled={saving||!form.courseId} className="btn-primary w-full flex items-center justify-center gap-2 h-12 disabled:opacity-40">
                    {saving?<Loader2 className="w-4 h-4 animate-spin"/>:<BookOpen className="w-4 h-4"/>} Asignar curso
                  </button>
                </>
              )}
              {modal==="delete"&&(
                <>
                  <div className="bg-red-50 border border-red-200 rounded-2xl p-4 text-center">
                    <div className="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-3"><Trash2 className="w-6 h-6 text-red-500"/></div>
                    <p className="font-semibold text-red-800">{selUser?.firstName} {selUser?.lastName}</p>
                    <p className="text-red-600 text-sm mt-1">Que accion deseas realizar?</p>
                  </div>
                  <button onClick={()=>doDelete(false)} disabled={saving} className="w-full bg-yellow-50 border border-yellow-200 text-yellow-700 hover:bg-yellow-100 rounded-2xl py-3 text-sm font-semibold transition-colors flex items-center justify-center gap-2">
                    <XCircle className="w-4 h-4"/> Desactivar (conserva sus datos)
                  </button>
                  <button onClick={()=>doDelete(true)} disabled={saving} className="w-full bg-red-50 border border-red-200 text-red-700 hover:bg-red-100 rounded-2xl py-3 text-sm font-semibold transition-colors flex items-center justify-center gap-2">
                    <Trash2 className="w-4 h-4"/> Eliminar permanentemente
                  </button>
                </>
              )}
            </div>
          </div>
        </div>
      )}
    </AppShell>
  );
}