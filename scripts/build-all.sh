#!/bin/bash
echo "========================================="
echo "🏗️  Construyendo todas las extensiones"
echo "========================================="
echo
# Limpiar dist
rm -rf dist/*
mkdir -p dist
# Chrome
echo "📦 Chrome..."
cd packages/chrome-extension
zip -r ../../dist/cv-generator-chrome.zip . -x "*.git*" "*.DS_Store" "*.log"
cd ../..
echo "   ✅ chrome: dist/cv-generator-chrome.zip"
echo
# Firefox
echo "📦 Firefox..."
cd packages/firefox-extension
zip -r ../../dist/cv-generator-firefox.xpi . -x "*.git*" "*.DS_Store" "*.log"
cd ../..
echo "   ✅ firefox: dist/cv-generator-firefox.xpi"
echo
# Edge
echo "📦 Edge..."
cd packages/edge-extension
zip -r ../../dist/cv-generator-edge.zip . -x "*.git*" "*.DS_Store" "*.log"
cd ../..
echo "   ✅ edge: dist/cv-generator-edge.zip"
echo
echo "========================================="
echo "✅ Todas las extensiones construidas"
echo "📁 Directorio: dist/"
echo "========================================="
ls -lh dist/
