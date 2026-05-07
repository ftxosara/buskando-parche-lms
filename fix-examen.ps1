Write-Host "=== FIX EXAMEN: OPCIONES Y PREGUNTAS ===" -ForegroundColor Yellow

$path = "$PWD\frontend\src\app\(dashboard)\formador\courses\page.tsx"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)

# ── Funcion para inicializar el examen correctamente ──────────
$initExam = @'
  const getExamForm = (sessionId: string) => {
    if (!examForms[sessionId]) {
      const initial = { title: "", pass: "60", qs: [{ text: "", options: ["", "", "", ""], correct: 0, points: 25 }] };
      setExamForms(p => ({ ...p, [sessionId]: initial }));
      return initial;
    }
    return examForms[sessionId];
  };

  const updateQuestion = (sessionId: string, qi: number, field: string, value: any) => {
    setExamForms(p => {
      const form = p[sessionId] || { title: "", pass: "60", qs: [{ text: "", options: ["", "", "", ""], correct: 0, points: 25 }] };
      const qs = form.qs.map((q: any, i: number) => i === qi ? { ...q, [field]: value } : q);
      return { ...p, [sessionId]: { ...form, qs } };
    });
  };

  const updateOption = (sessionId: string, qi: number, oi: number, value: string) => {
    setExamForms(p => {
      const form = p[sessionId] || { title: "", pass: "60", qs: [{ text: "", options: ["", "", "", ""], correct: 0, points: 25 }] };
      const qs = form.qs.map((q: any, i: number) => {
        if (i !== qi) return q;
        const opts = [...q.options];
        opts[oi] = value;
        return { ...q, options: opts };
      });
      return { ...p, [sessionId]: { ...form, qs } };
    });
  };

  const addOption = (sessionId: string, qi: number) => {
    setExamForms(p => {
      const form = p[sessionId];
      if (!form) return p;
      const qs = form.qs.map((q: any, i: number) => {
        if (i !== qi) return q;
        return { ...q, options: [...q.options, ""] };
      });
      return { ...p, [sessionId]: { ...form, qs } };
    });
  };

  const removeOption = (sessionId: string, qi: number, oi: number) => {
    setExamForms(p => {
      const form = p[sessionId];
      if (!form) return p;
      const qs = form.qs.map((q: any, i: number) => {
        if (i !== qi) return q;
        if (q.options.length <= 2) return q;
        const opts = q.options.filter((_: any, idx: number) => idx !== oi);
        const correct = q.correct >= opts.length ? 0 : q.correct;
        return { ...q, options: opts, correct };
      });
      return { ...p, [sessionId]: { ...form, qs } };
    });
  };

  const addQuestion = (sessionId: string) => {
    setExamForms(p => {
      const form = p[sessionId] || { title: "", pass: "60", qs: [] };
      const qs = [...form.qs, { text: "", options: ["", "", "", ""], correct: 0, points: 25 }];
      return { ...p, [sessionId]: { ...form, qs } };
    });
  };

  const removeQuestion = (sessionId: string, qi: number) => {
    setExamForms(p => {
      const form = p[sessionId];
      if (!form || form.qs.length <= 1) return p;
      const qs = form.qs.filter((_: any, i: number) => i !== qi);
      return { ...p, [sessionId]: { ...form, qs } };
    });
  };

'@

# Insertar las funciones antes de "if (loading)"
$content = $content -replace '(  if \(loading\) return \()', "$initExam`$1"

# ── Reemplazar el bloque completo del TAB EXAMEN ─────────────
$oldExamTab = @'
                  {/* TAB: EXAMEN */}
                  {activeTab[s.id + "_tab"] === "examen" && (
                    <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-4">
                      <p className="text-xs text-text-muted">Crea un examen de seleccion multiple. El estudiante lo responde en linea y recibe su nota automaticamente.</p>
                      <div className="grid grid-cols-2 gap-3">
                        <input className="input text-sm" placeholder="Titulo del examen *"
                          value={examForms[s.id]?.title || ""}
                          onChange={e => setExamForms(p => ({ ...p, [s.id]: { ...p[s.id], title: e.target.value } }))} />
                        <div className="flex items-center gap-2">
                          <span className="text-xs text-text-muted whitespace-nowrap">Nota minima para aprobar</span>
                          <input className="input text-sm w-20" type="number" min="0" max="100"
                            value={examForms[s.id]?.pass || "60"}
                            onChange={e => setExamForms(p => ({ ...p, [s.id]: { ...p[s.id], pass: e.target.value } }))} />
                        </div>
                      </div>

                      {(examForms[s.id]?.qs || [{ text: "", options: ["", "", "", ""], correct: 0, points: 25 }]).map((q: any, qi: number) => (
                        <div key={qi} className="border border-gray-200 rounded-xl p-3 space-y-2">
                          <div className="flex items-center gap-2">
                            <span className="w-6 h-6 rounded-full bg-primary text-white text-xs flex items-center justify-center font-bold">{qi + 1}</span>
                            <input className="input text-sm flex-1" placeholder={`Pregunta ${qi + 1}`}
                              value={q.text}
                              onChange={e => setExamForms(p => {
                                const qs = [...(p[s.id]?.qs || [])];
                                qs[qi] = { ...qs[qi], text: e.target.value };
                                return { ...p, [s.id]: { ...p[s.id], qs } };
                              })} />
                            <input className="input text-sm w-16" type="number" min="0" max="100" placeholder="pts"
                              value={q.points || 25}
                              onChange={e => setExamForms(p => {
                                const qs = [...(p[s.id]?.qs || [])];
                                qs[qi] = { ...qs[qi], points: parseInt(e.target.value) };
                                return { ...p, [s.id]: { ...p[s.id], qs } };
                              })} />
                          </div>
                          <p className="text-xs text-text-muted">Marca el radio de la opcion correcta:</p>
                          {(q.options || ["", "", "", ""]).map((opt: string, oi: number) => (
                            <div key={oi} className={clsx("flex items-center gap-2 rounded-lg p-2 border transition-colors",
                              q.correct === oi ? "bg-green-50 border-green-300" : "border-gray-200")}>
                              <input type="radio" name={`q_${s.id}_${qi}`} checked={q.correct === oi}
                                onChange={() => setExamForms(p => {
                                  const qs = [...(p[s.id]?.qs || [])];
                                  qs[qi] = { ...qs[qi], correct: oi };
                                  return { ...p, [s.id]: { ...p[s.id], qs } };
                                })} />
                              <input className="flex-1 bg-transparent text-sm outline-none" placeholder={`Opcion ${oi + 1}`}
                                value={opt}
                                onChange={e => setExamForms(p => {
                                  const qs = [...(p[s.id]?.qs || [])];
                                  const opts = [...(qs[qi].options || [])];
                                  opts[oi] = e.target.value;
                                  qs[qi] = { ...qs[qi], options: opts };
                                  return { ...p, [s.id]: { ...p[s.id], qs } };
                                })} />
                              {q.correct === oi && <span className="text-green-600 text-xs font-semibold">Correcta</span>}
                            </div>
                          ))}
                        </div>
                      ))}

                      <div className="flex gap-2">
                        <button onClick={() => setExamForms(p => {
                          const qs = [...(p[s.id]?.qs || []), { text: "", options: ["", "", "", ""], correct: 0, points: 25 }];
                          return { ...p, [s.id]: { ...p[s.id], qs } };
                        })} className="btn-outline flex items-center gap-1 text-sm">
                          <Plus className="w-4 h-4" /> Agregar pregunta
                        </button>
                        <button onClick={() => publishExam(s.id)} disabled={uploading === s.id + "_exam" || !examForms[s.id]?.title}
                          className="btn-primary flex items-center gap-2 text-sm disabled:opacity-50">
                          {uploading === s.id + "_exam" ? <Loader2 className="w-4 h-4 animate-spin" /> : <CheckCircle className="w-4 h-4" />}
                          Publicar examen
                        </button>
                      </div>
                    </div>
                  )}
'@

$newExamTab = @'
                  {/* TAB: EXAMEN */}
                  {activeTab[s.id + "_tab"] === "examen" && (
                    <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-4">
                      <p className="text-xs text-text-muted">Crea un examen de seleccion multiple. El estudiante lo responde en linea y recibe su nota automaticamente.</p>
                      <div className="grid grid-cols-2 gap-3">
                        <input className="input text-sm" placeholder="Titulo del examen *"
                          value={examForms[s.id]?.title || ""}
                          onChange={e => setExamForms(p => ({ ...p, [s.id]: { ...(p[s.id] || { title: "", pass: "60", qs: [{ text: "", options: ["","","",""], correct: 0, points: 25 }] }), title: e.target.value } }))} />
                        <div className="flex items-center gap-2">
                          <span className="text-xs text-text-muted whitespace-nowrap">Nota minima</span>
                          <input className="input text-sm w-20" type="number" min="0" max="100"
                            value={examForms[s.id]?.pass || "60"}
                            onChange={e => setExamForms(p => ({ ...p, [s.id]: { ...(p[s.id] || { title: "", pass: "60", qs: [{ text: "", options: ["","","",""], correct: 0, points: 25 }] }), pass: e.target.value } }))} />
                        </div>
                      </div>

                      {(examForms[s.id]?.qs || [{ text: "", options: ["", "", "", ""], correct: 0, points: 25 }]).map((q: any, qi: number) => (
                        <div key={qi} className="border border-gray-200 rounded-xl p-3 space-y-2">
                          <div className="flex items-center gap-2">
                            <span className="w-6 h-6 rounded-full bg-primary text-white text-xs flex items-center justify-center font-bold flex-shrink-0">{qi + 1}</span>
                            <input className="input text-sm flex-1" placeholder={`Pregunta ${qi + 1}`}
                              value={q.text}
                              onChange={e => updateQuestion(s.id, qi, "text", e.target.value)} />
                            <input className="input text-sm w-16" type="number" min="0" max="100" placeholder="pts"
                              value={q.points || 25}
                              onChange={e => updateQuestion(s.id, qi, "points", parseInt(e.target.value))} />
                            {(examForms[s.id]?.qs?.length || 1) > 1 && (
                              <button onClick={() => removeQuestion(s.id, qi)} className="text-red-400 hover:text-red-600 p-1" title="Eliminar pregunta">
                                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                              </button>
                            )}
                          </div>
                          <p className="text-xs text-text-muted">Marca el radio de la opcion correcta:</p>
                          {(q.options || ["", "", "", ""]).map((opt: string, oi: number) => (
                            <div key={oi} className={clsx("flex items-center gap-2 rounded-lg p-2 border transition-colors",
                              q.correct === oi ? "bg-green-50 border-green-300" : "border-gray-200")}>
                              <input type="radio" name={`q_${s.id}_${qi}`} checked={q.correct === oi}
                                onChange={() => updateQuestion(s.id, qi, "correct", oi)} />
                              <input className="flex-1 bg-transparent text-sm outline-none" placeholder={`Opcion ${oi + 1}`}
                                value={opt}
                                onChange={e => updateOption(s.id, qi, oi, e.target.value)} />
                              {q.correct === oi && <span className="text-green-600 text-xs font-semibold">Correcta</span>}
                              {(q.options?.length || 0) > 2 && (
                                <button onClick={() => removeOption(s.id, qi, oi)} className="text-red-300 hover:text-red-500" title="Quitar opcion">
                                  <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                                </button>
                              )}
                            </div>
                          ))}
                          <button onClick={() => addOption(s.id, qi)} className="text-xs text-primary hover:underline flex items-center gap-1 mt-1">
                            <svg xmlns="http://www.w3.org/2000/svg" width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                            Agregar opcion
                          </button>
                        </div>
                      ))}

                      <div className="flex gap-2 flex-wrap">
                        <button onClick={() => addQuestion(s.id)} className="btn-outline flex items-center gap-1 text-sm">
                          <Plus className="w-4 h-4" /> Agregar pregunta
                        </button>
                        <button onClick={() => publishExam(s.id)} disabled={uploading === s.id + "_exam" || !examForms[s.id]?.title}
                          className="btn-primary flex items-center gap-2 text-sm disabled:opacity-50">
                          {uploading === s.id + "_exam" ? <Loader2 className="w-4 h-4 animate-spin" /> : <CheckCircle className="w-4 h-4" />}
                          Publicar examen
                        </button>
                      </div>
                    </div>
                  )}
'@

$content = $content.Replace($oldExamTab, $newExamTab)

[System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
Write-Host "OK - Examen arreglado" -ForegroundColor Green

Write-Host ""
Write-Host "GitHub Desktop -> Commit 'Fix examen opciones' -> Push" -ForegroundColor Cyan
Write-Host "VPS: git pull && docker compose -f docker-compose.prod.yml --env-file .env up -d --build" -ForegroundColor Cyan
