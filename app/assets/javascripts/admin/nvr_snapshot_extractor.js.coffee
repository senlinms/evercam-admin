schedule = undefined
scheduleCalendar = undefined
camera_select = null
fullWeekSchedule =
  "Monday": ["08:00-18:00"]
  "Tuesday": ["08:00-18:00"]
  "Wednesday": ["08:00-18:00"]
  "Thursday": ["08:00-18:00"]
  "Friday": ["08:00-18:00"]
  "Saturday": []
  "Sunday": []

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
    format: 'd/m/Y'
    timepicker: false

  $('#datetimepicker1,#datetimepicker2').val getTodayDate()

getTodayDate = ->
  date = new Date
  date.setDate date.getDate()
  date.getDate() + '/' + (date.getMonth() + 1) + '/' + date.getFullYear()

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
  schedule = JSON.stringify(parseCalendar())

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
    api_id = $("#inputCameraId").find('option:selected').attr("api_id")
    api_key = $("#inputCameraId").find('option:selected').attr("api_key")
    from_date = $("#datetimepicker1").val()
    to_date = $("#datetimepicker2").val()
    interval = $("#interval").val()
    mp4 = $("#mp4_to_dbx").val()
    jpegs = $("#jpegs_to_dbx").val()
    inject_to_cr = $("#inject_to_cr").val()
    if schedule is undefined
      schedule = JSON.stringify(fullWeekSchedule)
    else
      schedule

    data = {}
    data.start_date = moment.utc("#{from_date} 00:00:00", "DD/MM/YYYY HH:mm:ss") / 1000
    data.end_date = moment.utc("#{to_date} 23:59:59", "DD/MM/YYYY HH:mm:ss") / 1000
    data.interval = interval
    data.schedule = schedule
    data.mp4 = mp4
    data.jpegs = jpegs
    data.inject_to_cr = inject_to_cr
    data.requester = $("#txtRequester").val()

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
      putMeInDatabase(camera_id, api_id, api_key, data)

putMeInDatabase = (camera_id, api_id, api_key, data) ->

  onError = (xhrData) ->
    $(".bb-alert")
    .removeClass("alert-success")
    .addClass("alert-danger")
    .text(xhrData.statusText)
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
    url: "#{$("#server-api-url").val()}/v1/cameras/#{camera_id}/nvr/snapshots/extract?api_id=#{api_id}&api_key=#{api_key}"

  jQuery.ajax(settings)

initCameraSelect = ->
  camera_select = $("#inputCameraId").select2
    placeholder: 'Select Camera',
    templateSelection: format,
    templateResult: format

format = (state) ->
  is_offline = ""
  if !state.id
    return state.text
  if state.id == '0'
    return state.text
  if state.element.className is "onlinec"
    is_offline = '<i class="red main-sidebar fa fa-chain-broken"></i>'
  return $("<span><img style='height:30px;margin-bottom:1px;margin-top:1px;width:35px;' src='#{state.element.attributes[1].value}' class='img-flag' />&nbsp;#{state.text}</span>&nbsp;#{is_offline}")

clearForm = ->
  camera_select.val(null).trigger("change")
  $("#datetimepicker1").val getTodayDate()
  $("#datetimepicker2").val getTodayDate()
  $('#interval option:eq(4)').prop('selected', true)

window.initializNvrSnapshotExtractor = ->
  initDateTime()
  initScheduleCalendar()
  makeScheduleOpen()
  renderEvents()
  onSearchSET()
  initCameraSelect()
