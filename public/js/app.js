// On Document load jQuery callbacks

$(document).ready(function() {
    $("input#message_url").focus(function() { $(this).select(); } );
});
