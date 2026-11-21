@echo off
chcp 65001 >nul 2>nul
setlocal
cd /d "%~dp0"
title 쇼츠 메이커 - 로컬 영상 서버
color 0B

echo ==========================================================
echo    쇼츠 메이커  -  짤 + 음성 + 자막 = 9:16 영상
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
echo [1/4] 처음 한 번만 준비합니다. (2~4분 걸려요)
echo       가상환경을 만드는 중...
%PYEXE% -m venv .venv
if errorlevel 1 goto venv_fail
goto check_pkg

:have_venv
echo [1/4] 준비된 환경을 찾았습니다.

:check_pkg
".venv\Scripts\python.exe" -c "import imageio_ffmpeg, PIL" >nul 2>nul
if not errorlevel 1 goto check_ffmpeg

echo [2/4] 필요한 패키지(Pillow, FFmpeg)를 설치하는 중...
".venv\Scripts\python.exe" -m pip install --upgrade pip --disable-pip-version-check -q
".venv\Scripts\python.exe" -m pip install --disable-pip-version-check -q -r requirements.txt
if errorlevel 1 goto pip_fail

:check_ffmpeg
echo [3/4] FFmpeg 실행 파일을 확인하는 중...
".venv\Scripts\python.exe" -c "import imageio_ffmpeg,sys; p=imageio_ffmpeg.get_ffmpeg_exe(); sys.exit(0 if p else 1)" >nul 2>nul
if errorlevel 1 goto pip_fail

echo [4/4] 서버를 시작합니다. 잠시 뒤 브라우저가 열립니다.
echo.
echo    * 이 검은 창을 닫으면 서버가 꺼집니다.
echo    * 주소: http://127.0.0.1:8766
echo    * 만든 영상은 output 폴더에도 저장됩니다.
echo.
".venv\Scripts\python.exe" server.py
goto end

:no_files
echo [문제] server.py 를 찾을 수 없습니다.
echo        ZIP 압축을 푼 폴더 안에서 실행해 주세요.
echo.
pause
goto end

:no_python
echo.
echo [문제] Python 이 설치되어 있지 않습니다.
echo.
echo   1) https://www.python.org/downloads/windows/ 접속
echo   2) "Download Python 3.12" 설치
echo   3) 설치 첫 화면에서 "Add python.exe to PATH" 를 꼭 체크
echo   4) 이 창을 닫고 실행하기.bat 을 다시 더블클릭
echo.
pause
goto end

:old_python
echo.
echo [문제] Python 버전이 너무 낮습니다. 3.9 이상이 필요합니다.
echo        https://www.python.org/downloads/windows/ 에서 새로 설치해 주세요.
echo.
pause
goto end

:venv_fail
echo.
echo [문제] 가상환경(.venv)을 만들지 못했습니다.
echo        폴더 경로에 특수문자가 있거나 권한 문제일 수 있습니다.
echo        압축을 C:\shorts-maker 처럼 단순한 경로에 다시 풀어 보세요.
echo.
pause
goto end

:pip_fail
echo.
echo [문제] 패키지 설치에 실패했습니다. (인터넷 연결을 확인해 주세요)
echo        다시 실행하면 이어서 설치합니다.
echo        사내망/방화벽에서 pip 를 막는 경우 관리자에게 문의하세요.
echo.
pause
goto end

:end
echo.
echo 서버가 종료되었습니다. 이 창은 닫아도 됩니다.
pause >nul
exit /b 0
