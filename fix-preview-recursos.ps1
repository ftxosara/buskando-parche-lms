Write-Host "=== FIX PREVIEW RECURSOS FORMADOR ===" -ForegroundColor Yellow

$path = "$PWD\frontend\src\app\(dashboard)\formador\courses\page.tsx"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)

# ── 1. Corregir publishExam para guardar JSON en URL ──────────
$oldExam = "await api.post(""/sessions/"" + sessionId + ""/resources"", {
        courseId, sessionId,
        title: f.title, type: ""examen"",
        url: ""#"", description: JSON.stringify({ pass: f.pass, questions: f.qs })"
$newExam = "await api.post(""/sessions/"" + sessionId + ""/resources"", {
        courseId, sessionId,
        title: f.title, type: ""examen"",
        url: JSON.stringify({ pass: f.pass, questions: f.qs })"

$content = $content.Replace($oldExam, $newExam)

# ── 2. Corregir addActivity para guardar descripcion en URL ──
$oldAct = "await api.post(""/sessions/"" + sessionId + ""/resources"", {
      courseId, sessionId,
      title: f.title, description: f.description || """",
      type: ""actividad"", url: ""#"""
$newAct = "await api.post(""/sessions/"" + sessionId + ""/resources"", {
      courseId, sessionId,
      title: f.title,
      type: ""actividad"", url: f.description || ""Sin descripcion"""

$content = $content.Replace($oldAct, $newAct)

# ── 3. Agregar estado para preview modal ──────────────────────
$content = $content -replace '(\[uploading, setUploading\] = useState<string \| null>\(null\);)', '$1
  const [preview, setPreview] = useState<any>(null);'

# ── 4. Mejorar la visualizacion de recursos con preview ───────
$oldResourceItem = @'
                        <div key={r.id} className="flex items-center gap-3 bg-white rounded-xl px-3 py-2.5 border border-gray-100">
                          {r.type === "video" ? <Video className="w-4 h-4 text-red-500 flex-shrink-0" />
                            : r.type === "pdf" ? <FileText className="w-4 h-4 text-blue-500 flex-shrink-0" />
                            : <LinkIcon className="w-4 h-4 text-green-500 flex-shrink-0" />}
                          <span className="text-sm text-text-primary flex-1">{r.title}</span>
                          {r.url && r.url !== "#" ? (
                            <a href={r.url} target="_blank" rel="noopener noreferrer"
                              className="text-primary text-xs hover:underline">Ver</a>
                          ) : (
                            <span className="text-gray-300 text-xs">Sin URL</span>
                          )}
'@

$newResourceItem = @'
                        <div key={r.id} className="flex items-center gap-3 bg-white rounded-xl px-3 py-2.5 border border-gray-100">
                          {r.type === "video" ? <Video className="w-4 h-4 text-red-500 flex-shrink-0" />
                            : r.type === "pdf" || r.type === "doc" || r.type === "ppt" || r.type === "excel" ? <FileText className="w-4 h-4 text-blue-500 flex-shrink-0" />
                            : r.type === "examen" ? <Star className="w-4 h-4 text-yellow-500 flex-shrink-0" />
                            : r.type === "actividad" ? <ClipboardList className="w-4 h-4 text-purple-500 flex-shrink-0" />
                            : <LinkIcon className="w-4 h-4 text-green-500 flex-shrink-0" />}
                          <span className="text-sm text-text-primary flex-1">{r.title}</span>
                          {r.type === "examen" || r.type === "actividad" ? (
                            <button onClick={() => setPreview(r)} className="text-primary text-xs hover:underline font-medium">Ver</button>
                          ) : r.url && r.url !== "#" ? (
                            <a href={r.url.startsWith("/uploads") ? (process.env.NEXT_PUBLIC_API_URL || "") + r.url : r.url}
                              target="_blank" rel="noopener noreferrer"
                              className="text-primary text-xs hover:underline font-medium">
                              {r.url.startsWith("/uploads") ? "Descargar" : "Ver"}
                            </a>
                          ) : (
                            <span className="text-gray-300 text-xs">Sin URL</span>
                          )}
'@

$content = $content.Replace($oldResourceItem, $newResourceItem)

# ── 5. Agregar modal de preview antes del ultimo return ────────
$previewModal = @'

      {/* MODAL PREVIEW EXAMEN/ACTIVIDAD */}
      {preview && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4 overflow-y-auto"
          onClick={e => { if (e.target === e.currentTarget) setPreview(null); }}>
          <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl my-4">
            <div className="flex items-center justify-between p-5 border-b border-gray-100">
              <div>
                <h2 className="font-bold text-text-primary text-lg">{preview.title}</h2>
                <span className={clsx("text-xs font-semibold px-2 py-0.5 rounded-full mt-1 inline-block",
                  preview.type === "examen" ? "bg-yellow-100 text-yellow-700" : "bg-purple-100 text-purple-700")}>
                  {preview.type === "examen" ? "Examen online" : "Actividad"}
                </span>
              </div>
              <button onClick={() => setPreview(null)} className="p-2 hover:bg-gray-100 rounded-xl">
                <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
              </button>
            </div>
            <div className="p-5">
              {preview.type === "actividad" && (
                <div className="bg-purple-50 rounded-xl p-4">
                  <p className="text-sm font-semibold text-purple-800 mb-2">Instrucciones para el estudiante:</p>
                  <p className="text-sm text-purple-700 whitespace-pre-wrap">{preview.url === "#" ? "Sin descripcion" : preview.url}</p>
                </div>
              )}
              {preview.type === "examen" && (() => {
                let examData: any = null;
                try { examData = JSON.parse(preview.url); } catch { return <p className="text-gray-500 text-sm">No se pudo cargar el examen</p>; }
                return (
                  <div className="space-y-4">
                    <div className="bg-yellow-50 rounded-xl p-3 flex items-center gap-3">
                      <Star className="w-5 h-5 text-yellow-600" />
                      <div>
                        <p className="text-sm font-semibold text-yellow-800">Nota minima para aprobar: {examData.pass || 60}/100</p>
                        <p className="text-xs text-yellow-600">{examData.questions?.length || 0} preguntas</p>
                      </div>
                    </div>
                    {examData.questions?.map((q: any, qi: number) => (
                      <div key={qi} className="border border-gray-200 rounded-xl p-4 space-y-2">
                        <div className="flex items-start gap-2">
                          <span className="w-6 h-6 rounded-full bg-primary text-white text-xs flex items-center justify-center font-bold flex-shrink-0 mt-0.5">{qi+1}</span>
                          <div className="flex-1">
                            <p className="text-sm font-semibold text-text-primary">{q.text || "Pregunta sin texto"}</p>
                            <p className="text-xs text-text-muted mt-0.5">{q.points || 0} puntos</p>
                          </div>
                        </div>
                        <div className="space-y-1 ml-8">
                          {(q.options || []).map((opt: string, oi: number) => (
                            <div key={oi} className={clsx("flex items-center gap-2 rounded-lg px-3 py-2 text-sm",
                              q.correct === oi ? "bg-green-50 border border-green-300 text-green-800 font-medium" : "bg-gray-50 text-gray-600")}>
                              {q.correct === oi ? (
                                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                              ) : (
                                <div className="w-3.5 h-3.5 rounded-full border border-gray-400"/>
                              )}
                              {opt || "Opcion vacia"}
                              {q.correct === oi && <span className="ml-auto text-green-600 text-xs font-bold">CORRECTA</span>}
                            </div>
                          ))}
                        </div>
                      </div>
                    ))}
                  </div>
                );
              })()}
            </div>
          </div>
        </div>
      )}

'@

# Insertar antes del cierre de AppShell
$content = $content -replace '(\s+</AppShell>\s+\);\s*\})', "$previewModal`$1"

[System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
Write-Host "OK - Preview recursos agregado" -ForegroundColor Green

Write-Host ""
Write-Host "GitHub Desktop -> Commit 'Fix preview recursos' -> Push" -ForegroundColor Cyan
Write-Host "VPS: git pull && docker compose -f docker-compose.prod.yml --env-file .env up -d --build" -ForegroundColor Cyan
