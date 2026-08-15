@echo off
setlocal EnableExtensions
title SayLow Optimizer Launcher

cd /d "%~dp0"

:: Checking PowerShell script
set "GUI=%~dp0SayLow_GUI_v4.ps1"

if not exist "%GUI%" (
    echo [ERROR] File not found: SayLow_GUI_v4.ps1
    echo Please place SayLow_GUI_v4.ps1 near this BAT file.
    pause
    exit /b 1
)

:: Elevate to Administrator if needed and run PS1
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%GUI%""' -Verb RunAs"
    exit /b 0
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%GUI%"
exit /b 0
