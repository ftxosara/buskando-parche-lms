"use client";
import { useEffect, useState, useRef } from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { useAuth } from "@/contexts/AuthContext";
import { Camera, Lock, CheckCircle, XCircle, Loader2, User, Mail, Phone, BookOpen, MapPin, Eye, EyeOff } from "lucide-react";

export default function ProfilePage() {
  const { user: authUser } = useAuth();
  const [profile, setProfile] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [msg, setMsg] = useState({ text:"", type:"" });
  const [showPwd, setShowPwd] = useState(false);
  const [pwdForm, setPwdForm] = useState({ current:"", new:"", confirm:"" });
  const [savingPwd, setSavingPwd] = useState(false);
  const [uploadingAvatar, setUploadingAvatar] = useState(false);
  const fileRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    api.get("/profile").then(({ data }) => setProfile(data)).finally(() => setLoading(false));
  }, []);

  const ok = (text: string) => { setMsg({text,type:"ok"}); setTimeout(()=>setMsg({text:"",type:""}),4000); };
  const err = (text: string) => setMsg({text,type:"err"});

  const handleAvatar = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setUploadingAvatar(true);
    try {
      const fd = new FormData(); fd.append("avatar", file);
      const { data } = await api.post("/profile/avatar", fd, { headers: { "Content-Type":"multipart/form-data" } });
      setProfile((p: any) => ({ ...p, avatarUrl: data.avatarUrl }));
      ok("Foto de perfil actualizada");
    } catch { err("Error al subir la foto"); }
    finally { setUploadingAvatar(false); }
  };

  const handlePassword = async () => {
    if (pwdForm.new !== pwdForm.confirm) return err("Las contrasenas no coinciden");
    if (pwdForm.new.length < 6) return err("Minimo 6 caracteres");
    setSavingPwd(true);
    try {
      await api.put("/profile/password", { currentPassword: pwdForm.current, newPassword: pwdForm.new });
      ok("Contrasena actualizada correctamente");
      setPwdForm({ current:"", new:"", confirm:"" });
      setShowPwd(false);
    } catch (e: any) { err(e.response?.data?.error || "Error al cambiar contrasena"); }
    finally { setSavingPwd(false); }
  };

  const role = authUser?.role;
  const allowedRoles = role === "FORMADOR" ? ["FORMADOR"] : ["BENEFICIARIO"];

  if (loading) return (
    <AppShell allowedRoles={allowedRoles}>
      <div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div>
    </AppShell>
  );

  const initials = profile ? (profile.firstName[0] + (profile.lastName[0]||"")).toUpperCase() : "?";
  const enrollment = profile?.enrollments?.[0];

  return (
    <AppShell allowedRoles={allowedRoles}>
      <div className="max-w-2xl mx-auto space-y-6">
        <div>
          <h1 className="font-display text-3xl font-bold text-text-primary">Mi Perfil</h1>
          <p className="text-text-secondary mt-1">Gestiona tu foto y contrasena</p>
        </div>

        {msg.text && (
          <div className={`flex items-center gap-3 px-4 py-3 rounded-2xl text-sm font-medium border ${msg.type==="err"?"bg-red-50 border-red-200 text-red-700":"bg-green-50 border-green-200 text-green-700"}`}>
            {msg.type==="err"?<XCircle className="w-4 h-4 flex-shrink-0"/>:<CheckCircle className="w-4 h-4 flex-shrink-0"/>}
            {msg.text}
          </div>
        )}

        {/* Card de perfil */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-card p-6">
          <div className="flex items-start gap-6">
            {/* Avatar */}
            <div className="relative flex-shrink-0">
              <div className="w-24 h-24 rounded-2xl bg-gradient-brand flex items-center justify-center text-white text-3xl font-bold overflow-hidden">
                {profile?.avatarUrl
                  ? <img src={`${process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000"}${profile.avatarUrl}`} alt="Avatar" className="w-full h-full object-cover"/>
                  : initials}
              </div>
              <button onClick={() => fileRef.current?.click()} disabled={uploadingAvatar}
                className="absolute -bottom-2 -right-2 w-8 h-8 bg-primary rounded-full flex items-center justify-center shadow-lg hover:bg-primary-dark transition-colors disabled:opacity-50">
                {uploadingAvatar ? <Loader2 className="w-4 h-4 text-white animate-spin"/> : <Camera className="w-4 h-4 text-white"/>}
              </button>
              <input ref={fileRef} type="file" accept="image/*" className="hidden" onChange={handleAvatar}/>
            </div>

            {/* Info */}
            <div className="flex-1 space-y-3">
              <div>
                <h2 className="text-xl font-bold text-text-primary">{profile?.firstName} {profile?.lastName}</h2>
                <span className={`inline-block mt-1 px-3 py-1 rounded-full text-xs font-semibold ${role==="FORMADOR"?"bg-yellow-100 text-yellow-700":"bg-blue-100 text-blue-700"}`}>
                  {role==="FORMADOR"?"Formador":"Beneficiario"}
                </span>
              </div>

              <div className="grid grid-cols-1 gap-2">
                <div className="flex items-center gap-2 text-sm text-text-secondary">
                  <Mail className="w-4 h-4 text-gray-400 flex-shrink-0"/>
                  <span>{profile?.email}</span>
                </div>
                {profile?.phone && (
                  <div className="flex items-center gap-2 text-sm text-text-secondary">
                    <Phone className="w-4 h-4 text-gray-400 flex-shrink-0"/>
                    <span>{profile.phone}</span>
                  </div>
                )}
                {profile?.locality && (
                  <div className="flex items-center gap-2 text-sm text-text-secondary">
                    <MapPin className="w-4 h-4 text-gray-400 flex-shrink-0"/>
                    <span>{profile.locality}{profile.upz && " - " + profile.upz}</span>
                  </div>
                )}
                {enrollment?.course && (
                  <div className="flex items-center gap-2 text-sm text-text-secondary">
                    <BookOpen className="w-4 h-4 text-gray-400 flex-shrink-0"/>
                    <span>{enrollment.course.title} <span className="text-text-muted">({enrollment.course.modality})</span></span>
                  </div>
                )}
              </div>

              {profile?.gender && (
                <div className="flex items-center gap-2">
                  <span className={`px-2.5 py-1 rounded-full text-xs font-medium ${profile.gender==="FEMENINO"?"bg-pink-50 text-pink-700":profile.gender==="MASCULINO"?"bg-blue-50 text-blue-700":"bg-purple-50 text-purple-700"}`}>
                    {profile.gender==="FEMENINO"?"Mujer":profile.gender==="MASCULINO"?"Hombre":"LGBTIQ+"}
                  </span>
                  {profile.populationGroup && (
                    <span className="px-2.5 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-600">
                      {profile.populationGroup.replace(/_/g," ")}
                    </span>
                  )}
                </div>
              )}
            </div>
          </div>

          <div className="mt-4 pt-4 border-t border-gray-100 flex items-center gap-2 text-xs text-text-muted">
            <Camera className="w-3.5 h-3.5"/>
            Haz clic en la foto para cambiarla. Formatos: JPG, PNG, WebP. Max 5MB.
          </div>
        </div>

        {/* Cambiar contrasena */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-card overflow-hidden">
          <button onClick={() => setShowPwd(!showPwd)}
            className="w-full flex items-center justify-between px-6 py-4 hover:bg-gray-50 transition-colors">
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 bg-yellow-100 rounded-xl flex items-center justify-center">
                <Lock className="w-4 h-4 text-yellow-600"/>
              </div>
              <div className="text-left">
                <p className="font-semibold text-text-primary text-sm">Cambiar contrasena</p>
                <p className="text-xs text-text-muted">Actualiza tu clave de acceso</p>
              </div>
            </div>
            <span className={`text-xs font-medium px-3 py-1 rounded-full transition-colors ${showPwd?"bg-primary text-white":"bg-gray-100 text-text-muted"}`}>
              {showPwd?"Cerrar":"Abrir"}
            </span>
          </button>

          {showPwd && (
            <div className="px-6 pb-6 space-y-3 border-t border-gray-100 pt-4">
              <div>
                <label className="block text-xs font-bold text-text-muted mb-1.5">Contrasena actual</label>
                <div className="relative">
                  <input type="password" className="input pr-10" placeholder="Tu contrasena actual"
                    value={pwdForm.current} onChange={e=>setPwdForm(p=>({...p,current:e.target.value}))}/>
                </div>
              </div>
              <div>
                <label className="block text-xs font-bold text-text-muted mb-1.5">Nueva contrasena</label>
                <input type="password" className="input" placeholder="Minimo 6 caracteres"
                  value={pwdForm.new} onChange={e=>setPwdForm(p=>({...p,new:e.target.value}))}/>
              </div>
              <div>
                <label className="block text-xs font-bold text-text-muted mb-1.5">Confirmar nueva contrasena</label>
                <input type="password" className="input" placeholder="Repite la nueva contrasena"
                  value={pwdForm.confirm} onChange={e=>setPwdForm(p=>({...p,confirm:e.target.value}))}/>
                {pwdForm.new && pwdForm.confirm && pwdForm.new !== pwdForm.confirm && (
                  <p className="text-red-500 text-xs mt-1">Las contrasenas no coinciden</p>
                )}
              </div>
              <button onClick={handlePassword}
                disabled={savingPwd || !pwdForm.current || !pwdForm.new || pwdForm.new !== pwdForm.confirm}
                className="btn-primary w-full flex items-center justify-center gap-2 h-11 disabled:opacity-40">
                {savingPwd?<Loader2 className="w-4 h-4 animate-spin"/>:<CheckCircle className="w-4 h-4"/>}
                {savingPwd?"Guardando...":"Actualizar contrasena"}
              </button>
            </div>
          )}
        </div>
      </div>
    </AppShell>
  );
}