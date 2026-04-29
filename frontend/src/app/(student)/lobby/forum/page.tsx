"use client";
import { useEffect, useState } from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import ForumComponent from "@/components/forum/ForumComponent";
import { Loader2, MessageSquare } from "lucide-react";
export default function BenForumPage() {
  const [courses, setCourses] = useState<any[]>([]);
  const [selCourse, setSelCourse] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    api.get("/courses/lobby").then(({ data }) => {
      const enrolled = data.filter((c: any) => c.isEnrolled);
      setCourses(enrolled);
      if (enrolled.length > 0) setSelCourse(enrolled[0]);
    }).finally(() => setLoading(false));
  }, []);
  return (
    <AppShell allowedRoles={["BENEFICIARIO"]}>
      <div className="max-w-3xl mx-auto space-y-6">
        <div><h1 className="font-display text-2xl font-bold text-text-primary">Foro del curso</h1><p className="text-text-secondary mt-1">Participa y comparte con tus compaÃ±eros y formador.</p></div>
        {loading ? <div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div> : (
          <>
            {courses.length > 1 && (
              <div className="flex gap-2 flex-wrap">
                {courses.map((c: any) => (
                  <button key={c.id} onClick={() => setSelCourse(c)}
                    className={`px-4 py-2 rounded-full text-sm font-medium transition-colors ${selCourse?.id === c.id ? "bg-primary text-white" : "bg-gray-100 text-text-secondary hover:bg-gray-200"}`}>
                    {c.title}
                  </button>
                ))}
              </div>
            )}
            {selCourse ? <ForumComponent courseId={selCourse.id} courseTitle={selCourse.title} /> : (
              <div className="card text-center py-12"><MessageSquare className="w-10 h-10 text-gray-200 mx-auto mb-3" /><p className="text-text-muted">No tienes cursos inscritos aun.</p></div>
            )}
          </>
        )}
      </div>
    </AppShell>
  );
}