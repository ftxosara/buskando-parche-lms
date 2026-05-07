Write-Host "=== FIX LIMPIO FORMADOR COURSES ===" -ForegroundColor Yellow

$path = "$PWD\frontend\src\app\(dashboard)\formador\courses\page.tsx"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

# Leer el archivo original (debe tener 330 lineas)
$content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
$lineCount = ($content -split "`n").Count
Write-Host "Lineas actuales: $lineCount" -ForegroundColor Cyan

# Solo proceder si es el archivo original (330 lineas aprox)
# Agregar Suspense al import si no existe
if ($content -notmatch "Suspense") {
    $content = $content -replace 'import React, \{ useEffect, useState \}', 'import React, { useEffect, useState, Suspense }'
    if ($content -notmatch "Suspense") {
        $content = $content -replace 'import \{ useEffect, useState \}', 'import { useEffect, useState, Suspense }'
    }
    Write-Host "Suspense agregado al import" -ForegroundColor Green
}

# Las 3 funciones a agregar
$funcs = @'

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

# Insertar las funciones antes del primer "return (" del componente
if ($content -notmatch "deleteSession") {
    $content = $content -replace '(  return \(\r?\n    <AppShell)', "$funcs`$1"
    Write-Host "Funciones insertadas" -ForegroundColor Green
} else {
    Write-Host "Funciones ya existen" -ForegroundColor Yellow
}

# Agregar boton subir archivo junto al boton de Material/Enlace en la UI
# Buscar el tab de Material y agregar boton azul despues
if ($content -notmatch "Subir archivo") {
    $content = $content -replace '(Material / Enlace</button>)', @'
$1
                        <button onClick={() => uploadFile(s.id)} className="flex items-center gap-1.5 px-3 py-2 rounded-xl text-xs font-semibold bg-blue-100 text-blue-700 border border-blue-200 hover:bg-blue-200 transition-colors">
                          <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                          Subir archivo
                        </button>
'@
    Write-Host "Boton subir archivo agregado" -ForegroundColor Green
}

# Agregar botones eliminar sesion junto al chevron
if ($content -notmatch "deleteSession\(s\.id\)") {
    $content = $content -replace '(<ChevronRight className="w-4 h-4 text-text-muted" />)', @'
<button onClick={(e) => { e.stopPropagation(); deleteSession(s.id); }} className="p-1 rounded hover:bg-red-100 text-red-400 hover:text-red-600 transition-colors">
                          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/></svg>
                        </button>
                        $1
'@
    Write-Host "Boton eliminar sesion agregado" -ForegroundColor Green
}

# Agregar boton eliminar recurso junto al "Ver"
if ($content -notmatch "deleteResource\(r\.id\)") {
    $content = $content -replace '(<a href=\{r\.url\}[^>]+>Ver</a>)', @'
$1
                          <button onClick={() => deleteResource(r.id)} className="ml-1 p-0.5 text-red-400 hover:text-red-600">
                            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                          </button>
'@
    Write-Host "Boton eliminar recurso agregado" -ForegroundColor Green
}

# Wrap con Suspense si no existe
if ($content -notmatch "FormadorCoursesPageInner") {
    $content = $content -replace 'export default function FormadorCoursesPage\b', 'function FormadorCoursesPageInner'
    $content = $content.TrimEnd()
    $content += @'


export default function FormadorCoursesPage() {
  return (
    <Suspense fallback={<div className="flex justify-center py-20"><div className="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin"/></div>}>
      <FormadorCoursesPageInner />
    </Suspense>
  );
}
'@
    Write-Host "Suspense wrapper agregado" -ForegroundColor Green
}

[System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
$newCount = ($content -split "`n").Count
Write-Host "Archivo guardado: $newCount lineas" -ForegroundColor Green

Write-Host ""
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host "LISTO - Ahora:" -ForegroundColor Cyan
Write-Host "1. GitHub Desktop -> Commit 'Fix formador limpio' -> Push" -ForegroundColor White
Write-Host "2. VPS: git checkout frontend/src/app/(dashboard)/formador/courses/page.tsx" -ForegroundColor White  
Write-Host "        git pull" -ForegroundColor White
Write-Host "        docker compose -f docker-compose.prod.yml --env-file .env up -d --build" -ForegroundColor White
