nvrs_table = null
is_loaded = false
stream_info = []

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)

initializeDataTable = ->
  nvrs_table = $("#nvrs_datatables").DataTable
    aaSorting: [1, "asc"]
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    columns: [
      {data: "0", sWidth: "100px" },
      {data: "1", sWidth: "100px", "render": (data, type, row) ->
        getStreamInfo(row[2], row[3], row[4]) if type is "display"
        return "<table id='div-#{row[2]}' style='width:1px;'></table>#{data}"
      },
      {data: "2", visible: false },
      {data: "3", visible: false },
      {data: "4", visible: false },
      {data: "5", sWidth: "60px" },
      {data: "6", sWidth: "80px" },
      {data: "7", sWidth: "40px" },
      {data: "8", sWidth: "40px" },
      {data: "9", sWidth: "40px" },
      {data: "10", sWidth: "45px" },
      {data: "11", sWidth: "50px" },
      {data: "12", sWidth: "50px" },
      {data: "13", sWidth: "50px" },
      {data: "14", sWidth: "60px" },
      {data: "15", sWidth: "40px", sClass: "center" }
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
      is_loaded = true
      $("#nvrs_datatables_wrapper div.row:first").hide()

getStreamInfo = (exid, api_id, api_key) ->
  data = {}

  onError = (jqXHR, status, error) ->
    false

  onSuccess = (result, status, jqXHR) ->
    displayValues(this.camera_id, result.stream_info, result.device_info)

  settings =
    data: data
    dataType: 'json'
    error: onError
    success: onSuccess
    context: {camera_id: exid}
    type: 'GET'
    url: "#{$("#server-api-url").val()}/v1/cameras/#{exid}/nvr/stream/info?api_id=#{api_id}&api_key=#{api_key}"

  jQuery.ajax(settings)

displayValues = (camera_exid, stream_info, device_info) ->
  tb_row = $("#div-#{camera_exid}").closest('tr')

  tb_row.find('td').eq(2).text(device_info.model)
  tb_row.find('td').eq(3).text(device_info.device_name)
  tb_row.find('td').eq(4).text(device_info.mac_address)
  tb_row.find('td').eq(5).text(device_info.firmware_version)

  tb_row.find('td').eq(6).text(stream_info.resolution) if stream_info.resolution isnt "x"
  tb_row.find('td').eq(7).text(stream_info.bitrate_type)
  tb_row.find('td').eq(8).text(stream_info.video_quality)
  tb_row.find('td').eq(9).text(stream_info.frame_rate)
  tb_row.find('td').eq(10).text(stream_info.bitrate)
  tb_row.find('td').eq(11).text(stream_info.video_encoding)
  tb_row.find('td').eq(12).text(stream_info.smart_code)

window.initializeNvrs = ->
  initializeDataTable()
