schedule = undefined
fullWeekSchedule =
  "Monday": ["00:00-23:59"]
  "Tuesday": ["00:00-23:59"]
  "Wednesday": ["00:00-23:59"]
  "Thursday": ["00:00-23:59"]
  "Friday": ["00:00-23:59"]
  "Saturday": ["00:00-23:59"]
  "Sunday": ["00:00-23:59"]
data = {}

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)
  true

initDateTime = ->
  $('#datetimepicker1,#datetimepicker2').datetimepicker
    format: 'Y/m/d'
    timepicker: false

  $('#datetimepicker1,#datetimepicker2').val getTodayDate()

getTodayDate = ->
  date = new Date
  date.setDate date.getDate()
  date.getFullYear() + '/' + (date.getMonth() + 1) + '/' + date.getDate()

initScheduleCalendar = ->
  scheduleCalendar = $('#cloud-recording-calendar').fullCalendar
    axisFormat: 'HH'
    allDaySlot: false
    columnFormat: 'ddd'
    defaultDate: '1970-01-01'
    defaultView: 'agendaWeek'
    dayNamesShort: ["S", "M", "T", "W", "T", "F", "S"]
    eventColor: '#428bca'
    editable: true
    eventClick: (event, element) ->
      event.preventDefault
      if (window.confirm("Are you sure you want to delete this event?"))
        scheduleCalendar.fullCalendar('removeEvents', event._id)
        updateScheduleFromCalendar()
    eventDrop: (event) ->
      updateScheduleFromCalendar()
    eventResize: (event) ->
      updateScheduleFromCalendar()
    eventLimit: true
    eventOverlap: false
    firstDay: 1
    header:
      left: ''
      center: ''
      right: ''
    height: 'auto'
    select: (start, end) ->
      # TODO: select whole day range when allDaySlot is selected
      eventData =
        start: start
        end: end
      scheduleCalendar.fullCalendar('renderEvent', eventData, true)
      scheduleCalendar.fullCalendar('unselect')
      updateScheduleFromCalendar()
    selectHelper: true
    selectable: true
    timezone: 'local'

updateScheduleFromCalendar = ->
  schedule = parseCalendar()
  schedule = JSON.stringify(parseCalendar())
  schedule

onCollapsRecording = ->
  $('#cloud-recording-collaps').click ->
    $('#cloud-recording-calendar').toggleClass 'open'

parseCalendar = ->
  events = $('#cloud-recording-calendar').fullCalendar('clientEvents')
  schedule =
    'Monday': []
    'Tuesday': []
    'Wednesday': []
    'Thursday': []
    'Friday': []
    'Saturday': []
    'Sunday': []
  _.forEach events, (event) ->
    startTime = "#{moment(event.start).get('hours')}:#{moment(event.start).get('minutes')}"
    endTime = "#{moment(event.end).get('hours')}:#{moment(event.end).get('minutes')}"
    day = moment(event.start).format('dddd')
    schedule[day] = schedule[day].concat("#{startTime}-#{endTime}")
  schedule

onSearchSET = ->
  $("#set").on "click", ->
    camera_id = $("#inputCameraId").val()
    from_date = $("#datetimepicker1").val()
    to_date = $("#datetimepicker2").val()
    interval = $("#interval").val()
    if schedule is undefined
      schedule = JSON.stringify(fullWeekSchedule)
    else
      schedule
    data.camera_id = camera_id
    data.from_date = from_date
    data.to_date = to_date
    data.interval = interval
    data.schedule = schedule

    putMeInDatabase(data)

putMeInDatabase = (data) ->

  onError = (data) ->
    $(".bb-alert")
      .removeClass("alert-success")
      .addClass("alert-danger")
      .text(data.statusText)
      .delay(200)
      .fadeIn()
      .delay(4000)
      .fadeOut()

  onSuccess = (data) ->
    $(".bb-alert")
      .removeClass("alert-danger")
      .addClass("alert-success")
      .text("Your Query has been saved! we will ge back to you soon!")
      .delay(200)
      .fadeIn()
      .delay(4000)
      .fadeOut()

  settings =
    error: onError
    success: onSuccess
    cache: false
    data: data
    dataType: "json"
    type: "POST"
    url: "snapshot_extractors#create"

  sendAJAXRequest(settings)

window.initializSnapshotExtractors = ->
  initDateTime()
  initScheduleCalendar()
  onCollapsRecording()
  onSearchSET()
