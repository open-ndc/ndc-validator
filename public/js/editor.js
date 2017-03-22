// Load CodeMirror editor in the textAreaEditor
console.log("editor.js loaded!");

window.onload = function(e){
  var editor = ace.edit('xml_body')
  editor.setOptions({
    minLines: 30,
    maxLines: 50
  })
  editor.getSession().setMode("ace/mode/xml")

  $('form').submit(function(e) {
    var contents = editor.getValue()
    var elem = $('<input type="hidden" name="xml_body" value=""/>')
    elem.val(contents)
    $('form').append(elem)
    e.submit()
    e.preventDefault()
  })
};
