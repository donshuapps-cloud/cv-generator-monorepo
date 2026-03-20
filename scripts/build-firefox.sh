#!/bin/bash
# Script para construir la extensión de Firefox
echo "🔧 Construyendo extensión para Firefox..."
cd packages/firefox-extension
# Crear directorio de distribución
mkdir -p ../../dist
# Limpiar archivos temporales
find . -name ".DS_Store" -delete
find . -name "*.log" -delete
# Empaquetar
echo "📦 Creando archivo XPI..."
zip -r ../../dist/cv-generator-firefox.xpi . \
    -x "*.git*" \
    -x "*.idea*" \
    -x "*.vscode*" \
    -x "*.log" \
    -x "*.tmp"
echo "✅ Extensión creada: dist/cv-generator-firefox.xpi"
echo "📏 Tamaño: $(du -h ../../dist/cv-generator-firefox.xpi | cut -f1)"
cd ../..
