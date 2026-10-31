# ------------------------------------------------------------------
# actualizar.ps1 — Aplica el último zip de MotoTestA2 descargado,
# lo sube a GitHub, espera la compilación y abre la página del .ipa.
#
# Uso (desde la carpeta del proyecto):
#   .\actualizar.ps1 "Mensaje del cambio"
#
# Si PowerShell no deja ejecutar scripts, una sola vez:
#   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
# ------------------------------------------------------------------
param([string]$Mensaje = "Actualización")

$proyecto = "C:\Users\David\Documents\Proyectos"
$repo     = "DKings77/MotoTestA2"

# 1. Último zip descargado
$zip = Get-ChildItem "$env:USERPROFILE\Downloads\MotoTestA2*.zip" |
       Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $zip) { Write-Host "No hay ningún MotoTestA2*.zip en Descargas" -ForegroundColor Red; exit 1 }
Write-Host "Aplicando $($zip.Name)" -ForegroundColor Cyan

# 2. Descomprimir encima del proyecto
Expand-Archive $zip.FullName -DestinationPath $proyecto -Force
Set-Location "$proyecto\MotoTestA2"

# 3. Subir (add -A también registra los ficheros borrados)
git add -A
git commit -m $Mensaje
git push
if ($LASTEXITCODE -ne 0) { Write-Host "Error al subir a GitHub" -ForegroundColor Red; exit 1 }

# 4. Esperar a la compilación
Start-Sleep 15
do {
    $run = (Invoke-RestMethod "https://api.github.com/repos/$repo/actions/runs?per_page=1").workflow_runs[0]
    Write-Host "$(Get-Date -Format HH:mm:ss)  $($run.status)  $($run.conclusion)"
    if ($run.status -ne "completed") { Start-Sleep 20 }
} while ($run.status -ne "completed")

if ($run.conclusion -eq "success") {
    Write-Host "`nCompilado. Descarga MotoTestA2-ipa en Artifacts e instálalo con Sideloadly." -ForegroundColor Green
} else {
    Write-Host "`nHa fallado. Copia el log del paso en rojo." -ForegroundColor Red
}
Start-Process $run.html_url
