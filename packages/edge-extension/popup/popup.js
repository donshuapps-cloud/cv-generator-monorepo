// Popup para Edge con características exclusivas
let edgeFeatures = {};
document.addEventListener('DOMContentLoaded', async () => {
  await detectEdgeFeatures();
  await loadRecentFiles();
  setupEventListeners();
  updateStatus();
  // Añadir badge de Edge si hay características especiales
  if (Object.values(edgeFeatures).some(v => v)) {
    addEdgeFeaturesBadge();
  }
});
async function detectEdgeFeatures() {
  const result = await chrome.runtime.sendMessage({ type: 'GET_EDGE_FEATURES' });
  edgeFeatures = result || {};
}
function addEdgeFeaturesBadge() {
  const header = document.querySelector('.popup-header');
  const badge = document.createElement('span');
  badge.className = 'edge-badge';
  badge.innerHTML = '<i class="fab fa-edge"></i> Edge';
  badge.title = 'Características exclusivas de Edge disponibles';
  header.appendChild(badge);
}
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
            <div class="recent-name">${escapeHtml(file.name)}</div>
            <div class="recent-date">${new Date(file.date).toLocaleDateString()}</div>
          </div>
        </div>
        <button class="recent-delete" data-id="${file.id}">
          <i class="fas fa-times"></i>
        </button>
      </div>
    `).join('');
  // Añadir menú contextual de Edge
  if (edgeFeatures.collections) {
    document.querySelectorAll('.recent-item').forEach(item => {
      item.addEventListener('contextmenu', (e) => {
        e.preventDefault();
        showEdgeContextMenu(e, item.dataset.id);
      });
    });
  }
  setupRecentListeners();
}
function showEdgeContextMenu(event, fileId) {
  const menu = document.createElement('div');
  menu.className = 'edge-context-menu';
  menu.style.top = event.pageY + 'px';
  menu.style.left = event.pageX + 'px';
  menu.innerHTML = `
    <ul>
      <li onclick="addToCollections('${fileId}')">
        <i class="fas fa-layer-group"></i> Añadir a Collections
      </li>
      <li onclick="shareWithDrop('${fileId}')">
        <i class="fas fa-cloud-upload-alt"></i> Compartir con Drop
      </li>
      <li onclick="openInEditor('${fileId}')">
        <i class="fas fa-pen"></i> Abrir en editor
      </li>
      <li onclick="downloadFile('${fileId}')">
        <i class="fas fa-download"></i> Descargar
      </li>
    </ul>
  `;
  document.body.appendChild(menu);
  // Cerrar al hacer clic fuera
  setTimeout(() => {
    document.addEventListener('click', () => menu.remove(), { once: true });
  }, 100);
}
async function addToCollections(fileId) {
  const result = await chrome.storage.local.get(fileId);
  const file = result[fileId];
  if (file) {
    const response = await chrome.runtime.sendMessage({
      type: 'ADD_TO_COLLECTIONS',
      data: file
    });
    if (response.success) {
      showNotification('Añadido a Collections', 'success');
    }
  }
}
async function shareWithDrop(fileId) {
  const result = await chrome.storage.local.get(fileId);
  const file = result[fileId];
  if (file) {
    const response = await chrome.runtime.sendMessage({
      type: 'SAVE_TO_DROP',
      data: file
    });
    if (response.success) {
      showNotification('Guardado en Drop', 'success');
    }
  }
}
function showNotification(message, type) {
  const notification = document.createElement('div');
  notification.className = `edge-notification ${type}`;
  notification.innerHTML = `
    <i class="fas fa-${type === 'success' ? 'check-circle' : 'info-circle'}"></i>
    ${message}
  `;
  document.body.appendChild(notification);
  setTimeout(() => notification.remove(), 3000);
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
        await chrome.storage.local.set({ 'currentYaml': content });
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
  document.querySelectorAll('.template-item').forEach(item => {
    item.addEventListener('click', () => {
      loadTemplate(item.dataset.template);
    });
  });
}
function setupRecentListeners() {
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
async function openRecent(id) {
  const result = await chrome.storage.local.get(id);
  const file = result[id];
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
  await chrome.storage.local.remove(id);
  await loadRecentFiles();
  updateStatus('Archivo eliminado');
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
  return `persona:
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
perfil: "Profesional con experiencia..."
habilidades:
- nombre: "Python"
  valor: 5
- nombre: "JavaScript"
  valor: 4
experiencia:
- fecha_inicio: "Ene/2023"
  fecha_fin: "actualidad"
  puesto: "Desarrollador"
  lugar: "Empresa Tech"
  descripcion:
  - "Desarrollo de aplicaciones"`;
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
perfil: "Persona responsable, puntual..."
habilidades:
- nombre: "Limpieza y orden"
  valor: 5
- nombre: "Responsabilidad"
  valor: 5
experiencia:
- fecha_inicio: "Ene/2023"
  fecha_fin: "actualidad"
  puesto: "Auxiliar"
  lugar: "Empresa"
  descripcion:
  - "Limpieza de áreas"`;
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
function updateStatus(message = 'Listo') {
  const status = document.getElementById('status');
  status.innerHTML = `<i class="fas fa-circle"></i> ${message}`;
}
function escapeHtml(text) {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}
