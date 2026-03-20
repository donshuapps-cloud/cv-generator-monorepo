@echo off
setlocal enabledelayedexpansion
:: ====================================================================
:: GENERADOR AUTOMATICO DE CURRICULUM VITAE - WINDOWS
:: Version: 8.1
:: ====================================================================
title Generador de CV
set "SCRIPT_DIR=%~dp0"
set "TIMESTAMP=%DATE:/=%-%TIME::=%"
set "TIMESTAMP=%TIMESTAMP: =0%"
set "LOG_FILE=%SCRIPT_DIR%cv-generator-%TIMESTAMP%.log"
set "ERROR_COUNT=0"
set "WARNING_COUNT=0"
:: Colores (con codigos ANSI en Windows 10+)
set "BLUE=[94m"
set "GREEN=[92m"
set "RED=[91m"
set "YELLOW=[93m"
set "PURPLE=[95m"
set "CYAN=[96m"
set "NC=[0m"
:: --------------------------------------------------------------------
:: FUNCIONES
:: --------------------------------------------------------------------
:print_msg
echo %BLUE%[%TIME%]%NC% %* | tee -a "%LOG_FILE%"
goto :eof
:print_success
echo %GREEN%[OK]%NC% %* | tee -a "%LOG_FILE%"
goto :eof
:print_error
echo %RED%[ERROR]%NC% %* | tee -a "%LOG_FILE%"
set /a ERROR_COUNT+=1
goto :eof
:print_warning
echo %YELLOW%[WARNING]%NC% %* | tee -a "%LOG_FILE%"
set /a WARNING_COUNT+=1
goto :eof
:print_section
echo.
echo %PURPLE%====================================================================%NC%
echo %CYAN% %*%NC%
echo %PURPLE%====================================================================%NC%
goto :eof
:check_dependency
where %1 >nul 2>&1
if %errorlevel% neq 0 (
    call :print_error "%1 no encontrado"
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('%1 --version 2^>^&1 ^| findstr /i "version"') do set "VERSION=%%i"
    call :print_success "%1: !VERSION!"
    exit /b 0
)
:: --------------------------------------------------------------------
:: INICIO
:: --------------------------------------------------------------------
cls
echo.
echo %PURPLE%====================================================================%NC%
echo         GENERADOR AUTOMATICO DE CURRICULUM VITAE - WINDOWS
echo %PURPLE%====================================================================%NC%
echo.
echo Log file: %LOG_FILE%
echo.
:: --------------------------------------------------------------------
:: VERIFICAR DEPENDENCIAS
:: --------------------------------------------------------------------
call :print_section "VERIFICANDO DEPENDENCIAS"
call :check_dependency python
if %errorlevel% neq 0 exit /b 1
call :check_dependency pip
if %errorlevel% neq 0 (
    call :print_warning "pip no encontrado"
)
:: Verificar PyYAML
call :print_msg "Verificando PyYAML..."
python -c "import yaml" 2>nul
if %errorlevel% neq 0 (
    call :print_warning "PyYAML no instalado, instalando..."
    pip install pyyaml >> "%LOG_FILE%" 2>&1
    if %errorlevel% neq 0 (
        call :print_error "Error al instalar PyYAML"
        exit /b 1
    ) else (
        call :print_success "PyYAML instalado"
    )
) else (
    call :print_success "PyYAML OK"
)
:: Verificar pdflatex
where pdflatex >nul 2>&1
if %errorlevel% equ 0 (
    set "HAS_PDFLATEX=1"
    call :print_success "pdflatex encontrado"
) else (
    set "HAS_PDFLATEX=0"
    call :print_warning "pdflatex no encontrado - No se generara PDF"
)
:: --------------------------------------------------------------------
:: VERIFICAR ESTRUCTURA DE ARCHIVOS
:: --------------------------------------------------------------------
call :print_section "VERIFICANDO ESTRUCTURA DE ARCHIVOS"
:: Carpeta datos
if not exist "datos" (
    call :print_warning "Carpeta 'datos' no encontrada, creando..."
    mkdir datos
)
:: datos.yaml
if exist "datos.yaml" (
    call :print_msg "Moviendo datos.yaml a carpeta datos/"
    move datos.yaml datos\ >nul
    call :print_success "datos.yaml movido"
) else if exist "datos\datos.yaml" (
    call :print_success "datos.yaml encontrado"
) else (
    call :print_error "No se encuentra datos.yaml"
    exit /b 1
)
:: Mostrar preview
call :print_msg "Contenido de datos.yaml:"
echo ----------------------------------------
type datos\datos.yaml | findstr /v "^#" | more
echo ----------------------------------------
:: Foto
if exist "foto-perfil.jpg" (
    call :print_success "foto-perfil.jpg encontrada"
    set "HAS_PHOTO=1"
) else if exist "datos\foto-perfil.jpg" (
    call :print_msg "Moviendo foto desde carpeta datos/"
    move datos\foto-perfil.jpg . >nul
    call :print_success "foto-perfil.jpg movida"
    set "HAS_PHOTO=1"
) else (
    call :print_warning "foto-perfil.jpg no encontrada - CV sin foto"
    set "HAS_PHOTO=0"
)
:: Clase LaTeX
if not exist "twentysecondcv-espanol.cls" (
    call :print_error "No se encuentra twentysecondcv-espanol.cls"
    exit /b 1
) else (
    call :print_success "twentysecondcv-espanol.cls encontrado"
)
:: --------------------------------------------------------------------
:: GENERAR CV DESDE YAML
:: --------------------------------------------------------------------
call :print_section "GENERANDO CV DESDE YAML"
if not exist "yaml2latex.py" (
    call :print_error "No se encuentra yaml2latex.py"
    exit /b 1
)
call :print_msg "Ejecutando yaml2latex.py..."
cd datos
python ..\yaml2latex.py datos.yaml >> "%LOG_FILE%" 2>&1
cd ..
if not exist "cv-completo.tex" (
    if exist "datos\cv-completo.tex" (
        move datos\cv-completo.tex . >nul
    ) else (
        call :print_error "No se genero cv-completo.tex"
        exit /b 1
    )
)
call :print_success "cv-completo.tex generado correctamente"
:: --------------------------------------------------------------------
:: CORREGIR HABILIDADES
:: --------------------------------------------------------------------
call :print_section "VERIFICANDO HABILIDADES"
echo Habilidades generadas:
findstr /i "habilidades" cv-completo.tex | findstr /i "Limpiezayorden" >nul
if %errorlevel% equ 0 (
    call :print_warning "Habilidades sin espacios detectadas - corrigiendo..."
    powershell -Command "(Get-Content cv-completo.tex) -replace 'Limpiezayorden', 'Limpieza y orden' | Set-Content cv-completo.tex"
    powershell -Command "(Get-Content cv-completo.tex) -replace 'Trabajoenequipo', 'Trabajo en equipo' | Set-Content cv-completo.tex"
    powershell -Command "(Get-Content cv-completo.tex) -replace 'Atencionalcliente', 'Atencion al cliente' | Set-Content cv-completo.tex"
    call :print_success "Habilidades corregidas"
) else (
    call :print_success "Habilidades OK"
)
:: --------------------------------------------------------------------
:: COMPILAR CV
:: --------------------------------------------------------------------
call :print_section "COMPILANDO CV"
if "%HAS_PDFLATEX%"=="1" (
    :: Limpiar temporales
    del *.aux *.log *.out *.toc 2>nul
    call :print_msg "Compilacion 1/3..."
    pdflatex -interaction=nonstopmode cv-completo.tex >> "%LOG_FILE%" 2>&1
    call :print_msg "Compilacion 2/3..."
    pdflatex -interaction=nonstopmode cv-completo.tex >> "%LOG_FILE%" 2>&1
    call :print_msg "Compilacion 3/3..."
    pdflatex -interaction=nonstopmode cv-completo.tex >> "%LOG_FILE%" 2>&1
    if exist "cv-completo.pdf" (
        call :print_success "PDF GENERADO: cv-completo.pdf"
        for %%i in (cv-completo.pdf) do set "PDF_SIZE=%%~zi"
        set /a "PDF_SIZE_KB=!PDF_SIZE! / 1024"
        echo    📄 Tamaño: !PDF_SIZE_KB! KB
        :: Abrir PDF
        start cv-completo.pdf
    ) else (
        call :print_error "ERROR: No se genero el PDF"
        echo Ultimas lineas del log:
        type cv-completo.log | findstr /i "error" | more
    )
) else (
    call :print_warning "pdflatex no instalado - No se genero PDF"
    echo    Para compilar manualmente sube cv-completo.tex a overleaf.com
)
:: --------------------------------------------------------------------
:: RESUMEN FINAL
:: --------------------------------------------------------------------
call :print_section "RESUMEN FINAL"
echo.
echo 📊 ESTADISTICAS:
echo    ⚠️  Warnings: %WARNING_COUNT%
echo    ❌ Errores: %ERROR_COUNT%
echo.
echo 📁 ARCHIVOS GENERADOS:
echo    📄 cv-completo.tex
if exist "cv-completo.pdf" echo    📄 cv-completo.pdf
echo    📄 %LOG_FILE%
echo.
echo %PURPLE%====================================================================%NC%
if exist "cv-completo.pdf" (
    echo %GREEN%✅✅✅ PROCESO COMPLETADO CON EXITO ✅✅✅%NC%
) else (
    echo %RED%❌❌❌ PROCESO FALLIDO ❌❌❌%NC%
    echo    El archivo .tex se genero correctamente pero no se pudo compilar
)
echo %PURPLE%====================================================================%NC%
echo.
pause
