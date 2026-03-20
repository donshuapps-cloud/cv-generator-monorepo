// Gestión del popup principal
document.addEventListener('DOMContentLoaded', async () => {
    await loadRecentFiles();
    setupEventListeners();
    updateStatus();
});
async function loadRecentFiles() {
    const result = await chrome.storage.local.get('recentFiles');
    const recentFiles = result.recentFiles || [];
    const recentList = document.getElementById('recent-list');
    if (recentFiles.length === 0) {
        recentList.innerHTML = '<p class="empty-state">No hay archivos recientes</p>';
        return;
    }
    recentList.innerHTML = recentFiles
        .slice(0, 5)
        .map(file => `
            <div class="recent-item" data-id="${file.id}">
                <div class="recent-info">
                    <i class="fas fa-file-alt"></i>
                    <div>
                        <div class="recent-name">${file.name}</div>
                        <div class="recent-date">${new Date(file.date).toLocaleDateString()}</div>
                    </div>
                </div>
                <button class="recent-delete" data-id="${file.id}">
                    <i class="fas fa-times"></i>
                </button>
            </div>
        `).join('');
    // Event listeners para items recientes
    document.querySelectorAll('.recent-item').forEach(item => {
        item.addEventListener('click', (e) => {
            if (!e.target.closest('.recent-delete')) {
                openRecent(item.dataset.id);
            }
        });
    });
    document.querySelectorAll('.recent-delete').forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.stopPropagation();
            deleteRecent(btn.dataset.id);
        });
    });
}
function setupEventListeners() {
    document.getElementById('btn-nuevo').addEventListener('click', () => {
        chrome.tabs.create({
            url: chrome.runtime.getURL('editor/editor.html?new=true')
        });
    });
    document.getElementById('btn-editar').addEventListener('click', () => {
        chrome.tabs.create({
            url: chrome.runtime.getURL('editor/editor.html')
        });
    });
    document.getElementById('btn-cargar').addEventListener('click', () => {
        const input = document.createElement('input');
        input.type = 'file';
        input.accept = '.yaml,.yml';
        input.onchange = async (e) => {
            const file = e.target.files[0];
            if (file) {
                const content = await file.text();
                chrome.storage.local.set({ 'currentYaml': content });
                chrome.tabs.create({
                    url: chrome.runtime.getURL('editor/editor.html?load=true')
                });
            }
        };
        input.click();
    });
    document.getElementById('open-options').addEventListener('click', (e) => {
        e.preventDefault();
        chrome.runtime.openOptionsPage();
    });
    // Plantillas
    document.querySelectorAll('.template-item').forEach(item => {
        item.addEventListener('click', () => {
            loadTemplate(item.dataset.template);
        });
    });
}
async function loadTemplate(templateName) {
    let yamlContent = '';
    switch(templateName) {
        case 'basico':
            yamlContent = getBasicTemplate();
            break;
        case 'tecnico':
            yamlContent = getTechnicalTemplate();
            break;
        case 'servicios':
            yamlContent = getServicesTemplate();
            break;
        case 'vacio':
            yamlContent = getEmptyTemplate();
            break;
    }
    await chrome.storage.local.set({ 'currentYaml': yamlContent });
    chrome.tabs.create({
        url: chrome.runtime.getURL('editor/editor.html?template=' + templateName)
    });
}
function getBasicTemplate() {
    return `# PLANTILLA BÁSICA
persona:
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
  - "Otra tarea"
educacion:
- fecha_inicio: "Sep/2010"
  fecha_fin: "Jul/2015"
  titulo: "Título obtenido"
  institucion: "Institución"`;
}
function getTechnicalTemplate() {
    return `# PLANTILLA PARA PERFILES TÉCNICOS
persona:
  nombre: "Tu Nombre"
  puesto: "Desarrollador / Técnico"
  cedula: "V-12345678"
  nacionalidad: "venezolana"
  fecha_nacimiento: "01/01/1990"
  direccion: "Tu dirección"
  telefono: "+58 412 1234567"
  email: "tu@email.com"
  github: "usuario"
  linkedin: "usuario"
perfil: "Profesional con experiencia en desarrollo de software..."
habilidades:
- nombre: "Python"
  valor: 5
- nombre: "JavaScript"
  valor: 4
- nombre: "Bases de datos"
  valor: 4
- nombre: "Git"
  valor: 5
experiencia:
- fecha_inicio: "Ene/2023"
  fecha_fin: "actualidad"
  puesto: "Desarrollador"
  lugar: "Empresa Tech"
  descripcion:
  - "Desarrollo de aplicaciones web"
  - "Mantenimiento de sistemas"`;
}
function getServicesTemplate() {
    return `# PLANTILLA PARA SERVICIOS GENERALES
persona:
  nombre: "Tu Nombre"
  puesto: "Auxiliar de Servicios"
  cedula: "V-12345678"
  nacionalidad: "venezolana"
  fecha_nacimiento: "01/01/1990"
  direccion: "Tu dirección"
  telefono: "+58 412 1234567"
  email: "tu@email.com"
perfil: "Persona responsable, puntual y con gran disposición para el trabajo."
habilidades:
- nombre: "Limpieza y orden"
  valor: 5
- nombre: "Responsabilidad"
  valor: 5
- nombre: "Trabajo en equipo"
  valor: 5
- nombre: "Atención al cliente"
  valor: 4
experiencia:
- fecha_inicio: "Ene/2023"
  fecha_fin: "actualidad"
  puesto: "Auxiliar de Servicios"
  lugar: "Empresa"
  descripcion:
  - "Limpieza de áreas comunes"
  - "Atención al cliente"`;
}
function getEmptyTemplate() {
    return `# PLANTILLA VACÍA - COMPLETA TUS DATOS
persona:
  nombre: ""
  puesto: ""
  cedula: ""
  nacionalidad: ""
  fecha_nacimiento: ""
  direccion: ""
  telefono: ""
  email: ""
  foto: ""
perfil: ""
habilidades:
- nombre: ""
  valor: 0
experiencia:
- fecha_inicio: ""
  fecha_fin: ""
  puesto: ""
  lugar: ""
  descripcion: []
educacion:
- fecha_inicio: ""
  fecha_fin: ""
  titulo: ""
  institucion: ""`;
}
async function openRecent(id) {
    const result = await chrome.storage.local.get('recentFiles');
    const files = result.recentFiles || [];
    const file = files.find(f => f.id === id);
    if (file) {
        await chrome.storage.local.set({ 'currentYaml': file.content });
        chrome.tabs.create({
            url: chrome.runtime.getURL('editor/editor.html?id=' + id)
        });
    }
}
async function deleteRecent(id) {
    const result = await chrome.storage.local.get('recentFiles');
    const files = result.recentFiles || [];
    const updated = files.filter(f => f.id !== id);
    await chrome.storage.local.set({ 'recentFiles': updated });
    await loadRecentFiles();
    updateStatus('Archivo eliminado');
}
async function updateStatus(message = 'Listo') {
    const status = document.getElementById('status');
    status.innerHTML = `<i class="fas fa-circle"></i> ${message}`;
}
// Comunicación con background
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
    if (message.type === 'UPDATE_STATUS') {
        updateStatus(message.text);
    }
});
