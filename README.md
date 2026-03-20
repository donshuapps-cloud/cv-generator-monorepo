# 📄 Generador Automático de Curriculum Vitae (CV)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.6+](https://img.shields.io/badge/python-3.6+-blue.svg)](https://www.python.org/downloads/)
[![LaTeX](https://img.shields.io/badge/LaTeX-Required-green)](https://www.latex-project.org/)
[![Multi-Platform](https://img.shields.io/badge/platform-windows%20%7C%20macos%20%7C%20linux%20%7C%20web-lightgrey)](https://github.com/donshuapps-cloud/cv-generator-monorepo)
> **Crea un CV profesional en PDF a partir de un simple archivo YAML.**  
> Diseñado para perfiles técnicos y no técnicos, con énfasis en facilidad de uso y automatización.
---
## ✨ Características
- 📝 **Configuración simple**: Edita `datos.yaml` con tu información.
- 🤖 **Automatización total**: Genera el código LaTeX y compila a PDF con un solo comando.
- 🖼️ **Soporte para foto**: Incluye tu foto de perfil automáticamente.
- 🎨 **Diseño profesional**: Plantilla `twentysecondcv` adaptada al español y mercado venezolano.
- 🔧 **Correcciones automáticas**: Limpia caracteres especiales, formatea teléfonos y más.
- 🌐 **Multiplataforma**: Disponible para Linux, macOS, Windows y como extensión de Chrome.
- 📦 **Logs detallados**: Para depuración fácil.
---
## 📁 Estructura del Monorepo
```
cv-generator-monorepo/
├── packages/
│   ├── core/              # Núcleo común (scripts, clase LaTeX)
│   ├── cli/                # Versión para terminal (Linux/macOS/WSL)
│   ├── windows/            # Versión para Windows (batch)
│   ├── web/                # Versión web (HTML/JS)
│   └── chrome-extension/   # Extensión de Chrome
├── docs/                   # Documentación
├── scripts/                # Scripts de construcción y prueba
└── dist/                   # Archivos para distribución
```
---
## 🚀 Instalación Rápida
### Linux / macOS / WSL
```bash
# Clonar el repositorio
git clone https://github.com/donshuapps-cloud/cv-generator-monorepo.git
cd cv-generator-monorepo
# Ejecutar el instalador
./scripts/install.sh
```
### Windows
1. Descarga el instalador desde [Releases](https://github.com/donshuapps-cloud/cv-generator-monorepo/releases).
2. Ejecuta `install.bat` como administrador.
3. Sigue las instrucciones en pantalla.
### Web (sin instalación)
Visita: [https://donshuapps-cloud.github.io/cv-generator](https://donshuapps-cloud.github.io/cv-generator)
### Extensión de Chrome
1. Ve a [Chrome Web Store](https://chrome.google.com/webstore) (próximamente).
2. Busca "CV Generator Donshu".
3. Haz clic en "Añadir a Chrome".
---
## ⚙️ Uso Básico
1. **Edita tus datos**: Modifica `packages/core/datos/datos.yaml` con tu información.
2. **Añade tu foto**: Coloca `foto-perfil.jpg` en la misma carpeta (opcional).
3. **Ejecuta el generador**:
   ```bash
   cd packages/cli
   ./generar-cv.sh
   ```
4. **Encuentra tu CV**: Se generará `cv-completo.pdf` en la carpeta actual.
---
## 📚 Documentación
- [Guía de instalación detallada](docs/INSTALLATION.md)
- [Cómo editar datos.yaml](docs/EDITANDO_DATOS.md)
- [Solución de problemas](docs/TROUBLESHOOTING.md)
- [Contribuir al proyecto](docs/CONTRIBUTING.md)
- [Historial de cambios](docs/CHANGELOG.md)
---
## 🧪 Ejemplo de `datos.yaml`
```yaml
persona:
  nombre: "YDIANA VIDAN MENA MENA"
  puesto: "Auxiliar de Servicios / Lavandería"
  cedula: "V-20045507"
  nacionalidad: "venezolana"
  telefono: "+58 4245507425"
  email: "ydianavidanmenamena@gmail.com"
```
---
## 🛠️ Requisitos del Sistema
- **Python 3.6+** y **pip**
- **LaTeX** (para compilar a PDF): TeX Live (Linux), MacTeX (macOS), MikTeX (Windows)
- **Conexión a internet** (solo para primera instalación de dependencias)
---
## 🤝 Contribuciones
¡Las contribuciones son bienvenidas! Por favor, lee la [guía de contribución](docs/CONTRIBUTING.md) antes de enviar un pull request.
---
## 📄 Licencia
Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.
---
## 📞 Contacto
- **Alias:** Donshu  
- **Email:** [donshu.apps@gmail.com](mailto:donshu.apps@gmail.com)  
- **GitHub:** [@donshuapps-cloud](https://github.com/donshuapps-cloud)
---
**¡Mucho éxito en tu búsqueda laboral!** 🌟
