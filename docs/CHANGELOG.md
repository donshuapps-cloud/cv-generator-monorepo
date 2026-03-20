# Historial de Cambios
Todas las notas de versión de este proyecto están documentadas en este archivo.
Formato basado en [Keep a Changelog](https://keepachangelog.com/es/1.0.0/), y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
---
## [9.0.0] - 2026-03-19
### ✨ Añadido
- **Monorepo completo** con soporte para Linux, macOS, Windows, Web y Chrome Extension.
- Nuevos campos en `datos.yaml`: `cedula`, `nacionalidad`, `fecha_nacimiento`.
- Soporte para múltiples compilaciones LaTeX (3 pasadas) para referencias cruzadas.
- Script de instalación automática para Linux/macOS (`install.sh`).
- Instalador batch para Windows (`install.bat`).
- Versión web funcional con compilación en servidor (Python backend).
- Extensión de Chrome con generación local (usando Pyodide/WASM).
- GitHub Actions para pruebas automáticas y generación de releases.
### 🔧 Mejorado
- `generar-cv.sh`: Detección corregida de `pdflatex`, colores en terminal, manejo de errores.
- `yaml2latex.py`: Limpieza de caracteres especiales, formato de teléfonos, escape LaTeX.
- `twentysecondcv-espanol.cls`: Iconos estándar de FontAwesome, corrección de colores, mejor espaciado.
- Documentación completa en español e inglés (próximamente).
### 🐛 Corregido
- Problema con habilidades sin espacios (ej. "Limpiezayorden" → "Limpieza y orden").
- Caracteres especiales en teléfonos (`\textbackslash{}` eliminados).
- Error al compilar si no había foto de perfil.
- Advertencias de LaTeX por paquetes faltantes.
### ⚠️ Deprecado
- Soporte para Python < 3.6.
- Versiones anteriores del generador (anteriores a 8.0) no son compatibles con este monorepo.
---
## [8.1.0] - 2025-10-15
### Añadido
- Backup automático de `datos.yaml` antes de modificar.
- Logs detallados con timestamp.
### Corregido
- Detección de `pdflatex` en sistemas sin `which`.
- Error al abrir PDF automáticamente en macOS.
---
## [8.0.0] - 2025-08-20
### Añadido
- Primera versión estable del generador.
- Soporte para foto de perfil.
- Plantilla LaTeX en español.
### Cambiado
- Reestructuración completa del código.
---
## [7.0.0] - 2025-05-01
### Añadido
- Versión inicial del convertidor YAML a LaTeX.
- Soporte básico para experiencia, educación y referencias.
---
**Nota**: Para versiones anteriores a la 7.0, no se mantiene registro.
