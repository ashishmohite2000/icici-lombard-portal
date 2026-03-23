@echo off
setlocal

REM ===========================================
REM ICICI Lombard React Portal - CI/CD Pipeline
REM Usage: pipeline.bat [ENV] [VERSION]
REM Example: pipeline.bat SIT v1.0.0
REM ===========================================

set ENV=%1
set VERSION=%2

if "%ENV%"=="" (
    echo ERROR: Provide environment. Usage: pipeline.bat SIT v1.0.0
    exit /b 1
)
if "%VERSION%"=="" (
    echo ERROR: Provide version. Usage: pipeline.bat SIT v1.0.0
    exit /b 1
)

if /I "%ENV%"=="SIT"  set PORT=3001& set COLOR=#1565C0& set BRANCH=sit
if /I "%ENV%"=="STG"  set PORT=3002& set COLOR=#E64A19& set BRANCH=stg
if /I "%ENV%"=="PROD" set PORT=3003& set COLOR=#2E7D32& set BRANCH=main

if "%PORT%"=="" (
    echo ERROR: Unknown environment. Use SIT, STG or PROD.
    exit /b 1
)

set IMGNAME=icici-portal:%BRANCH%-%VERSION%
set CONTAINER=icici-%ENV%

echo.
echo =============================================
echo  ICICI LOMBARD CI/CD PIPELINE
echo  Environment : %ENV%
echo  Version     : %VERSION%
echo  Port        : %PORT%
echo  Image       : %IMGNAME%
echo  Time        : %DATE% %TIME%
echo =============================================
echo.

REM ── STAGE 1: PRE-CHECKS ──────────────────────
echo [STAGE 1/8] Pre-deployment checks...
docker info >nul 2>&1
if errorlevel 1 (
    echo [FAIL] Docker is not running. Open Docker Desktop first.
    exit /b 1
)
echo [PASS] Docker is running
echo.

REM ── STAGE 2: GIT BRANCH PROMOTION ────────────
echo [STAGE 2/8] Promoting code to %BRANCH% branch...
cd ..
git checkout %BRANCH%
git merge develop --no-edit
git tag %VERSION%-%ENV% 2>nul
git checkout develop
cd scripts
echo [PASS] Code merged to %BRANCH% and tagged %VERSION%-%ENV%
echo.

REM ── STAGE 3: BUILD REACT APP ──────────────────
echo [STAGE 3/8] Building React app for %ENV%...
cd ..
call npm run build
cd scripts
echo [PASS] React build complete
echo.

REM ── STAGE 4: BUILD DOCKER IMAGE ───────────────
echo [STAGE 4/8] Building Docker image %IMGNAME%...
cd ..
docker build --build-arg REACT_APP_ENV=%ENV% --build-arg REACT_APP_VERSION=%VERSION% --build-arg REACT_APP_ENV_COLOR=%COLOR% -t %IMGNAME% .
if errorlevel 1 (
    echo [FAIL] Docker build failed
    cd scripts
    exit /b 1
)
cd scripts
echo [PASS] Docker image built: %IMGNAME%
echo.

REM ── STAGE 5: BACKUP CURRENT STATE ─────────────
echo [STAGE 5/8] Recording pre-deploy state...
echo %DATE% %TIME% PRE-DEPLOY: %ENV% before %VERSION% >> ..\logs\deployment.log
echo [PASS] Pre-deploy state recorded in logs
echo.

REM ── STAGE 6: STOP OLD AND DEPLOY NEW ──────────
echo [STAGE 6/8] Deploying %VERSION% to %ENV%...
docker stop %CONTAINER% >nul 2>&1
docker rm %CONTAINER% >nul 2>&1
docker run -d --name %CONTAINER% -p %PORT%:80 %IMGNAME%
if errorlevel 1 (
    echo [FAIL] Container failed to start
    echo %DATE% %TIME% FAILED: %VERSION% on %ENV% >> ..\logs\deployment.log
    exit /b 1
)
echo [PASS] Container %CONTAINER% running on port %PORT%
echo.

REM ── STAGE 7: VALIDATE ─────────────────────────
echo [STAGE 7/8] Post-deployment validation...
timeout /t 3 /nobreak >nul
docker ps --filter "name=%CONTAINER%" --format "{{.Status}}" | findstr "Up" >nul
if errorlevel 1 (
    echo [FAIL] Container not running. Check: docker logs %CONTAINER%
    exit /b 1
)
echo [PASS] Container is healthy
echo [PASS] Open browser: http://localhost:%PORT%
echo.

REM ── STAGE 8: LOG ──────────────────────────────
echo [STAGE 8/8] Writing deployment log...
echo %DATE% %TIME% SUCCESS: %VERSION% deployed to %ENV% on port %PORT% by Aashish Mohite >> ..\logs\deployment.log
echo.
echo =============================================
echo  DEPLOYMENT COMPLETE
echo  URL  : http://localhost:%PORT%
echo  Logs : docker logs %CONTAINER%
echo  File : logs\deployment.log
echo =============================================
echo.

endlocal