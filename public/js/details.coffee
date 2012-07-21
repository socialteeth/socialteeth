$(document).ready ->
  $("#voteButton").click (e) ->
    ad_id = $(e.target).siblings("input[name=ad_id]").val()
    $.ajax
      type: "post"
      url: "/vote/#{ad_id}"
      success: -> window.location.reload()
