# 🎹 CV Generator Professional
## Generador Automático de Currículums Vitae

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.6+](https://img.shields.io/badge/python-3.6+-blue.svg)](https://www.python.org/downloads/)
[![Platforms](https://img.shields.io/badge/platform-linux%20%7C%20macos%20%7C%20windows%20%7C%20web%20%7C%20extensions-lightgrey)](https://github.com/donshuapps-cloud/cv-generator-monorepo)
[![GitHub release](https://img.shields.io/github/v/release/donshuapps-cloud/cv-generator-monorepo)](https://github.com/donshuapps-cloud/cv-generator-monorepo/releases)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

**Crea CV profesionales en PDF desde un simple archivo YAML**  
*Inspirado en la vida y obra de la gran pianista Teresa Carreño*
</div>

---

## 🎭 ¿Qué es CV Generator?
CV Generator es una herramienta multiplataforma que convierte un archivo YAML con tus datos personales en un **currículum vitae profesional en formato PDF**. No necesitas saber LaTeX, diseñar plantillas o pagar por servicios costosos.

**¿Por qué "inspirado en Teresa Carreño"?**
Porque la gran pianista venezolana necesitaba un CV cuando quiso postularse como "pianista de ensayos" en el Teatro Principal de Caracas. Este proyecto nació de ese ejercicio de imaginación histórica: si Teresa viviera hoy, usaría esta herramienta para organizar sus 400 conciertos de memoria, sus giras internacionales y sus referencias de Lincoln, Gottschalk y Liszt en un solo archivo YAML.
---

## ✨ Características
### 📝 **Simple y poderoso**
- Edita un solo archivo `datos.yaml` con tu información
- Soporte completo para: datos personales, perfil, habilidades, experiencia, educación, referencias
- Validación en tiempo real y corrección automática de errores comunes
### 🤖 **Automatización total**
- Genera automáticamente el código LaTeX
- Compila a PDF con un solo comando
- Logs detallados de todo el proceso
### 🎨 **Diseño profesional**
- Plantilla `twentysecondcv` adaptada al español
- Diseño limpio, moderno y orientado al mercado laboral
- Soporte para foto de perfil
- Barras de habilidades visuales
### 🌐 **Multiplataforma**
- **CLI** para Linux, macOS y Windows (WSL/nativo)
- **Versión Web** para uso instantáneo sin instalación
- **Extensión Chrome** con integración nativa
- **Extensión Firefox** con soporte para Android
- **Extensión Edge** con Collections y Edge Drop
### 🔒 **Privacidad y seguridad**
- 100% offline (opción web con backend opcional)
- Tus datos nunca salen de tu dispositivo
- Código abierto y verificable
- Sin registro, sin cuentas, sin seguimiento
---
## 🚀 Instalación rápida
### CLI - Linux / macOS / WSL
```bash
# Clonar el repositorio
git clone https://github.com/donshuapps-cloud/cv-generator-monorepo.git
cd cv-generator-monorepo
# Ejecutar el instalador
./scripts/install.sh
# Activar el entorno
source use-cv-generator.sh
# Generar tu CV
cd packages/cli
./generar-cv.sh
```
### CLI - Windows (nativo)
```cmd
git clone https://github.com/donshuapps-cloud/cv-generator-monorepo.git
cd cv-generator-monorepo
scripts\install.bat
cd packages\cli
generar-cv.bat
```
### Versión Web (sin instalación)
👉 [https://donshuapps-cloud.github.io/cv-generator-monorepo/](https://donshuapps-cloud.github.io/cv-generator-monorepo/)
### Extensiones de navegador
| Navegador | Estado | Enlace |
|-----------|--------|--------|
| 🟢 **Chrome** | Próximamente | [Chrome Web Store](https://chrome.google.com/webstore) |
| 🦊 **Firefox** | Próximamente | [Firefox Add-ons](https://addons.mozilla.org) |
| 🌐 **Edge** | Próximamente | [Microsoft Edge Add-ons](https://microsoftedge.microsoft.com/addons) |
---
## 📋 Estructura del proyecto
```
cv-generator-monorepo/
├── packages/                    # Código fuente por plataforma
│   ├── core/                    # Núcleo común (clase LaTeX, datos)
│   ├── cli/                     # Versión línea de comandos
│   │   ├── generar-cv.sh        # Script Linux/macOS
│   │   ├── generar-cv.bat       # Script Windows
│   │   └── yaml2latex.py        # Convertidor YAML → LaTeX
│   ├── web/                     # Versión web (HTML/JS)
│   ├── chrome-extension/        # Extensión para Chrome
│   ├── firefox-extension/       # Extensión para Firefox
│   └── edge-extension/          # Extensión para Edge
├── docs/                        # Documentación completa
│   ├── INSTALLATION.md          # Guía de instalación detallada
│   ├── CHANGELOG.md             # Historial de cambios
│   ├── CONTRIBUTING.md          # Guía para contribuir
│   ├── privacy-policy.md        # Política de privacidad
│   └── EDITANDO_DATOS.md        # Cómo editar el YAML
├── scripts/                     # Scripts de utilidad
│   ├── install.sh               # Instalador Linux/macOS
│   ├── install.bat              # Instalador Windows
│   ├── build-all.sh             # Construir todas las versiones
│   └── generate-screenshots.sh  # Generar capturas
├── store-listings/              # Listings para tiendas
│   ├── chrome-web-store/
│   ├── firefox-addons/
│   └── edge-addons/
├── screenshots/                 # Capturas de pantalla
├── .github/workflows/           # GitHub Actions
│   └── release.yml              # Automatización de releases
├── LICENSE                      # Licencia MIT
└── README.md                    # Este archivo
```

---
## 📝 Ejemplo de `datos.yaml`
```yaml
persona:
  nombre: "Tu Nombre Completo"
  puesto: "Tu Puesto Profesional"
  cedula: "V-12345678"
  nacionalidad: "venezolana"
  fecha_nacimiento: "01/01/1990"
  direccion: "Tu dirección"
  telefono: "+58 412 1234567"
  email: "tu@email.com"
perfil: |
  Persona responsable, puntual y con gran disposición para el trabajo.
habilidades:
- nombre: "Responsabilidad"
  valor: 5
- nombre: "Trabajo en equipo"
  valor: 5
- nombre: "Comunicación"
  valor: 4
experiencia:
- fecha_inicio: "Ene/2023"
  fecha_fin: "actualidad"
  puesto: "Tu puesto actual"
  lugar: "Nombre de la empresa"
  descripcion:
  - "Logro o responsabilidad principal"
  - "Otro logro importante"
educacion:
- fecha_inicio: "Sep/2015"
  fecha_fin: "Jul/2020"
  titulo: "Título obtenido"
  institucion: "Nombre de la institución"
```
### 📚 Ejemplo completo
Ver el archivo [`packages/core/datos/ejemplo-completo.yaml`](packages/core/datos/ejemplo-completo.yaml) con la recreación histórica de Teresa Carreño postulándose como pianista de ensayos.
---
## 🛠️ Requisitos del sistema
### CLI
- **Python 3.6 o superior**
- **pip** (gestor de paquetes de Python)
- **LaTeX** (para compilar a PDF):
  - Linux: `sudo apt install texlive-latex-recommended texlive-latex-extra`
  - macOS: `brew install --cask mactex`
  - Windows: [MiKTeX](https://miktex.org/)
### Extensiones
- **Chrome/Edge**: versión 88 o superior
- **Firefox**: versión 78 o superior (Android: 113+)
### Versión Web
- Cualquier navegador moderno con JavaScript habilitado
- Opcional: servidor Python para compilación real (Flask)
---
## 📖 Documentación
| Documento | Descripción |
|-----------|-------------|
| [INSTALLATION.md](docs/INSTALLATION.md) | Guía detallada de instalación por sistema operativo |
| [EDITANDO_DATOS.md](docs/EDITANDO_DATOS.md) | Cómo personalizar tu CV |
| [CHANGELOG.md](docs/CHANGELOG.md) | Historial completo de versiones |
| [CONTRIBUTING.md](docs/CONTRIBUTING.md) | Cómo contribuir al proyecto |
| [privacy-policy.md](docs/privacy-policy.md) | Política de privacidad |
---
## 🧪 Ejemplos reales
### Teresa Carreño - Pianista de Ensayos
Basado en la vida de la gran pianista venezolana (1853-1917), este ejemplo muestra cómo una profesional con décadas de experiencia internacional puede presentar:
- Giras por Nueva York, Londres, París, Berlín, San Petersburgo
- Referencias de Abraham Lincoln, Louis Moreau Gottschalk, Anton Rubinstein
- Repertorio completo de 400 obras memorizadas
- Habilidades como: lectura a primera vista, improvisación, composición
*Ver el archivo completo en [`packages/core/datos/ejemplo-completo.yaml`](packages/core/datos/ejemplo-completo.yaml)*
---
## 🤝 Contribuciones
Las contribuciones son bienvenidas y apreciadas. Por favor, lee la [guía de contribución](docs/CONTRIBUTING.md) antes de enviar un Pull Request.
### Áreas donde puedes ayudar
- Traducciones a otros idiomas
- Mejoras en la plantilla LaTeX
- Optimizaciones para extensiones de navegador
- Corrección de bugs
- Documentación
- Ejemplos de CV para diferentes profesiones
---
## 📄 Licencia
Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.
```
MIT License
Copyright (c) 2026 Donshu (donshu.apps@gmail.com)
Se concede permiso, de forma gratuita, a cualquier persona que obtenga una copia
de este software y los archivos de documentación asociados...
```
---
## 📞 Contacto
- **Alias:** Donshu
- **Email:** [donshu.apps@gmail.com](mailto:donshu.apps@gmail.com)
- **GitHub:** [@donshuapps-cloud](https://github.com/donshuapps-cloud)
- **Repositorio:** [cv-generator-monorepo](https://github.com/donshuapps-cloud/cv-generator-monorepo)
- **Web:** [https://donshuapps-cloud.github.io/cv-generator-monorepo/](https://donshuapps-cloud.github.io/cv-generator-monorepo/)
---
## ⭐ Agradecimientos
- A **Teresa Carreño**, por inspirarnos con su talento, carácter y amor por Venezuela
- A **Gottschalk**, por enseñar que el piano puede sonar como orquesta
- A **Abraham Lincoln**, por ser un público atento aunque estuviera pensando en la guerra
- A **todos los pianistas, auxiliares de servicios, desarrolladores y soñadores** que buscan su lugar en el mundo
---
## 🙏 ¿Te ha sido útil?
Si este proyecto te ha ayudado a conseguir un empleo o simplemente te ha sacado una sonrisa:
- ⭐ Dale una estrella en GitHub
- 🐛 Reporta bugs o sugiere mejoras
- 📢 Compártelo con quien pueda necesitarlo
- 💌 Escríbenos tu historia
---
<div align="center">
**"El piano no se toca, se lucha contra él"**  
*— Teresa Carreño*
**¡Mucho éxito en tu búsqueda laboral!** 🌟
</div>
