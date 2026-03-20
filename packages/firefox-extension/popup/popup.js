// Detectar Firefox
const isFirefox = typeof browser !== 'undefined';
const api = isFirefox ? browser : chrome;
document.addEventListener('DOMContentLoaded', async () => {
    await loadRecentFiles();
    setupEventListeners();
    updateStatus();
    // Ajustes específicos Firefox
    if (isFirefox) {
        document.body.classList.add('firefox');
        // Firefox Android tiene tamaños de toque más grandes
        if (navigator.userAgent.includes('Android')) {
            document.body.classList.add('mobile');
        }
    }
});
async function loadRecentFiles() {
    const result = await api.storage.local.get('recentFiles');
    const recentFiles = result.recentFiles || [];
    const recentList = document.getElementById('recent-list');
    if (recentFiles.length === 0) {
        recentList.innerHTML = '<p class="empty-state">' + getMessage('noRecent') + '</p>';
        return;
    }
    recentList.innerHTML = recentFiles
        .slice(0, 5)
        .map(file => `
            <div class="recent-item" data-id="${file.id}">
                <div class="recent-info">
                    <i class="fas fa-file-alt"></i>
                    <div>
                        <div class="recent-name">${escapeHtml(file.name)}</div>
                        <div class="recent-date">${new Date(file.date).toLocaleDateString()}</div>
                    </div>
                </div>
                <button class="recent-delete" data-id="${file.id}">
                    <i class="fas fa-times"></i>
                </button>
            </div>
        `).join('');
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
        api.tabs.create({
            url: api.runtime.getURL('editor/editor.html?new=true')
        });
    });
    document.getElementById('btn-editar').addEventListener('click', () => {
        api.tabs.create({
            url: api.runtime.getURL('editor/editor.html')
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
                await api.storage.local.set({ 'currentYaml': content });
                api.tabs.create({
                    url: api.runtime.getURL('editor/editor.html?load=true')
                });
            }
        };
        input.click();
    });
    document.getElementById('open-options').addEventListener('click', (e) => {
        e.preventDefault();
        api.runtime.sendMessage({ type: 'OPEN_OPTIONS' });
    });
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
    await api.storage.local.set({ 'currentYaml': yamlContent });
    api.tabs.create({
        url: api.runtime.getURL('editor/editor.html?template=' + templateName)
    });
}
function getBasicTemplate() {
    return `persona:
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
}
function getTechnicalTemplate() {
    return `persona:
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
}
function getServicesTemplate() {
    return `persona:
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
}
function getEmptyTemplate() {
    return `persona:
  nombre: ""
  puesto: ""
  cedula: ""
  nacionalidad: ""
  fecha_nacimiento: ""
  direccion: ""
  telefono: ""
  email: ""
perfil: ""
habilidades: []
experiencia: []
educacion: []`;
}
async function openRecent(id) {
    const result = await api.storage.local.get(id);
    const file = result[id];
    if (file) {
        await api.storage.local.set({ 'currentYaml': file.content });
        api.tabs.create({
            url: api.runtime.getURL('editor/editor.html?id=' + id)
        });
    }
}
async function deleteRecent(id) {
    const result = await api.storage.local.get('recentFiles');
    const files = result.recentFiles || [];
    const updated = files.filter(f => f.id !== id);
    await api.storage.local.set({ 'recentFiles': updated });
    await api.storage.local.remove(id);
    await loadRecentFiles();
    updateStatus('Archivo eliminado');
}
function updateStatus(message = 'ready') {
    const status = document.getElementById('status');
    status.innerHTML = `<i class="fas fa-circle"></i> ${getMessage(message)}`;
}
function getMessage(key) {
    // Simulación simple de i18n
    const messages = {
        'ready': 'Listo',
        'noRecent': 'No hay archivos recientes',
        'newCV': 'Nuevo CV',
        'openEditor': 'Abrir editor',
        'loadYAML': 'Cargar YAML',
        'templates': 'Plantillas',
        'basicTemplate': 'Básica',
        'technicalTemplate': 'Técnica',
        'servicesTemplate': 'Servicios',
        'emptyTemplate': 'Vacía',
        'recentFiles': 'Archivos recientes'
    };
    return messages[key] || key;
}
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}
