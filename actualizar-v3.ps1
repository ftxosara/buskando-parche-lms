Write-Host "=== ACTUALIZACION COMPLETA V3 - BUSKANDO PARCHE ===" -ForegroundColor Yellow
Write-Host "Aplicando: Dashboard mejorado, Formador completo, Visor curso Moodle, Foro, Sabana de notas, Reportes PDF..." -ForegroundColor Cyan

# Ejecutar las 3 partes
. "$PSScriptRoot\parte1-backend.ps1"
. "$PSScriptRoot\parte2-admin.ps1"
. "$PSScriptRoot\parte3-student-formador.ps1"

# Crear carpeta de uploads si no existe
New-Item -ItemType Directory -Force -Path "backend\uploads" | Out-Null

Write-Host ""
Write-Host "=========================================================" -ForegroundColor Yellow
Write-Host "  ACTUALIZACION V3 COMPLETA" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "NUEVAS FUNCIONES:" -ForegroundColor Cyan
Write-Host "  - Dashboard admin: KPIs con hover, graficas por genero"
Write-Host "  - Usuarios admin: columna 'Curso' en lugar de 'Grupo'"
Write-Host "  - Cursos admin: ver inscritos por curso expandible"
Write-Host "  - Reportes: PDF descargable con todos los datos"
Write-Host "  - Formador: gestionar sesiones, asistencia, calificar"
Write-Host "  - Visor de curso estilo Moodle con materiales"
Write-Host "  - Entrega de actividades con archivo adjunto"
Write-Host "  - Sabana de notas por sesion"
Write-Host "  - Foro funcional con respuestas"
Write-Host ""
Write-Host "Ejecuta: docker-compose down && docker-compose up --build" -ForegroundColor Green
