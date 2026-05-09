@echo off
setlocal enabledelayedexpansion

echo.
echo ========================================================
echo    LIMPIAR REPORTES DE SERENITY - SARA3
echo ========================================================
echo.
echo Limpiando reportes anteriores...
echo.

set deleted=0

if exist "target\site\serenity" (
    rmdir /s /q "target\site\serenity" >nul 2>&1
    echo [OK] Reportes de Serenity eliminados
    set /a deleted=deleted+1
)

if exist "target\test-results" (
    rmdir /s /q "target\test-results" >nul 2>&1
    echo [OK] Resultados de tests eliminados
    set /a deleted=deleted+1
)

if exist "build\reports" (
    rmdir /s /q "build\reports" >nul 2>&1
    echo [OK] Reportes de build eliminados
    set /a deleted=deleted+1
)

if exist "build\test-results" (
    rmdir /s /q "build\test-results" >nul 2>&1
    echo [OK] Resultados de tests (build) eliminados
    set /a deleted=deleted+1
)

if exist "test_timings_report.xlsx" (
    del /q "test_timings_report.xlsx" >nul 2>&1
    echo [OK] Reporte Excel de timings eliminado
    set /a deleted=deleted+1
)

if exist "test_timings_report.csv" (
    del /q "test_timings_report.csv" >nul 2>&1
    echo [OK] Reporte CSV de timings eliminado
    set /a deleted=deleted+1
)

if exist "gradle-test-output.txt" (
    del /q "gradle-test-output.txt" >nul 2>&1
    echo [OK] Log de gradle eliminado
    set /a deleted=deleted+1
)

if exist "test_output.txt" (
    del /q "test_output.txt" >nul 2>&1
    echo [OK] Archivo test_output.txt eliminado
    set /a deleted=deleted+1
)

if exist "test_log.txt" (
    del /q "test_log.txt" >nul 2>&1
    echo [OK] Archivo test_log.txt eliminado
    set /a deleted=deleted+1
)

echo.
echo ========================================================
if %deleted% gtr 0 (
    echo [OK] Se eliminaron %deleted% carpeta(s) de reportes
) else (
    echo [INFO] No hay reportes para limpiar
)
echo ========================================================
echo.
pause
exit /b 0
