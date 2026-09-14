@echo off
title B-2 Spirit — 3D Ordnance Personalization Studio
echo ============================================================
echo   B-2 SPIRIT ORDNANCE PERSONALIZATION STUDIO (PHASE 14)
echo ============================================================
echo Starting local bridge server and launching 3D Studio...
echo.

start "" "http://localhost:8082"
python "%~dp0ordnance_customizer\server.py"

pause
