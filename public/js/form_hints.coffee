class window.FormHints
  init: ->
    $("form.hints input").each (i, el) ->
      $("#signupPage label[for=#{el.name}]").show() if el.value == ""

    $("form.hints input").keydown (e) ->
      $(".formField label[for=#{e.target.name}]").hide()

    $("form.hints input").blur (e) ->
      $(".formField label[for=#{e.target.name}]").show() if e.target.value == ""

$(document).ready -> new FormHints().init()
