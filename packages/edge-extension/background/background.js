// Background service worker para Edge
const isEdge = navigator.userAgent.indexOf("Edg") > -1;
// Detectar características de Edge
const edgeFeatures = {
  collections: false,
  webSelect: false,
  drop: false
};
// Inicialización
chrome.runtime.onInstalled.addListener(async (details) => {
  console.log('CV Generator instalado en Edge', details.reason);
  // Detectar características de Edge
  await detectEdgeFeatures();
  if (details.reason === 'install') {
    // Configuración inicial
    await chrome.storage.local.set({
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
        useEdgeAI: false,
        useCollections: false
      },
      recentFiles: [],
      edgeFeatures: edgeFeatures,
      installDate: Date.now()
    });
    // Abrir página de bienvenida con características Edge
    chrome.tabs.create({
      url: chrome.runtime.getURL('edge-specific/edge-promo.html?welcome=true')
    });
  } else if (details.reason === 'update') {
    // Mostrar novedades
    chrome.tabs.create({
      url: chrome.runtime.getURL('edge-specific/edge-promo.html?updated=true')
    });
  }
});
// Detectar características específicas de Edge
async function detectEdgeFeatures() {
  try {
    // Verificar si Edge Collections está disponible
    edgeFeatures.collections = 'collections' in chrome;
    // Verificar Web Select
    edgeFeatures.webSelect = 'webSelect' in chrome;
    // Verificar Edge Drop
    edgeFeatures.drop = 'drop' in chrome;
    console.log('Edge features detectadas:', edgeFeatures);
  } catch (error) {
    console.log('Error detectando features Edge:', error);
  }
}
// Integración con Edge Collections
async function addToCollection(data) {
  if (!edgeFeatures.collections) {
    return { success: false, error: 'Collections no disponible' };
  }
  try {
    // Aquí iría la API de Collections de Edge
    // Por ahora es una simulación
    return { success: true, message: 'Añadido a Collections' };
  } catch (error) {
    return { success: false, error: error.message };
  }
}
// Integración con Edge Drop (para compartir entre dispositivos)
async function saveToDrop(fileData) {
  if (!edgeFeatures.drop) {
    return { success: false, error: 'Drop no disponible' };
  }
  try {
    // Simulación de Edge Drop
    console.log('Guardando en Edge Drop:', fileData.name);
    return { success: true, message: 'Guardado en Drop' };
  } catch (error) {
    return { success: false, error: error.message };
  }
}
// Manejar mensajes
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  switch(message.type) {
    case 'GET_EDGE_FEATURES':
      sendResponse(edgeFeatures);
      break;
    case 'ADD_TO_COLLECTIONS':
      addToCollection(message.data).then(sendResponse);
      return true;
    case 'SAVE_TO_DROP':
      saveToDrop(message.data).then(sendResponse);
      return true;
    case 'GET_VERSION':
      sendResponse({ 
        version: '1.0.0',
        browser: 'edge',
        edgeFeatures: edgeFeatures
      });
      break;
    case 'SYNC_WITH_MICROSOFT':
      syncWithMicrosoftAccount(message.data).then(sendResponse);
      return true;
  }
});
// Sincronización con cuenta Microsoft (opcional)
async function syncWithMicrosoftAccount(data) {
  // Aquí iría la integración con OneDrive/Microsoft Graph
  return { success: true, message: 'Sincronizado con Microsoft' };
}
// Manejar actualizaciones desde Microsoft Store
chrome.runtime.onUpdateAvailable.addListener((details) => {
  console.log('Actualización disponible desde Microsoft Store:', details.version);
  chrome.notifications.create({
    type: 'basic',
    iconUrl: 'icons/icon128.png',
    title: 'Actualización disponible',
    message: `Versión ${details.version} lista para instalar desde Microsoft Store`,
    buttons: [{ title: 'Actualizar ahora' }]
  });
});
chrome.notifications.onButtonClicked.addListener((notificationId, buttonIndex) => {
  if (buttonIndex === 0) {
    chrome.tabs.create({
      url: 'https://microsoftedge.microsoft.com/addons/detail/cv-generator-profesional/'
    });
  }
});
// Limpiar caché periódicamente
chrome.alarms.create('cleanCache', { periodInMinutes: 60 * 24 });
chrome.alarms.onAlarm.addListener((alarm) => {
  if (alarm.name === 'cleanCache') {
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
// Optimizaciones para Edge
if (isEdge) {
  // Edge maneja mejor los service workers
  self.addEventListener('install', (event) => {
    console.log('Service worker instalado en Edge');
  });
  self.addEventListener('activate', (event) => {
    console.log('Service worker activado en Edge');
  });
}
