﻿﻿﻿"use client";
import { useEffect, useState } from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { BookOpen, ClipboardList, Lock, Star, Loader2 } from "lucide-react";
import Link from "next/link";
import { useAuth } from "@/contexts/AuthContext";
import clsx from "clsx";
export default function FormadorPanel() {
  const { user } = useAuth();
  const [courses, setCourses] = useState<any[]>([]); const [loading, setLoading] = useState(true);
  useEffect(() => { api.get("/courses/lobby").then(({ data }) => setCourses(data)).finally(() => setLoading(false)); }, []);
  const myCourse = courses.find((c: any) => c.isMyCourseFomador);
  const otherCourses = courses.filter((c: any) => !c.isMyCourseFomador);
  return (
    <AppShell allowedRoles={["FORMADOR"]}>
      <div className="max-w-4xl mx-auto space-y-8">
        <div><h1 className="font-display text-3xl font-bold text-text-primary">Bienvenido, {user?.firstName}</h1><p className="text-text-secondary mt-1">Panel del formador - gestiona tu curso asignado.</p></div>
        {loading ? <div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div> : (
          <>
            {myCourse && (
              <div>
                <div className="flex items-center gap-2 mb-4"><div className="w-1 h-6 bg-primary rounded-full" /><h2 className="text-lg font-bold text-text-primary">Mi curso asignado</h2></div>
                <div className="card border-l-4 border-l-primary">
                  <div className="flex items-start gap-4 mb-4">
                    <div className="p-3 bg-red-50 rounded-xl"><BookOpen className="w-7 h-7 text-primary" /></div>
                    <div><h3 className="font-bold text-xl text-text-primary">{myCourse.title}</h3><p className="text-text-muted text-sm mt-1">{myCourse.modality === "VIRTUAL" ? "Virtual" : "Presencial"} - {myCourse.totalSessions} sesiones - {myCourse.totalEnrolled} estudiantes</p></div>
                  </div>
                  <div className="grid grid-cols-3 gap-3">
                    <Link href={"/formador/courses?id=" + myCourse.id} className="btn-primary flex items-center justify-center gap-2 py-2.5 text-sm"><BookOpen className="w-4 h-4" /> Contenido</Link>
                    <Link href={"/formador/attendance?courseId=" + myCourse.id} className="btn-outline flex items-center justify-center gap-2 py-2.5 text-sm"><ClipboardList className="w-4 h-4" /> Asistencia</Link>
                    <Link href={"/formador/grades?courseId=" + myCourse.id} className="btn-ghost flex items-center justify-center gap-2 py-2.5 text-sm border border-gray-200 rounded-lg"><Star className="w-4 h-4" /> Calificaciones</Link>
                  </div>
                </div>
              </div>
            )}
            {!myCourse && <div className="card text-center py-12"><BookOpen className="w-12 h-12 text-gray-300 mx-auto mb-3" /><p className="text-text-muted">No tienes un curso asignado. Contacta al administrador.</p></div>}
            {otherCourses.length > 0 && (
              <div>
                <div className="flex items-center gap-2 mb-4"><div className="w-1 h-6 bg-gray-300 rounded-full" /><h2 className="text-lg font-bold text-text-primary">Otros cursos</h2><span className="badge-muted">{otherCourses.length} bloqueados</span></div>
                <div className="grid md:grid-cols-3 gap-4">
                  {otherCourses.map((c: any) => (
                    <div key={c.id} className="card opacity-50 cursor-not-allowed relative overflow-hidden">
                      <div className="absolute inset-0 flex items-center justify-center bg-gray-50/80"><div className="flex flex-col items-center gap-2"><Lock className="w-8 h-8 text-gray-400" /><p className="text-xs text-gray-500 font-medium">Acceso restringido</p></div></div>
                      <div className="p-3 bg-gray-100 rounded-xl w-fit mb-3"><BookOpen className="w-5 h-5 text-gray-400" /></div>
                      <h3 className="font-semibold text-gray-400">{c.title}</h3>
                      <p className="text-xs text-gray-400 mt-1">{c.formador}</p>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </>
        )}
      </div>
    </AppShell>
  );
}