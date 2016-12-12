schedule = undefined
scheduleCalendar = undefined
fullWeekSchedule =
  "Monday": ["08:00-17:30"]
  "Tuesday": ["08:00-17:30"]
  "Wednesday": ["08:00-17:30"]
  "Thursday": ["08:00-17:30"]
  "Friday": ["08:00-17:30"]
  "Saturday": []
  "Sunday": []
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
  $('#cloud-recording-calendar').addClass 'open'

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
    if camera_id is "" || interval is ""
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
  $('#cloud-recording-calendar').removeClass "open"
  schedule = undefined

window.initializSnapshotExtractors = ->
  initDateTime()
  initScheduleCalendar()
  makeScheduleOpen()
  renderEvents()
  onSearchSET()
  initChosen()
