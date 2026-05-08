@echo off
REM ========================================================
REM Script wrapper que mantiene ventana abierta
REM ========================================================
REM Este script ejecuta run_tests.bat y NO cierra la ventana
REM asi puedes ver cualquier error que ocurra

setlocal enabledelayedexpansion

echo.
echo ========================================================
echo EJECUTANDO: run_tests.bat
echo ========================================================
echo.

REM Ejecutar el script principal
call run_tests.bat

REM Si llegamos aquí, el script terminó
echo.
echo ========================================================
echo El script ha terminado
echo ========================================================
echo.
pause
