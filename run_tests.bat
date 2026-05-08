@echo off
setlocal enabledelayedexpansion

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
echo  9. Salir
echo.
set /p choice="Selecciona opcion (1-9): "

if "%choice%"=="1" goto custom_runners
if "%choice%"=="2" goto run_2
if "%choice%"=="3" goto run_4
if "%choice%"=="4" goto run_8
if "%choice%"=="5" goto run_12
if "%choice%"=="6" goto run_50
if "%choice%"=="7" goto run_one
if "%choice%"=="8" goto report
if "%choice%"=="9" goto end
goto menu

:custom_runners
set /p FORKS="Numero de runners (1-50): "
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=%FORKS%' | Set-Content gradle.properties"
call .\gradlew.bat test
pause
goto menu

:run_2
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=2' | Set-Content gradle.properties"
call .\gradlew.bat test
pause
goto menu

:run_4
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=4' | Set-Content gradle.properties"
call .\gradlew.bat test
pause
goto menu

:run_8
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=8' | Set-Content gradle.properties"
call .\gradlew.bat test
pause
goto menu

:run_12
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=12' | Set-Content gradle.properties"
call .\gradlew.bat test
pause
goto menu

:run_50
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=50' | Set-Content gradle.properties"
call .\gradlew.bat test
pause
goto menu

:run_one
set /p runner="Numero del runner (01-50): "
powershell -Command "(Get-Content gradle.properties) -replace '^maxParallelForks=.*', 'maxParallelForks=1' | Set-Content gradle.properties"
call .\gradlew.bat test --tests "com.sara.automation.runners.CasesRunner%runner%"
pause
goto menu

:report
if exist "target\site\serenity\index.html" (
    start target\site\serenity\index.html
) else (
    echo No hay reporte. Ejecuta primero los tests.
    pause
)
goto menu

:end
exit /b 0
