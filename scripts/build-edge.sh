#!/bin/bash
# Script para construir la extensión para Microsoft Edge
echo "🔧 Construyendo extensión para Microsoft Edge..."
cd packages/edge-extension
# Crear directorio de distribución
mkdir -p ../../dist
# Limpiar archivos temporales
find . -name ".DS_Store" -delete
find . -name "*.log" -delete
# Crear capturas de pantalla para la tienda (si no existen)
if [ ! -d "screenshots" ]; then
    mkdir -p screenshots
    echo "⚠️  Crea capturas de pantalla en screenshots/ antes de publicar"
fi
# Empaquetar para Microsoft Store
echo "📦 Creando paquete para Microsoft Store..."
zip -r ../../dist/cv-generator-edge.zip . \
    -x "*.git*" \
    -x "*.idea*" \
    -x "*.vscode*" \
    -x "*.log" \
    -x "*.tmp" \
    -x "screenshots/placeholder.txt"
# Crear versión para sideloading (desarrolladores)
echo "📦 Creando versión para sideloading..."
cp ../../dist/cv-generator-edge.zip ../../dist/cv-generator-edge-sideload.zip
echo "✅ Extensión creada: dist/cv-generator-edge.zip"
echo "📏 Tamaño: $(du -h ../../dist/cv-generator-edge.zip | cut -f1)"
cd ../..
