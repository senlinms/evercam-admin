loadPopUp = ->
  $("#delete-jpegs").on "click", ->
    $("#td-has-snapshot").css("display", "none")
    $("#archive-modal").modal('show')

getDatePart = (url) ->
  url.substr(url.lastIndexOf('/') + 1)

showImageCount = ->
  $("#start-url, #end-url").on "keyup", ->
    startUrl = $("#start-url").val()
    endUrl = $("#end-url").val()
    if is_valid_url(startUrl) && is_valid_url(endUrl)
      $("#td-has-snapshot").css("display", "none")
      if moment(getDatePart(startUrl)).unix() > moment(getDatePart(endUrl)).unix()
        $("#td-has-snapshot").css("display", "block")
        $("#td-has-snapshot").text("Start date cannot be greater than end date.")
        $("#delete_jpegs_button").prop('disabled', 'disabled')
      else
        countJpegs(startUrl, endUrl)
    else
      $("#td-has-snapshot").css("display", "block")
      $("#td-has-snapshot").text("Please enter valid URLs.")
      $("#delete_jpegs_button").prop('disabled', 'disabled')

onDeleteJpegs = ->
  $("#delete_jpegs_button").on "click", ->
    startUrl = $("#start-url").val()
    endUrl = $("#end-url").val()
    camera_id = $("#camera_exid").val()
    api_id = $("#api_id").val()
    api_key = $("#api_key").val()

    from_date = moment(getDatePart(startUrl)).unix()
    to_date = moment(getDatePart(endUrl)).unix()

    data = {}
    data.from_date = from_date
    data.to_date = to_date

    onError = (xhrData) ->
      $("#delete_jpegs_button").prop('disabled', 'disabled')
      $("#td-has-snapshot")
      .removeClass("alert-success")
      .addClass("alert-danger")
      .text(xhrData.statusText)

    onSuccess = (data) ->
      $("#td-has-snapshot").css("display", "none")
      $("#archive-modal").modal('hide')
      $(".bb-alert")
      .removeClass("alert-danger")
      .addClass("alert-success")
      .text("Jpegs have been deleted.")
      .delay(200)
      .fadeIn()
      .delay(4000)
      .fadeOut()
      $("#start-url").val("")
      $("#end-url").val("")
      $("#delete_jpegs_button").prop('disabled', false)

    settings =
      error: onError
      success: onSuccess
      cache: false
      data: data
      dataType: "json"
      type: "DELETE"
      url: "#{$("#server-api-url").val()}/v1/cameras/#{camera_id}/recordings/snapshots?api_id=#{api_id}&api_key=#{api_key}"
    jQuery.ajax(settings)


countJpegs = (startUrl, endUrl) ->
  camera_id = $("#camera_exid").val()
  api_id = $("#api_id").val()
  api_key = $("#api_key").val()

  from_date = moment(getDatePart(startUrl)).unix()
  to_date = moment(getDatePart(endUrl)).unix()

  data = {}

  onError = (xhrData) ->
    $("#delete_jpegs_button").prop('disabled', 'disabled')
    $("#td-has-snapshot")
    .removeClass("alert-success")
    .addClass("alert-danger")
    .text(xhrData.statusText)
    .delay(200)
    .fadeIn()
    .delay(4000)
    .fadeOut()

  onSuccess = (data) ->
    if data.snapshots.length > 0
      $("#td-has-snapshot").css("display", "block")
      $("#td-has-snapshot")
      .removeClass("alert-danger")
      .addClass("alert-success")
      .text("#{data.snapshots.length} jpegs are available for deletion.")
      $("#delete_jpegs_button").prop('disabled', false)
    else
      $("#td-has-snapshot").css("display", "block")
      $("#td-has-snapshot")
      .addClass("alert-danger")
      .removeClass("alert-success")
      .text("0 jpegs are available for deletion.")
      $("#delete_jpegs_button").prop('disabled', 'disabled')

  settings =
    error: onError
    success: onSuccess
    cache: false
    data: data
    dataType: "json"
    type: "GET"
    url: "#{$("#server-api-url").val()}/v1/cameras/#{camera_id}/recordings/snapshots?api_id=#{api_id}&api_key=#{api_key}&from=#{from_date}&to=#{to_date}&limit=3600&page=1"

  jQuery.ajax(settings)

is_valid_url = (url) ->
  /^(http(s)?:\/\/)?(www\.)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/.test url

window.initializeDeletJpegs = ->
  showImageCount()
  loadPopUp()
  onDeleteJpegs()
