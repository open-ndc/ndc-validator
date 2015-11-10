// Load CodeMirror editor in the textAreaEditor
console.log("editor.js loaded!");

window.onload = function(e){
  var textAreaEditor = document.getElementById('xml_body');
  if (textAreaEditor !== null) {
    var codeMirror = CodeMirror.fromTextArea(textAreaEditor, {
      value: textAreaEditor.value,
      mode: 'application/xml',
      tabMode: 'indent',
      lineNumbers: true,
      autofocus: true
    });
  } else {
    alert("ERR: textAreaEditor not found in document!")
  }
};
