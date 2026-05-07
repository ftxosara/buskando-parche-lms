Write-Host "=== FIX ICONOS RECURSOS ===" -ForegroundColor Yellow

$path = "$PWD\frontend\src\app\(dashboard)\formador\courses\page.tsx"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)

# Reemplazar el boton eliminar con icono SVG correcto y agregar editar URL
$oldBtn = '<button onClick={() => deleteResource(r.id)}
                            className="ml-2 text-red-400 hover:text-red-600 text-xs" title="Eliminar">✕</button>'

$newBtns = @'
<button onClick={() => {
                            const newUrl = window.prompt("Nueva URL para: " + r.title, r.url === "#" ? "" : r.url);
                            if (newUrl !== null) {
                              api.put("/sessions/resource/" + r.id, { title: r.title, url: newUrl, type: r.type })
                                .then(() => api.get("/courses/" + courseId).then(({data}) => setCourse(data)))
                                .catch(() => alert("Error al actualizar"));
                            }
                          }} className="ml-1 text-blue-400 hover:text-blue-600" title="Editar URL">
                            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                          </button>
                          <button onClick={() => deleteResource(r.id)} className="ml-1 text-red-400 hover:text-red-600" title="Eliminar">
                            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg>
                          </button>
'@

if ($content -match [regex]::Escape($oldBtn)) {
  $content = $content.Replace($oldBtn, $newBtns)
  Write-Host "Botones actualizados OK" -ForegroundColor Green
} else {
  # Buscar cualquier variante del boton eliminar con el caracter roto
  $content = $content -replace '<button onClick=\{.*?deleteResource\(r\.id\).*?title="Eliminar">.*?</button>', @'
<button onClick={() => {
                            const newUrl = window.prompt("Nueva URL:", r.url === "#" ? "" : r.url);
                            if (newUrl !== null) {
                              api.put("/sessions/resource/" + r.id, { title: r.title, url: newUrl, type: r.type })
                                .then(() => api.get("/courses/" + courseId).then(({data}) => setCourse(data)))
                                .catch(() => alert("Error al actualizar"));
                            }
                          }} className="ml-1 text-blue-400 hover:text-blue-600" title="Editar URL">
                            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                          </button>
                          <button onClick={() => deleteResource(r.id)} className="ml-1 text-red-400 hover:text-red-600" title="Eliminar">
                            <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg>
                          </button>
'@
  Write-Host "Botones actualizados con regex OK" -ForegroundColor Green
}

[System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
Write-Host "Guardado OK" -ForegroundColor Green

Write-Host ""
Write-Host "GitHub Desktop -> Commit 'Fix iconos recursos' -> Push" -ForegroundColor Cyan
Write-Host "VPS: git pull && docker compose -f docker-compose.prod.yml --env-file .env up -d --build" -ForegroundColor Cyan
