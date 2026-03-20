// Configuración global
const App = {
    yamlData: null,
    latexCode: null,
    pdfBlob: null,
    init() {
        this.initEventListeners();
        this.loadDefaultYaml();
        this.initLog();
    },
    initEventListeners() {
        document.getElementById('btn-cargar-ejemplo').addEventListener('click', () => this.cargarEjemplo());
        document.getElementById('btn-generar').addEventListener('click', () => this.generarCV());
        document.getElementById('btn-descargar-pdf').addEventListener('click', () => this.descargarPDF());
        document.getElementById('btn-copiar').addEventListener('click', () => this.copiarYAML());
        document.getElementById('btn-descargar-yaml').addEventListener('click', () => this.descargarYAML());
        document.getElementById('btn-copiar-latex').addEventListener('click', () => this.copiarLaTeX());
        // Tabs
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.addEventListener('click', (e) => this.switchTab(e.target.dataset.tab));
        });
    },
    initLog() {
        this.addLog('info', 'Bienvenido al generador de CV');
        this.addLog('info', 'Edita el YAML y haz clic en "Generar CV"');
    },
    addLog(type, message) {
        const logContent = document.getElementById('log-content');
        const time = new Date().toLocaleTimeString();
        const entry = document.createElement('div');
        entry.className = `log-entry ${type}`;
        entry.innerHTML = `<span class="log-time">[${time}]</span> <span class="log-msg">${message}</span>`;
        logContent.appendChild(entry);
        logContent.scrollTop = logContent.scrollHeight;
    },
    async loadDefaultYaml() {
        try {
            const response = await fetch('examples/datos-ejemplo.yaml');
            const yamlText = await response.text();
            window.yamlEditor.setValue(yamlText);
            this.parseYAML(yamlText);
        } catch (error) {
            // Si no carga el ejemplo, usar YAML por defecto
            const defaultYaml = `# INFORMACIÓN PERSONAL
persona:
  nombre: "YDIANA VIDAN MENA MENA"
  puesto: "Auxiliar de Servicios / Lavandería"
  cedula: "V-20045507"
  nacionalidad: "venezolana"
  fecha_nacimiento: "14/06/1988"
  direccion: "Barquisimeto, Parroquia Tamaca"
  telefono: "+58 4245507425"
  email: "ydianavidanmenamena@gmail.com"
  foto: "foto-perfil.jpg"
perfil: "Persona responsable, puntual y con gran disposición para el trabajo."
habilidades:
- nombre: "Limpieza y orden"
  valor: 5
- nombre: "Responsabilidad"
  valor: 5
experiencia:
- fecha_inicio: "Ene/2024"
  fecha_fin: "actualidad"
  puesto: "Auxiliar de Servicios"
  lugar: "Restaurante SHULEMENA C.A."
  descripcion:
  - "Limpieza y organización del comedor"
  - "Apoyo en labores de cocina básica"`;
            window.yamlEditor.setValue(defaultYaml);
            this.parseYAML(defaultYaml);
        }
    },
    parseYAML(yamlText) {
        try {
            this.yamlData = jsyaml.load(yamlText);
            document.getElementById('yaml-status').className = 'status-badge success';
            document.getElementById('yaml-status').innerHTML = '<i class="fas fa-check"></i> YAML válido';
            this.actualizarVistaPrevia();
            this.addLog('success', 'YAML validado correctamente');
            return true;
        } catch (error) {
            document.getElementById('yaml-status').className = 'status-badge error';
            document.getElementById('yaml-status').innerHTML = '<i class="fas fa-exclamation-triangle"></i> YAML inválido';
            this.addLog('error', `Error en YAML: ${error.message}`);
            return false;
        }
    },
    actualizarVistaPrevia() {
        if (!this.yamlData) return;
        const p = this.yamlData.persona || {};
        // Datos personales
        document.getElementById('preview-nombre').textContent = p.nombre || 'No especificado';
        document.getElementById('preview-puesto').textContent = p.puesto || '';
        document.getElementById('preview-cedula').textContent = p.cedula || '-';
        document.getElementById('preview-nacionalidad').textContent = p.nacionalidad || '-';
        document.getElementById('preview-fecha-nac').textContent = p.fecha_nacimiento || '-';
        document.getElementById('preview-direccion').textContent = p.direccion || '-';
        document.getElementById('preview-telefono').textContent = p.telefono || '-';
        document.getElementById('preview-email').textContent = p.email || '-';
        // Perfil
        document.getElementById('preview-perfil').textContent = this.yamlData.perfil || 'No especificado';
        // Habilidades
        this.renderHabilidades();
        // Experiencia
        this.renderExperiencia();
        // Educación
        this.renderEducacion();
    },
    renderHabilidades() {
        const container = document.getElementById('preview-habilidades');
        container.innerHTML = '';
        const habilidades = this.yamlData.habilidades || [];
        habilidades.forEach(h => {
            const valor = (h.valor || 3) * 20; // 0-5 a porcentaje
            const item = document.createElement('div');
            item.className = 'skill-item';
            item.innerHTML = `
                <span class="skill-name">${h.nombre || 'Habilidad'}</span>
                <div class="skill-bar">
                    <div class="skill-progress" style="width: ${valor}%"></div>
                </div>
            `;
            container.appendChild(item);
        });
    },
    renderExperiencia() {
        const container = document.getElementById('preview-experiencia');
        container.innerHTML = '';
        const exp = this.yamlData.experiencia || [];
        exp.forEach(e => {
            const item = document.createElement('div');
            item.className = 'exp-item';
            const descList = (e.descripcion || []).map(d => `<li>${d}</li>`).join('');
            item.innerHTML = `
                <div class="exp-header">
                    <span class="exp-title">${e.puesto || 'Puesto'}</span>
                    <span class="exp-date">${e.fecha_inicio || ''} - ${e.fecha_fin || ''}</span>
                </div>
                <div class="exp-lugar">${e.lugar || ''}</div>
                <ul class="exp-desc">${descList}</ul>
            `;
            container.appendChild(item);
        });
    },
    renderEducacion() {
        const container = document.getElementById('preview-educacion');
        container.innerHTML = '';
        const edu = this.yamlData.educacion || [];
        edu.forEach(e => {
            const item = document.createElement('div');
            item.className = 'edu-item';
            item.innerHTML = `
                <div class="edu-header">
                    <span class="edu-title">${e.titulo || 'Título'}</span>
                    <span class="edu-date">${e.fecha_inicio || ''} - ${e.fecha_fin || ''}</span>
                </div>
                <div class="edu-institucion">${e.institucion || ''}</div>
            `;
            container.appendChild(item);
        });
    },
    async generarCV() {
        this.addLog('info', 'Iniciando generación del CV...');
        // Validar YAML
        const yamlText = window.yamlEditor.getValue();
        if (!this.parseYAML(yamlText)) {
            this.addLog('error', 'Corrige los errores del YAML antes de continuar');
            return;
        }
        // Generar LaTeX
        this.addLog('info', 'Generando código LaTeX...');
        this.latexCode = LatexGenerator.generate(this.yamlData);
        document.getElementById('latex-code').textContent = this.latexCode;
        // Habilitar botón de copiar LaTeX
        document.getElementById('btn-copiar-latex').disabled = false;
        // Compilar a PDF (usando backend o simulación)
        this.addLog('info', 'Compilando a PDF...');
        try {
            // Intentar compilar vía backend
            await this.compilarPDF(this.latexCode);
            document.getElementById('btn-descargar-pdf').disabled = false;
            this.addLog('success', 'PDF generado correctamente');
            // Cambiar a pestaña PDF
            this.switchTab('pdf');
        } catch (error) {
            this.addLog('error', `Error al compilar PDF: ${error.message}`);
            this.addLog('info', 'Puedes descargar el código LaTeX y compilarlo manualmente');
        }
    },
    async compilarPDF(latexCode) {
        // Opción 1: Backend real (Flask)
        try {
            const response = await fetch('http://localhost:5000/compile', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ latex: latexCode })
            });
            if (!response.ok) throw new Error('Error en el servidor');
            const blob = await response.blob();
            this.pdfBlob = blob;
            // Mostrar PDF en el visor
            PDFViewer.show(blob);
        } catch (error) {
            // Opción 2: Simulación (modo demostración)
            this.addLog('warning', 'Usando modo demostración (PDF simulado)');
            // Crear PDF simulado con instrucciones
            const mockPdfBlob = new Blob(
                ['CV generado correctamente. Para el PDF real, instala LaTeX localmente o usa Overleaf.'],
                { type: 'application/pdf' }
            );
            this.pdfBlob = mockPdfBlob;
            // Simular visor
            document.querySelector('.pdf-placeholder').innerHTML = `
                <i class="fas fa-check-circle fa-4x" style="color: var(--success);"></i>
                <p>PDF generado exitosamente (modo demo)</p>
                <button onclick="App.descargarPDF()" class="btn btn-primary btn-sm">
                    <i class="fas fa-download"></i> Descargar
                </button>
            `;
        }
    },
    descargarPDF() {
        if (!this.pdfBlob) {
            this.addLog('error', 'No hay PDF para descargar');
            return;
        }
        const url = URL.createObjectURL(this.pdfBlob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `cv-${new Date().toISOString().slice(0,10)}.pdf`;
        a.click();
        URL.revokeObjectURL(url);
        this.addLog('success', 'PDF descargado');
    },
    copiarYAML() {
        const yamlText = window.yamlEditor.getValue();
        navigator.clipboard.writeText(yamlText);
        this.addLog('info', 'YAML copiado al portapapeles');
    },
    descargarYAML() {
        const yamlText = window.yamlEditor.getValue();
        const blob = new Blob([yamlText], { type: 'text/yaml' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'datos.yaml';
        a.click();
        URL.revokeObjectURL(url);
    },
    copiarLaTeX() {
        if (this.latexCode) {
            navigator.clipboard.writeText(this.latexCode);
            this.addLog('info', 'Código LaTeX copiado al portapapeles');
        }
    },
    switchTab(tabId) {
        // Actualizar botones
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.tab === tabId);
        });
        // Actualizar contenido
        document.querySelectorAll('.tab-content').forEach(content => {
            content.classList.toggle('active', content.id === `tab-${tabId}`);
        });
    },
    cargarEjemplo() {
        this.loadDefaultYaml();
        this.addLog('info', 'Ejemplo cargado');
    }
};
// Inicializar cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', () => App.init());
// Función global para toggle logs
function toggleLogs() {
    const logContent = document.getElementById('log-content');
    const arrow = document.getElementById('log-arrow');
    if (logContent.style.display === 'none') {
        logContent.style.display = 'block';
        arrow.style.transform = 'rotate(0deg)';
    } else {
        logContent.style.display = 'none';
        arrow.style.transform = 'rotate(-90deg)';
    }
}
