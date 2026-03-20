#!/bin/bash
#====================================================================
# INSTALADOR DEL GENERADOR DE CV - LINUX/macOS
# Versión: 1.0
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
LOG_FILE="$REPO_ROOT/install.log"
print_msg() {
    echo -e "${BLUE}[$(date +%H:%M:%S)]${NC} $1" | tee -a "$LOG_FILE"
}
print_success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_FILE"
}
print_error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$LOG_FILE"
}
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$LOG_FILE"
}
print_section() {
    echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
    echo -e "${CYAN}🔷 $1${NC}" | tee -a "$LOG_FILE"
    echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
}
check_command() {
    if command -v $1 &> /dev/null; then
        return 0
    else
        return 1
    fi
}
#====================================================================
# INICIO
#====================================================================
clear
echo -e "${PURPLE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     INSTALADOR DEL GENERADOR DE CV - LINUX/macOS            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo "Log: $LOG_FILE"
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
DEPS=("python3" "pip3" "git")
for dep in "${DEPS[@]}"; do
    if check_command $dep; then
        version=$($dep --version 2>/dev/null | head -n1 | cut -d' ' -f2)
        print_success "$dep: $version"
    else
        print_error "$dep no está instalado"
        print_msg "Instalando $dep..."
        if [ "$OS_FAMILY" = "linux" ]; then
            sudo apt update && sudo apt install -y python3 python3-pip git
        elif [ "$OS_FAMILY" = "macos" ]; then
            if ! check_command brew; then
                print_msg "Instalando Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew install python git
        fi
    fi
done
#--------------------------------------------------------------------
# VERIFICAR LATEX
#--------------------------------------------------------------------
print_section "VERIFICANDO LATEX"
if check_command pdflatex; then
    version=$(pdflatex --version | head -n1)
    print_success "LaTeX encontrado: $version"
else
    print_warning "LaTeX no está instalado"
    echo
    echo "Para compilar a PDF necesitas instalar LaTeX:"
    echo "  Linux:   sudo apt install texlive-latex-recommended"
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
    else
        print_warning "Continuando sin LaTeX. Podrás generar el archivo .tex pero no el PDF."
    fi
fi
#--------------------------------------------------------------------
# CREAR ENTORNO VIRTUAL E INSTALAR DEPENDENCIAS PYTHON
#--------------------------------------------------------------------
print_section "CONFIGURANDO ENTORNO PYTHON"
cd "$REPO_ROOT"
print_msg "Creando entorno virtual..."
python3 -m venv venv
if [ $? -eq 0 ]; then
    print_success "Entorno virtual creado"
else
    print_error "Error al crear entorno virtual"
    exit 1
fi
print_msg "Activando entorno virtual..."
source venv/bin/activate
print_msg "Instalando PyYAML..."
pip install --upgrade pip
pip install pyyaml
if [ $? -eq 0 ]; then
    print_success "PyYAML instalado"
else
    print_error "Error al instalar PyYAML"
    exit 1
fi
#--------------------------------------------------------------------
# CONFIGURAR PERMISOS
#--------------------------------------------------------------------
print_section "CONFIGURANDO PERMISOS"
chmod +x packages/cli/generar-cv.sh
chmod +x packages/cli/yaml2latex.py
print_success "Permisos configurados"
#--------------------------------------------------------------------
# CREAR ARCHIVO DE ACTIVACIÓN
#--------------------------------------------------------------------
print_section "CREANDO COMANDO DE ACTIVACIÓN"
cat > "$REPO_ROOT/use-cv-generator.sh" << EOF
#!/bin/bash
# Activar el generador de CV
source "$REPO_ROOT/venv/bin/activate"
export PATH="$REPO_ROOT/packages/cli:\$PATH"
echo "✅ Entorno CV Generator activado"
echo "📁 Directorio: $REPO_ROOT/packages/cli"
echo "Ejecuta: generar-cv.sh"
EOF
chmod +x "$REPO_ROOT/use-cv-generator.sh"
print_success "Comando de activación creado: ./use-cv-generator.sh"
#--------------------------------------------------------------------
# RESUMEN FINAL
#--------------------------------------------------------------------
print_section "INSTALACIÓN COMPLETADA"
echo "📊 RESUMEN:" | tee -a "$LOG_FILE"
echo "   📁 Repositorio: $REPO_ROOT" | tee -a "$LOG_FILE"
echo "   🐍 Python: $(python3 --version)" | tee -a "$LOG_FILE"
echo "   📦 PyYAML: Instalado" | tee -a "$LOG_FILE"
if check_command pdflatex; then
    echo "   📄 LaTeX: OK" | tee -a "$LOG_FILE"
else
    echo "   📄 LaTeX: No instalado (puedes generar .tex manualmente)" | tee -a "$LOG_FILE"
fi
echo | tee -a "$LOG_FILE"
echo "📋 PRÓXIMOS PASOS:" | tee -a "$LOG_FILE"
echo "   1. Activa el entorno: source $REPO_ROOT/use-cv-generator.sh" | tee -a "$LOG_FILE"
echo "   2. Ve a la carpeta CLI: cd $REPO_ROOT/packages/cli" | tee -a "$LOG_FILE"
echo "   3. Edita tus datos: nano datos/datos.yaml" | tee -a "$LOG_FILE"
echo "   4. Genera tu CV: ./generar-cv.sh" | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"
echo -e "${GREEN}✅✅✅ INSTALACIÓN COMPLETADA ✅✅✅${NC}" | tee -a "$LOG_FILE"
echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
