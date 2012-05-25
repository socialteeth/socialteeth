class window.FormHints
  constructor: (form) ->
    $form = $(form)

    $("form.hints input").each (i, el) ->
      $form.find("label[for=#{el.name}]").show() if el.value == ""

    $("form.hints input").keydown (e) ->
      $form.find("label[for=#{e.target.name}]").hide()

    $("form.hints input").blur (e) ->
      $form.find("label[for=#{e.target.name}]").show() if e.target.value == ""

$(document).ready -> new FormHints("form.hints")
