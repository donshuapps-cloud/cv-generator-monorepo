// Service Worker para la extensión
chrome.runtime.onInstalled.addListener((details) => {
    if (details.reason === 'install') {
        // Primera instalación
        chrome.storage.local.set({
            settings: {
                language: 'es',
                autoSave: true,
                theme: 'light',
                defaultTemplate: 'basico'
            },
            recentFiles: []
        });
        // Abrir página de bienvenida
        chrome.tabs.create({
            url: chrome.runtime.getURL('editor/editor.html?welcome=true')
        });
    }
});
// Manejar descargas
chrome.downloads.onDeterminingFilename.addListener((downloadItem, suggest) => {
    // Personalizar nombres de archivo si es necesario
    suggest();
});
// Sincronización con almacenamiento en la nube (opcional)
chrome.storage.onChanged.addListener((changes, area) => {
    if (area === 'sync') {
        console.log('Cambios en sync:', changes);
    }
});
// Comandos de teclado globales
chrome.commands.onCommand.addListener((command) => {
    if (command === 'open-editor') {
        chrome.tabs.create({
            url: chrome.runtime.getURL('editor/editor.html')
        });
    } else if (command === 'new-cv') {
        chrome.tabs.create({
            url: chrome.runtime.getURL('editor/editor.html?new=true')
        });
    }
});
// Manejar mensajes de content scripts
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
    if (message.type === 'GET_VERSION') {
        sendResponse({ version: '1.0.0' });
    } else if (message.type === 'CAPTURE_PAGE_DATA') {
        // Capturar datos de LinkedIn o portales de empleo (futuro)
        sendResponse({ success: false, reason: 'Not implemented yet' });
    }
    return true;
});
// Actualización de la extensión
chrome.runtime.onUpdateAvailable.addListener((details) => {
    console.log('Actualización disponible:', details.version);
    // Preguntar al usuario si quiere actualizar ahora
    chrome.notifications.create({
        type: 'basic',
        iconUrl: 'icons/icon128.png',
        title: 'Actualización disponible',
        message: `Versión ${details.version} lista para instalar`,
        buttons: [{ title: 'Actualizar ahora' }]
    });
});
chrome.notifications.onButtonClicked.addListener((notificationId, buttonIndex) => {
    if (buttonIndex === 0) {
        chrome.runtime.reload();
    }
});
// Limpiar caché periódicamente
chrome.alarms.create('cleanCache', { periodInMinutes: 60 * 24 }); // Cada 24 horas
chrome.alarms.onAlarm.addListener((alarm) => {
    if (alarm.name === 'cleanCache') {
        // Limpiar archivos temporales antiguos
        chrome.storage.local.get(null, (items) => {
            const now = Date.now();
            const oneWeek = 7 * 24 * 60 * 60 * 1000;
            Object.keys(items).forEach(key => {
                if (key.startsWith('temp_') && (now - items[key].timestamp) > oneWeek) {
                    chrome.storage.local.remove(key);
                }
            });
        });
    }
});
