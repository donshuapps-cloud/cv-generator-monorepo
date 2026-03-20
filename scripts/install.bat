@echo off
setlocal enabledelayedexpansion
:: ====================================================================
:: INSTALADOR DEL GENERADOR DE CV - WINDOWS
:: Versión: 1.0
:: ====================================================================
title Instalador del Generador de CV
color 0B
set "SCRIPT_DIR=%~dp0"
set "REPO_ROOT=%SCRIPT_DIR%.."
set "LOG_FILE=%REPO_ROOT%\install.log"
echo ====================================================================
echo       INSTALADOR DEL GENERADOR DE CV - WINDOWS
echo ====================================================================
echo.
echo Log: %LOG_FILE%
echo.
:: --------------------------------------------------------------------
:: VERIFICAR PYTHON
:: --------------------------------------------------------------------
echo [INFO] Verificando Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python no esta instalado o no esta en el PATH.
    echo.
    echo Por favor, instala Python desde: https://www.python.org/downloads/
    echo Asegurate de marcar "Add Python to PATH" durante la instalacion.
    echo.
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('python --version 2^>^&1') do set PY_VERSION=%%i
echo [OK] Python: !PY_VERSION!
:: --------------------------------------------------------------------
:: VERIFICAR PIP
:: --------------------------------------------------------------------
echo [INFO] Verificando pip...
pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] pip no esta instalado.
    exit /b 1
)
for /f "tokens=*" %%i in ('pip --version') do set PIP_VERSION=%%i
echo [OK] pip: !PIP_VERSION!
:: --------------------------------------------------------------------
:: VERIFICAR LATEX (opcional)
:: --------------------------------------------------------------------
echo [INFO] Verificando LaTeX (pdflatex)...
pdflatex --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] LaTeX (pdflatex) no encontrado.
    echo           Para compilar PDF, instala MiKTeX desde: https://miktex.org/
    echo.
    set "HAS_PDFLATEX=0"
) else (
    echo [OK] LaTeX encontrado
    set "HAS_PDFLATEX=1"
)
:: --------------------------------------------------------------------
:: INSTALAR PYYAML
:: --------------------------------------------------------------------
echo [INFO] Instalando PyYAML...
pip install pyyaml > "%LOG_FILE%" 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Error al instalar PyYAML
    type "%LOG_FILE%"
    pause
    exit /b 1
) else (
    echo [OK] PyYAML instalado correctamente
)
:: --------------------------------------------------------------------
:: CREAR ACCESO DIRECTO (OPCIONAL)
:: --------------------------------------------------------------------
echo [INFO] Creando acceso directo...
set "SHORTCUT=%USERPROFILE%\Desktop\Generar CV.lnk"
set "TARGET=%REPO_ROOT%\packages\cli\generar-cv.bat"
set "WORKDIR=%REPO_ROOT%\packages\cli"
if exist "%TARGET%" (
    echo [OK] Script encontrado: %TARGET%
    :: Intentar crear acceso directo con PowerShell
    powershell -Command "$WS = New-Object -ComObject WScript.Shell; $SC = $WS.CreateShortcut('%SHORTCUT%'); $SC.TargetPath = '%TARGET%'; $SC.WorkingDirectory = '%WORKDIR%'; $SC.Save()" >nul 2>&1
    if exist "%SHORTCUT%" (
        echo [OK] Acceso directo creado en el escritorio
    ) else (
        echo [WARNING] No se pudo crear acceso directo
    )
) else (
    echo [WARNING] No se encuentra %TARGET%
)
:: --------------------------------------------------------------------
:: CREAR ARCHIVO DE ACTIVACION
:: --------------------------------------------------------------------
echo [INFO] Creando archivo de activacion...
set "ACTIVATE_CMD=%REPO_ROOT%\activar-cv.cmd"
(
    echo @echo off
    echo echo Activando entorno CV Generator...
    echo echo.
    echo echo Para usar el generador:
    echo echo   1. cd packages\cli
    echo echo   2. generar-cv.bat
    echo echo.
    echo cmd /k
) > "%ACTIVATE_CMD%"
echo [OK] Archivo de activacion creado: %ACTIVATE_CMD%
:: --------------------------------------------------------------------
:: RESUMEN FINAL
:: --------------------------------------------------------------------
echo.
echo ====================================================================
echo                     INSTALACION COMPLETADA
echo ====================================================================
echo.
echo 📊 RESUMEN:
echo    📁 Repositorio: %REPO_ROOT%
echo    🐍 Python: %PY_VERSION%
echo    📦 PyYAML: Instalado
if "%HAS_PDFLATEX%"=="1" (echo    📄 LaTeX: OK) else (echo    📄 LaTeX: No instalado)
echo.
echo 📋 PROXIMOS PASOS:
echo    1. Abre una nueva terminal
echo    2. Ejecuta: %ACTIVATE_CMD%
echo    3. Navega a: cd packages\cli
echo    4. Edita tus datos: notepad datos\datos.yaml
echo    5. Genera tu CV: generar-cv.bat
echo.
echo ====================================================================
echo              ✅✅ INSTALACION EXITOSA ✅✅
echo ====================================================================
echo.
pause
