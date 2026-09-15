@echo off
title B-2 Spirit - Custom MOAB Inscription Tool
echo ============================================================
echo   B-2 SPIRIT GBU-43/B MOAB CUSTOM INSCRIBER (MAX 32 CHARS)
echo ============================================================
echo Type the message you want written on your MOAB bomb casing.
echo It will appear physically in 3D when you drop the bomb (F6 view)!
echo.
set /p USER_MSG="Enter Custom Inscription (Max 32 Chars): "
echo.
python "%~dp0set_moab_inscription.py" "%USER_MSG%"
echo.
pause
