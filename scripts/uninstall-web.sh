#!/bin/bash
#====================================================================
# DESINSTALADOR DE CV GENERATOR WEB
# Versión: 1.0
#====================================================================
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'
INSTALL_DIR="/opt/cv-generator-web"
SERVICE_NAME="cv-generator-web"
print_msg() {
    echo -e "${BLUE}[$(date +%H:%M:%S)]${NC} $1"
}
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}
print_error() {
    echo -e "${RED}❌ $1${NC}"
}
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}
clear
echo "========================================="
echo "   DESINSTALADOR DE CV GENERATOR WEB"
echo "========================================="
echo ""
read -p "¿Estás seguro de que quieres desinstalar CV Generator Web? (s/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    print_msg "Desinstalación cancelada"
    exit 0
fi
print_msg "Deteniendo servicios..."
# Detener y deshabilitar servicio systemd
if systemctl is-active --quiet $SERVICE_NAME; then
    sudo systemctl stop $SERVICE_NAME
    print_success "Servicio detenido"
fi
if systemctl is-enabled --quiet $SERVICE_NAME 2>/dev/null; then
    sudo systemctl disable $SERVICE_NAME
    print_success "Servicio deshabilitado"
fi
# Eliminar archivo de servicio
sudo rm -f /etc/systemd/system/$SERVICE_NAME.service
sudo systemctl daemon-reload
print_success "Archivo de servicio eliminado"
# Eliminar configuración de NGINX
if [ -f "/etc/nginx/sites-available/$SERVICE_NAME" ]; then
    sudo rm -f "/etc/nginx/sites-available/$SERVICE_NAME"
    sudo rm -f "/etc/nginx/sites-enabled/$SERVICE_NAME"
    sudo systemctl reload nginx
    print_success "Configuración de NGINX eliminada"
fi
# Eliminar directorio de instalación
if [ -d "$INSTALL_DIR" ]; then
    sudo rm -rf "$INSTALL_DIR"
    print_success "Directorio de instalación eliminado"
fi
# Eliminar comandos globales
sudo rm -f /usr/local/bin/cv-web-start
sudo rm -f /usr/local/bin/cv-web-status
sudo rm -f /usr/local/bin/cv-web-update
print_success "Comandos globales eliminados"
# Opcional: eliminar reglas de firewall
read -p "¿Eliminar reglas de firewall de CV Generator? (s/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    sudo ufw delete allow 5000/tcp 2>/dev/null
    sudo ufw delete allow 8000/tcp 2>/dev/null
    print_success "Reglas de firewall eliminadas"
fi
print_success "✅ Desinstalación completada"
