$(document).ready () ->
  $(".subFlowChartFork").click () ->
    name = $(this).attr("name")
    $("#" + name).fadeIn("slow")

    if (name.substring(name.length-3,name.length)=="End") 
      $("#Donate").fadeIn('slow')
    
    if (name == "Tier2Question" || name == "Tier3Question")
      $("#fullFlow").css("height","+=150")
      $("#Donate").css("marginTop","+=150")
      if (name == "Tier3Question")
        $(".subFlowChart").css("clip","rect(0px,800px,600px,0px)")

    if (name == "Tier4YesEnd")
      $("#Tier4YesEndReload").delay(2000).fadeIn("slow")
      $("#Tier2End").delay(2000).fadeIn("slow")

  $(".subFlowChartFork").mouseover () ->
    temp = $(this).attr("src")
    highlight = temp.substring(0, temp.length - 9)
    $(this).attr("src", highlight + ".png")

  $(".subFlowChartFork").mouseout () ->
    temp = $(this).attr("src")
    highlight = temp.substring(0, temp.length - 4)
    $(this).attr("src", highlight + "Black.png")

  $("#videoHeading").click () ->
    $("#fullFlow").toggle("slow")
    if( $("#videoHeading").text() == "Bring Back the Flow Chart!")
      $("#videoHeading").html("<a href='#' id='flowChartHeader'>Just Show me the Videos</a>")
    else
      $("#videoHeading").html("<a href='#' id='flowChartHeader'>Bring Back the Flow Chart!</a>")
    false
