vendor_table = null
method = 'POST'

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)

initializeDataTable = ->
  headers = undefined
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers = 'X-CSRF-Token': token.attr('content')

  vendor_table = $('#datatable_vendors').DataTable({
    ajax: {
      url: "/vendors",
      'headers': headers
      dataSrc: 'vendors',
      error: (xhr, error, thrown) ->
        console.log(xhr.responseJSON.message)
    },
    columns: [
      {data: "id", width: '20%', 'render': showLogo },
      {data: "id", width: '20%', 'render': editVendor },
      {data: "name", width: '20%'},
      {data: "known_macs", width: '40%', 'render': showMacs }
    ],
    iDisplayLength: 50
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    aaSorting: [1, "asc"]
  })

editVendor = (id, type, row) ->
  return "<a style='cursor:pointer;' class='edit-vandor' val-id='#{row.id}' val-name='#{row.name}' val-macs='#{row.known_macs}'>#{row.id}</a>"

showLogo = (id, type, row) ->
  img = new Image()
  image_url = "http://evercam-public-assets.s3.amazonaws.com/#{id}/logo.jpg"
  img.onload = ->

  img.onerror = ->
    $("#image-#{row.id}").remove()
  img.src = image_url
  return "<img id='image-#{row.id}' style='width:100%;' src='#{image_url}'/>"

showMacs = (macs, type, row) ->
  known_macs = "#{macs}"
  return "<span style='word-wrap: break-word;'>#{known_macs.replace(RegExp(",", "g"), ", ")}</span>"

clearForm = ->
  $("#vendor_exid").val('')
  $("#vendor_exid").removeAttr("disabled")
  $("#name").val('')
  $("#vendor_known_macs").val('')
  $(".thumbnail-img").hide()
  $(".thumbnail-img").attr("src","camera.svg")
  $(".center-thumbnail").css("min-height", "160px")
  $(".vendor-alert").slideUp()
  $("#add-vendor div.caption").text("Add a Vendor");
  method = 'POST'

handleAddNewModel = ->
  $("#save-vendor").on 'click', ->

    if $("#vendor_exid").val() is ''
      $(".vendor-alert").html('Vendor id can not be empty.')
      $(".vendor-alert").slideDown()
      return
    if $("#vendor_name").val() is ''
      $(".vendor-alert").html('Vendor name can not be empty.')
      $(".vendor-alert").slideDown()
      return
    $(".vendor-alert").slideUp()

    data = {}
    data.name = $("#vendor_name").val()
    data.known_macs = $("#vendor_known_macs").val() unless $("#vendor_known_macs").val() is ''

    onError = (jqXHR, status, error) ->
      $(".vendor-alert").html(jqXHR.responseJSON.message)
      $(".vendor-alert").slideDown()
      false

    onSuccess = (result, status, jqXHR) ->
      vendor_table.ajax.reload()
      $('#add-vendor').modal('hide')
      method = 'POST'
      clearForm()
      true
    vendor_exid = ''
    if method is 'POST'
      data.exid = $("#vendor_exid").val()
    else
      vendor_exid = "/#{$("#vendor_exid").val()}"

    settings =
      cache: false
      data: {vendor: data}
      dataType: 'json'
      error: onError
      success: onSuccess
      contentType: "application/x-www-form-urlencoded"
      type: method
      url: "vendors"

    sendAJAXRequest(settings)

onModelClose = ->
  $(".modal").on "hide.bs.modal", ->
    clearForm()

$(".edit-vandor").live 'click', ->
  $("#vendor_exid").val($(this).attr("val-id"))
  $("#vendor_exid").attr("disabled", true)
  $("#vendor_name").val($(this).attr("val-name"))
  $("#vendor_known_macs").val($(this).attr("val-macs"))
  $(".thumbnail-img").attr("src", "http://evercam-public-assets.s3.amazonaws.com/#{$(this).attr("val-id")}/logo.jpg")
  $(".center-thumbnail").css("min-height", "30px")
  $(".thumbnail-img").show()
  method = 'PATCH'
  $('#add-vendor').modal('show')
  $("#add-vendor div.caption").text("Edit Vendor");

window.initializeVendors = ->
  initializeDataTable()
  handleAddNewModel()
  onModelClose()
