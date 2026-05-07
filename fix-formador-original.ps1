Write-Host "=== FIX FORMADOR: EDITAR/ELIMINAR/SUBIR ARCHIVO ===" -ForegroundColor Yellow

# Lee el archivo original
$path = "$PWD\frontend\src\app\(dashboard)\formador\courses\page.tsx"
$content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

# ── 1. Agregar funciones deleteSession, deleteResource, uploadFile ──
$newFunctions = @'

  const deleteSession = async (sessionId: string) => {
    if (!confirm("Eliminar esta sesion y todo su contenido?")) return;
    try {
      await api.delete("/sessions/" + sessionId);
      const res = await api.get("/courses/lobby");
      const updated = res.data.find((c: any) => c.id === courseId);
      if (updated) setCourse(updated);
    } catch { alert("Error al eliminar la sesion"); }
  };

  const deleteResource = async (resourceId: string) => {
    if (!confirm("Eliminar este recurso?")) return;
    try {
      await api.delete("/sessions/resource/" + resourceId);
      const res = await api.get("/courses/lobby");
      const updated = res.data.find((c: any) => c.id === courseId);
      if (updated) setCourse(updated);
    } catch { alert("Error al eliminar el recurso"); }
  };

  const uploadFile = (sessionId: string) => {
    const input = document.createElement("input");
    input.type = "file";
    input.accept = ".pdf,.doc,.docx,.ppt,.pptx,.xls,.xlsx,.mp4,.jpg,.png,.zip";
    input.onchange = async (e: any) => {
      const file = e.target.files[0];
      if (!file) return;
      const title = window.prompt("Nombre del material:", file.name) || file.name;
      const fd = new FormData();
      fd.append("file", file);
      fd.append("title", title);
      try {
        await api.post("/sessions/" + sessionId + "/resources/file", fd, { headers: { "Content-Type": "multipart/form-data" } });
        const res = await api.get("/courses/lobby");
        const updated = res.data.find((c: any) => c.id === courseId);
        if (updated) setCourse(updated);
        alert("Archivo subido correctamente");
      } catch { alert("Error al subir el archivo"); }
    };
    input.click();
  };

'@

# Insertar funciones antes de "const addResource"
$content = $content -replace '(  const addResource)', "$newFunctions`$1"

# ── 2. Agregar boton eliminar sesion en el header ──
# Buscar el patron del titulo de sesion y agregar boton eliminar
$content = $content -replace '(<p className="font-semibold text-text-primary">\{s\.title\}</p>)', @'
<div className="flex items-center gap-2">
                    $1
                    <button onClick={(e)=>{e.stopPropagation();deleteSession(s.id);}} className="p-1 rounded hover:bg-red-100 text-red-400 hover:text-red-600 transition-colors" title="Eliminar sesion"><svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/></svg></button>
                  </div>
'@

# ── 3. Agregar botones editar URL y eliminar recurso junto al "Ver" ──
$content = $content -replace '(<a href=\{r\.url\} target="_blank" rel="noopener noreferrer"\s+className="text-primary text-xs hover:underline">Ver</a>)', @'
{r.url && r.url !== "#" ? ($1) : <span className="text-gray-300 text-xs">Sin URL</span>}
                          <button onClick={()=>{const u=window.prompt("Nueva URL:",r.url==="#"?"":r.url);if(u!==null)api.put("/sessions/resource/"+r.id,{title:r.title,description:r.description,url:u,type:r.type}).then(()=>{api.get("/courses/lobby").then(({data})=>{const up=data.find((c:any)=>c.id===courseId);if(up)setCourse(up);});});}} className="ml-1 text-blue-400 hover:text-blue-600" title="Editar URL"><svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg></button>
                          <button onClick={()=>deleteResource(r.id)} className="ml-1 text-red-400 hover:text-red-600" title="Eliminar"><svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg></button>
'@

# ── 4. Agregar boton "Subir archivo" junto a los tabs ──
$content = $content -replace '(AGREGAR A ESTA SESION</p>)', @'
$1
                  <button onClick={()=>uploadFile(s.id)} className="mt-2 mb-1 flex items-center gap-1.5 px-3 py-1.5 bg-blue-50 text-blue-700 border border-blue-200 rounded-xl text-xs font-semibold hover:bg-blue-100 transition-colors"><svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg> Subir archivo (PDF/Word/PPT)</button>
'@

[System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
Write-Host "OK - formador courses actualizado" -ForegroundColor Green

Write-Host ""
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host "AHORA:" -ForegroundColor Cyan
Write-Host "1. GitHub Desktop -> Commit 'Fix formador editar subir' -> Push" -ForegroundColor White
Write-Host "2. VPS:" -ForegroundColor White
Write-Host "   cd /home/proyectos/buskandoparche-LMS" -ForegroundColor White
Write-Host "   git checkout backend/src/routes/sessions.js" -ForegroundColor White
Write-Host "   git pull" -ForegroundColor White
Write-Host "   docker compose -f docker-compose.prod.yml --env-file .env up -d --build" -ForegroundColor White
