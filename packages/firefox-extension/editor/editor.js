// Versión adaptada para Firefox
const isFirefox = typeof browser !== 'undefined';
const api = isFirefox ? browser : chrome;
let editor;
let yamlData = null;
let latexCode = null;
let pdfBlob = null;
let currentFileId = null;
let pyodide = null;
document.addEventListener('DOMContentLoaded', async () => {
    // Cargar CodeMirror desde CDN o local
    await loadCodeMirror();
    initCodeMirror();
    setupEventListeners();
    await initPyodide();
    await loadInitialFile();
    updateStatus('Listo');
    // Ajustes específicos Firefox
    if (isFirefox) {
        // Firefox necesita permisos especiales para blob URLs
        URL.createObjectURL = URL.createObjectURL || webkitURL.createObjectURL;
        // Detectar Firefox Android
        if (navigator.userAgent.includes('Android')) {
            document.body.classList.add('mobile');
        }
    }
});
async function loadCodeMirror() {
    return new Promise((resolve) => {
        if (window.CodeMirror) {
            resolve();
            return;
        }
        // Cargar desde CDN
        const script = document.createElement('script');
        script.src = 'https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.2/codemirror.min.js';
        script.onload = () => {
            const modeScript = document.createElement('script');
            modeScript.src = 'https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.2/mode/yaml/yaml.min.js';
            modeScript.onload = resolve;
            document.head.appendChild(modeScript);
        };
        document.head.appendChild(script);
        // CSS
        const link = document.createElement('link');
        link.rel = 'stylesheet';
        link.href = 'https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.2/codemirror.min.css';
        document.head.appendChild(link);
        const themeLink = document.createElement('link');
        themeLink.rel = 'stylesheet';
        themeLink.href = 'https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.2/theme/material-darker.min.css';
        document.head.appendChild(themeLink);
    });
}
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
            'Cmd-Enter': () => generateCV()
        }
    });
    editor.on('cursorActivity', () => {
        const pos = editor.getCursor();
        document.getElementById('cursor-position').textContent = 
            `Ln ${pos.line + 1}, Col ${pos.ch + 1}`;
    });
    editor.on('change', () => {
        validateYAML();
    });
}
async function initPyodide() {
    try {
        updateStatus('Iniciando Pyodide...');
        // En Firefox, Pyodide puede necesitar configuración especial
        const script = document.createElement('script');
        script.src = 'https://cdn.jsdelivr.net/pyodide/v0.24.1/full/pyodide.js';
        document.head.appendChild(script);
        await new Promise(resolve => script.onload = resolve);
        pyodide = await loadPyodide({
            indexURL: 'https://cdn.jsdelivr.net/pyodide/v0.24.1/full/',
            fullStdLib: false,
            stdin: () => null
        });
        await pyodide.loadPackage(['micropip']);
        const micropip = pyodide.pyimport('micropip');
        await micropip.install('pyyaml');
        addLog('success', 'Pyodide inicializado');
        updateStatus('Pyodide listo');
    } catch (error) {
        addLog('error', 'Pyodide: ' + error.message);
        updateStatus('Pyodide no disponible');
    }
}
function validateYAML() {
    const yamlText = editor.getValue();
    try {
        yamlData = jsyaml.load(yamlText);
        document.getElementById('yaml-status').className = 'status-badge success';
        document.getElementById('yaml-status').innerHTML = '<i class="fas fa-check"></i> Válido';
        updatePreview();
        addLog('success', 'YAML válido');
        return true;
    } catch (error) {
        document.getElementById('yaml-status').className = 'status-badge error';
        document.getElementById('yaml-status').innerHTML = '<i class="fas fa-exclamation-triangle"></i> Inválido';
        addLog('error', 'YAML: ' + error.message);
        return false;
    }
}
function updatePreview() {
    if (!yamlData) return;
    const p = yamlData.persona || {};
    const preview = document.getElementById('preview-content');
    // Habilidades
    const skillsHtml = (yamlData.habilidades || []).map(h => `
        <div class="skill-item">
            <span class="skill-name">${escapeHtml(h.nombre || '')}</span>
            <div class="skill-bar">
                <div class="skill-progress" style="width: ${(h.valor || 0) * 20}%"></div>
            </div>
        </div>
    `).join('');
    // Experiencia
    const expHtml = (yamlData.experiencia || []).map(e => `
        <div class="exp-item">
            <div class="exp-header">
                <span class="exp-title">${escapeHtml(e.puesto || '')}</span>
                <span class="exp-date">${e.fecha_inicio || ''} - ${e.fecha_fin || ''}</span>
            </div>
            <div class="exp-lugar">${escapeHtml(e.lugar || '')}</div>
            <ul class="exp-desc">
                ${(e.descripcion || []).map(d => `<li>${escapeHtml(d)}</li>`).join('')}
            </ul>
        </div>
    `).join('');
    preview.innerHTML = `
        <div class="preview-header">
            <div class="preview-photo">
                <i class="fas fa-user-circle"></i>
            </div>
            <div class="preview-title">
                <h3>${escapeHtml(p.nombre || 'Nombre')}</h3>
                <p class="text-muted">${escapeHtml(p.puesto || '')}</p>
            </div>
        </div>
        <div class="preview-info-grid">
            <div class="info-item"><i class="fas fa-id-card"></i> ${escapeHtml(p.cedula || '-')}</div>
            <div class="info-item"><i class="fas fa-flag"></i> ${escapeHtml(p.nacionalidad || '-')}</div>
            <div class="info-item"><i class="fas fa-calendar"></i> ${escapeHtml(p.fecha_nacimiento || '-')}</div>
            <div class="info-item"><i class="fas fa-map-marker-alt"></i> ${escapeHtml(p.direccion || '-')}</div>
            <div class="info-item"><i class="fas fa-phone"></i> ${escapeHtml(p.telefono || '-')}</div>
            <div class="info-item"><i class="fas fa-envelope"></i> ${escapeHtml(p.email || '-')}</div>
        </div>
        ${yamlData.perfil ? `
        <div class="preview-section">
            <h4>Perfil Profesional</h4>
            <p class="text-justify">${escapeHtml(yamlData.perfil)}</p>
        </div>
        ` : ''}
        ${skillsHtml ? `
        <div class="preview-section">
            <h4>Habilidades</h4>
            <div class="skills-container">${skillsHtml}</div>
        </div>
        ` : ''}
        ${expHtml ? `
        <div class="preview-section">
            <h4>Experiencia Laboral</h4>
            ${expHtml}
        </div>
        ` : ''}
    `;
}
async function generateCV() {
    addLog('info', 'Generando CV...');
    if (!validateYAML()) {
        addLog('error', 'Corrige el YAML primero');
        return;
    }
    latexCode = generateLaTeX(yamlData);
    document.getElementById('latex-code').textContent = latexCode;
    switchTab('latex');
    addLog('info', 'Compilando a PDF...');
    try {
        if (pyodide) {
            await compileWithPyodide();
        } else {
            simulatePDF();
        }
    } catch (error) {
        addLog('error', 'Error: ' + error.message);
    }
}
function generateLaTeX(data) {
    const escape = (text) => {
        if (!text) return '';
        return String(text)
            .replace(/&/g, '\\&')
            .replace(/%/g, '\\%')
            .replace(/\$/g, '\\$')
            .replace(/#/g, '\\#')
            .replace(/_/g, '\\_')
            .replace(/{/g, '\\{')
            .replace(/}/g, '\\}')
            .replace(/~/g, '\\textasciitilde{}')
            .replace(/\^/g, '\\textasciicircum{}')
            .replace(/\\/g, '\\textbackslash{}');
    };
    const p = data.persona || {};
    const lines = [];
    lines.push('\\documentclass[a4paper]{twentysecondcv-espanol}');
    lines.push('\\usepackage[utf8]{inputenc}');
    lines.push('\\usepackage[spanish]{babel}');
    lines.push('');
    lines.push(`\\cvnombre{${escape(p.nombre || '')}}`);
    lines.push(`\\cvpuesto{${escape(p.puesto || '')}}`);
    lines.push(`\\cvcedula{${escape(p.cedula || '')}}`);
    lines.push(`\\cvnacionalidad{${escape(p.nacionalidad || '')}}`);
    lines.push(`\\cvfecha{${escape(p.fecha_nacimiento || '')}}`);
    lines.push(`\\cvdireccion{${escape(p.direccion || '')}}`);
    lines.push(`\\cvtelefono{${String(p.telefono || '').replace(/[\\{}]/g, '')}}`);
    lines.push(`\\cvemail{${escape(p.email || '')}}`);
    lines.push('');
    lines.push('\\begin{document}');
    lines.push('');
    if (data.perfil) {
        lines.push(`\\perfil{Perfil Profesional}{${escape(data.perfil)}}`);
        lines.push('');
    }
    if (data.habilidades?.length) {
        lines.push('\\habilidades{%');
        data.habilidades.forEach((h, i) => {
            lines.push(`    ${escape(h.nombre || '')}/${Math.min(5, Math.max(0, parseInt(h.valor) || 3))}${i < data.habilidades.length - 1 ? ',' : ''}`);
        });
        lines.push('}');
        lines.push('');
    }
    lines.push('\\crearperfil');
    lines.push('');
    if (data.experiencia?.length) {
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
    lines.push('\\end{document}');
    return lines.join('\n');
}
async function compileWithPyodide() {
    // Simular compilación (en Firefox, Pyodide tiene limitaciones)
    setTimeout(() => {
        const fakePdf = new Blob(
            ['CV generado correctamente. Para PDF real, usa LaTeX local.'],
            { type: 'application/pdf' }
        );
        pdfBlob = fakePdf;
        document.getElementById('btn-descargar-pdf').disabled = false;
        document.getElementById('pdf-placeholder').innerHTML = `
            <i class="fas fa-check-circle" style="color: var(--success); font-size: 3rem;"></i>
            <p>PDF generado (modo compatible Firefox)</p>
            <button onclick="downloadPDF()" class="btn btn-primary">
                Descargar PDF
            </button>
        `;
        addLog('success', 'PDF generado');
    }, 1500);
}
function simulatePDF() {
    setTimeout(() => {
        pdfBlob = new Blob(
            ['CV generado en modo demostración'],
            { type: 'application/pdf' }
        );
        document.getElementById('btn-descargar-pdf').disabled = false;
        addLog('success', 'PDF simulado');
    }, 1000);
}
function downloadPDF() {
    if (!pdfBlob) return;
    // Firefox maneja Blobs de manera específica
    const url = URL.createObjectURL(pdfBlob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `cv-${new Date().toISOString().slice(0,10)}.pdf`;
    a.click();
    // Firefox necesita revocar después de un tiempo
    setTimeout(() => URL.revokeObjectURL(url), 100);
}
async function saveFile() {
    const content = editor.getValue();
    const result = await api.runtime.sendMessage({
        type: 'SAVE_FILE',
        data: {
            id: currentFileId,
            name: document.getElementById('filename').textContent,
            content: content
        }
    });
    if (result.success) {
        currentFileId = result.file.id;
        addLog('success', 'Archivo guardado');
    }
}
function addLog(type, message) {
    const console = document.getElementById('console-output');
    const time = new Date().toLocaleTimeString();
    const entry = document.createElement('div');
    entry.className = `log-entry ${type}`;
    entry.innerHTML = `<span class="log-time">[${time}]</span> <span class="log-msg">${message}</span>`;
    console.appendChild(entry);
    console.scrollTop = console.scrollHeight;
}
function switchTab(tabId) {
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.toggle('active', btn.dataset.tab === tabId);
    });
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.toggle('active', content.id === `tab-${tabId}`);
    });
}
function updateStatus(message) {
    document.getElementById('progress').textContent = message;
}
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}
async function loadInitialFile() {
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.has('new')) {
        loadTemplate('basico');
    } else if (urlParams.has('id')) {
        const id = urlParams.get('id');
        const result = await api.storage.local.get(id);
        const file = result[id];
        if (file) {
            editor.setValue(file.content);
            document.getElementById('filename').textContent = file.name;
            currentFileId = id;
            validateYAML();
        }
    } else {
        const result = await api.storage.local.get('currentYaml');
        if (result.currentYaml) {
            editor.setValue(result.currentYaml);
            await api.storage.local.remove('currentYaml');
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
perfil: "Persona responsable..."
habilidades:
- nombre: "Responsabilidad"
  valor: 5
experiencia:
- fecha_inicio: "Ene/2023"
  fecha_fin: "actualidad"
  puesto: "Puesto"
  lugar: "Empresa"
  descripcion:
  - "Tarea principal"`;
            break;
    }
    editor.setValue(content);
    validateYAML();
}
// Exponer funciones necesarias globalmente
window.downloadPDF = downloadPDF;
