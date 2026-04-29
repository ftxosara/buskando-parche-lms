﻿﻿"use client";
import { useEffect, useState } from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { useAuth } from "@/contexts/AuthContext";
import { BookOpen, Lock, Users, PlayCircle, Search, CheckCircle, Loader2 } from "lucide-react";
import Link from "next/link";
import clsx from "clsx";
const IMGS: Record<string,string> = {
  "Ingles": "/images/ingles.jpg",
  "Gestion Empresarial": "/images/gestion.jpg",
  "Gestion Turistica": "/images/turismo.jpg",
  "Marketing Digital": "/images/marketing.jpg",
};
const COLORS = ["#C0392B","#2563EB","#16A34A","#D97706"];
export default function LobbyPage() {
  const { user } = useAuth();
  const [courses, setCourses] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  useEffect(() => { api.get("/courses/lobby").then(({ data }) => setCourses(data)).finally(() => setLoading(false)); }, []);
  const filtered = courses.filter((c: any) => c.title.toLowerCase().includes(search.toLowerCase()));
  const enrolled = filtered.filter((c: any) => c.isEnrolled);
  const locked = filtered.filter((c: any) => !c.isEnrolled);
  return (
    <AppShell allowedRoles={["BENEFICIARIO"]}>
      <div className="max-w-5xl mx-auto space-y-8">
        <div>
          <h1 className="font-display text-3xl font-bold text-text-primary">Hola, <span className="text-primary">{user?.firstName}</span></h1>
          <p className="text-text-secondary mt-1">Bienvenido a tu espacio de aprendizaje en Buskando Parche.</p>
        </div>
        <div className="relative max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
          <input className="input pl-10" placeholder="Buscar cursos..." value={search} onChange={(e) => setSearch(e.target.value)} />
        </div>
        {loading ? (
          <div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div>
        ) : (
          <>
            {enrolled.length > 0 && (
              <section>
                <div className="flex items-center gap-2 mb-5">
                  <div className="w-1 h-6 bg-primary rounded-full" />
                  <h2 className="text-xl font-bold text-text-primary">Mis Cursos</h2>
                  <span className="badge-primary ml-1">{enrolled.length}</span>
                </div>
                <div className="grid md:grid-cols-2 gap-5">
                  {enrolled.map((c: any, i: number) => (
                    <div key={c.id} className="card overflow-hidden p-0 hover:shadow-lg transition-shadow group">
                      <div className="relative h-44 overflow-hidden" style={{ background: COLORS[i % 4] }}>
                        <img
                          src={IMGS[c.title] || "/images/marketing.jpg"}
                          alt={c.title}
                          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                          onError={(e) => { (e.target as HTMLImageElement).style.display = "none"; }}
                        />
                        <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
                        <div className="absolute top-3 left-3">
                          <span className="badge-success"><CheckCircle className="w-3 h-3" /> Inscrito</span>
                        </div>
                        <div className="absolute top-3 right-3">
                          <span className={clsx("badge", c.modality === "VIRTUAL" ? "bg-blue-100 text-blue-700" : "bg-green-100 text-green-700")}>
                            {c.modality === "VIRTUAL" ? "Virtual" : "Presencial"}
                          </span>
                        </div>
                      </div>
                      <div className="p-5">
                        <h3 className="font-bold text-lg text-text-primary mb-1">{c.title}</h3>
                        <p className="text-text-muted text-sm line-clamp-2 mb-4">{c.description}</p>
                        <div className="flex items-center gap-4 text-xs text-text-muted mb-4">
                          <span className="flex items-center gap-1"><PlayCircle className="w-4 h-4" /> {c.totalSessions} sesiones</span>
                          <span className="flex items-center gap-1"><Users className="w-4 h-4" /> {c.totalEnrolled} inscritos</span>
                        </div>
                        <Link href={"/courses/" + c.id} className="btn-primary w-full text-center block py-2.5 text-sm">
                          Acceder al curso
                        </Link>
                      </div>
                    </div>
                  ))}
                </div>
              </section>
            )}
            {locked.length > 0 && (
              <section>
                <div className="flex items-center gap-2 mb-4">
                  <div className="w-1 h-6 bg-gray-300 rounded-full" />
                  <h2 className="text-xl font-bold text-text-primary">Otros programas</h2>
                  <span className="badge-muted">{locked.length}</span>
                </div>
                <div className="grid md:grid-cols-2 gap-5">
                  {locked.map((c: any, i: number) => (
                    <div key={c.id} className="card overflow-hidden p-0 opacity-60 cursor-not-allowed">
                      <div className="relative h-44 bg-gray-200">
                        <img src={IMGS[c.title] || "/images/marketing.jpg"} alt={c.title} className="w-full h-full object-cover grayscale"
                          onError={(e) => { (e.target as HTMLImageElement).style.display = "none"; }} />
                        <div className="absolute inset-0 bg-gray-900/50 flex items-center justify-center">
                          <div className="bg-white/90 rounded-full p-3"><Lock className="w-6 h-6 text-gray-500" /></div>
                        </div>
                      </div>
                      <div className="p-5">
                        <h3 className="font-bold text-lg text-gray-500 mb-1">{c.title}</h3>
                        <div className="bg-gray-100 rounded-lg px-4 py-2.5 text-center text-sm text-gray-500 flex items-center justify-center gap-2">
                          <Lock className="w-4 h-4" /> Solo para participantes asignados
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </section>
            )}
          </>
        )}
      </div>
    </AppShell>
  );
}