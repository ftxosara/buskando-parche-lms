"use client";
import { useAuth } from "@/contexts/AuthContext";
import { useRouter } from "next/navigation";
import { useEffect } from "react";
import Sidebar from "./Sidebar";
import { Loader2 } from "lucide-react";
export default function AppShell({ children, allowedRoles }: { children: React.ReactNode; allowedRoles: string[] }) {
  const { user, isLoading } = useAuth();
  const router = useRouter();
  useEffect(() => {
    if (!isLoading && !user) router.push("/login");
    if (!isLoading && user && !allowedRoles.includes(user.role)) router.push("/login");
  }, [user, isLoading]);
  if (isLoading) return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <Loader2 className="w-8 h-8 text-primary animate-spin" />
    </div>
  );
  return (
    <div className="flex min-h-screen bg-gray-50 relative overflow-hidden">
      {/* Logo traslucido de fondo - no afecta el contenido */}
      <div className="fixed inset-0 pointer-events-none z-0 flex items-center justify-center" style={{ left: "256px" }}>
        <img
          src="/images/logo.png"
          alt=""
          className="w-96 h-96 object-contain select-none"
          style={{ opacity: 0.03, filter: "grayscale(100%)" }}
        />
      </div>
      <Sidebar />
      <main className="flex-1 overflow-y-auto animate-fade-in relative z-10">
        <div className="bg-white border-b border-gray-200 px-8 py-4 flex items-center justify-between shadow-sm">
          <div className="flex items-center gap-3">
            <img src="/images/logo.png" alt="Buskando Parche" className="h-8 w-auto object-contain"
              onError={(e) => { (e.target as HTMLImageElement).style.display = "none"; }} />
            <span className="font-display font-bold text-primary text-xl">Buskando <span className="text-secondary">Parche</span></span>
          </div>
          <span className="text-sm text-text-muted">Programa de Formacion - Kennedy, Bogota</span>
        </div>
        <div className="p-8">{children}</div>
      </main>
    </div>
  );
}