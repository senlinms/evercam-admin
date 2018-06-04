schedule = undefined
scheduleCalendar = undefined
camera_select = null
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
    onClose: (date) ->
      isRecordingInCloud($('#datetimepicker1').val(), $('#datetimepicker2').val())

  $('#datetimepicker1,#datetimepicker2').val getTodayDate()

isRecordingInCloud = (start_date, end_date) ->
  camera_id = $("#inputCameraId").val()
  api_id = $("#inputCameraId").find('option:selected').attr("api_id")
  api_key = $("#inputCameraId").find('option:selected').attr("api_key")

  from_date = moment.utc("#{start_date} 00:00:00", "DD/MM/YYYY HH:mm:ss") / 1000
  to_date = moment.utc("#{end_date} 23:59:59", "DD/MM/YYYY HH:mm:ss") / 1000

  data = {}

  onError = (xhrData) ->
    $("#inject_to_cr").prop('disabled', 'disabled')
    $(".bb-alert")
    .removeClass("alert-success")
    .addClass("alert-danger")
    .text(xhrData.statusText)
    .delay(200)
    .fadeIn()
    .delay(4000)
    .fadeOut()

  onSuccess = (data) ->
    if data.snapshots.length > 10
      $(".bb-alert")
      .removeClass("alert-danger")
      .addClass("alert-success")
      .text("#{data.snapshots.length} jpegs are available on Cloud Recording for this Camera. You cannot inject NVR recordings to Cloud.")
      .delay(200)
      .fadeIn()
      .delay(4000)
      .fadeOut()
      $("#inject_to_cr").prop('disabled', 'disabled')
    else
      $("#inject_to_cr").prop('disabled', false)

  settings =
    error: onError
    success: onSuccess
    cache: false
    data: data
    dataType: "json"
    type: "GET"
    url: "#{$("#server-api-url").val()}/v1/cameras/#{camera_id}/recordings/snapshots?api_id=#{api_id}&api_key=#{api_key}&from=#{from_date}&to=#{to_date}&limit=3600&page=1"

  jQuery.ajax(settings)


getTodayDate = ->
  # date should be like that 29/05/2018 03:05:00
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

onSelectiveEvents = ->
  $("#_schedule").on "change", ->
    if $(this).val() == "random_hours"
      initScheduleCalendar()
    else
      $('.cloud-recording-calendar').fullCalendar('destroy')

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

onSearchSET = ->
  $("#set").on "click", ->
    camera_id = $("#inputCameraId").val()
    api_id = $("#inputCameraId").find('option:selected').attr("api_id")
    api_key = $("#inputCameraId").find('option:selected').attr("api_key")
    from_date = $("#datetimepicker1").val()
    to_date = $("#datetimepicker2").val()
    interval = $("#interval").val()
    create_mp4 = $("#create_mp4").val()
    jpegs_to_dropbox = $("#jpegs_to_dropbox").val()
    inject_to_cr = $("#inject_to_cr").val()

    if $("#_schedule").val() == "full_week"
      schedule = JSON.stringify(fullWeekSchedule)
    else if $("#_schedule").val() == "working_hours"
      schedule = JSON.stringify(workingHours)
    else
      schedule = JSON.stringify(parseCalendar())

    data = {}
    data.start_date = moment.utc("#{from_date} 00:00:00", "DD/MM/YYYY HH:mm:ss") / 1000
    data.end_date = moment.utc("#{to_date} 23:59:59", "DD/MM/YYYY HH:mm:ss") / 1000
    data.interval = interval
    data.schedule = schedule
    data.create_mp4 = create_mp4
    data.jpegs_to_dropbox = jpegs_to_dropbox
    data.inject_to_cr = inject_to_cr
    data.requester = $("#txtRequester").val()

    if camera_id is "" || interval is ""
      $(".bb-alert")
      .removeClass("alert-success")
      .addClass("alert-danger")
      .text("Camera Id Or Interval can't be empty!")
      .delay(200)
      .fadeIn()
      .delay(4000)
      .fadeOut()
    else if create_mp4 == "false" && jpegs_to_dropbox == "false" && inject_to_cr == "false"
      $(".bb-alert")
        .removeClass("alert-success")
        .addClass("alert-danger")
        .text("Please select an option for extraction!")
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
    $('.cloud-recording-calendar').fullCalendar('destroy')
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
  $('#_schedule option:eq(1)').prop('selected', true)

checkRTSPort = ->
  $('#inputCameraId').on 'change', ->
    camera_exid = $("#inputCameraId").val()
    data = {}
    data.camera_exid = camera_exid

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
      if data is 0
        $(".bb-alert")
        .removeClass("alert-success")
        .addClass("alert-danger")
        .text("Please add a Valid RTSP Port for Camera!")
        .delay(200)
        .fadeIn()
        .delay(4000)
        .fadeOut()
      else
        # Ignore it

    settings =
      error: onError
      success: onSuccess
      cache: false
      data: data
      dataType: "json"
      type: "GET"
      url: "/check_rtsp_port"

    jQuery.ajax(settings)

window.initializNvrSnapshotExtractor = ->
  initDateTime()
  makeScheduleOpen()
  onSelectiveEvents()
  onSearchSET()
  initCameraSelect()
  checkRTSPort()
