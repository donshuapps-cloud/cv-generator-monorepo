#!/bin/bash
# Script de verificación para CV Generator
echo "========================================="
echo "   VERIFICACIÓN DE CV GENERATOR"
echo "========================================="
echo ""
cd ~/Development/LaTeX/cv-generator-monorepo/packages/cli
echo "📁 1. Verificando archivos necesarios:"
echo "   twentysecondcv-espanol.cls: $(test -f twentysecondcv-espanol.cls && echo "✅ OK" || echo "❌ FALTA")"
echo "   yaml2latex.py: $(test -f yaml2latex.py && echo "✅ OK" || echo "❌ FALTA")"
echo "   generar-cv.sh: $(test -f generar-cv.sh && echo "✅ OK" || echo "❌ FALTA")"
echo "   datos/datos.yaml: $(test -f datos/datos.yaml && echo "✅ OK" || echo "❌ FALTA")"
echo ""
echo "📸 2. Verificando foto:"
if [ -f "datos/fotoperfil.jpg" ]; then
    echo "   ✅ datos/fotoperfil.jpg existe ($(file -b datos/fotoperfil.jpg))"
else
    echo "   ⚠️  datos/fotoperfil.jpg NO EXISTE"
    echo "   Creando placeholder..."
    convert -size 200x200 xc:lightblue -gravity center -fill darkblue -pointsize 12 -annotate +0+0 "Teresa Carreño" datos/fotoperfil.jpg 2>/dev/null || \
    echo "   ⚠️  No se pudo crear. Coloca una foto manualmente."
fi
echo ""
echo "🔧 3. Verificando clase LaTeX:"
echo "   Versión: $(grep "Versión:" twentysecondcv-espanol.cls | head -1)"
echo "   Busca foto en datos/: $(grep -c "datos/" twentysecondcv-espanol.cls || echo "0")"
echo "   Usa parbox: $(grep -c "parbox" twentysecondcv-espanol.cls || echo "0")"
echo ""
echo "📄 4. Generando CV..."
rm -f cv-completo.* *.aux *.log *.out *.toc 2>/dev/null
./generar-cv.sh 2>&1 | tail -20
echo ""
echo "📊 5. Resultado:"
if [ -f "cv-completo.pdf" ]; then
    PAGES=$(pdfinfo cv-completo.pdf 2>/dev/null | grep Pages | awk '{print $2}')
    SIZE=$(du -h cv-completo.pdf | cut -f1)
    echo "   ✅ PDF generado: $SIZE, $PAGES páginas"
    echo "   📄 Ubicación: $(pwd)/cv-completo.pdf"
else
    echo "   ❌ ERROR: No se generó el PDF"
fi
echo ""
echo "========================================="
