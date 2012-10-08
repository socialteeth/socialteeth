$(document).ready () ->
  temp = $('#socialMedia').position()
  top1 = temp.top
  temp = $('#twitterFeed').position()
  top2 = temp.top
  $('#twitterFeed').css('margin-top',top1-top2+50)
  $('#twitterFeed').css('height',top2-top1-50)

