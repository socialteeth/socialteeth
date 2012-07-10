$(document).ready ->
  $(".commentInput a.submit").click (e) ->
    $commentInput = $(e.target).closest(".commentInput")
    text = $commentInput.find("textarea").val()
    return if text == ""
    $.ajax
      type: "post"
      url: "/labs/discussions/create_comment"
      data:
        user_public_id: $commentInput.find("[name=user_id]").val()
        discussion_public_id: $commentInput.find("[name=discussion_id]").val()
        text: text
      success: (html) -> $(".commentList").append(html)
      complete: -> $commentInput.find("textarea").val("")
