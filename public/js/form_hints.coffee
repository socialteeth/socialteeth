$(document).ready ->
  if !Modernizr.input.placeholder
    $("form.hints input,textarea").each ->
      $(@).before("<label for='" + $(@).attr("name") + "''>" + $(@).attr("placeholder") + "</label>")
