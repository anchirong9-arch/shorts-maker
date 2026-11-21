@echo off
rem English-named launcher (same as 실행하기.bat) in case the Korean filename is mangled.
chcp 65001 >nul 2>nul
setlocal
cd /d "%~dp0"
title Shorts Maker - local video server
color 0B

echo ==========================================================
echo    Shorts Maker  -  images + voice + subtitles = 9:16 MP4
echo ==========================================================
echo.

if not exist "server.py" goto no_files

set "PYEXE="
where py >nul 2>nul
if errorlevel 1 goto try_python
py -3 -c "import sys" >nul 2>nul
if errorlevel 1 goto try_python
set "PYEXE=py -3"
goto python_ready

:try_python
where python >nul 2>nul
if errorlevel 1 goto no_python
set "PYEXE=python"

:python_ready
%PYEXE% -c "import sys;sys.exit(0 if sys.version_info>=(3,9) else 1)" >nul 2>nul
if errorlevel 1 goto old_python

if exist ".venv\Scripts\python.exe" goto have_venv
echo [1/4] First run: creating virtual environment (2-4 min)...
%PYEXE% -m venv .venv
if errorlevel 1 goto venv_fail
goto check_pkg

:have_venv
echo [1/4] Found existing environment.

:check_pkg
".venv\Scripts\python.exe" -c "import imageio_ffmpeg, PIL" >nul 2>nul
if not errorlevel 1 goto check_ffmpeg

echo [2/4] Installing Pillow and FFmpeg...
".venv\Scripts\python.exe" -m pip install --upgrade pip --disable-pip-version-check -q
".venv\Scripts\python.exe" -m pip install --disable-pip-version-check -q -r requirements.txt
if errorlevel 1 goto pip_fail

:check_ffmpeg
echo [3/4] Checking the FFmpeg binary...
".venv\Scripts\python.exe" -c "import imageio_ffmpeg,sys; p=imageio_ffmpeg.get_ffmpeg_exe(); sys.exit(0 if p else 1)" >nul 2>nul
if errorlevel 1 goto pip_fail

echo [4/4] Starting the server. A browser window will open shortly.
echo.
echo    * Closing this window stops the server.
echo    * Address: http://127.0.0.1:8766
echo    * Finished videos are also saved in the output folder.
echo.
".venv\Scripts\python.exe" server.py
goto end

:no_files
echo [ERROR] server.py not found. Please run this from the unzipped folder.
echo.
pause
goto end

:no_python
echo.
echo [ERROR] Python is not installed.
echo   1) Open https://www.python.org/downloads/windows/
echo   2) Install Python 3.12
echo   3) Check "Add python.exe to PATH" during setup
echo   4) Close this window and run this file again
echo.
pause
goto end

:old_python
echo.
echo [ERROR] Python 3.9 or newer is required.
echo.
pause
goto end

:venv_fail
echo.
echo [ERROR] Could not create .venv. Try unzipping to a simple path like C:\shorts-maker
echo.
pause
goto end

:pip_fail
echo.
echo [ERROR] Package install failed. Check your internet connection and try again.
echo.
pause
goto end

:end
echo.
echo Server stopped. You can close this window.
pause >nul
exit /b 0
