const LatexGenerator = {
    escape(text) {
        if (!text) return '';
        const replacements = {
            '&': '\\&',
            '%': '\\%',
            '$': '\\$',
            '#': '\\#',
            '_': '\\_',
            '{': '\\{',
            '}': '\\}',
            '~': '\\textasciitilde{}',
            '^': '\\textasciicircum{}',
            '\\': '\\textbackslash{}'
        };
        return String(text).replace(/[&%$#_{}~^\\]/g, char => replacements[char]);
    },
    cleanPhone(phone) {
        if (!phone) return '';
        return String(phone).replace(/[\\{}]/g, '').trim();
    },
    generate(data) {
        const p = data.persona || {};
        const lines = [];
        lines.push('%' + '='.repeat(80));
        lines.push('% CURRÍCULUM VITAE - GENERADO DESDE WEB');
        lines.push('% Generado el: ' + new Date().toLocaleString());
        lines.push('%' + '='.repeat(80));
        lines.push('');
        lines.push('\\documentclass[a4paper]{twentysecondcv-espanol}');
        lines.push('');
        lines.push('\\usepackage[utf8]{inputenc}');
        lines.push('\\usepackage[spanish]{babel}');
        lines.push('');
        // Información personal
        lines.push(`\\cvnombre{${this.escape(p.nombre || '')}}`);
        lines.push(`\\cvpuesto{${this.escape(p.puesto || '')}}`);
        lines.push(`\\cvcedula{${this.escape(p.cedula || '')}}`);
        lines.push(`\\cvnacionalidad{${this.escape(p.nacionalidad || '')}}`);
        lines.push(`\\cvfecha{${this.escape(p.fecha_nacimiento || '')}}`);
        lines.push(`\\cvdireccion{${this.escape(p.direccion || '')}}`);
        lines.push(`\\cvtelefono{${this.cleanPhone(p.telefono || '')}}`);
        lines.push(`\\cvemail{${this.escape(p.email || '')}}`);
        lines.push(`\\cvsitio{${this.escape(p.sitio_web || '')}}`);
        lines.push(`\\cvgithub{${this.escape(p.github || '')}}`);
        lines.push(`\\cvlinkedin{${this.escape(p.linkedin || '')}}`);
        if (p.foto) {
            lines.push(`\\fotoperfil{${p.foto}}`);
        }
        lines.push('');
        lines.push('\\begin{document}');
        lines.push('');
        // Perfil
        if (data.perfil) {
            lines.push(`\\perfil{Perfil Profesional}{${this.escape(data.perfil)}}`);
            lines.push('');
        }
        // Sobre mí
        if (data.sobre_mi) {
            lines.push(`\\sobremi{Sobre Mí}{${this.escape(data.sobre_mi)}}`);
            lines.push('');
        }
        // Intereses
        if (data.intereses && data.intereses.length > 0) {
            const interesesStr = data.intereses.map(i => this.escape(i)).join(' • ');
            lines.push(`\\intereses{Intereses}{${interesesStr}}`);
            lines.push('');
        }
        // Habilidades
        if (data.habilidades && data.habilidades.length > 0) {
            lines.push('\\habilidades{%');
            data.habilidades.forEach((h, i) => {
                const nombre = this.escape(h.nombre || '');
                const valor = Math.min(5, Math.max(0, parseInt(h.valor) || 3));
                lines.push(`    ${nombre}/${valor}${i < data.habilidades.length - 1 ? ',' : ''}`);
            });
            lines.push('}');
            lines.push('');
        }
        lines.push('\\crearperfil');
        lines.push('');
        // Experiencia
        if (data.experiencia && data.experiencia.length > 0) {
            lines.push('\\section{Experiencia Laboral}');
            lines.push('\\begin{veinte}');
            lines.push('');
            data.experiencia.forEach(exp => {
                const descripcion = (exp.descripcion || [])
                    .map(d => `        ${this.escape(d)};%`)
                    .join('\n');
                lines.push(`    \\veinteitemtiempo{mainblue}{mainblue}{${exp.fecha_inicio || ''}}{${exp.fecha_fin || ''}}{${this.escape(exp.puesto || '')}}{${this.escape(exp.lugar || '')}}{%`);
                lines.push(`    \\makeList{%`);
                lines.push(descripcion);
                lines.push(`    }`);
                lines.push(`    }`);
                lines.push(`    `);
            });
            lines.push('\\end{veinte}');
            lines.push('');
        }
        // Educación
        if (data.educacion && data.educacion.length > 0) {
            lines.push('\\section{Educación}');
            lines.push('\\begin{veinte}');
            lines.push('');
            data.educacion.forEach(edu => {
                lines.push(`    \\veinteitemtiempo{mainblue}{mainblue}{${edu.fecha_inicio || ''}}{${edu.fecha_fin || ''}}{${this.escape(edu.titulo || '')}}{${this.escape(edu.institucion || '')}}{${this.escape(edu.descripcion || '')}}`);
                lines.push(`    `);
            });
            lines.push('\\end{veinte}');
            lines.push('');
        }
        // Referencias
        if (data.referencias && data.referencias.length > 0) {
            lines.push('\\section{Referencias Personales}');
            lines.push('\\begin{veinte}');
            lines.push('');
            data.referencias.forEach(ref => {
                const tel = this.cleanPhone(ref.telefono || '');
                lines.push(`    \\veinteitem{}{${this.escape(ref.nombre || '')}}{${this.escape(ref.relacion || '')}}{Tel: ${tel} - "${this.escape(ref.comentario || '')}"}`);
                lines.push(`    `);
            });
            lines.push('\\end{veinte}');
            lines.push('');
        }
        lines.push('\\end{document}');
        return lines.join('\n');
    }
};
