#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Backend para compilación de LaTeX a PDF
Ejecutar: python server.py
"""
from flask import Flask, request, send_file, jsonify
from flask_cors import CORS
import tempfile
import os
import subprocess
import uuid
app = Flask(__name__)
CORS(app)
@app.route('/compile', methods=['POST'])
def compile_latex():
    """Recibe código LaTeX y devuelve PDF"""
    try:
        data = request.get_json()
        latex_code = data.get('latex', '')
        if not latex_code:
            return jsonify({'error': 'No se recibió código LaTeX'}), 400
        # Crear directorio temporal
        temp_dir = tempfile.mkdtemp()
        tex_file = os.path.join(temp_dir, 'cv.tex')
        pdf_file = os.path.join(temp_dir, 'cv.pdf')
        # Guardar código LaTeX
        with open(tex_file, 'w', encoding='utf-8') as f:
            f.write(latex_code)
        # Compilar (3 pasadas para referencias)
        for i in range(3):
            result = subprocess.run(
                ['pdflatex', '-interaction=nonstopmode', '-output-directory', temp_dir, tex_file],
                capture_output=True,
                text=True
            )
            if result.returncode != 0:
                return jsonify({
                    'error': 'Error en compilación',
                    'log': result.stderr + result.stdout
                }), 500
        # Verificar que se generó PDF
        if not os.path.exists(pdf_file):
            return jsonify({'error': 'No se generó el PDF'}), 500
        # Enviar PDF
        return send_file(
            pdf_file,
            mimetype='application/pdf',
            as_attachment=True,
            download_name=f'cv-{uuid.uuid4().hex[:8]}.pdf'
        )
    except Exception as e:
        return jsonify({'error': str(e)}), 500
@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'ok'})
if __name__ == '__main__':
    print("="*60)
    print("Servidor de compilación LaTeX")
    print("Asegúrate de tener pdflatex instalado")
    print("="*60)
    app.run(host='0.0.0.0', port=5000, debug=True)
