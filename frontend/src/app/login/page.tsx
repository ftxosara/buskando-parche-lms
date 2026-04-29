"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/contexts/AuthContext";
import toast from "react-hot-toast";
import { Lock, Mail, Loader2, CheckCircle, AlertCircle } from "lucide-react";
export default function LoginPage() {
  const { login } = useAuth(); const router = useRouter();
  const [email, setEmail] = useState(""); const [password, setPassword] = useState(""); const [loading, setLoading] = useState(false);
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault(); setLoading(true);
    try {
      await login(email, password);
      const payload = JSON.parse(atob(localStorage.getItem("bp_token")!.split(".")[1]));
      toast.custom((t) => (
        <div className={"flex items-center gap-3 bg-white border border-green-200 rounded-2xl shadow-xl px-5 py-4 " + (t.visible ? "animate-slide-up" : "opacity-0")}>
          <div className="bg-green-100 p-2 rounded-full"><CheckCircle className="w-5 h-5 text-green-600" /></div>
          <div><p className="font-semibold text-text-primary text-sm">Ingreso exitoso</p><p className="text-text-muted text-xs">Bienvenido a Buskando Parche</p></div>
        </div>
      ), { duration: 2000 });
      setTimeout(() => {
        if (payload.role === "ADMIN") router.push("/admin");
        else if (payload.role === "FORMADOR") router.push("/formador");
        else router.push("/lobby");
      }, 800);
    } catch {
      toast.custom((t) => (
        <div className={"flex items-center gap-3 bg-white border border-red-200 rounded-2xl shadow-xl px-5 py-4 " + (t.visible ? "animate-slide-up" : "opacity-0")}>
          <div className="bg-red-100 p-2 rounded-full"><AlertCircle className="w-5 h-5 text-red-600" /></div>
          <div><p className="font-semibold text-text-primary text-sm">Credenciales incorrectas</p><p className="text-text-muted text-xs">Verifica tu email y contrasena</p></div>
        </div>
      ), { duration: 4000 });
    } finally { setLoading(false); }
  };
  return (
    <div className="min-h-screen flex items-center justify-center relative overflow-hidden">
      <video autoPlay muted loop playsInline className="absolute inset-0 w-full h-full object-cover z-0">
        <source src="/videos/kennedy.mp4" type="video/mp4" />
      </video>
      <div className="absolute inset-0 bg-black/60 z-10" />
      <div className="relative z-20 w-full max-w-md px-6 animate-slide-up">
        <div className="flex flex-col items-center mb-8">
          <div className="bg-white rounded-2xl p-4 shadow-2xl mb-4">
            <img src="/images/logo.png" alt="Buskando Parche" className="h-20 w-auto object-contain" onError={(e) => { (e.target as HTMLImageElement).style.display = "none"; }} />
          </div>
          <h1 className="font-display text-3xl font-bold text-white text-center">Buskando <span className="text-secondary">Parche</span></h1>
          <p className="text-white/80 text-sm mt-1 text-center">Plataforma de Formacion - Kennedy, Bogota</p>
        </div>
        <div className="bg-white rounded-2xl shadow-2xl p-8">
          <h2 className="text-xl font-bold text-text-primary mb-1">Iniciar sesion</h2>
          <p className="text-text-muted text-sm mb-6">Ingresa con tus credenciales asignadas</p>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-text-secondary mb-1.5">Correo electronico</label>
              <div className="relative"><Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input type="email" className="input pl-10" placeholder="tu@correo.com" value={email} onChange={(e) => setEmail(e.target.value)} required />
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-text-secondary mb-1.5">Contrasena</label>
              <div className="relative"><Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input type="password" className="input pl-10" placeholder="..." value={password} onChange={(e) => setPassword(e.target.value)} required />
              </div>
            </div>
            <button type="submit" disabled={loading} className="btn-primary w-full flex items-center justify-center gap-2 mt-2">
              {loading && <Loader2 className="w-5 h-5 animate-spin" />}
              {loading ? "Verificando..." : "Ingresar a la plataforma"}
            </button>
          </form>
          <p className="text-center text-text-muted text-xs mt-4">Problemas? Contacta al coordinador.</p>
        </div>
        <div className="flex items-center justify-center gap-6 mt-6">
          <img src="/images/logo-kennedy.png" alt="Kennedy" className="h-8 w-auto opacity-70" onError={(e) => { (e.target as HTMLImageElement).style.display = "none"; }} />
          <img src="/images/logo-bogota.png" alt="Bogota" className="h-8 w-auto opacity-70" onError={(e) => { (e.target as HTMLImageElement).style.display = "none"; }} />
        </div>
      </div>
    </div>
  );
}