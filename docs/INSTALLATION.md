# Guía de Instalación Detallada
Esta guía te ayudará a instalar y configurar el **Generador Automático de CV** en tu sistema operativo.
---
## 📋 Requisitos Previos Comunes
- **Conexión a internet** (solo para la instalación inicial).
- **Python 3.6 o superior**.
- **pip** (gestor de paquetes de Python).
- **Git** (opcional, para clonar el repositorio).
---
## 🐧 Instalación en Linux (Ubuntu/Debian)
### 1. Instalar dependencias del sistema
```bash
sudo apt update
sudo apt install -y python3 python3-pip python3-venv git curl wget
```
### 2. Instalar LaTeX (para compilar PDF)
```bash
# Instalación completa (recomendada)
sudo apt install -y texlive-full
# O instalación mínima (si tienes poco espacio)
sudo apt install -y texlive-base texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended
```
### 3. Clonar el repositorio
```bash
git clone https://github.com/donshuapps-cloud/cv-generator-monorepo.git
cd cv-generator-monorepo
```
### 4. Ejecutar el instalador
```bash
chmod +x scripts/install.sh
./scripts/install.sh
```
El instalador:
- Creará un entorno virtual de Python.
- Instalará `pyyaml`.
- Verificará que LaTeX esté instalado.
- Te guiará para crear tu primer CV.
### 5. Probar la instalación
```bash
cd packages/cli
./generar-cv.sh
```
---
## 🍎 Instalación en macOS
### 1. Instalar Homebrew (si no lo tienes)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
### 2. Instalar dependencias
```bash
brew install python git wget
```
### 3. Instalar LaTeX (MacTeX)
```bash
brew install --cask mactex
```
**Nota**: La instalación de MacTeX puede tomar varios minutos y ocupa ~4GB.
### 4. Clonar el repositorio
```bash
git clone https://github.com/donshuapps-cloud/cv-generator-monorepo.git
cd cv-generator-monorepo
```
### 5. Ejecutar el instalador
```bash
chmod +x scripts/install.sh
./scripts/install.sh
```
---
## 🪟 Instalación en Windows
### Opción 1: Usando WSL (Recomendado)
1. **Instalar WSL2**:
   ```powershell
   # Abre PowerShell como Administrador
   wsl --install
   ```
2. **Reinicia tu PC**.
3. **Instalar una distribución Linux** (ej. Ubuntu) desde Microsoft Store.
4. **Abrir Ubuntu** y seguir las instrucciones para Linux (arriba).
### Opción 2: Instalación nativa (sin WSL)
#### 2.1 Instalar Python
1. Descarga Python desde [python.org](https://www.python.org/downloads/).
2. Durante la instalación, **marca "Add Python to PATH"**.
3. Verifica la instalación:
   ```cmd
   python --version
   pip --version
   ```
#### 2.2 Instalar LaTeX (MiKTeX)
1. Descarga MiKTeX desde [miktex.org](https://miktex.org/download).
2. Ejecuta el instalador y elige la instalación completa.
3. Durante la instalación, permite que MiKTeX instale paquetes sobre la marcha.
#### 2.3 Instalar Git (opcional)
1. Descarga Git desde [git-scm.com](https://git-scm.com/download/win).
2. Instala con opciones por defecto.
#### 2.4 Obtener el generador
```cmd
# Con Git
git clone https://github.com/donshuapps-cloud/cv-generator-monorepo.git
cd cv-generator-monorepo
# O descarga el ZIP desde GitHub y extráelo
```
#### 2.5 Ejecutar el instalador
```cmd
cd scripts
install.bat
```
#### 2.6 Probar
```cmd
cd ..\packages\cli
generar-cv.bat
```
---
## 🌐 Instalación Web (Sin instalación local)
1. Abre tu navegador (Chrome, Firefox, Edge).
2. Ve a: [https://donshuapps-cloud.github.io/cv-generator](https://donshuapps-cloud.github.io/cv-generator)
3. Sigue las instrucciones en pantalla:
   - Edita `datos.yaml` en el editor integrado.
   - Sube tu foto (opcional).
   - Haz clic en "Generar CV".
   - Descarga el PDF.
---
## 🧩 Instalación de la Extensión de Chrome
1. Abre Chrome.
2. Ve a [Chrome Web Store](https://chrome.google.com/webstore) y busca "CV Generator Donshu".
3. Haz clic en "Añadir a Chrome".
4. Una vez instalada, haz clic en el ícono de la extensión en la barra de herramientas.
5. Sigue los pasos para generar tu CV sin necesidad de instalar nada más.
---
## ✅ Verificación de Instalación
Ejecuta este comando para verificar que todo está correcto:
```bash
python -c "import yaml; print('PyYAML OK')"
pdflatex --version
```
Si ves mensajes de éxito, ¡estás listo!
---
## 🐛 Solución de Problemas Comunes
### Error: "pdflatex not found"
- **Linux**: `sudo apt install texlive-latex-recommended`
- **macOS**: `brew install --cask mactex`
- **Windows**: Reinstala MiKTeX y asegúrate de que esté en el PATH.
### Error: "ModuleNotFoundError: No module named 'yaml'"
```bash
pip install pyyaml
```
### Error de permisos en Linux/macOS
```bash
chmod +x generar-cv.sh
```
### La foto no aparece en el PDF
- Asegúrate de que el archivo se llame exactamente `foto-perfil.jpg`.
- Debe estar en la misma carpeta que `generar-cv.sh`.
---
## 📚 Siguientes pasos
- [Cómo editar datos.yaml](EDITANDO_DATOS.md)
- [Ejemplos de CV](EJEMPLOS.md)
- [Preguntas frecuentes](FAQ.md)
---
¿Necesitas más ayuda? Abre un issue en [GitHub](https://github.com/donshuapps-cloud/cv-generator-monorepo/issues) o escríbenos a [donshu.apps@gmail.com](mailto:donshu.apps@gmail.com).
