@echo off
REM ============================================================
REM SMD-CHD - SMD Computer Health Device
REM Main Launcher Batch Script
REM ============================================================

title SMD-CHD - SMD Computer Health Device

REM Change to script directory
cd /d "%~dp0"

REM Run PowerShell with the main script
REM -NoProfile: Don't load user profile
REM -ExecutionPolicy Bypass: Allow script execution
REM -File: Execute the specified file

powershell -NoProfile -ExecutionPolicy Bypass -File "src\SMD-CHD.ps1"

REM Pause to show any final messages
pause
