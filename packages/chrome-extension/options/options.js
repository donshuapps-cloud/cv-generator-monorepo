// Cargar configuración guardada
document.addEventListener('DOMContentLoaded', async () => {
    await loadSettings();
    await loadStorageInfo();
    await loadFiles();
    setupEventListeners();
});
async function loadSettings() {
    const result = await chrome.storage.local.get('settings');
    const settings = result.settings || {
        language: 'es',
        autoSave: true,
        theme: 'light',
        defaultTemplate: 'basico',
        fontSize: '13',
        tabSize: '2',
        lineNumbers: true,
        wordWrap: true,
        autoComplete: true
    };
    // Aplicar valores
    document.getElementById('language').value = settings.language;
    document.getElementById('auto-save').checked = settings.autoSave;
    document.getElementById('theme').value = settings.theme;
    document.getElementById('default-template').value = settings.defaultTemplate;
    document.getElementById('font-size').value = settings.fontSize || '13';
    document.getElementById('tab-size').value = settings.tabSize || '2';
    document.getElementById('line-numbers').checked = settings.lineNumbers !== false;
    document.getElementById('word-wrap').checked = settings.wordWrap !== false;
    document.getElementById('auto-complete').checked = settings.autoComplete !== false;
}
async function saveSettings() {
    const settings = {
        language: document.getElementById('language').value,
        autoSave: document.getElementById('auto-save').checked,
        theme: document.getElementById('theme').value,
        defaultTemplate: document.getElementById('default-template').value,
        fontSize: document.getElementById('font-size').value,
        tabSize: document.getElementById('tab-size').value,
        lineNumbers: document.getElementById('line-numbers').checked,
        wordWrap: document.getElementById('word-wrap').checked,
        autoComplete: document.getElementById('auto-complete').checked
    };
    await chrome.storage.local.set({ settings });
    // Notificar al editor si está abierto
    chrome.runtime.sendMessage({ type: 'SETTINGS_UPDATED', settings });
    showNotification('Configuración guardada');
}
async function loadStorageInfo() {
    const result = await chrome.storage.local.get(null);
    const bytes = new Blob([JSON.stringify(result)]).size;
    const mb = (bytes / (1024 * 1024)).toFixed(2);
    // Estimación de cuota (típicamente 5-10MB para extensiones)
    const quota = 10; // MB
    document.getElementById('storage-used').textContent = `${mb} MB`;
    document.getElementById('storage-quota').textContent = `${quota} MB`;
    const percent = Math.min(100, (bytes / (quota * 1024 * 1024)) * 100);
    document.getElementById('storage-bar-fill').style.width = `${percent}%`;
}
async function loadFiles() {
    const result = await chrome.storage.local.get('recentFiles');
    const files = result.recentFiles || [];
    const container = document.getElementById('file-list');
    if (files.length === 0) {
        container.innerHTML = '<p class="empty-state">No hay archivos guardados</p>';
        return;
    }
    container.innerHTML = files.map(file => `
        <div class="file-item" data-id="${file.id}">
            <div class="file-info">
                <i class="fas fa-file-alt"></i>
                <div>
                    <div class="file-name">${file.name}</div>
                    <div class="file-date">${new Date(file.date).toLocaleString()}</div>
                </div>
            </div>
            <button class="file-delete" onclick="deleteFile('${file.id}')">
                <i class="fas fa-trash"></i>
            </button>
        </div>
    `).join('');
}
async function deleteFile(id) {
    await chrome.storage.local.remove(id);
    // Actualizar lista de recientes
    const result = await chrome.storage.local.get('recentFiles');
    const files = result.recentFiles || [];
    const updated = files.filter(f => f.id !== id);
    await chrome.storage.local.set({ recentFiles: updated });
    await loadFiles();
    await loadStorageInfo();
}
function setupEventListeners() {
    // Navegación
    document.querySelectorAll('.options-nav li').forEach(item => {
        item.addEventListener('click', () => {
            document.querySelectorAll('.options-nav li').forEach(i => i.classList.remove('active'));
            item.classList.add('active');
            document.querySelectorAll('.panel').forEach(p => p.classList.remove('active'));
            document.getElementById(`panel-${item.dataset.section}`).classList.add('active');
        });
    });
    // Botones
    document.getElementById('save-settings').addEventListener('click', saveSettings);
    document.getElementById('reset-settings').addEventListener('click', resetSettings);
    document.getElementById('export-data').addEventListener('click', exportData);
    document.getElementById('import-data').addEventListener('click', importData);
    document.getElementById('clear-data').addEventListener('click', clearAllData);
    document.getElementById('check-updates').addEventListener('click', checkUpdates);
    document.getElementById('add-template').addEventListener('click', addTemplate);
}
function showNotification(message) {
    // Crear notificación simple
    const notification = document.createElement('div');
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: var(--success);
        color: white;
        padding: 1rem;
        border-radius: 4px;
        animation: slideIn 0.3s;
    `;
    notification.textContent = message;
    document.body.appendChild(notification);
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s';
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}
async function resetSettings() {
    if (confirm('¿Restablecer configuración por defecto?')) {
        await chrome.storage.local.remove('settings');
        await loadSettings();
        showNotification('Configuración restablecida');
    }
}
async function exportData() {
    const result = await chrome.storage.local.get(null);
    const blob = new Blob([JSON.stringify(result, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `cv-generator-backup-${new Date().toISOString().slice(0,10)}.json`;
    a.click();
    URL.revokeObjectURL(url);
}
async function importData() {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.json';
    input.onchange = async (e) => {
        const file = e.target.files[0];
        if (!file) return;
        try {
            const content = await file.text();
            const data = JSON.parse(content);
            if (confirm('¿Importar datos? Esto sobrescribirá la configuración actual.')) {
                await chrome.storage.local.clear();
                await chrome.storage.local.set(data);
                await loadSettings();
                await loadStorageInfo();
                await loadFiles();
                showNotification('Datos importados correctamente');
            }
        } catch (error) {
            alert('Error al importar: ' + error.message);
        }
    };
    input.click();
}
async function clearAllData() {
    if (confirm('¿Eliminar TODOS los datos? Esta acción no se puede deshacer.')) {
        await chrome.storage.local.clear();
        await loadSettings();
        await loadStorageInfo();
        await loadFiles();
        showNotification('Datos eliminados');
    }
}
async function checkUpdates() {
    showNotification('Buscando actualizaciones...');
    // Simular búsqueda
    setTimeout(() => {
        showNotification('Ya tienes la última versión');
    }, 2000);
}
function addTemplate() {
    const name = prompt('Nombre de la plantilla:');
    if (!name) return;
    const templateList = document.getElementById('template-list');
    const item = document.createElement('div');
    item.className = 'template-item';
    item.innerHTML = `
        <span>${name}</span>
        <div class="template-actions">
            <button onclick="editTemplate(this)"><i class="fas fa-edit"></i></button>
            <button onclick="deleteTemplate(this)"><i class="fas fa-trash"></i></button>
        </div>
    `;
    templateList.appendChild(item);
}
window.deleteFile = deleteFile;
