$(document).ready ->
  if !Modernizr.input.placeholder
    $("form.hints input").each ->
      $(@).before("<label for='" + @.name + "''>" + @.placeholder + "</label>")
