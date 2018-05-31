schedule = undefined
scheduleCalendar = undefined
workingHours =
  "Monday": ["08:00-18:00"]
  "Tuesday": ["08:00-18:00"]
  "Wednesday": ["08:00-18:00"]
  "Thursday": ["08:00-18:00"]
  "Friday": ["08:00-18:00"]
  "Saturday": []
  "Sunday": []

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
    format: 'd/m/Y H:m:s'

  $('#datetimepicker1,#datetimepicker2').val getTodayDate()

getTodayDate = ->
  date = new Date
  date.setDate date.getDate()
  date.getDate() + '/' + (date.getMonth() + 1) + '/' + date.getFullYear() + ' ' + date.getHours() + ':' + date.getMinutes() + ':' + date.getSeconds()

initScheduleCalendar = ->
  scheduleCalendar = $('.cloud-recording-calendar').fullCalendar
    axisFormat: 'HH'
    allDaySlot: false
    columnFormat: 'ddd'
    defaultDate: '1970-01-01'
    slotDuration: '00:60:00'
    defaultView: 'agendaWeek'
    dayNamesShort: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
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
      eventData =
        start: start
        end: end
      scheduleCalendar.fullCalendar('renderEvent', eventData, true)
      scheduleCalendar.fullCalendar('unselect')
      updateScheduleFromCalendar()
    selectHelper: true
    selectable: true
    timezone: 'local'

renderEvents = ->
  schedule = fullWeekSchedule
  days = _.keys(schedule)
  calendarWeek = currentCalendarWeek()

  _.forEach days, (weekDay) ->
    day = schedule[weekDay]
    unless day.length == 0
      _.forEach day, (event) ->
        start = event.split("-")[0]
        end = event.split("-")[1]
        event =
          start: moment("#{calendarWeek[weekDay]} #{start}", "YYYY-MM-DD HH:mm")
          end: moment("#{calendarWeek[weekDay]} #{end}", "YYYY-MM-DD HH:mm")
        scheduleCalendar.fullCalendar('renderEvent', event, true)

currentCalendarWeek = ->
  calendarWeek = {}
  weekStart = scheduleCalendar.fullCalendar('getView').start
  weekEnd = scheduleCalendar.fullCalendar('getView').end
  day = weekStart
  while day.isBefore(weekEnd)
    weekDay = day.format("dddd")
    calendarWeek[weekDay] = day.format('YYYY-MM-DD')
    day.add 1, 'days'
  calendarWeek

updateScheduleFromCalendar = ->
  schedule = parseCalendar()
  schedule = JSON.stringify(parseCalendar())
  schedule

makeScheduleOpen = ->
  $('.cloud-recording-calendar').addClass 'open'

parseCalendar = ->
  events = $('.cloud-recording-calendar').fullCalendar('clientEvents')
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
    endingTime = "#{moment(event.end).get('hours')}:#{moment(event.end).get('minutes')}"
    endTime = if endingTime == "0:0" then "23:59" else endingTime
    day = moment(event.start).format('dddd')
    schedule[day] = schedule[day].concat("#{startTime}-#{endTime}")
  schedule

onSelectiveEvents = ->
  $("#_schedule").on "change", ->
    if $(this).val() == "random_hours"
      initScheduleCalendar()
    else
      $('.cloud-recording-calendar').fullCalendar('destroy')

onSearchSET = ->
  $("#set").on "click", ->
    camera_id = $("#inputCameraId").val()
    from_date = $("#datetimepicker1").val()
    to_date = $("#datetimepicker2").val()
    interval = $("#interval").val()
    create_mp4 = $("#create_mp4").val()
    if $("#_schedule").val() == "full_week"
      schedule = fullWeekSchedule
    else if $("#_schedule").val() == "working_hours"
      schedule = workingHours
    else
      schedule = parseCalendar()
    data.camera_id = camera_id
    data.from_date = from_date
    data.to_date = to_date
    data.interval = interval
    data.schedule = schedule
    data.create_mp4 = create_mp4
    if camera_id is "Select Camera" || interval is ""
      $(".bb-alert")
        .removeClass("alert-success")
        .addClass("alert-danger")
        .text("Camera Id Or Interval can't be empty!")
        .delay(200)
        .fadeIn()
        .delay(4000)
        .fadeOut()
    else
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
    clearForm()
    $('.cloud-recording-calendar').fullCalendar('destroy')
    makeScheduleOpen()
    $(".bb-alert")
      .removeClass("alert-danger")
      .addClass("alert-success")
      .text("Your request has been sent to Admin!. We will get back to you soon!")
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

initChosen = ->
  $('#inputCameraId').chosen()

clearForm = ->
  $(".chosen-single span").text "Select Camera"
  $("#datetimepicker1").val getTodayDate()
  $("#datetimepicker2").val getTodayDate()
  $('#interval option:eq(4)').prop('selected', true)
  $('#_schedule option:eq(1)').prop('selected', true)
  schedule = undefined

window.initializSnapshotExtractors = ->
  initDateTime()
  onSelectiveEvents()
  makeScheduleOpen()
  onSearchSET()
  initChosen()
