nvrs_vh_table = null
info_array = []

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)

initializeDataTable = ->
  nvrs_vh_table = $("#nvrs_vh_datatables").DataTable
    aaSorting: [1, "asc"]
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    columns: [
      {data: "0", sWidth: "100px" },
      {data: "1", sWidth: "100px", "render": (data, type, row, meta) ->
        getStreamInfo(row[2], row[3], row[4], type) if type is "display"
        return "<table id='div-#{row[2]}' style='width:1px;'></table>#{data}"
      },
      {data: "2", visible: false },
      {data: "3", visible: false },
      {data: "4", visible: false },
      {data: "5", sWidth: "80px", "type":"string" },
      {data: "6", sWidth: "100px", "type":"string" },
      {data: "7", sWidth: "40px", "type":"string" },
      {data: "8", sWidth: "40px", "type":"string" },
      {data: "9", sWidth: "40px", "type":"string" },
      {data: "10", sWidth: "45px", "type":"string" },
      {data: "11", sWidth: "50px", "type":"string" },
      {data: "12", sWidth: "20px", "type":"number" },
      {data: "13", sWidth: "50px", "type":"number" },
      {data: "14", sWidth: "50px", "type":"string" },
      {data: "15", sWidth: "30px", sClass: "center", "type":"string" },
      {data: "16", sWidth: "45px", "type":"number" },
      {data: "17", sWidth: "40px", "type":"string" },
      {data: "18", sWidth: "40px", "type":"number" },
      {data: "19", sWidth: "110px", "type":"string" }
    ],
    iDisplayLength: 500
    columnDefs: [
      type: "date-uk"
      targets: 'datatable-date'
    ],
    "oLanguage": {
      "sSearch": "Filter:"
    },
    initComplete: ->
      $("#nvrs_vh_datatables_wrapper div.row:first").hide()

getStreamInfo = (exid, api_id, api_key, type) ->
  if info_array["#{exid}"]
    return true
  info_array["#{exid}"] = "yes"
  data = {}

  onError = (jqXHR, status, error) ->
    false

  onSuccess = (result, status, jqXHR) ->
    info_array["#{this.camera_id}"] = result
    displayValues(this.camera_id, result)

  settings =
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    context: {camera_id: exid}
    type: 'GET'
    url: "#{$("#server-api-url").val()}/v1/cameras/#{exid}/nvr/stream/vhinfo?api_id=#{api_id}&api_key=#{api_key}"

  jQuery.ajax(settings)

displayValues = (camera_exid, data) ->
  stream_info = data.vh_stream_info
  device_info = data.vh_device_info
  vh_info = data.vh_info
  tb_row = $("#div-#{camera_exid}").closest('tr')

  if device_info isnt undefined
    tb_row.find('td').eq(2).text(device_info.model) if device_info.model
    tb_row.find('td').eq(3).text(device_info.device_name) if device_info.device_name
    tb_row.find('td').eq(4).text(device_info.mac_address) if device_info.mac_address
    tb_row.find('td').eq(5).text(device_info.firmware_version) if device_info.firmware_version

  if stream_info
    tb_row.find('td').eq(6).text(stream_info.resolution) if stream_info.resolution isnt "x" and stream_info.resolution
    tb_row.find('td').eq(7).text(stream_info.bitrate_type) if stream_info.bitrate_type
    tb_row.find('td').eq(8).text(stream_info.video_quality) if stream_info.video_quality
    tb_row.find('td').eq(9).text(stream_info.frame_rate) if stream_info.frame_rate
    tb_row.find('td').eq(10).text(stream_info.bitrate) if stream_info.bitrate
    tb_row.find('td').eq(11).text(stream_info.video_encoding) if stream_info.video_encoding
    tb_row.find('td').eq(12).text(stream_info.smart_code) if stream_info.smart_code

  if vh_info
    tb_row.find('td').eq(13).text(vh_info.manage_port) if vh_info.manage_port
    tb_row.find('td').eq(15).text(vh_info.vh_port) if vh_info.vh_port
    tb_row.find('td').eq(16).text(vh_info.vh_url) if vh_info.vh_url
    if vh_info.online and vh_info.online is "true"
      tb_row.find('td').eq(14).text("Online")
    else
      tb_row.find('td').eq(14).text("Offline")

setValues = (data) ->
  camera_exid = data[2]
  info = info_array["#{camera_exid}"]
  stream_info = info.vh_stream_info
  device_info = info.vh_device_info
  vh_info = data.vh_info

  if device_info isnt undefined
    data[5] = device_info.model if device_info.model
    data[6] = device_info.device_name if device_info.device_name
    data[7] = device_info.mac_address if device_info.mac_address
    data[8] = device_info.firmware_version if device_info.firmware_version

  if stream_info
    data[9] = stream_info.resolution if stream_info.resolution isnt "x" and stream_info.resolution
    data[10] = stream_info.bitrate_type if stream_info.bitrate_type
    data[11] = stream_info.video_quality if stream_info.video_quality
    data[12] = stream_info.frame_rate if stream_info.frame_rate
    data[13] = stream_info.bitrate if stream_info.bitrate
    data[14] = stream_info.video_encoding if stream_info.video_encoding
    data[15] = stream_info.smart_code if stream_info.smart_code

  if vh_info
    data[16] = vh_info.manage_port if vh_info.manage_port
    data[17] = vh_info.vh_port if vh_info.vh_port
    data[18] = vh_info.vh_url if vh_info.vh_url
    if vh_info.online and vh_info.online is "true"
      data[19] = "Online"
    else
      data[19] = "Offline"

resetDataSet = ->
  $("th.sorting").on "click", ->
    dataSet = nvrs_vh_table.data()
    $.each dataSet, (index, data) ->
      setValues(data)
    nvrs_vh_table.data(dataSet).draw()

window.initializeNvrsVh = ->
  initializeDataTable()
  resetDataSet()
