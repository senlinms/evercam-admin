loadingGif = '<img src="/assets/loader3.gif" class="camera-wait" />'
sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)
  true

loadSelects = ->
  $('#services').change ->
    if $(this).data('options') == undefined
      $(this).data 'options', $('#operations option').clone()
    id = $(this).val()
    options = $(this).data('options').filter('[value=' + id + ']')
    $('#operations').html options
    return

initChosen = ->
  $('#inputCameraId').chosen()

onOnvifRun = ->
  $("#searchOnvif").on "click", ->
    $("#json-renderer").append loadingGif
    data = {}
    data.camera_info = $("#inputCameraId").val()
    data.service = $("#services").val()
    data.operation = $("#operations").find(":selected").text()
    data.api_url = $("#server-api-url").val()
    if $("#inputCameraId").val() is "Select Camera"
      $('.camera-wait').hide()
      $(".bb-alert")
        .removeClass("alert-success")
        .addClass("alert-danger")
        .text("Camera cannot be empty!")
        .delay(200)
        .fadeIn()
        .delay(4000)
        .fadeOut()
    else
      getResponseFromCamera(data)

getResponseFromCamera = (data) ->

  onError = (response) ->
    $('.camera-wait').hide()
    $("#json-renderer").jsonViewer($.parseJSON(response.responseText))

  onSuccess = (response) ->
    $('.camera-wait').hide()
    $('#json-renderer').jsonViewer(response)

  settings =
    error: onError
    success: onSuccess
    cache: false
    dataType: "json"
    type: "GET"
    url: "#{data.api_url}/v1/onvif/v20/#{data.service}/#{data.operation}?#{data.camera_info}"

  sendAJAXRequest(settings)

window.initializeOnvif = ->
  loadSelects()
  initChosen()
  onOnvifRun()
