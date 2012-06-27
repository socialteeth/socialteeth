$(document).ready ->
  if !Modernizr.input.placeholder
    $("form.hints input,textarea").each ->
      $(@).before("<label for='" + @.name + "''>" + @.placeholder + "</label>")
