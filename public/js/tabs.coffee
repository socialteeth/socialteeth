$(document).ready () -> 
  $('#tabs div').hide()
  $('#tabs div:first').show()
  $('#tabs ul li:first').addClass('active')
  $('#tabs ul li a').click ()-> 
    $('#tabs ul li').removeClass('active')
    $(this).parent().addClass('active')
    currentTab = $(this).attr('href') 
    $('#tabs div').hide()
    $(currentTab).show()
    return false
  