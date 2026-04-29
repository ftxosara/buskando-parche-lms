"use client";
import { useEffect, useState } from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import ForumComponent from "@/components/forum/ForumComponent";
import { Loader2, MessageSquare } from "lucide-react";
export default function AdminForumPage() {
  const [courses, setCourses] = useState<any[]>([]);
  const [selCourse, setSelCourse] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    api.get("/courses/lobby").then(({ data }) => {
      setCourses(data);
      if (data.length > 0) setSelCourse(data[0]);
    }).finally(() => setLoading(false));
  }, []);
  return (
    <AppShell allowedRoles={["ADMIN"]}>
      <div className="max-w-4xl mx-auto space-y-6">
        <div><h1 className="font-display text-2xl font-bold text-text-primary">Foro general</h1><p className="text-text-secondary mt-1">Modera y participa en los foros de cada curso.</p></div>
        {loading ? <div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div> : (
          <>
            <div className="flex gap-2 flex-wrap">
              {courses.map((c: any) => (
                <button key={c.id} onClick={() => setSelCourse(c)}
                  className={`px-4 py-2 rounded-full text-sm font-medium transition-colors ${selCourse?.id === c.id ? "bg-primary text-white" : "bg-gray-100 text-text-secondary hover:bg-gray-200"}`}>
                  {c.title}
                </button>
              ))}
            </div>
            {selCourse && <ForumComponent courseId={selCourse.id} courseTitle={selCourse.title} />}
          </>
        )}
      </div>
    </AppShell>
  );
}