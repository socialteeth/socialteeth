$(document).ready ->
  $("#voteButton").click (e) ->
    ad_id = $(e.target).siblings("input[name=ad_id]").val()
    num_votes = $(e.target).siblings("input[name=num_votes]").val()
    $.ajax
      type: "post"
      url: "/vote/#{ad_id}"
      data: { num_votes: num_votes }
      success: -> window.location.reload()
