Write-Host "=== FIX SCHEMA PRISMA (BOM) ===" -ForegroundColor Yellow

# Leer el schema actual y eliminar el BOM + agregar avatarUrl correctamente
$schemaPath = "$PWD\backend\prisma\schema.prisma"

# Leer como bytes para detectar y eliminar BOM
$bytes = [System.IO.File]::ReadAllBytes($schemaPath)

# Detectar y eliminar BOM UTF-8 (EF BB BF)
$startIndex = 0
if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
  $startIndex = 3
  Write-Host "BOM detectado y eliminado" -ForegroundColor Yellow
}

$cleanText = [System.Text.Encoding]::UTF8.GetString($bytes, $startIndex, $bytes.Length - $startIndex)

# Agregar avatarUrl si no existe
if ($cleanText -notmatch "avatarUrl") {
  $cleanText = $cleanText -replace "isActive\s+Boolean\s+@default\(true\)", "isActive      Boolean   @default(true)`n  avatarUrl     String?"
  Write-Host "avatarUrl agregado al schema" -ForegroundColor Green
}

# Guardar SIN BOM usando StreamWriter con UTF8 sin BOM
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($schemaPath, $cleanText, $utf8NoBom)
Write-Host "schema.prisma guardado sin BOM OK" -ForegroundColor Green

# Verificar que no tiene BOM
$verify = [System.IO.File]::ReadAllBytes($schemaPath)
if ($verify[0] -eq 0xEF -and $verify[1] -eq 0xBB -and $verify[2] -eq 0xBF) {
  Write-Host "ERROR: Aun tiene BOM" -ForegroundColor Red
} else {
  Write-Host "Verificado: sin BOM" -ForegroundColor Green
}

Write-Host ""
Write-Host "Ahora ejecuta:" -ForegroundColor Cyan
Write-Host "  docker-compose down -v" -ForegroundColor White
Write-Host "  docker-compose up --build" -ForegroundColor White
