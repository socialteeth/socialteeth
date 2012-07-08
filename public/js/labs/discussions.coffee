$(document).ready ->
  $(".discussionInput input[type=submit]").click (e) ->
    $discussionInput = $(e.target).closest(".discussionInput")
    title = $discussionInput.find("input[type=text]").val()
    title != ""
