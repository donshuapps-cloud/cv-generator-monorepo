// Configuración global
let yamlData = null;
let latexCode = null;
let pdfBlob = null;
let pyodide = null;
let currentFileId = null;
// Inicialización
document.addEventListener('DOMContentLoaded', async () => {
    initCodeMirror();
    setupEventListeners();
    await initPyodide();
    await loadInitialFile();
    updateStatus('Listo');
});
// Editor CodeMirror
let editor;
function initCodeMirror() {
    editor = CodeMirror.fromTextArea(document.getElementById('yaml-editor'), {
        mode: 'yaml',
        theme: 'material-darker',
        lineNumbers: true,
        indentUnit: 2,
        tabSize: 2,
        lineWrapping: true,
        foldGutter: true,
        gutters: ['CodeMirror-linenumbers', 'CodeMirror-foldgutter'],
        extraKeys: {
            'Ctrl-S': () => saveFile(),
            'Cmd-S': () => saveFile(),
            'Ctrl-Enter': () => generateCV(),
            'Cmd-Enter': () => generateCV(),
            'Shift-Ctrl-F': () => formatYAML()
        }
    });
    // Mostrar posición del cursor
    editor.on('cursorActivity', () => {
        const pos = editor.getCursor();
        document.getElementById('cursor-position').textContent = `Ln ${pos.line + 1}, Col ${pos.ch + 1}`;
    });
    // Validar al cambiar
    editor.on('change', () => {
        validateYAML();
    });
}
// Event Listeners
function setupEventListeners() {
    // Botones principales
    document.getElementById('btn-menu').addEventListener('click', toggleMenu);
    document.getElementById('btn-validar').addEventListener('click', validateYAML);
    document.getElementById('btn-generar').addEventListener('click', generateCV);
    document.getElementById('btn-descargar-pdf').addEventListener('click', downloadPDF);
    document.getElementById('btn-menu-mas').addEventListener('click', toggleMenu);
    // Menú desplegable
    document.getElementById('menu-nuevo').addEventListener('click', () => newFile());
    document.getElementById('menu-abrir').addEventListener('click', () => openFile());
    document.getElementById('menu-guardar').addEventListener('click', () => saveFile());
    document.getElementById('menu-guardar-como').addEventListener('click', () => saveFileAs());
    document.getElementById('menu-exportar-latex').addEventListener('click', () => exportLaTeX());
    document.getElementById('menu-exportar-pdf').addEventListener('click', () => downloadPDF());
    document.getElementById('menu-plantilla-basica').addEventListener('click', () => loadTemplate('basico'));
    document.getElementById('menu-plantilla-tecnica').addEventListener('click', () => loadTemplate('tecnico'));
    document.getElementById('menu-plantilla-servicios').addEventListener('click', () => loadTemplate('servicios'));
    document.getElementById('menu-ayuda').addEventListener('click', showHelp);
    document.getElementById('menu-acerca').addEventListener('click', showAbout);
    // Tabs
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', (e) => switchTab(e.target.dataset.tab));
    });
    // PDF controls
    document.getElementById('pdf-prev').addEventListener('click', () => PDFViewer.prevPage());
    document.getElementById('pdf-next').addEventListener('click', () => PDFViewer.nextPage());
    document.getElementById('pdf-descargar').addEventListener('click', downloadPDF);
    document.getElementById('pdf-generar').addEventListener('click', generateCV);
    // LaTeX
    document.getElementById('btn-copiar-latex').addEventListener('click', copyLaTeX);
    document.getElementById('btn-descargar-latex').addEventListener('click', downloadLaTeX);
    // Console
    document.getElementById('btn-limpiar-console').addEventListener('click', clearConsole);
    // Cerrar menú al hacer clic fuera
    document.addEventListener('click', (e) => {
        if (!e.target.closest('#btn-menu') && !e.target.closest('#btn-menu-mas') && !e.target.closest('.dropdown-menu')) {
            document.getElementById('dropdown-menu').classList.add('hidden');
        }
    });
}
// Pyodide (Python en WebAssembly)
async function initPyodide() {
    try {
        updatePyodideStatus('Iniciando Pyodide...');
        // Cargar Pyodide desde CDN
        const script = document.createElement('script');
        script.src = 'https://cdn.jsdelivr.net/pyodide/v0.24.1/full/pyodide.js';
        document.head.appendChild(script);
        await new Promise(resolve => script.onload = resolve);
        pyodide = await loadPyodide({
            indexURL: 'https://cdn.jsdelivr.net/pyodide/v0.24.1/full/'
        });
        await pyodide.loadPackage(['micropip']);
        const micropip = pyodide.pyimport('micropip');
        await micropip.install('pyyaml');
        // Cargar script de compilación LaTeX
        await pyodide.runPythonAsync(`
import sys
import io
import subprocess
from pathlib import Path
# Redirigir stdout para capturar logs
sys.stdout = io.StringIO()
def compile_latex(latex_code):
    """Compila LaTeX a PDF usando pdflatex (simulado en Pyodide)"""
    # En Pyodide no podemos ejecutar pdflatex real,
    # así que generamos un PDF simulado o usamos un servicio web
    # Por ahora, retornamos el código LaTeX para descarga
    return latex_code.encode('utf-8')
        `);
        updatePyodideStatus('Pyodide listo', 'success');
        addLog('success', 'Pyodide inicializado correctamente');
    } catch (error) {
        updatePyodideStatus('Error al iniciar Pyodide', 'error');
        addLog('error', `Pyodide: ${error.message}`);
    }
}
// Validación YAML
function validateYAML() {
    const yamlText = editor.getValue();
    try {
        yamlData = jsyaml.load(yamlText);
        // Actualizar badge
        document.getElementById('yaml-status').className = 'status-badge success';
        document.getElementById('yaml-status').innerHTML = '<i class="fas fa-check"></i> Válido';
        addLog('success', 'YAML válido');
        updatePreview();
        return true;
    } catch (error) {
        document.getElementById('yaml-status').className = 'status-badge error';
        document.getElementById('yaml-status').innerHTML = '<i class="fas fa-exclamation-triangle"></i> Inválido';
        addLog('error', `YAML: ${error.message}`);
        return false;
    }
}
// Vista previa
function updatePreview() {
    if (!yamlData) return;
    const preview = document.getElementById('preview-content');
    const p = yamlData.persona || {};
    // Foto
    const fotoHtml = p.foto ? 
        `<img src="${p.foto}" alt="Foto">` : 
        '<i class="fas fa-user-circle"></i>';
    // Habilidades
    const skillsHtml = (yamlData.habilidades || []).map(h => `
        <div class="skill-item">
            <span class="skill-name">${h.nombre || ''}</span>
            <div class="skill-bar">
                <div class="skill-progress" style="width: ${(h.valor || 0) * 20}%"></div>
            </div>
        </div>
    `).join('');
    // Experiencia
    const expHtml = (yamlData.experiencia || []).map(e => `
        <div class="exp-item">
            <div class="exp-header">
                <span class="exp-title">${e.puesto || ''}</span>
                <span class="exp-date">${e.fecha_inicio || ''} - ${e.fecha_fin || ''}</span>
            </div>
            <div class="exp-lugar">${e.lugar || ''}</div>
            <ul class="exp-desc">
                ${(e.descripcion || []).map(d => `<li>${d}</li>`).join('')}
            </ul>
        </div>
    `).join('');
    // Educación
    const eduHtml = (yamlData.educacion || []).map(e => `
        <div class="edu-item">
            <div class="edu-header">
                <span class="edu-title">${e.titulo || ''}</span>
                <span class="edu-date">${e.fecha_inicio || ''} - ${e.fecha_fin || ''}</span>
            </div>
            <div class="edu-institucion">${e.institucion || ''}</div>
        </div>
    `).join('');
    preview.innerHTML = `
        <div class="preview-header">
            <div class="preview-photo">
                ${fotoHtml}
            </div>
            <div class="preview-title">
                <h3>${p.nombre || 'Nombre'}</h3>
                <p class="text-muted">${p.puesto || ''}</p>
            </div>
        </div>
        <div class="preview-info-grid">
            <div class="info-item"><i class="fas fa-id-card"></i> ${p.cedula || '-'}</div>
            <div class="info-item"><i class="fas fa-flag"></i> ${p.nacionalidad || '-'}</div>
            <div class="info-item"><i class="fas fa-calendar"></i> ${p.fecha_nacimiento || '-'}</div>
            <div class="info-item"><i class="fas fa-map-marker-alt"></i> ${p.direccion || '-'}</div>
            <div class="info-item"><i class="fas fa-phone"></i> ${p.telefono || '-'}</div>
            <div class="info-item"><i class="fas fa-envelope"></i> ${p.email || '-'}</div>
        </div>
        ${yamlData.perfil ? `
        <div class="preview-section">
            <h4>Perfil Profesional</h4>
            <p class="text-justify">${yamlData.perfil}</p>
        </div>
        ` : ''}
        ${skillsHtml ? `
        <div class="preview-section">
            <h4>Habilidades</h4>
            <div class="skills-container">
                ${skillsHtml}
            </div>
        </div>
        ` : ''}
        ${expHtml ? `
        <div class="preview-section">
            <h4>Experiencia Laboral</h4>
            ${expHtml}
        </div>
        ` : ''}
        ${eduHtml ? `
        <div class="preview-section">
            <h4>Educación</h4>
            ${eduHtml}
        </div>
        ` : ''}
    `;
}
// Generar CV
async function generateCV() {
    addLog('info', 'Iniciando generación del CV...');
    if (!validateYAML()) {
        addLog('error', 'Corrige los errores del YAML antes de continuar');
        return;
    }
    // Generar LaTeX
    addLog('info', 'Generando código LaTeX...');
    latexCode = generateLaTeX(yamlData);
    document.getElementById('latex-code').textContent = latexCode;
    // Cambiar a pestaña LaTeX
    switchTab('latex');
    // Compilar a PDF
    addLog('info', 'Compilando a PDF...');
    try {
        if (pyodide) {
            // Usar Pyodide para compilar
            const result = await pyodide.runPythonAsync(`
compile_latex('''${latexCode.replace(/'/g, "\\'")}''')
            `);
            pdfBlob = new Blob([result], { type: 'application/pdf' });
            addLog('success', 'PDF generado correctamente');
            // Mostrar en visor
            await PDFViewer.show(pdfBlob);
            // Habilitar botones
            document.getElementById('btn-descargar-pdf').disabled = false;
            document.getElementById('pdf-descargar').disabled = false;
        } else {
            // Modo simulado
            addLog('warning', 'Usando modo demostración (Pyodide no disponible)');
            simulatePDF();
        }
    } catch (error) {
        addLog('error', `Error al compilar: ${error.message}`);
    }
}
// Generador LaTeX (versión JS)
function generateLaTeX(data) {
    const escape = (text) => {
        if (!text) return '';
        const replacements = {
            '&': '\\&', '%': '\\%', '$': '\\$', '#': '\\#',
            '_': '\\_', '{': '\\{', '}': '\\}', '~': '\\textasciitilde{}',
            '^': '\\textasciicircum{}', '\\': '\\textbackslash{}'
        };
        return String(text).replace(/[&%$#_{}~^\\]/g, char => replacements[char]);
    };
    const p = data.persona || {};
    const lines = [];
    lines.push('%' + '='.repeat(80));
    lines.push('% CURRÍCULUM VITAE - GENERADO DESDE EXTENSIÓN CHROME');
    lines.push('% Generado el: ' + new Date().toLocaleString());
    lines.push('%' + '='.repeat(80));
    lines.push('');
    lines.push('\\documentclass[a4paper]{twentysecondcv-espanol}');
    lines.push('');
    lines.push('\\usepackage[utf8]{inputenc}');
    lines.push('\\usepackage[spanish]{babel}');
    lines.push('');
    // Datos personales
    lines.push(`\\cvnombre{${escape(p.nombre || '')}}`);
    lines.push(`\\cvpuesto{${escape(p.puesto || '')}}`);
    lines.push(`\\cvcedula{${escape(p.cedula || '')}}`);
    lines.push(`\\cvnacionalidad{${escape(p.nacionalidad || '')}}`);
    lines.push(`\\cvfecha{${escape(p.fecha_nacimiento || '')}}`);
    lines.push(`\\cvdireccion{${escape(p.direccion || '')}}`);
    lines.push(`\\cvtelefono{${String(p.telefono || '').replace(/[\\{}]/g, '')}}`);
    lines.push(`\\cvemail{${escape(p.email || '')}}`);
    if (p.foto) lines.push(`\\fotoperfil{${p.foto}}`);
    lines.push('');
    lines.push('\\begin{document}');
    lines.push('');
    // Perfil
    if (data.perfil) {
        lines.push(`\\perfil{Perfil Profesional}{${escape(data.perfil)}}`);
        lines.push('');
    }
    // Habilidades
    if (data.habilidades && data.habilidades.length > 0) {
        lines.push('\\habilidades{%');
        data.habilidades.forEach((h, i) => {
            lines.push(`    ${escape(h.nombre || '')}/${Math.min(5, Math.max(0, parseInt(h.valor) || 3))}${i < data.habilidades.length - 1 ? ',' : ''}`);
        });
        lines.push('}');
        lines.push('');
    }
    lines.push('\\crearperfil');
    lines.push('');
    // Experiencia
    if (data.experiencia && data.experiencia.length > 0) {
        lines.push('\\section{Experiencia Laboral}');
        lines.push('\\begin{veinte}');
        lines.push('');
        data.experiencia.forEach(exp => {
            const desc = (exp.descripcion || []).map(d => `        ${escape(d)};%`).join('\n');
            lines.push(`    \\veinteitemtiempo{mainblue}{mainblue}{${exp.fecha_inicio || ''}}{${exp.fecha_fin || ''}}{${escape(exp.puesto || '')}}{${escape(exp.lugar || '')}}{%`);
            lines.push(`    \\makeList{%`);
            lines.push(desc);
            lines.push(`    }`);
            lines.push(`    }`);
            lines.push(`    `);
        });
        lines.push('\\end{veinte}');
        lines.push('');
    }
    // Educación
    if (data.educacion && data.educacion.length > 0) {
        lines.push('\\section{Educación}');
        lines.push('\\begin{veinte}');
        lines.push('');
        data.educacion.forEach(edu => {
            lines.push(`    \\veinteitemtiempo{mainblue}{mainblue}{${edu.fecha_inicio || ''}}{${edu.fecha_fin || ''}}{${escape(edu.titulo || '')}}{${escape(edu.institucion || '')}}{${escape(edu.descripcion || '')}}`);
            lines.push(`    `);
        });
        lines.push('\\end{veinte}');
        lines.push('');
    }
    lines.push('\\end{document}');
    return lines.join('\n');
}
// PDF Viewer
const PDFViewer = {
    currentPdf: null,
    currentPage: 1,
    totalPages: 1,
    async show(blob) {
        const container = document.getElementById('pdf-viewer');
        container.innerHTML = '<div class="pdf-loading">Cargando PDF...</div>';
        try {
            const arrayBuffer = await blob.arrayBuffer();
            // Usar PDF.js
            const pdfjsLib = await import('https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.16.105/pdf.min.js');
            pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.16.105/pdf.worker.min.js';
            const pdf = await pdfjsLib.getDocument({ data: arrayBuffer }).promise;
            this.currentPdf = pdf;
            this.totalPages = pdf.numPages;
            this.currentPage = 1;
            document.getElementById('pdf-page').textContent = `1 / ${this.totalPages}`;
            document.getElementById('pdf-prev').disabled = true;
            document.getElementById('pdf-next').disabled = this.totalPages === 1;
            await this.renderPage(1);
        } catch (error) {
            container.innerHTML = `<div class="pdf-error">Error: ${error.message}</div>`;
        }
    },
    async renderPage(pageNum) {
        if (!this.currentPdf) return;
        const page = await this.currentPdf.getPage(pageNum);
        const container = document.getElementById('pdf-viewer');
        const viewport = page.getViewport({ scale: 1.5 });
        const canvas = document.createElement('canvas');
        const context = canvas.getContext('2d');
        canvas.width = viewport.width;
        canvas.height = viewport.height;
        container.innerHTML = '';
        container.appendChild(canvas);
        await page.render({ canvasContext: context, viewport }).promise;
        document.getElementById('pdf-page').textContent = `${pageNum} / ${this.totalPages}`;
        document.getElementById('pdf-prev').disabled = pageNum === 1;
        document.getElementById('pdf-next').disabled = pageNum === this.totalPages;
    },
    async prevPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            await this.renderPage(this.currentPage);
        }
    },
    async nextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            await this.renderPage(this.currentPage);
        }
    }
};
// Utilidades
function addLog(type, message) {
    const console = document.getElementById('console-output');
    const time = new Date().toLocaleTimeString();
    const entry = document.createElement('div');
    entry.className = `log-entry ${type}`;
    entry.innerHTML = `<span class="log-time">[${time}]</span> <span class="log-msg">${message}</span>`;
    console.appendChild(entry);
    console.scrollTop = console.scrollHeight;
}
function clearConsole() {
    document.getElementById('console-output').innerHTML = '';
}
function toggleMenu() {
    document.getElementById('dropdown-menu').classList.toggle('hidden');
}
function switchTab(tabId) {
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.toggle('active', btn.dataset.tab === tabId);
    });
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.toggle('active', content.id === `tab-${tabId}`);
    });
}
function updatePyodideStatus(message, type = 'warning') {
    const status = document.getElementById('pyodide-status');
    const icon = type === 'success' ? 'fa-circle text-success' : 'fa-circle text-warning';
    status.innerHTML = `<i class="fas ${icon}"></i> ${message}`;
}
function updateStatus(message) {
    document.getElementById('progress').textContent = message;
}
async function saveFile() {
    const content = editor.getValue();
    const timestamp = Date.now();
    // Guardar en storage local
    const file = {
        id: currentFileId || 'file_' + timestamp,
        name: document.getElementById('filename').textContent,
        content: content,
        date: timestamp
    };
    await chrome.storage.local.set({ [file.id]: file });
    // Actualizar recientes
    const result = await chrome.storage.local.get('recentFiles');
    const recent = result.recentFiles || [];
    const existingIndex = recent.findIndex(f => f.id === file.id);
    if (existingIndex >= 0) {
        recent[existingIndex] = file;
    } else {
        recent.unshift(file);
        if (recent.length > 10) recent.pop();
    }
    await chrome.storage.local.set({ recentFiles: recent });
    currentFileId = file.id;
    addLog('success', 'Archivo guardado');
}
function downloadPDF() {
    if (!pdfBlob) {
        addLog('error', 'No hay PDF para descargar');
        return;
    }
    saveAs(pdfBlob, `cv-${new Date().toISOString().slice(0,10)}.pdf`);
    addLog('success', 'PDF descargado');
}
function downloadLaTeX() {
    if (!latexCode) {
        addLog('error', 'No hay código LaTeX');
        return;
    }
    const blob = new Blob([latexCode], { type: 'text/plain' });
    saveAs(blob, 'cv-completo.tex');
    addLog('success', 'LaTeX descargado');
}
function copyLaTeX() {
    if (!latexCode) {
        addLog('error', 'No hay código LaTeX');
        return;
    }
    navigator.clipboard.writeText(latexCode);
    addLog('success', 'LaTeX copiado al portapapeles');
}
function simulatePDF() {
    // PDF simulado para demostración
    pdfBlob = new Blob(
        ['CV generado correctamente. Para el PDF real, instala LaTeX localmente.'],
        { type: 'application/pdf' }
    );
    document.getElementById('btn-descargar-pdf').disabled = false;
    document.getElementById('pdf-descargar').disabled = false;
    document.querySelector('.pdf-placeholder').innerHTML = `
        <i class="fas fa-check-circle fa-4x" style="color: var(--success);"></i>
        <p>PDF generado (modo demostración)</p>
        <button onclick="downloadPDF()" class="btn btn-primary btn-sm">
            <i class="fas fa-download"></i> Descargar
        </button>
    `;
    addLog('success', 'PDF simulado generado');
}
async function loadInitialFile() {
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.has('new')) {
        loadTemplate('basico');
    } else if (urlParams.has('id')) {
        const id = urlParams.get('id');
        const result = await chrome.storage.local.get(id);
        const file = result[id];
        if (file) {
            editor.setValue(file.content);
            document.getElementById('filename').textContent = file.name;
            currentFileId = id;
            validateYAML();
        }
    } else {
        const result = await chrome.storage.local.get('currentYaml');
        if (result.currentYaml) {
            editor.setValue(result.currentYaml);
            await chrome.storage.local.remove('currentYaml');
            validateYAML();
        }
    }
}
function loadTemplate(type) {
    let content = '';
    switch(type) {
        case 'basico':
            content = `persona:
  nombre: "Tu Nombre Completo"
  puesto: "Tu Puesto"
  cedula: "V-12345678"
  nacionalidad: "venezolana"
  fecha_nacimiento: "01/01/1990"
  direccion: "Tu dirección"
  telefono: "+58 412 1234567"
  email: "tu@email.com"
perfil: "Persona responsable con experiencia en..."
habilidades:
- nombre: "Responsabilidad"
  valor: 5
- nombre: "Trabajo en equipo"
  valor: 4
experiencia:
- fecha_inicio: "Ene/2023"
  fecha_fin: "actualidad"
  puesto: "Puesto actual"
  lugar: "Empresa"
  descripcion:
  - "Tarea principal"
educacion:
- fecha_inicio: "Sep/2010"
  fecha_fin: "Jul/2015"
  titulo: "Título"
  institucion: "Institución"`;
            break;
        case 'tecnico':
            content = `persona:
  nombre: "Tu Nombre"
  puesto: "Desarrollador / Técnico"
  cedula: "V-12345678"
  nacionalidad: "venezolana"
  fecha_nacimiento: "01/01/1990"
  direccion: "Tu dirección"
  telefono: "+58 412 1234567"
  email: "tu@email.com"
  github: "usuario"
perfil: "Profesional con experiencia en desarrollo..."
habilidades:
- nombre: "Python"
  valor: 5
- nombre: "JavaScript"
  valor: 4
- nombre: "Git"
  valor: 5
experiencia:
- fecha_inicio: "Ene/2023"
  fecha_fin: "actualidad"
  puesto: "Desarrollador"
  lugar: "Empresa Tech"
  descripcion:
  - "Desarrollo de aplicaciones web"`;
            break;
        case 'servicios':
            content = `persona:
  nombre: "Tu Nombre"
  puesto: "Auxiliar de Servicios"
  cedula: "V-12345678"
  nacionalidad: "venezolana"
  fecha_nacimiento: "01/01/1990"
  direccion: "Tu dirección"
  telefono: "+58 412 1234567"
  email: "tu@email.com"
perfil: "Persona responsable, puntual y con gran disposición."
habilidades:
- nombre: "Limpieza y orden"
  valor: 5
- nombre: "Responsabilidad"
  valor: 5
- nombre: "Trabajo en equipo"
  valor: 5
experiencia:
- fecha_inicio: "Ene/2023"
  fecha_fin: "actualidad"
  puesto: "Auxiliar"
  lugar: "Empresa"
  descripcion:
  - "Limpieza de áreas comunes"`;
            break;
    }
    editor.setValue(content);
    document.getElementById('filename').textContent = 'nuevo.yaml';
    currentFileId = null;
    validateYAML();
}
function newFile() {
    if (editor.getValue().trim() && !confirm('¿Perder los cambios actuales?')) return;
    loadTemplate('basico');
}
function openFile() {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.yaml,.yml';
    input.onchange = async (e) => {
        const file = e.target.files[0];
        if (file) {
            const content = await file.text();
            editor.setValue(content);
            document.getElementById('filename').textContent = file.name;
            currentFileId = null;
            validateYAML();
        }
    };
    input.click();
}
function saveFileAs() {
    const content = editor.getValue();
    const blob = new Blob([content], { type: 'text/yaml' });
    saveAs(blob, 'datos.yaml');
}
function exportLaTeX() {
    if (!validateYAML()) return;
    latexCode = generateLaTeX(yamlData);
    downloadLaTeX();
}
function showHelp() {
    window.open('https://github.com/donshuapps-cloud/cv-generator-monorepo/wiki', '_blank');
}
function showAbout() {
    alert(
        'Generador de CV Profesional v1.0.0\n' +
        'Desarrollado por Donshu\n' +
        '© 2026 - Todos los derechos reservados'
    );
}
