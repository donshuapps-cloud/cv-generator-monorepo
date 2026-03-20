// Background script para Firefox
let isFirefox = typeof browser !== 'undefined';
// Usar browser API (Firefox) o chrome API
const api = isFirefox ? browser : chrome;
// Al instalar
api.runtime.onInstalled.addListener((details) => {
    if (details.reason === 'install') {
        // Configuración inicial
        api.storage.local.set({
            settings: {
                language: 'es',
                autoSave: true,
                theme: 'light',
                defaultTemplate: 'basico',
                fontSize: '13',
                tabSize: '2',
                lineNumbers: true,
                wordWrap: true,
                autoComplete: true,
                usePyodide: true
            },
            recentFiles: []
        });
        // Abrir página de bienvenida
        api.tabs.create({
            url: api.runtime.getURL('editor/editor.html?welcome=true')
        });
    }
});
// Manejar descargas (Firefox maneja diferente)
api.downloads.onDeterminingFilename.addListener((downloadItem, suggest) => {
    // Personalizar nombres
    suggest({
        filename: downloadItem.filename
    });
});
// Sincronización con almacenamiento
api.storage.onChanged.addListener((changes, area) => {
    if (area === 'sync' || area === 'local') {
        console.log('Cambios en almacenamiento:', changes);
    }
});
// Comandos de teclado (Firefox soporta commands)
api.commands?.onCommand.addListener((command) => {
    if (command === 'open-editor') {
        api.tabs.create({
            url: api.runtime.getURL('editor/editor.html')
        });
    } else if (command === 'new-cv') {
        api.tabs.create({
            url: api.runtime.getURL('editor/editor.html?new=true')
        });
    }
});
// Manejar mensajes
api.runtime.onMessage.addListener((message, sender, sendResponse) => {
    if (message.type === 'GET_VERSION') {
        sendResponse({ 
            version: '1.0.0',
            browser: isFirefox ? 'firefox' : 'chrome'
        });
    }
    else if (message.type === 'GET_SETTINGS') {
        api.storage.local.get('settings').then(result => {
            sendResponse(result.settings);
        });
        return true; // Para respuesta asíncrona
    }
    else if (message.type === 'SAVE_FILE') {
        saveFile(message.data).then(result => {
            sendResponse(result);
        });
        return true;
    }
    else if (message.type === 'OPEN_OPTIONS') {
        api.runtime.openOptionsPage();
    }
});
async function saveFile(data) {
    try {
        const file = {
            id: data.id || 'file_' + Date.now(),
            name: data.name || 'untitled.yaml',
            content: data.content,
            date: Date.now()
        };
        await api.storage.local.set({ [file.id]: file });
        // Actualizar recientes
        const result = await api.storage.local.get('recentFiles');
        const recent = result.recentFiles || [];
        const existingIndex = recent.findIndex(f => f.id === file.id);
        if (existingIndex >= 0) {
            recent[existingIndex] = file;
        } else {
            recent.unshift(file);
            if (recent.length > 10) recent.pop();
        }
        await api.storage.local.set({ recentFiles: recent });
        return { success: true, file };
    } catch (error) {
        return { success: false, error: error.message };
    }
}
// Limpiar caché periódicamente (Firefox usa alarms)
api.alarms?.create('cleanCache', { periodInMinutes: 60 * 24 });
api.alarms?.onAlarm.addListener((alarm) => {
    if (alarm.name === 'cleanCache') {
        api.storage.local.get(null).then(items => {
            const now = Date.now();
            const oneWeek = 7 * 24 * 60 * 60 * 1000;
            Object.keys(items).forEach(key => {
                if (key.startsWith('temp_') && (now - items[key].timestamp) > oneWeek) {
                    api.storage.local.remove(key);
                }
            });
        });
    }
});
// Detectar si es Firefox Android
if (isFirefox && navigator.userAgent.includes('Android')) {
    // Ajustes para móvil
    document.documentElement.style.setProperty('--touch-target-size', '48px');
}
