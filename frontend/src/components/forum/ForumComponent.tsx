"use client";
import { useEffect, useState } from "react";
import api from "@/lib/api";
import { useAuth } from "@/contexts/AuthContext";
import { MessageSquare, Send, Plus, ChevronDown, ChevronRight, Loader2, Pin } from "lucide-react";
import clsx from "clsx";

export default function ForumComponent({ courseId, courseTitle }: { courseId: string; courseTitle: string }) {
  const { user } = useAuth();
  const [posts, setPosts] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [expanded, setExpanded] = useState<string | null>(null);
  const [newPost, setNewPost] = useState({ title: "", body: "" });
  const [replyBody, setReplyBody] = useState<Record<string, string>>({});
  const [posting, setPosting] = useState(false);

  const load = () => {
    setLoading(true);
    api.get("/forum/course/" + courseId).then(({ data }) => setPosts(data)).finally(() => setLoading(false));
  };
  useEffect(() => { load(); }, [courseId]);

  const submitPost = async () => {
    if (!newPost.title.trim()) return;
    setPosting(true);
    await api.post("/forum", { courseId, ...newPost });
    setNewPost({ title: "", body: "" });
    load();
    setPosting(false);
  };
  const submitReply = async (postId: string) => {
    if (!replyBody[postId]?.trim()) return;
    await api.post("/forum/" + postId + "/replies", { body: replyBody[postId] });
    setReplyBody((p) => ({ ...p, [postId]: "" }));
    load();
  };

  const roleBadge = (r: string) => r === "ADMIN" ? "badge-primary" : r === "FORMADOR" ? "badge-secondary" : "badge-muted";
  const roleLabel = (r: string) => r === "ADMIN" ? "Admin" : r === "FORMADOR" ? "Formador" : "Estudiante";

  return (
    <div className="space-y-5">
      <div className="card">
        <p className="font-bold text-text-primary mb-3 flex items-center gap-2"><Plus className="w-4 h-4 text-primary" /> Nueva publicacion</p>
        <input className="input mb-2 text-sm" placeholder="Titulo..." value={newPost.title} onChange={(e) => setNewPost((p) => ({ ...p, title: e.target.value }))} />
        <textarea className="input resize-none mb-3 text-sm" rows={3} placeholder="Escribe tu mensaje..." value={newPost.body} onChange={(e) => setNewPost((p) => ({ ...p, body: e.target.value }))} />
        <button onClick={submitPost} disabled={posting || !newPost.title.trim()} className="btn-primary flex items-center gap-2 text-sm disabled:opacity-40">
          {posting ? <Loader2 className="w-4 h-4 animate-spin" /> : <Send className="w-4 h-4" />} Publicar
        </button>
      </div>
      {loading ? <div className="flex justify-center py-8"><Loader2 className="w-6 h-6 text-primary animate-spin" /></div> : (
        <div className="space-y-3">
          {posts.length === 0 && (
            <div className="card text-center py-10"><MessageSquare className="w-10 h-10 text-gray-200 mx-auto mb-3" /><p className="text-text-muted text-sm">Sin publicaciones aun. Se el primero en participar.</p></div>
          )}
          {posts.map((p: any) => (
            <div key={p.id} className="card p-0 overflow-hidden">
              <button onClick={() => setExpanded((prev) => prev === p.id ? null : p.id)}
                className="w-full text-left p-4 hover:bg-gray-50 transition-colors flex items-start gap-3">
                {p.isPinned && <Pin className="w-4 h-4 text-primary flex-shrink-0 mt-0.5" />}
                <div className="flex-1 min-w-0">
                  <div className="flex items-start justify-between gap-2">
                    <p className="font-semibold text-text-primary text-sm">{p.title}</p>
                    <span className={clsx("badge text-xs flex-shrink-0", roleBadge(p.author?.role))}>{roleLabel(p.author?.role)}</span>
                  </div>
                  <p className="text-text-secondary text-xs mt-1 line-clamp-2">{p.body}</p>
                  <div className="flex items-center gap-3 mt-2 text-xs text-text-muted">
                    <span>{p.author?.firstName} {p.author?.lastName}</span>
                    <span>{new Date(p.createdAt).toLocaleDateString("es-CO")}</span>
                    <span className="flex items-center gap-1"><MessageSquare className="w-3 h-3" /> {p.replies?.length || 0}</span>
                  </div>
                </div>
                {expanded === p.id ? <ChevronDown className="w-4 h-4 text-text-muted flex-shrink-0 mt-1" /> : <ChevronRight className="w-4 h-4 text-text-muted flex-shrink-0 mt-1" />}
              </button>
              {expanded === p.id && (
                <div className="border-t border-gray-100 bg-gray-50 p-4 space-y-3">
                  <div className="bg-white rounded-xl p-3 border border-gray-100 text-sm text-text-secondary">{p.body}</div>
                  {p.replies?.map((r: any) => (
                    <div key={r.id} className="bg-white rounded-xl p-3 border border-gray-100 ml-4">
                      <div className="flex items-center gap-2 mb-1">
                        <span className="font-medium text-xs text-text-primary">{r.author?.firstName} {r.author?.lastName}</span>
                        <span className={clsx("badge text-xs", roleBadge(r.author?.role))}>{roleLabel(r.author?.role)}</span>
                        <span className="text-xs text-text-muted ml-auto">{new Date(r.createdAt).toLocaleDateString("es-CO")}</span>
                      </div>
                      <p className="text-xs text-text-secondary">{r.body}</p>
                    </div>
                  ))}
                  <div className="flex gap-2 mt-2">
                    <input className="input text-sm flex-1" placeholder="Responder..."
                      value={replyBody[p.id] || ""} onChange={(e) => setReplyBody((prev) => ({ ...prev, [p.id]: e.target.value }))}
                      onKeyDown={(e) => e.key === "Enter" && submitReply(p.id)} />
                    <button onClick={() => submitReply(p.id)} className="btn-primary px-4 py-2 text-sm"><Send className="w-4 h-4" /></button>
                  </div>
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}