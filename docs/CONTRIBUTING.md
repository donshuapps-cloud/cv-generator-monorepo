# Guía de Contribución
¡Gracias por tu interés en contribuir a **CV Generator**! Este documento te guiará en el proceso.
## 🧑‍💻 Código de Conducta
Este proyecto adopta un código de conducta para mantener un ambiente abierto y respetuoso. Al participar, se espera que mantengas este estándar.
## 🚀 Primeros pasos
1. **Fork el repositorio** desde GitHub
2. **Clona tu fork**:
   ```bash
   git clone https://github.com/tu-usuario/cv-generator-monorepo.git
   cd cv-generator-monorepo
   ```
3. **Crea una rama** para tu contribución:
   ```bash
   git checkout -b feature/nueva-caracteristica
   ```
## 📁 Estructura del proyecto
```
packages/
├── core/              # Núcleo común (clase LaTeX, etc.)
├── cli/               # Versión línea de comandos
├── web/               # Versión web
├── chrome-extension/  # Extensión Chrome
├── firefox-extension/ # Extensión Firefox
└── edge-extension/    # Extensión Edge
```
## 🔧 Desarrollo
### Para CLI
```bash
cd packages/cli
./generar-cv.sh
```
### Para extensiones
1. Carga la extensión en modo desarrollador
2. Los cambios se recargan automáticamente
## 📝 Guías de estilo
- **Python**: PEP 8
- **JavaScript**: Standard Style
- **HTML/CSS**: Estilo consistente con el proyecto
## 🧪 Pruebas
Ejecuta las pruebas antes de enviar un PR:
```bash
./scripts/test.sh
```
## 📤 Enviar cambios
1. **Commit tus cambios**:
   ```bash
   git add .
   git commit -m "Descripción clara del cambio"
   ```
2. **Push a tu fork**:
   ```bash
   git push origin feature/nueva-caracteristica
   ```
3. **Abre un Pull Request** en GitHub
## ✅ Checklist para PRs
- [ ] El código sigue los estándares del proyecto
- [ ] Se han añadido pruebas si es necesario
- [ ] La documentación está actualizada
- [ ] Los mensajes de commit son claros
## ❓ Preguntas
¿Dudas? Abre un issue o contacta a [donshu.apps@gmail.com](mailto:donshu.apps@gmail.com)
---
**¡Gracias por contribuir!** 🎉
