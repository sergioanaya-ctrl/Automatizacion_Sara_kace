@echo off
REM ========================================================
REM Ejecutor de Pruebas - PORTABLE (descarga deps automático)
REM ========================================================
REM Este script es PORTABLE: funciona en cualquier máquina
REM - Descarga dependencias automáticamente
REM - Compila el proyecto
REM - Luego permite elegir cuántos tests ejecutar

setlocal enabledelayedexpansion

REM ========================================================
REM FASE 1: Verificar y descargar dependencias
REM ========================================================

echo.
echo ========================================================
echo         DESCARGANDO DEPENDENCIAS (primera vez)
echo ========================================================
echo.

REM Intentar compilar - esto descargará todas las dependencias si no existen
echo Descargando Gradle y compilando proyecto...
echo (Esto puede tomar 2-5 minutos la primera vez)
echo.

call .\gradlew.bat compileTestJava -q
if %errorlevel% neq 0 (
    echo.
    echo ERROR: No se pudo descargar dependencias o compilar
    echo Verifica tu conexion a internet
    pause
    exit /b 1
)

echo.
echo ✓ Dependencias descargadas correctamente
echo ✓ Proyecto compilado
echo.

REM ========================================================
REM FASE 2: Mostrar menú de selección
REM ========================================================

:menu
cls
echo.
echo ========================================================
echo         AUTOMATIZACION SARA3 - EJECUCION DE PRUEBAS
echo ========================================================
echo.
echo 1. Ejecutar numero PERSONALIZADO de runners en paralelo
echo 2. Ejecutar 2 runners (paralelo)
echo 3. Ejecutar 4 runners (paralelo)
echo 4. Ejecutar 8 runners (paralelo)
echo 5. Ejecutar 12 runners (paralelo)
echo 6. Ejecutar todos los 50 runners
echo 7. Ejecutar solo 1 runner (test individual)
echo 8. Ver reporte de resultados (Serenity)
echo 9. Salir
echo.
set /p choice="Selecciona opcion (1-9): "

if "%choice%"=="1" goto custom_runners
if "%choice%"=="2" goto two_runners
if "%choice%"=="3" goto four_runners
if "%choice%"=="4" goto eight_runners
if "%choice%"=="5" goto twelve_runners
if "%choice%"=="6" goto all_runners
if "%choice%"=="7" goto one_runner
if "%choice%"=="8" goto report
if "%choice%"=="9" goto exit
echo Opcion invalida. Intenta de nuevo.
pause
goto menu

:custom_runners
cls
echo.
set /p num_runners="Numero de runners a ejecutar (1-50): "
if %num_runners% lss 1 (
    echo Error: Numero debe ser al menos 1
    pause
    goto menu
)
if %num_runners% gtr 50 (
    echo Error: Numero maximo es 50
    pause
    goto menu
)
echo.
echo Configurando maxParallelForks=%num_runners% en gradle.properties...
(
    for /f "tokens=*" %%A in (gradle.properties) do (
        if "%%A"=="maxParallelForks=2" (
            echo maxParallelForks=%num_runners%
        ) else (
            echo %%A
        )
    )
) > gradle.properties.tmp
move /y gradle.properties.tmp gradle.properties > nul
echo.
echo Ejecutando %num_runners% runners en paralelo...
echo Espera a que terminen todos los tests...
echo.
call .\gradlew.bat test
if %errorlevel% equ 0 (
    echo.
    echo ✓ Tests completados exitosamente
    echo Los resultados están en: target/site/serenity/index.html
) else (
    echo.
    echo ✗ Algunos tests fallaron
    echo Revisa los logs para más detalles
)
pause
goto menu

:two_runners
cls
echo.
echo Configurando 2 runners en paralelo...
(
    for /f "tokens=*" %%A in (gradle.properties) do (
        if "%%A"=="maxParallelForks=2" (
            echo maxParallelForks=2
        ) else (
            echo %%A
        )
    )
) > gradle.properties.tmp
move /y gradle.properties.tmp gradle.properties > nul
echo.
echo Ejecutando 2 runners en paralelo...
echo.
call .\gradlew.bat test
if %errorlevel% equ 0 (
    echo.
    echo ✓ Tests completados exitosamente
    echo Los resultados están en: target/site/serenity/index.html
) else (
    echo.
    echo ✗ Algunos tests fallaron
)
pause
goto menu

:four_runners
cls
echo.
echo Configurando 4 runners en paralelo...
(
    for /f "tokens=*" %%A in (gradle.properties) do (
        if "%%A"=="maxParallelForks=2" (
            echo maxParallelForks=4
        ) else (
            echo %%A
        )
    )
) > gradle.properties.tmp
move /y gradle.properties.tmp gradle.properties > nul
echo.
echo Ejecutando 4 runners en paralelo...
echo.
call .\gradlew.bat test
if %errorlevel% equ 0 (
    echo.
    echo ✓ Tests completados exitosamente
    echo Los resultados están en: target/site/serenity/index.html
) else (
    echo.
    echo ✗ Algunos tests fallaron
)
pause
goto menu

:eight_runners
cls
echo.
echo Configurando 8 runners en paralelo...
(
    for /f "tokens=*" %%A in (gradle.properties) do (
        if "%%A"=="maxParallelForks=2" (
            echo maxParallelForks=8
        ) else (
            echo %%A
        )
    )
) > gradle.properties.tmp
move /y gradle.properties.tmp gradle.properties > nul
echo.
echo Ejecutando 8 runners en paralelo...
echo.
call .\gradlew.bat test
if %errorlevel% equ 0 (
    echo.
    echo ✓ Tests completados exitosamente
    echo Los resultados están en: target/site/serenity/index.html
) else (
    echo.
    echo ✗ Algunos tests fallaron
)
pause
goto menu

:twelve_runners
cls
echo.
echo Configurando 12 runners en paralelo...
(
    for /f "tokens=*" %%A in (gradle.properties) do (
        if "%%A"=="maxParallelForks=2" (
            echo maxParallelForks=12
        ) else (
            echo %%A
        )
    )
) > gradle.properties.tmp
move /y gradle.properties.tmp gradle.properties > nul
echo.
echo Ejecutando 12 runners en paralelo...
echo.
call .\gradlew.bat test
if %errorlevel% equ 0 (
    echo.
    echo ✓ Tests completados exitosamente
    echo Los resultados están en: target/site/serenity/index.html
) else (
    echo.
    echo ✗ Algunos tests fallaron
)
pause
goto menu

:all_runners
cls
echo.
echo Configurando 50 runners en paralelo...
echo ADVERTENCIA: Esto requiere mucha memoria (minimo 8 GB RAM)
echo.
(
    for /f "tokens=*" %%A in (gradle.properties) do (
        if "%%A"=="maxParallelForks=2" (
            echo maxParallelForks=50
        ) else (
            echo %%A
        )
    )
) > gradle.properties.tmp
move /y gradle.properties.tmp gradle.properties > nul
echo.
echo Ejecutando 50 runners en paralelo...
echo Esto puede tomar 15-30 minutos...
echo.
call .\gradlew.bat test
if %errorlevel% equ 0 (
    echo.
    echo ✓ Tests completados exitosamente
    echo Los resultados están en: target/site/serenity/index.html
) else (
    echo.
    echo ✗ Algunos tests fallaron
)
pause
goto menu

:one_runner
cls
echo.
set /p runner="Numero del runner (01-50): "
if "%runner%"=="" (
    echo Error: Debes ingresar un numero
    pause
    goto menu
)
echo.
echo Ejecutando CasesRunner%runner% (sin paralelismo)...
(
    for /f "tokens=*" %%A in (gradle.properties) do (
        if "%%A"=="maxParallelForks=2" (
            echo maxParallelForks=1
        ) else (
            echo %%A
        )
    )
) > gradle.properties.tmp
move /y gradle.properties.tmp gradle.properties > nul
echo.
call .\gradlew.bat test --tests "com.sara.automation.runners.CasesRunner%runner%"
if %errorlevel% equ 0 (
    echo.
    echo ✓ Test completado exitosamente
    echo Los resultados están en: target/site/serenity/index.html
) else (
    echo.
    echo ✗ Test falló
)
pause
goto menu

:report
cls
echo.
if exist "target\site\serenity\index.html" (
    echo Abriendo reporte Serenity...
    echo.
    start target\site\serenity\index.html
    echo Espera a que se abra el navegador...
    timeout /t 3 /nobreak
) else (
    echo No se encontro reporte.
    echo Ejecuta primero algunos tests (opciones 2-7)
    echo.
    pause
)
goto menu

:exit
echo.
echo ========================================================
echo Hasta luego! Recuerda que tus credenciales están seguros
echo en: src/test/resources/credentials.properties
echo ========================================================
echo.
timeout /t 2 /nobreak
exit /b 0
