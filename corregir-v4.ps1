Write-Host "=== CORRECCION V4 - BUSKANDO PARCHE ===" -ForegroundColor Yellow
Write-Host "Corrigiendo: 4 cursos, formador bloqueado, certificado, graficas, examenes online..." -ForegroundColor Cyan

. "$PSScriptRoot\fix-parte1.ps1"
. "$PSScriptRoot\fix-parte2.ps1"

# Limpiar BD y reconstruir con datos correctos
Write-Host ""
Write-Host "IMPORTANTE: Se necesita reiniciar la BD para aplicar los 4 cursos correctos." -ForegroundColor Yellow
Write-Host "Ejecuta estos comandos EN ORDEN:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. docker-compose down -v" -ForegroundColor White
Write-Host "     (esto borra los datos anteriores con los cursos incorrectos)" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. docker-compose up --build" -ForegroundColor White
Write-Host "     (recrea todo con exactamente 4 cursos y 85 usuarios)" -ForegroundColor Gray
Write-Host ""
Write-Host "CORRECCIONES APLICADAS:" -ForegroundColor Green
Write-Host "  Dashboard admin: graficas corregidas, grupos poblacionales como barras, nueva grafica genero"
Write-Host "  Solo 4 cursos: Ingles, Gestion Empresarial, Gestion Turistica, Marketing Digital"
Write-Host "  Formador: solo ve su curso, los demas aparecen bloqueados"
Write-Host "  Asistencia: funcional con P/A/E por estudiante"
Write-Host "  Calificaciones: funcional + crear examenes online con resultado inmediato"
Write-Host "  Certificado: texto corregido, firmas Alcaldesa y CEO Boost incluidas"
Write-Host "  Next.config: advertencia appDir eliminada"
