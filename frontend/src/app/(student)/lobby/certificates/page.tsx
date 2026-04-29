"use client";
import {useEffect,useState} from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import {GraduationCap,Download,Lock,Loader2,CheckCircle} from "lucide-react";
import clsx from "clsx";
export default function CertificatesPage() {
  const [courses,setCourses]=useState<any[]>([]); const [loading,setLoading]=useState(true);
  useEffect(()=>{ api.get("/courses/lobby").then(({data})=>setCourses(data)).finally(()=>setLoading(false)); },[]);
  const handleDownload=async(courseId:string)=>{
    try {
      const res=await api.get("/certificates/"+courseId,{responseType:"blob"});
      const url=window.URL.createObjectURL(new Blob([res.data]));
      const a=document.createElement("a"); a.href=url; a.download="certificado.pdf"; a.click();
    } catch(e:any) {
      const msg=e.response?.data?.error||"Error al descargar";
      alert(msg);
    }
  };
  return (
    <AppShell allowedRoles={["BENEFICIARIO"]}>
      <div className="max-w-3xl mx-auto space-y-6">
        <div><h1 className="font-display text-3xl font-bold text-text-primary">Mis Certificados</h1>
          <p className="text-text-secondary mt-1">Descarga tus certificados al completar cada curso.</p>
        </div>
        {loading?<div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin"/></div>:(
          <div className="space-y-4">
            {courses.filter((c:any)=>c.isEnrolled).map((c:any)=>(
              <div key={c.id} className="card flex items-center gap-5">
                <div className={clsx("p-4 rounded-xl flex-shrink-0",c.enrollmentStatus==="COMPLETADO"?"bg-green-100":"bg-gray-100")}>
                  <GraduationCap className={clsx("w-8 h-8",c.enrollmentStatus==="COMPLETADO"?"text-green-600":"text-gray-400")}/>
                </div>
                <div className="flex-1">
                  <h3 className="font-bold text-text-primary">{c.title}</h3>
                  <p className="text-sm text-text-muted mt-0.5">
                    {c.enrollmentStatus==="COMPLETADO"
                      ?"Curso completado - Certificado disponible"
                      :"Completa el curso para habilitar el certificado"}
                  </p>
                  {c.enrollmentStatus==="COMPLETADO"&&(
                    <span className="badge-success mt-2 inline-flex"><CheckCircle className="w-3 h-3"/> Completado</span>
                  )}
                </div>
                {c.enrollmentStatus==="COMPLETADO"?(
                  <button onClick={()=>handleDownload(c.id)} className="btn-primary flex items-center gap-2 flex-shrink-0">
                    <Download className="w-4 h-4"/> Descargar PDF
                  </button>
                ):(
                  <div className="flex items-center gap-2 text-gray-400 flex-shrink-0 text-sm">
                    <Lock className="w-4 h-4"/> Bloqueado
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </AppShell>
  );
}