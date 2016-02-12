initDateTime = ->
  $('#datetimepicker1,#datetimepicker2').datetimepicker
  	timepicker: false,
  	mask: true
  $('#datetimepicker1,#datetimepicker2').val getTodayDate()

getTodayDate = ->
  date = new Date
  date.setDate date.getDate()
  date.getFullYear() + '/' + (date.getMonth() + 1) + '/' + date.getDate()

onConsoleLog = ->
  console.log "hi its me"

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
  console.log schedule
  frequency = $("#cloud-recording-frequency").val()
  storage_duration = $("#cloud-recording-duration").val()
  schedule = JSON.stringify(parseCalendar())
  console.log schedule

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

window.initializSnapshotExtractors = ->
  initDateTime()
  onConsoleLog()
  initScheduleCalendar()
  onCollapsRecording()
