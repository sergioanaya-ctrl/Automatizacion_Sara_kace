@echo off
setlocal enabledelayedexpansion

:: ============================================================
:: VALIDAR Y CORREGIR JAVA_HOME ANTES DE LLAMAR A GRADLEW
:: ============================================================
:: Si JAVA_HOME apunta a una ruta invalida, Gradle no puede arrancar.
:: Intentamos detectar un JDK valido automaticamente.
if defined JAVA_HOME (
    if not exist "%JAVA_HOME%\bin\java.exe" (
        echo ADVERTENCIA: JAVA_HOME invalido: %JAVA_HOME%
        set "JAVA_HOME="
    )
)
if not defined JAVA_HOME (
    if exist "C:\Program Files\Microsoft\jdk-21.0.8.9-hotspot\bin\java.exe" (
        set "JAVA_HOME=C:\Program Files\Microsoft\jdk-21.0.8.9-hotspot"
    ) else if exist "C:\Program Files\Eclipse Adoptium\jdk-21.0.8.9-hotspot\bin\java.exe" (
        set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-21.0.8.9-hotspot"
    ) else (
        where java >nul 2>&1
        if %errorlevel% neq 0 (
            echo ERROR: No se encontro una instalacion de Java valida.
            echo Instala JDK 21 o configura JAVA_HOME correctamente.
            pause
            exit /b 1
        )
    )
)
echo.
echo ========================================================
echo         SARA3 - Descargando dependencias...
echo ========================================================
echo.
echo (Primera vez: 3-5 minutos. Siguientes: 30 segundos)
echo.

call .\gradlew.bat compileTestJava -q
if %errorlevel% neq 0 (
    echo.
    echo ERROR: No se pudo compilar el proyecto
    echo Verifica tu conexion a internet
    echo.
    pause
    exit /b 1
)

:: ============================================================
:: FUNCION PARA LIMPIAR REPORTES DE SERENITY
:: ============================================================
:clean_reports
echo.
echo Limpiando reportes anteriores...
if exist "target\site\serenity" (
    rmdir /s /q "target\site\serenity" >nul 2>&1
    echo [OK] Reportes de Serenity eliminados
)
if exist "target\test-results" (
    rmdir /s /q "target\test-results" >nul 2>&1
    echo [OK] Resultados de tests eliminados
)
if exist "build\reports" (
    rmdir /s /q "build\reports" >nul 2>&1
    echo [OK] Reportes de build eliminados
)
exit /b 0

:menu
cls
echo.
echo ========================================================
echo       AUTOMATIZACION SARA3 - EJECUCION DE PRUEBAS
echo ========================================================
echo.
echo  1. Ejecutar numero personalizado de runners
echo  2. Ejecutar  2 runners en paralelo
echo  3. Ejecutar  4 runners en paralelo
echo  4. Ejecutar  8 runners en paralelo
echo  5. Ejecutar 12 runners en paralelo
echo  6. Ejecutar 50 runners en paralelo
echo  7. Ejecutar  1 runner individual
echo  8. Ver reporte de resultados
echo  9. Generar reporte de tiempos (EXCEL)
echo 10. Limpiar reportes
echo 11. Salir
echo.
set /p choice="Selecciona opcion (1-11): "

if "%choice%"=="1" goto custom_runners
if "%choice%"=="2" goto run_2
if "%choice%"=="3" goto run_4
if "%choice%"=="4" goto run_8
if "%choice%"=="5" goto run_12
if "%choice%"=="6" goto run_50
if "%choice%"=="7" goto run_one
if "%choice%"=="8" goto report
if "%choice%"=="9" goto timing_report
if "%choice%"=="10" goto clean_menu
if "%choice%"=="11" goto end
goto menu

:custom_runners
set /p FORKS="Numero de runners (1-50): "
call :clean_reports
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=%FORKS%' | Set-Content gradle.properties"
timeout /t 5
call .\gradlew.bat test --parallel
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Los tests fallaron o se ejecutaron incorrectamente
)
pause
goto menu

:run_2
call :clean_reports
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=2' | Set-Content gradle.properties"
timeout /t 5
call .\gradlew.bat test --parallel
pause
goto menu

:run_4
call :clean_reports
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=4' | Set-Content gradle.properties"
timeout /t 5
call .\gradlew.bat test --parallel
pause
goto menu

:run_8
call :clean_reports
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=8' | Set-Content gradle.properties"
timeout /t 5
call .\gradlew.bat test --parallel
pause
goto menu

:run_12
call :clean_reports
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=12' | Set-Content gradle.properties"
timeout /t 5
call .\gradlew.bat test --parallel
pause
goto menu

:run_50
call :clean_reports
echo.
echo ADVERTENCIA: Ejecutar 50 tests en paralelo requiere recursos significativos
echo Se aplicara timeout de 1 hora para evitar bloqueos infinitos
echo.
timeout /t 5
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=50' | Set-Content gradle.properties"
timeout /t 60 /nobreak
call .\gradlew.bat test --parallel --max-workers=50
if %errorlevel% equ 124 (
    echo.
    echo [TIMEOUT] La ejecucion tardo demasiado. Matando procesos...
    taskkill /F /IM java.exe /T >nul 2>&1
)
pause
goto menu

:run_one
set /p runner="Numero del runner (01-50): "
call :clean_reports
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=1' | Set-Content gradle.properties"
timeout /t 5
call .\gradlew.bat test --tests "com.sara.automation.runners.CasesRunner%runner%"
echo.
echo ========================================================
echo Test completado. Reporte disponible en:
echo ========================================================
echo target\site\serenity\index.html
echo.
pause
exit /b 0

:report
if exist "target\site\serenity\index.html" (
    start target\site\serenity\index.html
) else (
    echo No hay reporte. Ejecuta primero los tests.
    pause
)
goto menu

:timing_report
echo.
echo Generando reporte de tiempos...
if exist "build\test-results\test" (
    powershell -ExecutionPolicy Bypass -File "generate_timing_report.ps1"
    if exist "test_timings_report.csv" (
        echo [OK] Reporte generado: test_timings_report.csv
        timeout /t 2
        if exist "test_timings_report.xlsx" (
            start test_timings_report.xlsx
        ) else (
            start test_timings_report.csv
        )
    )
) else (
    echo [ERROR] No hay resultados de tests. Ejecuta los tests primero.
)
pause
goto menu

:clean_menu
call :clean_reports
echo.
echo [OK] Reportes limpiados exitosamente
pause
goto menu

:end
exit /b 0
