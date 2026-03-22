#!/bin/bash
#====================================================================
# INSTALADOR DEL GENERADOR DE CV - LINUX/macOS
# Versión: 2.0 - CORREGIDA (genera correctamente generar-cv.sh)
#====================================================================
# Configuración de colores
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
CLI_DIR="$REPO_ROOT/packages/cli"
CORE_DIR="$REPO_ROOT/packages/core"
LOG_FILE="$REPO_ROOT/install.log"
ERROR_COUNT=0
WARNING_COUNT=0
print_msg() {
    echo -e "${BLUE}[$(date +%H:%M:%S)]${NC} $1" | tee -a "$LOG_FILE"
}
print_success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_FILE"
}
print_error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$LOG_FILE"
    ((ERROR_COUNT++))
}
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$LOG_FILE"
    ((WARNING_COUNT++))
}
print_section() {
    echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}🔷 $1${NC}" | tee -a "$LOG_FILE"
    echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
}
check_command() {
    command -v $1 &> /dev/null
}
#====================================================================
# INICIO
#====================================================================
clear
echo -e "${PURPLE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     INSTALADOR DEL GENERADOR DE CV - LINUX/macOS            ║"
echo "║                       Versión 2.0                           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo "Log file: $LOG_FILE"
echo
#--------------------------------------------------------------------
# VERIFICAR SISTEMA OPERATIVO
#--------------------------------------------------------------------
print_section "VERIFICANDO SISTEMA OPERATIVO"
OS="$(uname -s)"
case "$OS" in
    Linux*)     
        print_success "Sistema: Linux"
        OS_FAMILY="linux"
        ;;
    Darwin*)    
        print_success "Sistema: macOS"
        OS_FAMILY="macos"
        ;;
    *)          
        print_error "Sistema no soportado: $OS"
        exit 1
        ;;
esac
#--------------------------------------------------------------------
# VERIFICAR DEPENDENCIAS BÁSICAS
#--------------------------------------------------------------------
print_section "VERIFICANDO DEPENDENCIAS BÁSICAS"
# Python
if check_command python3; then
    PY_VERSION=$(python3 --version 2>/dev/null | cut -d' ' -f2)
    print_success "Python3: $PY_VERSION"
else
    print_error "Python3 no está instalado"
    print_msg "Instalando Python3..."
    if [ "$OS_FAMILY" = "linux" ]; then
        sudo apt update && sudo apt install -y python3 python3-pip python3-venv
    elif [ "$OS_FAMILY" = "macos" ]; then
        if ! check_command brew; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install python
    fi
    if check_command python3; then
        print_success "Python3 instalado correctamente"
    else
        print_error "No se pudo instalar Python3"
        exit 1
    fi
fi
# pip
if check_command pip3; then
    PIP_VERSION=$(pip3 --version 2>/dev/null | cut -d' ' -f2)
    print_success "pip3: $PIP_VERSION"
else
    print_warning "pip3 no encontrado, instalando..."
    python3 -m ensurepip --upgrade
fi
# Git
if check_command git; then
    GIT_VERSION=$(git --version 2>/dev/null | cut -d' ' -f3)
    print_success "Git: $GIT_VERSION"
else
    print_warning "Git no está instalado"
    if [ "$OS_FAMILY" = "linux" ]; then
        sudo apt install -y git
    elif [ "$OS_FAMILY" = "macos" ]; then
        brew install git
    fi
fi
#--------------------------------------------------------------------
# VERIFICAR LATEX
#--------------------------------------------------------------------
print_section "VERIFICANDO LATEX"
if check_command pdflatex; then
    LATEX_VERSION=$(pdflatex --version 2>/dev/null | head -n1)
    print_success "LaTeX: $LATEX_VERSION"
    HAS_PDFLATEX=1
else
    print_warning "LaTeX (pdflatex) no está instalado"
    echo
    echo "Para compilar a PDF necesitas instalar LaTeX:"
    echo "  Linux:   sudo apt install texlive-latex-recommended texlive-latex-extra"
    echo "  macOS:   brew install --cask mactex"
    echo
    read -p "¿Deseas instalar LaTeX ahora? (s/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        if [ "$OS_FAMILY" = "linux" ]; then
            sudo apt install -y texlive-latex-recommended texlive-latex-extra
        elif [ "$OS_FAMILY" = "macos" ]; then
            brew install --cask mactex
        fi
        if check_command pdflatex; then
            print_success "LaTeX instalado correctamente"
            HAS_PDFLATEX=1
        else
            print_error "Error al instalar LaTeX"
            HAS_PDFLATEX=0
        fi
    else
        HAS_PDFLATEX=0
    fi
fi
#--------------------------------------------------------------------
# INSTALAR DEPENDENCIAS PYTHON
#--------------------------------------------------------------------
print_section "INSTALANDO DEPENDENCIAS PYTHON"
print_msg "Instalando PyYAML..."
pip3 install pyyaml >> "$LOG_FILE" 2>&1
if python3 -c "import yaml" 2>/dev/null; then
    print_success "PyYAML instalado correctamente"
else
    print_error "Error al instalar PyYAML"
    exit 1
fi
#--------------------------------------------------------------------
# VERIFICAR ESTRUCTURA DE ARCHIVOS
#--------------------------------------------------------------------
print_section "VERIFICANDO ESTRUCTURA DEL PROYECTO"
# Verificar que estamos en el repositorio correcto
if [ ! -d "$CLI_DIR" ]; then
    print_error "No se encuentra el directorio packages/cli"
    print_msg "Asegúrate de ejecutar este script desde la raíz del repositorio"
    exit 1
fi
print_success "Directorio CLI encontrado: $CLI_DIR"
#--------------------------------------------------------------------
# CREAR DIRECTORIO DE DATOS Y EJEMPLO
#--------------------------------------------------------------------
print_section "CONFIGURANDO DIRECTORIO DE DATOS"
# Crear directorio datos si no existe
if [ ! -d "$CLI_DIR/datos" ]; then
    print_msg "Creando directorio datos/"
    mkdir -p "$CLI_DIR/datos"
fi
# Copiar archivo de ejemplo si no existe
if [ ! -f "$CLI_DIR/datos/datos.yaml" ]; then
    if [ -f "$CORE_DIR/datos/ejemplo-completo.yaml" ]; then
        print_msg "Copiando ejemplo de CV a datos/datos.yaml"
        cp "$CORE_DIR/datos/ejemplo-completo.yaml" "$CLI_DIR/datos/datos.yaml"
        print_success "Archivo de ejemplo copiado"
    elif [ -f "$REPO_ROOT/ejemplo-completo.yaml" ]; then
        cp "$REPO_ROOT/ejemplo-completo.yaml" "$CLI_DIR/datos/datos.yaml"
        print_success "Archivo de ejemplo copiado"
    else
        print_warning "No se encontró archivo de ejemplo, creando archivo básico"
        cat > "$CLI_DIR/datos/datos.yaml" << 'EOF'
# Archivo de datos para CV - EDITAR CON TU INFORMACIÓN
persona:
  nombre: "Tu Nombre Completo"
  puesto: "Tu Puesto Profesional"
  cedula: "V-12345678"
  nacionalidad: "venezolana"
  fecha_nacimiento: "01/01/1990"
  direccion: "Tu dirección"
  telefono: "+58 412 1234567"
  email: "tu@email.com"
perfil: "Persona responsable, puntual y con gran disposición para el trabajo."
habilidades:
- nombre: "Responsabilidad"
  valor: 5
- nombre: "Trabajo en equipo"
  valor: 5
experiencia:
- fecha_inicio: "Ene/2023"
  fecha_fin: "actualidad"
  puesto: "Tu puesto"
  lugar: "Nombre de la empresa"
  descripcion:
  - "Descripción de tus responsabilidades"
EOF
        print_success "Archivo básico creado"
    fi
fi
# Verificar que existe la clase LaTeX
if [ ! -f "$CLI_DIR/twentysecondcv-espanol.cls" ]; then
    if [ -f "$CORE_DIR/twentysecondcv-espanol.cls" ]; then
        print_msg "Copiando clase LaTeX..."
        cp "$CORE_DIR/twentysecondcv-espanol.cls" "$CLI_DIR/"
        print_success "Clase LaTeX copiada"
    else
        print_error "No se encuentra twentysecondcv-espanol.cls"
        exit 1
    fi
fi
#--------------------------------------------------------------------
# CONFIGURAR PERMISOS Y CREAR ENLACES
#--------------------------------------------------------------------
print_section "CONFIGURANDO PERMISOS"
# Dar permisos de ejecución
chmod +x "$CLI_DIR/generar-cv.sh" 2>/dev/null || print_warning "No se encontró generar-cv.sh"
chmod +x "$CLI_DIR/yaml2latex.py" 2>/dev/null || print_warning "No se encontró yaml2latex.py"
# Verificar que generar-cv.sh existe, si no, crearlo
if [ ! -f "$CLI_DIR/generar-cv.sh" ]; then
    print_warning "generar-cv.sh no encontrado, creando..."
    cat > "$CLI_DIR/generar-cv.sh" << 'EOF'
#!/bin/bash
#====================================================================
# GENERADOR AUTOMÁTICO DE CURRÍCULUM VITAE
# Versión: 8.1 - CORREGIDO (detección de pdflatex)
#====================================================================
# Configuración de colores
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'
# Variables globales
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$SCRIPT_DIR/cv-generator-$TIMESTAMP.log"
ERROR_COUNT=0
WARNING_COUNT=0
#====================================================================
# FUNCIONES DE UTILIDAD
#====================================================================
print_msg() {
    echo -e "${BLUE}[$(date +%H:%M:%S)]${NC} $1" | tee -a "$LOG_FILE"
}
print_success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_FILE"
}
print_error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$LOG_FILE"
    ((ERROR_COUNT++))
}
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$LOG_FILE"
    ((WARNING_COUNT++))
}
print_section() {
    echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}🔷 $1${NC}" | tee -a "$LOG_FILE"
    echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
}
check_dependency() {
    if command -v $1 &> /dev/null; then
        version=$($1 --version 2>/dev/null | head -n1 | cut -d' ' -f3)
        print_success "$1: $version"
        return 0
    else
        print_error "$1 no está instalado"
        return 1
    fi
}
clean_temp_files() {
    print_msg "Limpiando archivos temporales..."
    rm -f *.aux *.log *.out *.toc *.lof *.lot *.bbl *.blg *.synctex.gz 2>/dev/null
    print_success "Archivos temporales eliminados"
}
#====================================================================
# INICIO
#====================================================================
clear
echo -e "${PURPLE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║       GENERADOR AUTOMÁTICO DE CURRÍCULUM VITAE              ║"
echo "║                    Versión 8.1 - CORREGIDO                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo "Log file: $LOG_FILE"
echo
#--------------------------------------------------------------------
# VERIFICAR DEPENDENCIAS
#--------------------------------------------------------------------
print_section "VERIFICANDO DEPENDENCIAS"
check_dependency python3 || exit 1
check_dependency pip3 || print_warning "pip3 no encontrado"
# CORRECCIÓN: Verificar pdflatex correctamente
if check_dependency pdflatex; then
    HAS_PDFLATEX=1
    print_success "pdflatex detectado correctamente"
else
    HAS_PDFLATEX=0
    print_warning "pdflatex no instalado - no se generará PDF"
fi
# Verificar PyYAML
print_msg "Verificando PyYAML..."
if ! python3 -c "import yaml" 2>/dev/null; then
    print_warning "PyYAML no instalado, instalando..."
    pip3 install pyyaml >> "$LOG_FILE" 2>&1
    if [ $? -eq 0 ]; then
        print_success "PyYAML instalado correctamente"
    else
        print_error "Error al instalar PyYAML"
        exit 1
    fi
else
    print_success "PyYAML OK"
fi
#--------------------------------------------------------------------
# VERIFICAR ESTRUCTURA DE ARCHIVOS
#--------------------------------------------------------------------
print_section "VERIFICANDO ESTRUCTURA DE ARCHIVOS"
# Carpeta datos
if [ ! -d "datos" ]; then
    print_warning "Carpeta 'datos' no encontrada, creando..."
    mkdir -p datos
fi
# datos.yaml
if [ -f "datos.yaml" ]; then
    print_msg "Moviendo datos.yaml a carpeta datos/"
    mv datos.yaml datos/
    print_success "datos.yaml movido a datos/"
elif [ -f "datos/datos.yaml" ]; then
    print_success "datos.yaml encontrado en carpeta datos/"
else
    print_error "No se encuentra datos.yaml"
    exit 1
fi
# Mostrar contenido del YAML
print_msg "Contenido de datos.yaml:"
echo "----------------------------------------"
cat datos/datos.yaml | grep -v "^#" | head -20
echo "----------------------------------------"
# Foto
if [ -f "foto-perfil.jpg" ]; then
    print_success "foto-perfil.jpg encontrada"
    HAS_PHOTO=1
elif [ -f "datos/foto-perfil.jpg" ]; then
    print_msg "Moviendo foto desde carpeta datos/"
    mv datos/foto-perfil.jpg .
    print_success "foto-perfil.jpg movida al directorio principal"
    HAS_PHOTO=1
else
    print_warning "foto-perfil.jpg no encontrada - CV sin foto"
    HAS_PHOTO=0
fi
# Clase LaTeX
if [ ! -f "twentysecondcv-espanol.cls" ]; then
    print_error "No se encuentra twentysecondcv-espanol.cls"
    exit 1
else
    print_success "twentysecondcv-espanol.cls encontrado"
fi
#--------------------------------------------------------------------
# GENERAR CV DESDE YAML
#--------------------------------------------------------------------
print_section "GENERANDO CV DESDE YAML"
if [ ! -f "yaml2latex.py" ]; then
    print_error "No se encuentra yaml2latex.py"
    exit 1
fi
print_msg "Ejecutando yaml2latex.py..."
cd datos
python3 ../yaml2latex.py datos.yaml 2>&1 | tee -a "$LOG_FILE"
cd ..
if [ ${PIPESTATUS[0]} -ne 0 ]; then
    print_error "Error al ejecutar yaml2latex.py"
    exit 1
fi
# Verificar que se generó cv-completo.tex
if [ ! -f "cv-completo.tex" ] && [ -f "datos/cv-completo.tex" ]; then
    mv datos/cv-completo.tex .
fi
if [ ! -f "cv-completo.tex" ]; then
    print_error "No se generó cv-completo.tex"
    exit 1
fi
print_success "cv-completo.tex generado correctamente"
#--------------------------------------------------------------------
# VERIFICAR HABILIDADES
#--------------------------------------------------------------------
print_section "VERIFICANDO HABILIDADES"
echo "📋 Habilidades generadas:"
grep -A10 "habilidades" cv-completo.tex | head -15
# Verificar que las habilidades tienen espacios
if grep -q "habilidades" cv-completo.tex; then
    if grep -q "Limpiezayorden" cv-completo.tex; then
        print_warning "Habilidades sin espacios detectadas - aplicando corrección manual"
        sed -i 's/Limpiezayorden/Limpieza y orden/g' cv-completo.tex
        sed -i 's/Trabajoenequipo/Trabajo en equipo/g' cv-completo.tex
        sed -i 's/Atencionalcliente/Atención al cliente/g' cv-completo.tex
        sed -i 's/Seguirinstrucciones/Seguir instrucciones/g' cv-completo.tex
        print_success "Habilidades corregidas manualmente"
    else
        print_success "Habilidades OK (con espacios)"
    fi
fi
#--------------------------------------------------------------------
# COMPILAR CV
#--------------------------------------------------------------------
print_section "COMPILANDO CV"
if [ $HAS_PDFLATEX -eq 1 ]; then
    clean_temp_files
    print_msg "Compilación 1/3..."
    pdflatex -interaction=nonstopmode cv-completo.tex >> "$LOG_FILE" 2>&1
    print_msg "Compilación 2/3..."
    pdflatex -interaction=nonstopmode cv-completo.tex >> "$LOG_FILE" 2>&1
    print_msg "Compilación 3/3..."
    pdflatex -interaction=nonstopmode cv-completo.tex 2>&1 | tee -a "$LOG_FILE"
    if [ -f "cv-completo.pdf" ]; then
        print_success "PDF GENERADO: cv-completo.pdf"
        PDF_SIZE=$(du -h cv-completo.pdf | cut -f1)
        PDF_PAGES=$(pdfinfo cv-completo.pdf 2>/dev/null | grep Pages | awk '{print $2}')
        echo "   📄 Tamaño: $PDF_SIZE" | tee -a "$LOG_FILE"
        [ ! -z "$PDF_PAGES" ] && echo "   📄 Páginas: $PDF_PAGES" | tee -a "$LOG_FILE"
        # Abrir PDF
        if command -v xdg-open &> /dev/null; then
            xdg-open cv-completo.pdf 2>/dev/null &
            print_msg "Abriendo PDF..."
        elif command -v open &> /dev/null; then
            open cv-completo.pdf 2>/dev/null &
        fi
    else
        print_error "ERROR: No se generó el PDF"
        echo "📋 Últimas 30 líneas del log:" | tee -a "$LOG_FILE"
        tail -30 cv-completo.log | tee -a "$LOG_FILE"
    fi
else
    print_warning "pdflatex no instalado - No se generó PDF"
    echo "   Para compilar manualmente sube cv-completo.tex a overleaf.com"
fi
#--------------------------------------------------------------------
# RESUMEN FINAL
#--------------------------------------------------------------------
print_section "RESUMEN FINAL"
echo "📊 ESTADÍSTICAS:" | tee -a "$LOG_FILE"
echo "   ⚠️  Warnings: $WARNING_COUNT" | tee -a "$LOG_FILE"
echo "   ❌ Errores: $ERROR_COUNT" | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"
echo "📁 ARCHIVOS GENERADOS:" | tee -a "$LOG_FILE"
echo "   📄 cv-completo.tex" | tee -a "$LOG_FILE"
[ -f "cv-completo.pdf" ] && echo "   📄 cv-completo.pdf" | tee -a "$LOG_FILE"
echo "   📄 $LOG_FILE" | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"
echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
if [ -f "cv-completo.pdf" ]; then
    echo -e "${GREEN}✅✅✅ PROCESO COMPLETADO CON ÉXITO ✅✅✅${NC}" | tee -a "$LOG_FILE"
else
    echo -e "${RED}❌❌❌ PROCESO FALLIDO ❌❌❌${NC}" | tee -a "$LOG_FILE"
    echo "   El archivo .tex se generó correctamente pero no se pudo compilar"
    echo "   Puedes compilarlo manualmente con: pdflatex cv-completo.tex"
fi
echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
#--------------------------------------------------------------------
# FIN
#--------------------------------------------------------------------
EOF
    chmod +x "$CLI_DIR/generar-cv.sh"
    print_success "generar-cv.sh creado correctamente"
fi
# Verificar que yaml2latex.py existe
if [ ! -f "$CLI_DIR/yaml2latex.py" ]; then
    print_warning "yaml2latex.py no encontrado, creando..."
    cat > "$CLI_DIR/yaml2latex.py" << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para convertir datos.yaml a LaTeX para CV
Versión: 9.0 - CORREGIDO: nuevos campos (cédula, nacionalidad)
"""
import yaml
import sys
import os
import re
from datetime import datetime
def cargar_yaml(archivo_yaml):
    """Carga el archivo YAML y retorna los datos"""
    try:
        with open(archivo_yaml, 'r', encoding='utf-8') as f:
            contenido = f.read()
            lineas = []
            for linea in contenido.split('\n'):
                if not linea.strip().startswith('#'):
                    lineas.append(linea)
            contenido_limpio = '\n'.join(lineas)
            return yaml.safe_load(contenido_limpio)
    except Exception as e:
        print(f"❌ Error al cargar YAML: {e}")
        sys.exit(1)
def escape_latex(texto):
    """Escapa caracteres especiales de LaTeX"""
    if not texto:
        return ""
    texto = str(texto)
    replacements = {
        '&': r'\&',
        '%': r'\%',
        '$': r'\$',
        '#': r'\#',
        '_': r'\_',
        '{': r'\{',
        '}': r'\}',
        '~': r'\textasciitilde{}',
        '^': r'\textasciicircum{}',
        '\\': r'\textbackslash{}',
    }
    for char, escaped in replacements.items():
        texto = texto.replace(char, escaped)
    return texto
def limpiar_telefono(telefono):
    """Limpia el teléfono de caracteres extraños"""
    if not telefono:
        return ""
    telefono = str(telefono)
    telefono = telefono.replace('\\textbackslash{}', '').replace('\\', '')
    telefono = telefono.replace('{', '').replace('}', '')
    return telefono.strip()
def formatear_habilidades(habilidades):
    """Formato para habilidades con espacios preservados"""
    if not habilidades:
        return ""
    lineas = []
    for i, h in enumerate(habilidades):
        if not isinstance(h, dict):
            continue
        nombre_original = h.get('nombre', '')
        if not nombre_original:
            continue
        nombre_seguro = escape_latex(nombre_original)
        try:
            valor = int(float(h.get('valor', 3)))
            valor = max(0, min(5, valor))
        except:
            valor = 3
        if i < len(habilidades) - 1:
            lineas.append(f"    {nombre_seguro}/{valor},")
        else:
            lineas.append(f"    {nombre_seguro}/{valor}")
    return "\n".join(lineas)
def formatear_lista(items):
    """Formato para makeList"""
    if not items:
        return ""
    lineas = []
    for item in items:
        if item and str(item).strip():
            lineas.append(f"    {escape_latex(str(item).strip())};%")
    return "\n".join(lineas)
def generar_cv_completo(datos):
    """Genera CV completo con todos los campos"""
    contenido = []
    persona = datos.get('persona', {})
    contenido.append("%" + "="*80)
    contenido.append("% CURRÍCULUM VITAE - GENERADO AUTOMÁTICAMENTE")
    contenido.append("% Generado el: " + datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    contenido.append("%" + "="*80)
    contenido.append("")
    contenido.append("\\documentclass[a4paper]{twentysecondcv-espanol}")
    contenido.append("")
    contenido.append("\\usepackage[utf8]{inputenc}")
    contenido.append("\\usepackage[spanish]{babel}")
    contenido.append("\\usepackage{anyfontsize}")
    contenido.append("")
    contenido.append(f"\\cvnombre{{{escape_latex(persona.get('nombre', ''))}}}")
    contenido.append(f"\\cvpuesto{{{escape_latex(persona.get('puesto', ''))}}}")
    cedula = persona.get('cedula', '')
    if cedula and str(cedula).strip():
        contenido.append(f"\\cvcedula{{{escape_latex(str(cedula).strip())}}}")
    else:
        contenido.append("\\cvcedula{}")
    nacionalidad = persona.get('nacionalidad', '')
    if nacionalidad and str(nacionalidad).strip():
        contenido.append(f"\\cvnacionalidad{{{escape_latex(str(nacionalidad).strip())}}}")
    else:
        contenido.append("\\cvnacionalidad{}")
    fecha_nac = persona.get('fecha_nacimiento', '')
    if fecha_nac and str(fecha_nac).strip():
        contenido.append(f"\\cvfecha{{{escape_latex(str(fecha_nac).strip())}}}")
    else:
        contenido.append("\\cvfecha{}")
    direccion = persona.get('direccion', '')
    if direccion:
        contenido.append(f"\\cvdireccion{{{escape_latex(direccion)}}}")
    else:
        contenido.append("\\cvdireccion{}")
    telefono = limpiar_telefono(persona.get('telefono', ''))
    if telefono:
        contenido.append(f"\\cvtelefono{{{telefono}}}")
    else:
        contenido.append("\\cvtelefono{}")
    email = persona.get('email', '')
    if email:
        contenido.append(f"\\cvemail{{{escape_latex(email)}}}")
    else:
        contenido.append("\\cvemail{}")
    contenido.append("")
    contenido.append("\\begin{document}")
    contenido.append("")
    perfil = datos.get('perfil', '')
    if perfil:
        contenido.append(f"\\perfil{{Perfil Profesional}}{{{escape_latex(perfil.strip())}}}")
        contenido.append("")
    sobre_mi = datos.get('sobre_mi', '')
    if sobre_mi:
        contenido.append(f"\\sobremi{{Sobre Mí}}{{{escape_latex(sobre_mi.strip())}}}")
        contenido.append("")
    intereses = datos.get('intereses', [])
    if intereses:
        intereses_proc = [escape_latex(str(i).strip()) for i in intereses if i]
        if intereses_proc:
            contenido.append(f"\\intereses{{Intereses}}{{{' • '.join(intereses_proc)}}}")
            contenido.append("")
    habilidades = datos.get('habilidades', [])
    if habilidades:
        habilidades_str = formatear_habilidades(habilidades)
        if habilidades_str:
            contenido.append("\\habilidades{%")
            contenido.append(habilidades_str)
            contenido.append("}")
            contenido.append("")
    contenido.append("\\crearperfil")
    contenido.append("")
    experiencia = datos.get('experiencia', [])
    if experiencia:
        contenido.append("\\section{Experiencia Laboral}")
        contenido.append("\\begin{veinte}")
        contenido.append("")
        for exp in experiencia:
            if not isinstance(exp, dict):
                continue
            fecha_ini = exp.get('fecha_inicio', '')
            fecha_fin = exp.get('fecha_fin', '')
            puesto = escape_latex(exp.get('puesto', ''))
            lugar = escape_latex(exp.get('lugar', ''))
            color_ini = exp.get('color_inicio', 'mainblue')
            color_fin = exp.get('color_fin', 'mainblue')
            desc = exp.get('descripcion', [])
            contenido.append(f"    \\veinteitemtiempo{{{color_ini}}}{{{color_fin}}}{{{fecha_ini}}}{{{fecha_fin}}}{{{puesto}}}{{{lugar}}}{{%")
            if desc:
                contenido.append("    \\makeList{%")
                contenido.append(formatear_lista(desc))
                contenido.append("    }")
            else:
                contenido.append("    \\makeList{}")
            contenido.append("    }")
            contenido.append("    ")
        contenido.append("\\end{veinte}")
        contenido.append("")
    educacion = datos.get('educacion', [])
    if educacion:
        contenido.append("\\section{Educación}")
        contenido.append("\\begin{veinte}")
        contenido.append("")
        for edu in educacion:
            if not isinstance(edu, dict):
                continue
            fecha_ini = edu.get('fecha_inicio', '')
            fecha_fin = edu.get('fecha_fin', '')
            titulo = escape_latex(edu.get('titulo', ''))
            institucion = escape_latex(edu.get('institucion', ''))
            descripcion = escape_latex(edu.get('descripcion', ''))
            contenido.append(f"    \\veinteitemtiempo{{mainblue}}{{mainblue}}{{{fecha_ini}}}{{{fecha_fin}}}{{{titulo}}}{{{institucion}}}{{{descripcion}}}")
            contenido.append("    ")
        contenido.append("\\end{veinte}")
        contenido.append("")
    referencias = datos.get('referencias', [])
    if referencias:
        contenido.append("\\section{Referencias Personales}")
        contenido.append("\\begin{veinte}")
        contenido.append("")
        for ref in referencias:
            if not isinstance(ref, dict):
                continue
            nombre = escape_latex(ref.get('nombre', ''))
            relacion = escape_latex(ref.get('relacion', ''))
            telefono = limpiar_telefono(ref.get('telefono', ''))
            comentario = escape_latex(ref.get('comentario', ''))
            contenido.append(f"    \\veinteitem{{}}{{{nombre}}}{{{relacion}}}{{Tel: {telefono} - \"{comentario}\"}}")
            contenido.append("    ")
        contenido.append("\\end{veinte}")
        contenido.append("")
    contenido.append("")
    contenido.append("\\end{document}")
    return "\n".join(contenido)
def main():
    print("="*70)
    print("🔄 CONVERTIDOR YAML → LATEX - VERSIÓN 9.0")
    print("="*70)
    print()
    archivo_yaml = sys.argv[1] if len(sys.argv) > 1 else "datos/datos.yaml"
    if not os.path.exists(archivo_yaml):
        print(f"❌ No se encuentra: {archivo_yaml}")
        sys.exit(1)
    print(f"📁 Leyendo: {archivo_yaml}")
    datos = cargar_yaml(archivo_yaml)
    print("\n📄 Generando CV...")
    contenido = generar_cv_completo(datos)
    with open("cv-completo.tex", "w", encoding='utf-8') as f:
        f.write(contenido)
    print("✅ cv-completo.tex generado")
    print()
    print("="*70)
    print("✅ PROCESO COMPLETADO")
    print("="*70)
if __name__ == "__main__":
    main()
EOF
    chmod +x "$CLI_DIR/yaml2latex.py"
    print_success "yaml2latex.py creado correctamente"
fi
#--------------------------------------------------------------------
# CREAR ARCHIVO DE ACTIVACIÓN
#--------------------------------------------------------------------
print_section "CREANDO ARCHIVO DE ACTIVACIÓN"
cat > "$REPO_ROOT/use-cv-generator.sh" << EOF
#!/bin/bash
# Activar el generador de CV
cd "$CLI_DIR"
echo "✅ Entorno CV Generator activado"
echo "📁 Directorio: $CLI_DIR"
echo ""
echo "Para generar tu CV, ejecuta:"
echo "  ./generar-cv.sh"
echo ""
echo "Para editar tus datos:"
echo "  nano datos/datos.yaml"
echo ""
exec "\$SHELL"
EOF
chmod +x "$REPO_ROOT/use-cv-generator.sh"
print_success "Archivo de activación creado: ./use-cv-generator.sh"
#--------------------------------------------------------------------
# RESUMEN FINAL
#--------------------------------------------------------------------
print_section "INSTALACIÓN COMPLETADA"
echo "📊 RESUMEN:" | tee -a "$LOG_FILE"
echo "   📁 CLI Directory: $CLI_DIR" | tee -a "$LOG_FILE"
echo "   🐍 Python: $(python3 --version)" | tee -a "$LOG_FILE"
echo "   📦 PyYAML: Instalado" | tee -a "$LOG_FILE"
if [ $HAS_PDFLATEX -eq 1 ]; then
    echo "   📄 LaTeX: OK" | tee -a "$LOG_FILE"
else
    echo "   📄 LaTeX: No instalado (puedes generar .tex manualmente)" | tee -a "$LOG_FILE"
fi
echo | tee -a "$LOG_FILE"
echo "📋 PRÓXIMOS PASOS:" | tee -a "$LOG_FILE"
echo "   1. Activa el entorno: source $REPO_ROOT/use-cv-generator.sh" | tee -a "$LOG_FILE"
echo "   2. Edita tus datos: nano datos/datos.yaml" | tee -a "$LOG_FILE"
echo "   3. Genera tu CV: ./generar-cv.sh" | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"
echo -e "${GREEN}✅✅✅ INSTALACIÓN COMPLETADA ✅✅✅${NC}" | tee -a "$LOG_FILE"
echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
#--------------------------------------------------------------------
# FIN
#--------------------------------------------------------------------
