class window.Signup
  nameToValueMap:
    name: "Name"
    email: "Email"
    password: "Password"
    passwordConfirm: "Confirm password"

  init: ->
    $("#signupPage form input").each (i, el) ->
      $("#signupPage label[for=#{el.name}]").show() if el.value == ""

    $("#signupPage form input").keydown (e) ->
      $(".formField label[for=#{e.target.name}]").hide()

    $("#signupPage form input").blur (e) ->
      $(".formField label[for=#{e.target.name}]").show() if e.target.value == ""

$(document).ready -> new Signup().init()
