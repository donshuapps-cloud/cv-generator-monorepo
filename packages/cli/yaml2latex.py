#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para convertir datos.yaml a LaTeX para CV
Versión: 10.0 - CORREGIDO (incluye foto correctamente)
"""
import yaml
import sys
import os
from datetime import datetime
def cargar_yaml(archivo_yaml):
    """Carga el archivo YAML y retorna los datos"""
    try:
        with open(archivo_yaml, 'r', encoding='utf-8') as f:
            contenido = f.read()
            lineas = []
            for linea in contenido.split('\n'):
                if not linea.strip().startswith('#'):
                    lineas.append(linea)
            contenido_limpio = '\n'.join(lineas)
            return yaml.safe_load(contenido_limpio)
    except Exception as e:
        print(f"❌ Error al cargar YAML: {e}")
        sys.exit(1)
def escape_latex(texto):
    """Escapa caracteres especiales de LaTeX"""
    if not texto:
        return ""
    texto = str(texto)
    replacements = {
        '&': r'\&',
        '%': r'\%',
        '$': r'\$',
        '#': r'\#',
        '_': r'\_',
        '{': r'\{',
        '}': r'\}',
        '~': r'\textasciitilde{}',
        '^': r'\textasciicircum{}',
        '\\': r'\textbackslash{}',
    }
    for char, escaped in replacements.items():
        texto = texto.replace(char, escaped)
    return texto
def limpiar_telefono(telefono):
    """Limpia el teléfono de caracteres extraños"""
    if not telefono:
        return ""
    telefono = str(telefono)
    telefono = telefono.replace('\\textbackslash{}', '').replace('\\', '')
    telefono = telefono.replace('{', '').replace('}', '')
    return telefono.strip()
def formatear_habilidades(habilidades):
    """Formato para habilidades"""
    if not habilidades:
        return ""
    lineas = []
    for i, h in enumerate(habilidades):
        if not isinstance(h, dict):
            continue
        nombre_original = h.get('nombre', '')
        if not nombre_original:
            continue
        nombre_seguro = escape_latex(nombre_original)
        try:
            valor = int(float(h.get('valor', 3)))
            valor = max(0, min(5, valor))
        except:
            valor = 3
        if i < len(habilidades) - 1:
            lineas.append(f"    {nombre_seguro}/{valor},")
        else:
            lineas.append(f"    {nombre_seguro}/{valor}")
    return "\n".join(lineas)
def formatear_lista(items):
    """Formato para makeList"""
    if not items:
        return ""
    lineas = []
    for item in items:
        if item and str(item).strip():
            lineas.append(f"    {escape_latex(str(item).strip())};%")
    return "\n".join(lineas)
def generar_cv_completo(datos):
    """Genera CV completo con todos los campos"""
    contenido = []
    persona = datos.get('persona', {})
    contenido.append("%" + "="*80)
    contenido.append("% CURRÍCULUM VITAE - GENERADO AUTOMÁTICAMENTE")
    contenido.append("% Generado el: " + datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    contenido.append("%" + "="*80)
    contenido.append("")
    contenido.append("\\documentclass[a4paper]{twentysecondcv-espanol}")
    contenido.append("")
    contenido.append("\\usepackage[utf8]{inputenc}")
    contenido.append("\\usepackage[spanish]{babel}")
    contenido.append("\\usepackage{anyfontsize}")
    contenido.append("")
    # NOMBRE Y PUESTO
    contenido.append(f"\\cvnombre{{{escape_latex(persona.get('nombre', ''))}}}")
    contenido.append(f"\\cvpuesto{{{escape_latex(persona.get('puesto', ''))}}}")
    # CÉDULA
    cedula = persona.get('cedula', '')
    if cedula and str(cedula).strip():
        contenido.append(f"\\cvcedula{{{escape_latex(str(cedula).strip())}}}")
    else:
        contenido.append("\\cvcedula{}")
    # NACIONALIDAD
    nacionalidad = persona.get('nacionalidad', '')
    if nacionalidad and str(nacionalidad).strip():
        contenido.append(f"\\cvnacionalidad{{{escape_latex(str(nacionalidad).strip())}}}")
    else:
        contenido.append("\\cvnacionalidad{}")
    # FECHA DE NACIMIENTO
    fecha_nac = persona.get('fecha_nacimiento', '')
    if fecha_nac and str(fecha_nac).strip():
        contenido.append(f"\\cvfecha{{{escape_latex(str(fecha_nac).strip())}}}")
    else:
        contenido.append("\\cvfecha{}")
    # DIRECCIÓN
    direccion = persona.get('direccion', '')
    if direccion:
        contenido.append(f"\\cvdireccion{{{escape_latex(direccion)}}}")
    else:
        contenido.append("\\cvdireccion{}")
    # TELÉFONO
    telefono = limpiar_telefono(persona.get('telefono', ''))
    if telefono:
        contenido.append(f"\\cvtelefono{{{telefono}}}")
    else:
        contenido.append("\\cvtelefono{}")
    # EMAIL
    email = persona.get('email', '')
    if email:
        contenido.append(f"\\cvemail{{{escape_latex(email)}}}")
    else:
        contenido.append("\\cvemail{}")
    # SITIO WEB
    sitio = persona.get('sitio_web', '')
    if sitio and str(sitio).strip():
        contenido.append(f"\\cvsitio{{{escape_latex(str(sitio).strip())}}}")
    else:
        contenido.append("\\cvsitio{}")
    # GITHUB
    github = persona.get('github', '')
    if github and str(github).strip():
        contenido.append(f"\\cvgithub{{{escape_latex(str(github).strip())}}}")
    else:
        contenido.append("\\cvgithub{}")
    # LINKEDIN
    linkedin = persona.get('linkedin', '')
    if linkedin and str(linkedin).strip():
        contenido.append(f"\\cvlinkedin{{{escape_latex(str(linkedin).strip())}}}")
    else:
        contenido.append("\\cvlinkedin{}")
    # ============================================================
    # FOTO - CORREGIDO: ahora siempre incluye el comando
    # ============================================================
    foto = persona.get('foto', '')
    if foto and str(foto).strip():
        # Solo el nombre del archivo, la clase añade la ruta datos/
        contenido.append(f"\\fotoperfil{{{foto.strip()}}}")
        print(f"📸 Foto configurada: {foto.strip()}")
    else:
        contenido.append("% \\fotoperfil{}  % No hay foto configurada")
        print("⚠️  No se encontró campo 'foto' en el YAML")
    contenido.append("")
    contenido.append("\\begin{document}")
    contenido.append("")
    # PERFIL
    perfil = datos.get('perfil', '')
    if perfil:
        contenido.append(f"\\perfil{{Perfil Profesional}}{{{escape_latex(perfil.strip())}}}")
        contenido.append("")
    # SOBRE MÍ
    sobre_mi = datos.get('sobre_mi', '')
    if sobre_mi:
        contenido.append(f"\\sobremi{{Sobre Mí}}{{{escape_latex(sobre_mi.strip())}}}")
        contenido.append("")
    # INTERESES
    intereses = datos.get('intereses', [])
    if intereses:
        intereses_proc = [escape_latex(str(i).strip()) for i in intereses if i]
        if intereses_proc:
            contenido.append(f"\\intereses{{Intereses}}{{{' • '.join(intereses_proc)}}}")
            contenido.append("")
    # HABILIDADES
    habilidades = datos.get('habilidades', [])
    if habilidades:
        habilidades_str = formatear_habilidades(habilidades)
        if habilidades_str:
            contenido.append("\\habilidades{%")
            contenido.append(habilidades_str)
            contenido.append("}")
            contenido.append("")
    contenido.append("\\crearperfil")
    contenido.append("")
    # EXPERIENCIA
    experiencia = datos.get('experiencia', [])
    if experiencia:
        contenido.append("\\section{Experiencia Laboral}")
        contenido.append("\\begin{veinte}")
        contenido.append("")
        for exp in experiencia:
            if not isinstance(exp, dict):
                continue
            fecha_ini = exp.get('fecha_inicio', '')
            fecha_fin = exp.get('fecha_fin', '')
            puesto = escape_latex(exp.get('puesto', ''))
            lugar = escape_latex(exp.get('lugar', ''))
            color_ini = exp.get('color_inicio', 'mainblue')
            color_fin = exp.get('color_fin', 'white')
            desc = exp.get('descripcion', [])
            contenido.append(f"    \\veinteitemtiempo{{{color_ini}}}{{{color_fin}}}{{{fecha_ini}}}{{{fecha_fin}}}{{{puesto}}}{{{lugar}}}{{%")
            if desc:
                contenido.append("    \\makeList{%")
                contenido.append(formatear_lista(desc))
                contenido.append("    }")
            else:
                contenido.append("    \\makeList{}")
            contenido.append("    }")
            contenido.append("    ")
        contenido.append("\\end{veinte}")
        contenido.append("")
    # EDUCACIÓN
    educacion = datos.get('educacion', [])
    if educacion:
        contenido.append("\\section{Educación}")
        contenido.append("\\begin{veinte}")
        contenido.append("")
        for edu in educacion:
            if not isinstance(edu, dict):
                continue
            fecha_ini = edu.get('fecha_inicio', '')
            fecha_fin = edu.get('fecha_fin', '')
            titulo = escape_latex(edu.get('titulo', ''))
            institucion = escape_latex(edu.get('institucion', ''))
            descripcion = escape_latex(edu.get('descripcion', ''))
            contenido.append(f"    \\veinteitemtiempo{{mainblue}}{{mainblue}}{{{fecha_ini}}}{{{fecha_fin}}}{{{titulo}}}{{{institucion}}}{{{descripcion}}}")
            contenido.append("    ")
        contenido.append("\\end{veinte}")
        contenido.append("")
    # REFERENCIAS
    referencias = datos.get('referencias', [])
    if referencias:
        contenido.append("\\section{Referencias Personales}")
        contenido.append("\\begin{veinte}")
        contenido.append("")
        for ref in referencias:
            if not isinstance(ref, dict):
                continue
            nombre = escape_latex(ref.get('nombre', ''))
            relacion = escape_latex(ref.get('relacion', ''))
            telefono = limpiar_telefono(ref.get('telefono', ''))
            comentario = escape_latex(ref.get('comentario', ''))
            contenido.append(f"    \\veinteitem{{}}{{{nombre}}}{{{relacion}}}{{Tel: {telefono} - \"{comentario}\"}}")
            contenido.append("    ")
        contenido.append("\\end{veinte}")
        contenido.append("")
    # INFORMACIÓN ADICIONAL
    info_adicional = datos.get('informacion_adicional', [])
    if info_adicional:
        contenido.append("\\section{Información Adicional}")
        contenido.append("\\begin{itemize}")
        contenido.append("")
        for info in info_adicional:
            if info and str(info).strip():
                contenido.append(f"    \\item {escape_latex(str(info).strip())}")
                contenido.append("    ")
        contenido.append("\\end{itemize}")
    contenido.append("")
    contenido.append("\\end{document}")
    return "\n".join(contenido)
def main():
    print("="*70)
    print("🔄 CONVERTIDOR YAML → LATEX - VERSIÓN 10.0")
    print("   CORREGIDO: Incluye foto correctamente")
    print("="*70)
    print()
    archivo_yaml = sys.argv[1] if len(sys.argv) > 1 else "datos/datos.yaml"
    if not os.path.exists(archivo_yaml):
        print(f"❌ No se encuentra: {archivo_yaml}")
        sys.exit(1)
    print(f"📁 Leyendo: {archivo_yaml}")
    datos = cargar_yaml(archivo_yaml)
    # Mostrar información de la foto
    persona = datos.get('persona', {})
    foto = persona.get('foto', '')
    if foto:
        print(f"📸 Foto encontrada: {foto}")
    else:
        print("⚠️  No se encontró campo 'foto' en persona")
    print("\n📄 Generando CV...")
    contenido = generar_cv_completo(datos)
    with open("cv-completo.tex", "w", encoding='utf-8') as f:
        f.write(contenido)
    print("✅ cv-completo.tex generado")
    print()
    print("="*70)
    print("✅ PROCESO COMPLETADO")
    print("="*70)
    print()
    print("📋 Verificar comandos generados:")
    print("   grep 'fotoperfil' cv-completo.tex")
if __name__ == "__main__":
    main()
