"use client";
import { useEffect, useState, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import ForumComponent from "@/components/forum/ForumComponent";
import { Loader2, MessageSquare } from "lucide-react";
function FormadorForumContent() {
  const params = useSearchParams();
  const courseId = params.get("courseId");
  const [course, setCourse] = useState<any>(null);
  useEffect(() => { if (courseId) api.get("/courses/" + courseId).then(({ data }) => setCourse(data)); }, [courseId]);
  if (!courseId) return (
    <div className="card text-center py-12"><MessageSquare className="w-10 h-10 text-gray-300 mx-auto mb-3" /><p className="text-text-muted">Accede desde el panel del formador.</p></div>
  );
  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <div><h1 className="font-display text-2xl font-bold text-text-primary">Foro del curso</h1><p className="text-text-secondary mt-1">{course?.title}</p></div>
      {course && <ForumComponent courseId={courseId} courseTitle={course.title} />}
    </div>
  );
}
export default function FormadorForumPage() {
  return (
    <AppShell allowedRoles={["FORMADOR","ADMIN"]}>
      <Suspense fallback={<div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div>}>
        <FormadorForumContent />
      </Suspense>
    </AppShell>
  );
}