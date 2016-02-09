
initDateTime = ->
  $('#datetimepicker1,#datetimepicker2').datetimepicker
  	mask: true
  $('#datetimepicker1,#datetimepicker2').val getTodayDate()

getTodayDate = ->
  date = new Date
  date.setDate date.getDate()
  date.getFullYear() + '/' + (date.getMonth() + 1) + '/' + date.getDate() +  " " + date.getHours() + ":00"

# getToday = ->
# 	date = new Date
#   date.setDate (date.getDate())
#   date.getFullYear() + '/' + (date.getMonth() + 1) + '/' + date.getDate() + " " + date.getHours() + ":" + date.getMinutes() 

window.initializSnapshotExtractors = ->
	initDateTime()