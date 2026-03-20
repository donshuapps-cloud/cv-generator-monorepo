#!/bin/bash
#====================================================================
# INSTALADOR AUTOMÁTICO DE CV GENERATOR - VERSIÓN WEB
# Con backend completo (compilación real de PDF) y configuración UFW
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
# Variables globales
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
WEB_DIR="$REPO_ROOT/packages/web"
BACKEND_DIR="$WEB_DIR/backend"
LOG_FILE="/tmp/cv-generator-web-install.log"
INSTALL_DIR="/opt/cv-generator-web"
SERVICE_NAME="cv-generator-web"
PORT_FRONTEND=8000
PORT_BACKEND=5000
# Variables de configuración
INSTALL_TYPE="local"  # local, server
SERVER_IP=""
DOMAIN=""
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
    command -v $1 &> /dev/null
}
check_port() {
    lsof -i:$1 &> /dev/null
    return $?
}
#====================================================================
# FUNCIONES DE CONFIGURACIÓN
#====================================================================
configure_ufw() {
    print_section "CONFIGURANDO UFW (FIREWALL)"
    if ! check_command ufw; then
        print_warning "UFW no está instalado. Instalando..."
        sudo apt update && sudo apt install -y ufw
    fi
    # Verificar estado actual
    if sudo ufw status | grep -q "Status: active"; then
        print_msg "UFW está activo"
    else
        print_msg "UFW no está activo. Activando..."
        echo "y" | sudo ufw enable
    fi
    # Configurar reglas
    print_msg "Configurando reglas de firewall..."
    # Permitir SSH (siempre)
    sudo ufw allow 22/tcp comment 'SSH'
    print_success "SSH (22) permitido"
    # Permitir puertos de la aplicación
    sudo ufw allow $PORT_FRONTEND/tcp comment 'CV Generator Frontend'
    sudo ufw allow $PORT_BACKEND/tcp comment 'CV Generator Backend'
    print_success "Puertos $PORT_FRONTEND y $PORT_BACKEND permitidos"
    # Si es servidor, permitir HTTP/HTTPS
    if [ "$INSTALL_TYPE" = "server" ]; then
        sudo ufw allow 80/tcp comment 'HTTP'
        sudo ufw allow 443/tcp comment 'HTTPS'
        print_success "Puertos HTTP/HTTPS permitidos"
    fi
    # Mostrar estado
    echo ""
    sudo ufw status numbered | tee -a "$LOG_FILE"
}
#====================================================================
# FUNCIONES DE INSTALACIÓN
#====================================================================
install_dependencies() {
    print_section "INSTALANDO DEPENDENCIAS DEL SISTEMA"
    # Actualizar repositorios
    print_msg "Actualizando repositorios..."
    sudo apt update >> "$LOG_FILE" 2>&1
    # Instalar Python y pip
    if ! check_command python3; then
        print_msg "Instalando Python3..."
        sudo apt install -y python3 python3-pip python3-venv >> "$LOG_FILE" 2>&1
        print_success "Python3 instalado"
    else
        print_success "Python3: $(python3 --version)"
    fi
    # Instalar LaTeX
    if ! check_command pdflatex; then
        print_msg "Instalando LaTeX (esto puede tomar varios minutos)..."
        sudo apt install -y texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended >> "$LOG_FILE" 2>&1
        print_success "LaTeX instalado"
    else
        print_success "LaTeX: $(pdflatex --version | head -n1)"
    fi
    # Instalar otras utilidades
    print_msg "Instalando utilidades adicionales..."
    sudo apt install -y curl wget git lsof nginx >> "$LOG_FILE" 2>&1
    print_success "Utilidades instaladas"
}
install_backend() {
    print_section "INSTALANDO BACKEND (Flask)"
    # Crear directorio de instalación
    if [ ! -d "$INSTALL_DIR" ]; then
        print_msg "Creando directorio: $INSTALL_DIR"
        sudo mkdir -p "$INSTALL_DIR"
        sudo chown -R $USER:$USER "$INSTALL_DIR"
    fi
    # Copiar archivos
    print_msg "Copiando archivos del proyecto..."
    cp -r "$WEB_DIR"/* "$INSTALL_DIR/"
    print_success "Archivos copiados"
    # Crear entorno virtual
    print_msg "Creando entorno virtual Python..."
    cd "$INSTALL_DIR/backend"
    python3 -m venv venv
    source venv/bin/activate
    # Instalar dependencias Python
    print_msg "Instalando dependencias Python..."
    pip install --upgrade pip >> "$LOG_FILE" 2>&1
    pip install -r requirements.txt >> "$LOG_FILE" 2>&1
    print_success "Dependencias instaladas"
    deactivate
}
configure_systemd_service() {
    print_section "CONFIGURANDO SERVICIO SYSTEMD"
    local service_file="/etc/systemd/system/$SERVICE_NAME.service"
    # Crear archivo de servicio
    sudo tee "$service_file" > /dev/null << EOF
[Unit]
Description=CV Generator Web Backend
After=network.target
[Service]
Type=simple
User=$USER
WorkingDirectory=$INSTALL_DIR/backend
Environment="PATH=$INSTALL_DIR/backend/venv/bin"
ExecStart=$INSTALL_DIR/backend/venv/bin/python $INSTALL_DIR/backend/server.py
Restart=always
RestartSec=10
[Install]
WantedBy=multi-user.target
EOF
    print_success "Archivo de servicio creado: $service_file"
    # Recargar systemd
    sudo systemctl daemon-reload
    print_success "systemd recargado"
    # Habilitar servicio
    sudo systemctl enable $SERVICE_NAME
    print_success "Servicio habilitado para inicio automático"
    # Iniciar servicio
    sudo systemctl start $SERVICE_NAME
    print_success "Servicio iniciado"
    # Verificar estado
    sleep 2
    if sudo systemctl is-active --quiet $SERVICE_NAME; then
        print_success "Servicio funcionando correctamente"
    else
        print_error "Error al iniciar servicio"
        sudo systemctl status $SERVICE_NAME
        exit 1
    fi
}
configure_nginx() {
    print_section "CONFIGURANDO NGINX"
    if [ "$INSTALL_TYPE" = "server" ]; then
        # Configuración para servidor con dominio
        local nginx_config="/etc/nginx/sites-available/$SERVICE_NAME"
        sudo tee "$nginx_config" > /dev/null << EOF
server {
    listen 80;
    server_name $DOMAIN $SERVER_IP;
    root $INSTALL_DIR;
    index index.html;
    # Logs
    access_log /var/log/nginx/cv-generator-access.log;
    error_log /var/log/nginx/cv-generator-error.log;
    # Frontend estático
    location / {
        try_files \$uri \$uri/ =404;
    }
    # API backend
    location /api/ {
        proxy_pass http://127.0.0.1:$PORT_BACKEND/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    # Compresión
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    # Caché
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
EOF
        # Habilitar sitio
        sudo ln -sf "$nginx_config" /etc/nginx/sites-enabled/
        sudo rm -f /etc/nginx/sites-enabled/default
        # Probar configuración
        sudo nginx -t
        if [ $? -eq 0 ]; then
            sudo systemctl reload nginx
            print_success "NGINX configurado y recargado"
        else
            print_error "Error en configuración de NGINX"
            exit 1
        fi
    fi
}
configure_frontend() {
    print_section "CONFIGURANDO FRONTEND"
    # Modificar app.js para apuntar al backend correcto
    local app_js="$INSTALL_DIR/js/app.js"
    if [ "$INSTALL_TYPE" = "server" ]; then
        # En servidor, usar ruta relativa /api/
        sed -i "s|http://localhost:$PORT_BACKEND|/api|g" "$app_js"
        print_success "Frontend configurado para usar /api/"
    else
        # En local, usar localhost
        sed -i "s|http://localhost:5000|http://localhost:$PORT_BACKEND|g" "$app_js"
        print_success "Frontend configurado para usar localhost:$PORT_BACKEND"
    fi
    # Ajustar permisos
    sudo chown -R www-data:www-data "$INSTALL_DIR"
    print_success "Permisos ajustados"
}
create_launcher_script() {
    print_section "CREANDO SCRIPT DE INICIO RÁPIDO"
    local launcher="$INSTALL_DIR/start.sh"
    cat > "$launcher" << 'EOF'
#!/bin/bash
# Script de inicio rápido para CV Generator Web
INSTALL_DIR="/opt/cv-generator-web"
BACKEND_PORT=5000
FRONTEND_PORT=8000
echo "🎹 Iniciando CV Generator Web..."
echo ""
# Verificar si el servicio está activo
if systemctl is-active --quiet cv-generator-web; then
    echo "✅ Backend activo (servicio systemd)"
else
    echo "⚠️  Backend no está activo"
    echo "   Ejecuta: sudo systemctl start cv-generator-web"
fi
# Iniciar servidor frontend (si no está configurado NGINX)
if ! command -v nginx &> /dev/null || ! systemctl is-active --quiet nginx; then
    echo "🚀 Iniciando servidor frontend..."
    cd $INSTALL_DIR
    python3 -m http.server $FRONTEND_PORT &
    echo "   Frontend: http://localhost:$FRONTEND_PORT"
fi
echo ""
echo "📋 Accesos:"
if systemctl is-active --quiet nginx; then
    echo "   🌐 Web: http://localhost (NGINX)"
else
    echo "   🌐 Web: http://localhost:$FRONTEND_PORT"
fi
echo "   🔧 API: http://localhost:$BACKEND_PORT"
echo ""
echo "📁 Logs: $INSTALL_DIR/logs/"
echo "   tail -f /var/log/nginx/cv-generator-*.log"
EOF
    chmod +x "$launcher"
    print_success "Script de inicio creado: $launcher"
    # Crear enlace simbólico en PATH
    sudo ln -sf "$launcher" /usr/local/bin/cv-web-start
    print_success "Comando 'cv-web-start' disponible globalmente"
}
create_status_script() {
    local status_script="$INSTALL_DIR/status.sh"
    cat > "$status_script" << 'EOF'
#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'
echo "========================================="
echo "   CV Generator Web - Estado del sistema"
echo "========================================="
echo ""
# Servicio backend
echo "🔧 Backend (systemd):"
if systemctl is-active --quiet cv-generator-web; then
    echo -e "   ${GREEN}✅ Activo${NC}"
else
    echo -e "   ${RED}❌ Inactivo${NC}"
fi
# NGINX
echo ""
echo "🌐 NGINX:"
if systemctl is-active --quiet nginx; then
    echo -e "   ${GREEN}✅ Activo${NC}"
else
    echo -e "   ${RED}❌ Inactivo${NC}"
fi
# Puertos
echo ""
echo "📡 Puertos:"
if lsof -i:5000 &> /dev/null; then
    echo -e "   ${GREEN}✅ 5000 (Backend)${NC}"
else
    echo -e "   ${RED}❌ 5000 (Backend)${NC}"
fi
if lsof -i:8000 &> /dev/null; then
    echo -e "   ${GREEN}✅ 8000 (Frontend directo)${NC}"
else
    echo -e "   ${YELLOW}⚠️  8000 (Frontend directo)${NC}"
fi
# UFW
echo ""
echo "🔥 Firewall (UFW):"
sudo ufw status | grep -E "(5000|8000|80|443|22)" | while read line; do
    echo "   $line"
done
echo ""
echo "📊 Logs recientes (backend):"
sudo journalctl -u cv-generator-web -n 5 --no-pager
EOF
    chmod +x "$status_script"
    sudo ln -sf "$status_script" /usr/local/bin/cv-web-status
    print_success "Script de estado creado: cv-web-status"
}
create_update_script() {
    local update_script="$INSTALL_DIR/update.sh"
    cat > "$update_script" << 'EOF'
#!/bin/bash
GREEN='\033[0;32m'
NC='\033[0m'
echo "🔄 Actualizando CV Generator Web..."
echo ""
# Detener servicio
sudo systemctl stop cv-generator-web
# Actualizar código
cd /opt/cv-generator-web
git pull origin main
# Actualizar dependencias Python
cd backend
source venv/bin/activate
pip install -r requirements.txt --upgrade
deactivate
# Reiniciar servicio
sudo systemctl start cv-generator-web
echo -e "${GREEN}✅ Actualización completada${NC}"
EOF
    chmod +x "$update_script"
    sudo ln -sf "$update_script" /usr/local/bin/cv-web-update
    print_success "Script de actualización creado: cv-web-update"
}
#====================================================================
# FUNCIÓN PRINCIPAL
#====================================================================
main() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║     INSTALADOR AUTOMÁTICO - CV GENERATOR WEB                ║"
    echo "║              Con backend completo y UFW                     ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo "Log file: $LOG_FILE"
    echo ""
    # Solicitar tipo de instalación
    echo "Selecciona el tipo de instalación:"
    echo "  1) Local (solo para desarrollo/pruebas)"
    echo "  2) Servidor (con NGINX y configuración para producción)"
    read -p "Opción [1-2]: " INSTALL_OPTION
    case $INSTALL_OPTION in
        2)
            INSTALL_TYPE="server"
            read -p "IP del servidor (dejar vacío para detectar automáticamente): " SERVER_IP
            if [ -z "$SERVER_IP" ]; then
                SERVER_IP=$(curl -s ifconfig.me)
            fi
            read -p "Nombre de dominio (opcional, dejar vacío si no tienes): " DOMAIN
            print_msg "Instalación tipo SERVIDOR"
            print_msg "IP: $SERVER_IP"
            [ -n "$DOMAIN" ] && print_msg "Dominio: $DOMAIN"
            ;;
        *)
            INSTALL_TYPE="local"
            print_msg "Instalación tipo LOCAL"
            ;;
    esac
    echo ""
    read -p "¿Continuar con la instalación? (s/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        print_msg "Instalación cancelada"
        exit 0
    fi
    # Verificar que estamos en el repositorio
    if [ ! -d "$WEB_DIR" ]; then
        print_error "No se encuentra el directorio $WEB_DIR"
        print_msg "Asegúrate de ejecutar este script desde el repositorio raíz"
        exit 1
    fi
    # Ejecutar instalación
    install_dependencies
    configure_ufw
    install_backend
    configure_systemd_service
    if [ "$INSTALL_TYPE" = "server" ]; then
        configure_nginx
    fi
    configure_frontend
    create_launcher_script
    create_status_script
    create_update_script
    #====================================================================
    # RESUMEN FINAL
    #====================================================================
    print_section "INSTALACIÓN COMPLETADA"
    echo "📊 RESUMEN:" | tee -a "$LOG_FILE"
    echo "   📁 Directorio: $INSTALL_DIR" | tee -a "$LOG_FILE"
    echo "   🔧 Backend: Puerto $PORT_BACKEND (servicio systemd)" | tee -a "$LOG_FILE"
    echo "   🌐 Frontend: Puerto $PORT_FRONTEND (servidor Python)" | tee -a "$LOG_FILE"
    if [ "$INSTALL_TYPE" = "server" ]; then
        echo "   🚀 NGINX: Configurado como proxy inverso" | tee -a "$LOG_FILE"
        echo "   🌍 Acceso web: http://$SERVER_IP" | tee -a "$LOG_FILE"
        [ -n "$DOMAIN" ] && echo "   🌍 Acceso web: http://$DOMAIN" | tee -a "$LOG_FILE"
    fi
    echo "" | tee -a "$LOG_FILE"
    echo "📋 COMANDOS ÚTILES:" | tee -a "$LOG_FILE"
    echo "   cv-web-start   - Iniciar servicios manualmente" | tee -a "$LOG_FILE"
    echo "   cv-web-status  - Ver estado del sistema" | tee -a "$LOG_FILE"
    echo "   cv-web-update  - Actualizar a la última versión" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    echo "📋 LOGS:" | tee -a "$LOG_FILE"
    echo "   sudo journalctl -u $SERVICE_NAME -f    # Log del backend" | tee -a "$LOG_FILE"
    if [ "$INSTALL_TYPE" = "server" ]; then
        echo "   sudo tail -f /var/log/nginx/cv-generator-*.log   # Log de NGINX" | tee -a "$LOG_FILE"
    fi
    echo "" | tee -a "$LOG_FILE"
    echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
    echo -e "${GREEN}✅✅✅ INSTALACIÓN COMPLETADA CON ÉXITO ✅✅✅${NC}" | tee -a "$LOG_FILE"
    echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
    # Verificar estado final
    echo ""
    print_msg "Verificando estado de los servicios..."
    sleep 2
    sudo systemctl status $SERVICE_NAME --no-pager | head -5
}
# Ejecutar instalación
main "$@"
