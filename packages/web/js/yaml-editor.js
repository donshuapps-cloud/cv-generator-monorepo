// Configuración del editor CodeMirror para YAML
window.yamlEditor = CodeMirror.fromTextArea(document.getElementById('yaml-editor'), {
    mode: 'yaml',
    theme: 'material-darker',
    lineNumbers: true,
    indentUnit: 2,
    tabSize: 2,
    lineWrapping: true,
    foldGutter: true,
    gutters: ['CodeMirror-linenumbers', 'CodeMirror-foldgutter'],
    extraKeys: {
        'Ctrl-Space': 'autocomplete',
        'Tab': (cm) => {
            if (cm.somethingSelected()) {
                cm.indentSelection('add');
            } else {
                cm.replaceSelection('  ', 'end');
            }
        }
    }
});
// Validar YAML en tiempo real
window.yamlEditor.on('change', () => {
    const yamlText = window.yamlEditor.getValue();
    App.parseYAML(yamlText);
});
// Atajos de teclado
window.yamlEditor.setOption('extraKeys', {
    'Ctrl-S': () => App.generarCV(),
    'Cmd-S': () => App.generarCV(),
    'Ctrl-Enter': () => App.generarCV()
});
