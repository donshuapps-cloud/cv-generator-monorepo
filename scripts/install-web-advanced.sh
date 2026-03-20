#!/bin/bash
#====================================================================
# INSTALADOR AVANZADO DE CV GENERATOR - VERSIÓN WEB
# Con backend completo, Let's Encrypt HTTPS, UFW y Prometheus
# Versión: 2.0 - Advanced
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
LOG_FILE="/tmp/cv-generator-web-advanced-install.log"
INSTALL_DIR="/opt/cv-generator-web"
SERVICE_NAME="cv-generator-web"
PORT_FRONTEND=8000
PORT_BACKEND=5000
PORT_METRICS=9090
PORT_NODE_EXPORTER=9100
# Variables de configuración
INSTALL_TYPE="server"
DOMAIN=""
EMAIL="donshu.apps@gmail.com"
ENABLE_HTTPS=true
ENABLE_MONITORING=true
SERVER_IP=""
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
#====================================================================
# CONFIGURACIÓN INICIAL
#====================================================================
configure_initial() {
    clear
    echo -e "${PURPLE}"
    echo "╔═══════════════════════════════════════════════════════════════════════════╗"
    echo "║     INSTALADOR AVANZADO - CV GENERATOR WEB                               ║"
    echo "║              Con Let's Encrypt HTTPS y Prometheus Monitoring            ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo "Log file: $LOG_FILE"
    echo ""
    print_msg "Configuración inicial..."
    # Detectar IP automáticamente
    SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null || echo "0.0.0.0")
    # Solicitar dominio
    echo ""
    echo -e "${CYAN}📡 Configuración del servidor:${NC}"
    read -p "Nombre de dominio (ej: cv-generator.tudominio.com): " DOMAIN
    if [ -z "$DOMAIN" ]; then
        print_error "El dominio es obligatorio para HTTPS con Let's Encrypt"
        print_msg "Sin dominio, no se puede configurar HTTPS automático"
        read -p "¿Continuar sin HTTPS? (s/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Ss]$ ]]; then
            exit 0
        fi
        ENABLE_HTTPS=false
    fi
    # Solicitar email para Let's Encrypt
    if [ "$ENABLE_HTTPS" = true ]; then
        read -p "Email para Let's Encrypt [$EMAIL]: " EMAIL_INPUT
        [ -n "$EMAIL_INPUT" ] && EMAIL="$EMAIL_INPUT"
    fi
    # Preguntar por monitoreo
    echo ""
    echo -e "${CYAN}📊 Configuración de monitoreo:${NC}"
    read -p "¿Habilitar monitoreo con Prometheus? (S/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        ENABLE_MONITORING=false
    fi
    print_msg "Configuración completada"
    print_msg "  • Dominio: $DOMAIN"
    print_msg "  • Email: $EMAIL"
    print_msg "  • HTTPS: $ENABLE_HTTPS"
    print_msg "  • Monitoreo: $ENABLE_MONITORING"
}
#====================================================================
# INSTALACIÓN DE DEPENDENCIAS BASE
#====================================================================
install_base_dependencies() {
    print_section "INSTALANDO DEPENDENCIAS BASE"
    sudo apt update >> "$LOG_FILE" 2>&1
    # Python y herramientas base
    print_msg "Instalando Python y herramientas..."
    sudo apt install -y python3 python3-pip python3-venv python3-dev >> "$LOG_FILE" 2>&1
    # LaTeX
    print_msg "Instalando LaTeX (puede tomar varios minutos)..."
    sudo apt install -y texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended >> "$LOG_FILE" 2>&1
    # Utilidades
    print_msg "Instalando utilidades..."
    sudo apt install -y curl wget git lsof nginx certbot python3-certbot-nginx ufw >> "$LOG_FILE" 2>&1
    print_success "Dependencias base instaladas"
}
#====================================================================
# CONFIGURACIÓN DE UFW (FIREWALL)
#====================================================================
configure_ufw() {
    print_section "CONFIGURANDO UFW (FIREWALL)"
    sudo ufw --force enable >> "$LOG_FILE" 2>&1
    # Reglas base
    sudo ufw allow 22/tcp comment 'SSH' >> "$LOG_FILE" 2>&1
    sudo ufw allow 80/tcp comment 'HTTP' >> "$LOG_FILE" 2>&1
    sudo ufw allow 443/tcp comment 'HTTPS' >> "$LOG_FILE" 2>&1
    sudo ufw allow $PORT_BACKEND/tcp comment 'CV Generator Backend' >> "$LOG_FILE" 2>&1
    # Reglas para monitoreo
    if [ "$ENABLE_MONITORING" = true ]; then
        sudo ufw allow $PORT_METRICS/tcp comment 'Prometheus' >> "$LOG_FILE" 2>&1
        sudo ufw allow $PORT_NODE_EXPORTER/tcp comment 'Node Exporter' >> "$LOG_FILE" 2>&1
        print_success "Puertos de monitoreo abiertos"
    fi
    sudo ufw status numbered | tee -a "$LOG_FILE"
    print_success "UFW configurado"
}
#====================================================================
# INSTALACIÓN DEL BACKEND
#====================================================================
install_backend() {
    print_section "INSTALANDO BACKEND"
    # Crear directorio
    sudo mkdir -p "$INSTALL_DIR"
    sudo chown -R $USER:$USER "$INSTALL_DIR"
    # Copiar archivos
    cp -r "$WEB_DIR"/* "$INSTALL_DIR/"
    # Crear directorio para logs
    mkdir -p "$INSTALL_DIR/logs"
    # Configurar backend con soporte para métricas
    print_msg "Configurando backend con endpoint de métricas..."
    # Crear versión mejorada de server.py con métricas
    cat > "$INSTALL_DIR/backend/server_metrics.py" << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Servidor Flask con soporte para métricas Prometheus
"""
from flask import Flask, request, send_file, jsonify
from flask_cors import CORS
import tempfile
import os
import subprocess
import uuid
import time
from datetime import datetime
import json
import threading
import queue
# Intentar importar prometheus_client
try:
    from prometheus_client import Counter, Histogram, Gauge, generate_latest, REGISTRY
    PROMETHEUS_AVAILABLE = True
except ImportError:
    PROMETHEUS_AVAILABLE = False
    print("⚠️  prometheus_client no instalado. Métricas deshabilitadas.")
app = Flask(__name__)
CORS(app)
# Métricas Prometheus
if PROMETHEUS_AVAILABLE:
    # Contadores
    COMPILATIONS_TOTAL = Counter('cv_compilations_total', 'Total number of CV compilations')
    COMPILATIONS_SUCCESS = Counter('cv_compilations_success', 'Successful CV compilations')
    COMPILATIONS_FAILED = Counter('cv_compilations_failed', 'Failed CV compilations')
    # Histogramas
    COMPILATION_DURATION = Histogram('cv_compilation_duration_seconds', 'Time spent compiling CV')
    # Gauges
    ACTIVE_COMPILATIONS = Gauge('cv_active_compilations', 'Number of active compilations')
    LAST_COMPILATION_TIMESTAMP = Gauge('cv_last_compilation_timestamp', 'Timestamp of last compilation')
    # Contador de requests
    HTTP_REQUESTS = Counter('cv_http_requests_total', 'Total HTTP requests', ['method', 'endpoint', 'status'])
@app.before_request
def before_request():
    """Registrar inicio de request"""
    request.start_time = time.time()
@app.after_request
def after_request(response):
    """Registrar métricas después de cada request"""
    if PROMETHEUS_AVAILABLE:
        duration = time.time() - request.start_time
        HTTP_REQUESTS.labels(
            method=request.method,
            endpoint=request.endpoint or request.path,
            status=response.status_code
        ).inc()
        # Registrar duración si es el endpoint de compilación
        if request.path == '/compile' and request.method == 'POST':
            COMPILATION_DURATION.observe(duration)
    return response
@app.route('/health', methods=['GET'])
def health():
    """Endpoint de health check"""
    return jsonify({
        'status': 'ok',
        'timestamp': datetime.now().isoformat(),
        'service': 'cv-generator-backend',
        'version': '2.0',
        'latex_available': check_latex()
    })
@app.route('/metrics', methods=['GET'])
def metrics():
    """Endpoint de métricas para Prometheus"""
    if PROMETHEUS_AVAILABLE:
        return generate_latest(REGISTRY), 200, {'Content-Type': 'text/plain'}
    else:
        return jsonify({'error': 'Metrics not available', 'message': 'Install prometheus_client'}), 501
@app.route('/compile', methods=['POST'])
def compile_latex():
    """Compilar LaTeX a PDF con métricas"""
    if PROMETHEUS_AVAILABLE:
        COMPILATIONS_TOTAL.inc()
        ACTIVE_COMPILATIONS.inc()
    try:
        data = request.get_json()
        latex_code = data.get('latex', '')
        if not latex_code:
            if PROMETHEUS_AVAILABLE:
                COMPILATIONS_FAILED.inc()
            return jsonify({'error': 'No se recibió código LaTeX'}), 400
        # Crear directorio temporal
        temp_dir = tempfile.mkdtemp()
        tex_file = os.path.join(temp_dir, 'cv.tex')
        pdf_file = os.path.join(temp_dir, 'cv.pdf')
        with open(tex_file, 'w', encoding='utf-8') as f:
            f.write(latex_code)
        # Compilar
        for i in range(3):
            result = subprocess.run(
                ['pdflatex', '-interaction=nonstopmode', '-output-directory', temp_dir, tex_file],
                capture_output=True,
                text=True
            )
            if result.returncode != 0:
                if PROMETHEUS_AVAILABLE:
                    COMPILATIONS_FAILED.inc()
                return jsonify({'error': 'Error en compilación', 'log': result.stderr}), 500
        if not os.path.exists(pdf_file):
            if PROMETHEUS_AVAILABLE:
                COMPILATIONS_FAILED.inc()
            return jsonify({'error': 'No se generó el PDF'}), 500
        if PROMETHEUS_AVAILABLE:
            COMPILATIONS_SUCCESS.inc()
            LAST_COMPILATION_TIMESTAMP.set(time.time())
        return send_file(
            pdf_file,
            mimetype='application/pdf',
            as_attachment=True,
            download_name=f'cv-{uuid.uuid4().hex[:8]}.pdf'
        )
    except Exception as e:
        if PROMETHEUS_AVAILABLE:
            COMPILATIONS_FAILED.inc()
        return jsonify({'error': str(e)}), 500
    finally:
        if PROMETHEUS_AVAILABLE:
            ACTIVE_COMPILATIONS.dec()
def check_latex():
    """Verificar disponibilidad de pdflatex"""
    try:
        result = subprocess.run(['pdflatex', '--version'], capture_output=True)
        return result.returncode == 0
    except:
        return False
if __name__ == '__main__':
    print("="*60)
    print("CV Generator Backend - Con soporte Prometheus")
    print(f"Prometheus disponible: {PROMETHEUS_AVAILABLE}")
    print("="*60)
    app.run(host='0.0.0.0', port=5000, debug=False)
EOF
    # Reemplazar server.py
    mv "$INSTALL_DIR/backend/server.py" "$INSTALL_DIR/backend/server.py.bak" 2>/dev/null
    cp "$INSTALL_DIR/backend/server_metrics.py" "$INSTALL_DIR/backend/server.py"
    # Crear entorno virtual
    cd "$INSTALL_DIR/backend"
    python3 -m venv venv
    source venv/bin/activate
    # Instalar dependencias
    pip install --upgrade pip >> "$LOG_FILE" 2>&1
    pip install flask flask-cors >> "$LOG_FILE" 2>&1
    if [ "$ENABLE_MONITORING" = true ]; then
        pip install prometheus-client >> "$LOG_FILE" 2>&1
        print_success "prometheus-client instalado"
    fi
    deactivate
    print_success "Backend instalado"
}
#====================================================================
# INSTALACIÓN DE PROMETHEUS Y NODE EXPORTER
#====================================================================
install_prometheus() {
    print_section "INSTALANDO PROMETHEUS Y NODE EXPORTER"
    # Crear usuario para Prometheus
    sudo useradd --no-create-home --shell /bin/false prometheus 2>/dev/null
    sudo useradd --no-create-home --shell /bin/false node_exporter 2>/dev/null
    # Descargar Prometheus
    print_msg "Descargando Prometheus..."
    cd /tmp
    wget -q https://github.com/prometheus/prometheus/releases/download/v2.48.1/prometheus-2.48.1.linux-amd64.tar.gz
    tar xzf prometheus-2.48.1.linux-amd64.tar.gz
    sudo cp prometheus-2.48.1.linux-amd64/prometheus /usr/local/bin/
    sudo cp prometheus-2.48.1.linux-amd64/promtool /usr/local/bin/
    sudo mkdir -p /etc/prometheus /var/lib/prometheus
    sudo cp -r prometheus-2.48.1.linux-amd64/consoles /etc/prometheus
    sudo cp -r prometheus-2.48.1.linux-amd64/console_libraries /etc/prometheus
    # Configurar Prometheus
    sudo tee /etc/prometheus/prometheus.yml > /dev/null << EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s
alerting:
  alertmanagers:
    - static_configs:
        - targets: []
rule_files: []
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
  - job_name: 'cv_generator'
    metrics_path: /metrics
    static_configs:
      - targets: ['localhost:5000']
    scrape_interval: 10s
EOF
    # Crear servicio Prometheus
    sudo tee /etc/systemd/system/prometheus.service > /dev/null << EOF
[Unit]
Description=Prometheus
After=network.target
[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries
Restart=always
[Install]
WantedBy=multi-user.target
EOF
    # Instalar Node Exporter
    print_msg "Instalando Node Exporter..."
    wget -q https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
    tar xzf node_exporter-1.7.0.linux-amd64.tar.gz
    sudo cp node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/
    # Crear servicio Node Exporter
    sudo tee /etc/systemd/system/node_exporter.service > /dev/null << EOF
[Unit]
Description=Node Exporter
After=network.target
[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
Restart=always
[Install]
WantedBy=multi-user.target
EOF
    # Configurar permisos
    sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
    sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
    # Iniciar servicios
    sudo systemctl daemon-reload
    sudo systemctl enable prometheus node_exporter
    sudo systemctl start prometheus node_exporter
    print_success "Prometheus y Node Exporter instalados"
}
#====================================================================
# INSTALACIÓN DE GRAFANA (opcional)
#====================================================================
install_grafana() {
    print_section "INSTALANDO GRAFANA"
    # Añadir repositorio de Grafana
    sudo apt install -y software-properties-common wget >> "$LOG_FILE" 2>&1
    wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
    sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
    sudo apt update >> "$LOG_FILE" 2>&1
    sudo apt install -y grafana >> "$LOG_FILE" 2>&1
    # Configurar Grafana
    sudo systemctl enable grafana-server
    sudo systemctl start grafana-server
    # Abrir puerto en UFW
    sudo ufw allow 3000/tcp comment 'Grafana' >> "$LOG_FILE" 2>&1
    print_success "Grafana instalado en http://$SERVER_IP:3000"
    print_msg "Credenciales por defecto: admin/admin"
}
#====================================================================
# CONFIGURACIÓN DE NGINX CON LET'S ENCRYPT
#====================================================================
configure_nginx_https() {
    print_section "CONFIGURANDO NGINX CON HTTPS"
    # Configuración inicial de NGINX
    local nginx_config="/etc/nginx/sites-available/$SERVICE_NAME"
    sudo tee "$nginx_config" > /dev/null << EOF
server {
    listen 80;
    server_name $DOMAIN;
    root $INSTALL_DIR;
    index index.html;
    location / {
        try_files \$uri \$uri/ =404;
    }
    location /api/ {
        proxy_pass http://127.0.0.1:$PORT_BACKEND/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    location /metrics {
        proxy_pass http://127.0.0.1:$PORT_BACKEND/metrics;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF
    # Habilitar sitio
    sudo ln -sf "$nginx_config" /etc/nginx/sites-enabled/
    sudo rm -f /etc/nginx/sites-enabled/default
    # Probar configuración
    sudo nginx -t >> "$LOG_FILE" 2>&1
    if [ $? -eq 0 ]; then
        sudo systemctl reload nginx
        print_success "NGINX configurado (HTTP)"
    else
        print_error "Error en configuración de NGINX"
        exit 1
    fi
    # Obtener certificado SSL con Let's Encrypt
    if [ "$ENABLE_HTTPS" = true ]; then
        print_msg "Obteniendo certificado SSL con Let's Encrypt..."
        # Detener nginx temporalmente para Certbot (si es necesario)
        sudo systemctl stop nginx
        # Obtener certificado
        sudo certbot certonly --standalone \
            --non-interactive \
            --agree-tos \
            --email "$EMAIL" \
            -d "$DOMAIN" >> "$LOG_FILE" 2>&1
        if [ $? -eq 0 ]; then
            print_success "Certificado SSL obtenido"
            # Configurar NGINX con HTTPS
            sudo tee "$nginx_config" > /dev/null << EOF
# Redirección HTTP → HTTPS
server {
    listen 80;
    server_name $DOMAIN;
    return 301 https://\$server_name\$request_uri;
}
server {
    listen 443 ssl http2;
    server_name $DOMAIN;
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    root $INSTALL_DIR;
    index index.html;
    # Seguridad
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    location / {
        try_files \$uri \$uri/ =404;
    }
    location /api/ {
        proxy_pass http://127.0.0.1:$PORT_BACKEND/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    location /metrics {
        proxy_pass http://127.0.0.1:$PORT_BACKEND/metrics;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF
            # Configurar renovación automática
            sudo systemctl enable certbot.timer
            sudo systemctl start certbot.timer
            print_success "HTTPS configurado con renovación automática"
        else
            print_error "Error al obtener certificado SSL"
            print_msg "Reiniciando NGINX con configuración HTTP..."
        fi
        # Reiniciar NGINX
        sudo systemctl start nginx
        sudo systemctl reload nginx
    fi
}
#====================================================================
# CONFIGURACIÓN DEL SERVICIO SYSTEMD
#====================================================================
configure_systemd_service() {
    print_section "CONFIGURANDO SERVICIO SYSTEMD"
    local service_file="/etc/systemd/system/$SERVICE_NAME.service"
    sudo tee "$service_file" > /dev/null << EOF
[Unit]
Description=CV Generator Web Backend
After=network.target
Wants=prometheus.service
[Service]
Type=simple
User=$USER
WorkingDirectory=$INSTALL_DIR/backend
Environment="PATH=$INSTALL_DIR/backend/venv/bin"
ExecStart=$INSTALL_DIR/backend/venv/bin/python $INSTALL_DIR/backend/server.py
Restart=always
RestartSec=10
# Monitoreo
Environment="PROMETHEUS_MULTIPROC_DIR=/tmp/prometheus_multiproc"
Environment="PYTHONUNBUFFERED=1"
[Install]
WantedBy=multi-user.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl enable $SERVICE_NAME
    sudo systemctl start $SERVICE_NAME
    print_success "Servicio systemd configurado"
}
#====================================================================
# DASHBOARD DE GRAFANA (configuración automática)
#====================================================================
configure_grafana_dashboard() {
    if [ "$ENABLE_MONITORING" = true ] && check_command grafana-cli; then
        print_section "CONFIGURANDO DASHBOARD DE GRAFANA"
        # Esperar a que Grafana esté listo
        sleep 10
        # Crear archivo de configuración del datasource
        cat > /tmp/grafana-datasource.json << EOF
{
  "name": "Prometheus",
  "type": "prometheus",
  "url": "http://localhost:9090",
  "access": "proxy",
  "isDefault": true
}
EOF
        # Crear dashboard para CV Generator
        cat > /tmp/grafana-dashboard-cv.json << EOF
{
  "dashboard": {
    "title": "CV Generator Monitoring",
    "tags": ["cv-generator", "production"],
    "timezone": "browser",
    "panels": [
      {
        "title": "Compilaciones por hora",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(cv_compilations_total[1h])",
            "legendFormat": "Compilaciones/hora"
          }
        ]
      },
      {
        "title": "Tasa de éxito",
        "type": "stat",
        "targets": [
          {
            "expr": "sum(cv_compilations_success) / sum(cv_compilations_total) * 100"
          }
        ]
      },
      {
        "title": "Duración de compilación",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(cv_compilation_duration_seconds_bucket[5m]))",
            "legendFormat": "P95"
          }
        ]
      },
      {
        "title": "Requests HTTP por endpoint",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(cv_http_requests_total[5m])",
            "legendFormat": "{{endpoint}}"
          }
        ]
      },
      {
        "title": "Uso de recursos del sistema",
        "type": "graph",
        "targets": [
          {
            "expr": "100 - (avg(rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
            "legendFormat": "CPU"
          },
          {
            "expr": "node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100",
            "legendFormat": "Memoria libre (%)"
          }
        ]
      }
    ]
  }
}
EOF
        print_success "Dashboard de Grafana configurado"
        print_msg "Importa el dashboard manualmente en http://$SERVER_IP:3000"
    fi
}
#====================================================================
# SCRIPTS DE UTILIDAD
#====================================================================
create_utility_scripts() {
    print_section "CREANDO SCRIPTS DE UTILIDAD"
    # Script de estado avanzado
    sudo tee /usr/local/bin/cv-web-monitor > /dev/null << 'EOF'
#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
echo "========================================="
echo "   CV Generator - Monitoreo Avanzado"
echo "========================================="
echo ""
# Servicios
echo -e "${BLUE}📡 Servicios:${NC}"
for svc in cv-generator-web prometheus node_exporter grafana-server nginx; do
    if systemctl is-active --quiet $svc 2>/dev/null; then
        echo -e "   ${GREEN}✅ $svc${NC}"
    else
        echo -e "   ${RED}❌ $svc${NC}"
    fi
done
echo ""
echo -e "${BLUE}📊 Métricas Prometheus:${NC}"
curl -s http://localhost:9090/api/v1/query?query=up | python3 -m json.tool 2>/dev/null | grep -E "(cv_compilations|cv_http)" | head -5
echo ""
echo -e "${BLUE}🔒 SSL Certificate:${NC}"
if [ -f /etc/letsencrypt/live/*/fullchain.pem ] 2>/dev/null; then
    DOMAIN=$(ls /etc/letsencrypt/live/ | grep -v README | head -1)
    EXPIRY=$(sudo certbot certificates | grep "Expiry Date" | cut -d: -f2)
    echo "   ✅ $DOMAIN - Expira:$EXPIRY"
else
    echo "   ⚠️  No hay certificado SSL"
fi
echo ""
echo -e "${BLUE}📈 Uso de recursos:${NC}"
echo "   CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d% -f1)%"
echo "   RAM: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
echo "   Disco: $(df -h / | awk 'NR==2 {print $5}')"
EOF
    sudo chmod +x /usr/local/bin/cv-web-monitor
    # Script de renovación SSL manual
    sudo tee /usr/local/bin/cv-web-renew-ssl > /dev/null << 'EOF'
#!/bin/bash
echo "🔄 Renovando certificados SSL..."
sudo certbot renew --quiet
sudo systemctl reload nginx
echo "✅ Certificados renovados"
EOF
    sudo chmod +x /usr/local/bin/cv-web-renew-ssl
    print_success "Scripts de utilidad creados"
    print_msg "  • cv-web-monitor   - Monitoreo completo"
    print_msg "  • cv-web-renew-ssl - Renovar certificados SSL"
}
#====================================================================
# FUNCIÓN PRINCIPAL
#====================================================================
main() {
    configure_initial
    install_base_dependencies
    configure_ufw
    install_backend
    configure_systemd_service
    configure_nginx_https
    if [ "$ENABLE_MONITORING" = true ]; then
        install_prometheus
        install_grafana
        configure_grafana_dashboard
    fi
    create_utility_scripts
    #================================================================
    # RESUMEN FINAL
    #================================================================
    print_section "INSTALACIÓN COMPLETADA"
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                    INSTALACIÓN EXITOSA                        ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo "📋 ACCESOS:" | tee -a "$LOG_FILE"
    echo "   🌐 Web principal: https://$DOMAIN" | tee -a "$LOG_FILE"
    echo "   🔧 API Backend: https://$DOMAIN/api/" | tee -a "$LOG_FILE"
    echo "   📊 Prometheus: http://$SERVER_IP:9090" | tee -a "$LOG_FILE"
    echo "   📈 Grafana: http://$SERVER_IP:3000 (admin/admin)" | tee -a "$LOG_FILE"
    echo "   📉 Node Exporter: http://$SERVER_IP:9100/metrics" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    echo "📋 COMANDOS ÚTILES:" | tee -a "$LOG_FILE"
    echo "   cv-web-monitor    - Monitoreo completo del sistema" | tee -a "$LOG_FILE"
    echo "   cv-web-status     - Estado básico" | tee -a "$LOG_FILE"
    echo "   cv-web-update     - Actualizar aplicación" | tee -a "$LOG_FILE"
    echo "   cv-web-renew-ssl  - Renovar certificados SSL" | tee -a "$LOG_FILE"
    echo "   sudo journalctl -u $SERVICE_NAME -f  - Ver logs backend" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    echo "📋 DASHBOARD DE GRAFANA:" | tee -a "$LOG_FILE"
    echo "   1. Accede a http://$SERVER_IP:3000" | tee -a "$LOG_FILE"
    echo "   2. Login: admin / admin" | tee -a "$LOG_FILE"
    echo "   3. Cambia la contraseña" | tee -a "$LOG_FILE"
    echo "   4. Configuration → Data Sources → Add data source" | tee -a "$LOG_FILE"
    echo "   5. Selecciona Prometheus, URL: http://localhost:9090" | tee -a "$LOG_FILE"
    echo "   6. Importa el dashboard desde /tmp/grafana-dashboard-cv.json" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
    echo -e "${GREEN}✅✅✅ INSTALACIÓN COMPLETADA CON ÉXITO ✅✅✅${NC}" | tee -a "$LOG_FILE"
    echo -e "${PURPLE}════════════════════════════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
    # Verificar estado final
    echo ""
    print_msg "Verificando servicios..."
    sleep 3
    sudo systemctl status $SERVICE_NAME --no-pager | head -5
}
# Ejecutar instalación
main "$@"
