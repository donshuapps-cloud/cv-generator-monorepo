#!/bin/bash
# Script para generar capturas de pantalla para las tiendas
# Requiere: chromium, imagemagick
echo "📸 Generando capturas de pantalla para las tiendas..."
# Crear directorios
mkdir -p screenshots/chrome
mkdir -p screenshots/firefox
mkdir -p screenshots/edge
mkdir -p screenshots/promo
# Captura 1: Editor principal
echo "Capturando editor principal..."
chromium --headless --disable-gpu --screenshot=screenshots/editor.png \
    --window-size=1280,800 \
    --virtual-time-budget=5000 \
    "https://localhost:3000/editor.html?demo=true" 2>/dev/null || \
    echo "⚠️  No se pudo capturar automáticamente. Captura manual requerida."
# Generar capturas para cada tienda con overlay
for store in chrome firefox edge; do
    echo "Procesando para $store..."
    # Copiar captura base
    cp screenshots/editor.png "screenshots/$store/1-editor.png"
    # Añadir badge del navegador
    convert "screenshots/$store/1-editor.png" \
        -font Arial -pointsize 40 -fill white -stroke black \
        -draw "rectangle 20,20 220,100" \
        -draw "text 30,70 '$store'" \
        "screenshots/$store/1-editor-with-badge.png"
done
echo "✅ Capturas listas en screenshots/"
echo ""
echo "📋 Instrucciones para capturas manuales:"
echo "1. Abrir el editor en modo desarrollo"
echo "2. Capturar pantalla completa (1280x800 mínimo)"
echo "3. Guardar en screenshots/[navegador]/ con nombres:"
echo "   - 1-editor.png (editor principal)"
echo "   - 2-preview.png (vista previa)"
echo "   - 3-pdf.png (PDF generado)"
echo "   - 4-templates.png (selección plantillas)"
echo "   - 5-mobile.png (vista móvil - opcional)"
