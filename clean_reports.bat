@echo off
setlocal enabledelayedexpansion

cls
echo.
echo ========================================================
echo    LIMPIAR REPORTES DE SERENITY - SARA3
echo ========================================================
echo.
echo IMPORTANTE: Cierra cualquier archivo abierto de estos reportes
echo             (Excel, archivos en Windows Explorer, etc.)
echo.
echo.
echo Analizando carpetas y archivos...
echo.
timeout /t 3 >nul

set deleted=0
set errors=0

REM Crear carpeta de reportes si no existe
if not exist "target\reports" (
    echo [CREANDO] target\reports
    mkdir "target\reports" >nul 2>&1
)
timeout /t 1 >nul

REM Serenity reports
if exist "target\site\serenity" (
    echo [BORRANDO] target\site\serenity
    rmdir /s /d /q "target\site\serenity" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK] Reportes de Serenity eliminados
        set /a deleted=deleted+1
    ) else (
        echo [ERROR] No se pudo borrar Serenity - verifica que no este abierto en Explorer
        set /a errors=errors+1
    )
) else (
    echo [INFO] target\site\serenity no existe
)
timeout /t 1 >nul

REM Test results target
if exist "target\test-results" (
    echo [BORRANDO] target\test-results
    rmdir /s /d /q "target\test-results" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK] Resultados de tests eliminados
        set /a deleted=deleted+1
    ) else (
        echo [ERROR] No se pudo borrar target\test-results
        set /a errors=errors+1
    )
) else (
    echo [INFO] target\test-results no existe
)
timeout /t 1 >nul

REM Build reports
if exist "build\reports" (
    echo [BORRANDO] build\reports
    rmdir /s /d /q "build\reports" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK] Reportes de build eliminados
        set /a deleted=deleted+1
    ) else (
        echo [ERROR] No se pudo borrar build\reports
        set /a errors=errors+1
    )
) else (
    echo [INFO] build\reports no existe
)
timeout /t 1 >nul

REM Build test-results
if exist "build\test-results" (
    echo [BORRANDO] build\test-results
    rmdir /s /d /q "build\test-results" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK] Resultados de tests (build) eliminados
        set /a deleted=deleted+1
    ) else (
        echo [ERROR] No se pudo borrar build\test-results
        set /a errors=errors+1
    )
) else (
    echo [INFO] build\test-results no existe
)
timeout /t 1 >nul

REM LIMPIAR ARCHIVOS VIEJOS EN RAIZ (compatibilidad con reportes anteriores)
if exist "test_timings_report.xlsx" (
    echo [BORRANDO] test_timings_report.xlsx (raiz)
    del /f /q "test_timings_report.xlsx" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK] Reporte Excel (raiz) eliminado
        set /a deleted=deleted+1
    ) else (
        echo [ERROR] No se pudo borrar Excel - verifica que no este abierto
        set /a errors=errors+1
    )
)
timeout /t 1 >nul

if exist "test_timings_report.csv" (
    echo [BORRANDO] test_timings_report.csv (raiz)
    del /f /q "test_timings_report.csv" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK] Reporte CSV (raiz) eliminado
        set /a deleted=deleted+1
    ) else (
        echo [ERROR] No se pudo borrar CSV - verifica que no este abierto
        set /a errors=errors+1
    )
)
timeout /t 1 >nul

REM Limpiar carpeta target\reports (los nuevos reportes)
if exist "target\reports" (
    echo [BORRANDO] target\reports (contenido)
    rmdir /s /d /q "target\reports" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK] Carpeta de reportes (target\reports) eliminada
        set /a deleted=deleted+1
    ) else (
        echo [ERROR] No se pudo borrar target\reports
        set /a errors=errors+1
    )
)
timeout /t 1 >nul

REM HTML report
if exist "test_timings_report.html" (
    echo [BORRANDO] test_timings_report.html
    del /f /q "test_timings_report.html" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK] Reporte HTML eliminado
        set /a deleted=deleted+1
    ) else (
        echo [ERROR] No se pudo borrar HTML
        set /a errors=errors+1
    )
) else (
    echo [INFO] test_timings_report.html no existe
)
timeout /t 1 >nul

REM CSV timing report
if exist "test_timings_report.csv" (
    echo [BORRANDO] test_timings_report.csv
    del /f /q "test_timings_report.csv" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK] Reporte CSV eliminado
        set /a deleted=deleted+1
    ) else (
        echo [ERROR] No se pudo borrar CSV
        set /a errors=errors+1
    )
) else (
    echo [INFO] test_timings_report.csv no existe
)
timeout /t 1 >nul

REM Gradle logs
if exist "gradle-test-output.txt" (
    echo [BORRANDO] gradle-test-output.txt
    del /f /q "gradle-test-output.txt" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK] Log de gradle eliminado
        set /a deleted=deleted+1
    ) else (
        echo [ERROR] No se pudo borrar gradle log
        set /a errors=errors+1
    )
) else (
    echo [INFO] gradle-test-output.txt no existe
)
timeout /t 1 >nul

REM Test output
if exist "test_output.txt" (
    echo [BORRANDO] test_output.txt
    del /f /q "test_output.txt" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK] test_output.txt eliminado
        set /a deleted=deleted+1
    ) else (
        echo [ERROR] No se pudo borrar test_output.txt
        set /a errors=errors+1
    )
) else (
    echo [INFO] test_output.txt no existe
)
timeout /t 1 >nul

REM Test log
if exist "test_log.txt" (
    echo [BORRANDO] test_log.txt
    del /f /q "test_log.txt" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK] test_log.txt eliminado
        set /a deleted=deleted+1
    ) else (
        echo [ERROR] No se pudo borrar test_log.txt
        set /a errors=errors+1
    )
) else (
    echo [INFO] test_log.txt no existe
)
timeout /t 1 >nul

REM Historic reports
if exist "reports_historic" (
    echo [BORRANDO] reports_historic
    rmdir /s /d /q "reports_historic" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [OK] Historico de reportes eliminado
        set /a deleted=deleted+1
    ) else (
        echo [ERROR] No se pudo borrar reports_historic
        set /a errors=errors+1
    )
) else (
    echo [INFO] reports_historic no existe
)
timeout /t 1 >nul

echo.
echo ========================================================
echo RESUMEN DE LIMPIEZA
echo ========================================================
echo Items eliminados: %deleted%
echo Errores: %errors%
echo ========================================================
echo.

if %errors% gtr 0 (
    echo [ADVERTENCIA] Algunos archivos no se pudieron borrar.
    echo Posibles causas:
    echo   - Excel o archivo abierto
    echo   - Carpeta abierta en Windows Explorer
    echo   - Permisos insuficientes
    echo.
    echo Cierra esos archivos y vuelve a intentar.
)

if %deleted% gtr 0 (
    echo [SUCCESS] Se limpiaron %deleted% elementos exitosamente!
) else (
    echo [INFO] No habia archivos/carpetas para limpiar
)

echo.
echo ========================================================
echo.
pause
exit /b 0
