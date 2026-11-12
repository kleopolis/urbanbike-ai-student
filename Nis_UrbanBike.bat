@echo off
setlocal
cd /d "%~dp0"
title UrbanBike AI
echo ==========================================
echo   UrbanBike AI - nisja e aplikacionit
echo ==========================================

rem 1) Gjej Python 3.12 (ose Python tjeter si rezerve)
set "PYLAUNCH="
py -3.12 --version >nul 2>&1 && set "PYLAUNCH=py -3.12"
if not defined PYLAUNCH (
    python --version >nul 2>&1 && set "PYLAUNCH=python"
)
if not defined PYLAUNCH (
    echo.
    echo GABIM: Python nuk u gjet.
    echo Instaloje Python 3.12 nga https://www.python.org/downloads/windows/
    echo dhe ekzekuto perseri kete skedar.
    pause
    exit /b 1
)

rem 2) Krijo mjedisin .venv nese mungon
if not exist ".venv\Scripts\python.exe" (
    echo.
    echo [1/4] Po krijohet mjedisi .venv ...
    %PYLAUNCH% -m venv .venv
    if errorlevel 1 goto :fail
)

rem 3) Instalo bibliotekat nje here (shenjoje me skedar)
if not exist ".venv\.deps_ok" (
    echo.
    echo [2/4] Po instalohen bibliotekat (kerkon internet, vetem here e pare) ...
    ".venv\Scripts\python.exe" -m pip install --upgrade pip
    ".venv\Scripts\python.exe" -m pip install -r requirements.txt
    if errorlevel 1 goto :fail
    echo ok> ".venv\.deps_ok"
)

rem 4) Trajno modelin nese nuk ekziston
if not exist "models\regression.joblib" (
    echo.
    echo [3/4] Po ekzekutohen fazat 01-04 (pastrim, grafike, modele) ...
    ".venv\Scripts\python.exe" run_all.py
    if errorlevel 1 goto :fail
)

rem 5) Hap shfletuesin pas 3 sekondash dhe nis serverin
echo.
echo [4/4] Po niset aplikacioni ...
echo Shfletuesi do te hapet te http://127.0.0.1:8000
echo Per ta ndaluar mbyll kete dritare ose shtyp Ctrl+C.
echo.
start "" cmd /c "timeout /t 3 /nobreak >nul & start http://127.0.0.1:8000"
".venv\Scripts\python.exe" app.py
echo.
pause
exit /b 0

:fail
echo.
echo GABIM: nje hap deshtoi. Lexo mesazhin siper.
echo Nese po ri-provon, fshi dosjen .venv dhe ekzekuto perseri.
pause
exit /b 1
