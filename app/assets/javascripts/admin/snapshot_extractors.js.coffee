
initDateTime = ->
  $('#datetimepicker1,#datetimepicker2').datetimepicker
  	timepicker: false,
  	mask: true
  $('#datetimepicker1,#datetimepicker2').val getTodayDate()

getTodayDate = ->
  date = new Date
  date.setDate date.getDate()
  date.getFullYear() + '/' + (date.getMonth() + 1) + '/' + date.getDate()

window.initializSnapshotExtractors = ->
	initDateTime()