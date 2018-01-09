compares = undefined

sendAJAXRequest = (settings) ->
  token = $('meta[name="csrf-token"]')
  if token.size() > 0
    headers =
      "X-CSRF-Token": token.attr("content")
    settings.headers = headers
  xhrRequestChangeMonth = jQuery.ajax(settings)

initializeDataTable = ->
  compares = $("#compares_datatables").DataTable
    aaSorting: [1, "desc"]
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    columns: [
      {data: "0", sWidth: "30px", sClass: "center" },
      {data: "1", sWidth: "120px" },
      {data: "2", sWidth: "150px" },
      {data: "3", sWidth: "150px" },
      {data: "4", sWidth: "150px" },
      {data: "5", sWidth: "100px", sClass: "center", "render": compareStatus },
      {data: "6", sWidth: "150px", sClass: "hide" },
      {data: "7", sWidth: "75px", sClass: "center" },
      {data: "8", sWidth: "85px", "render": downloadLinks, sClass: "center" }
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
      $("#compares_datatables_length").hide()
      $("#div-dropdown-checklist").css({"visibility": "visible", "width": "57px", "top": "0px", "left": "6px" })

columnsDropdown = ->
  $(".compares-column").on "click", ->
    column = compares.column($(this).attr("data-val"))
    column.visible !column.visible()

compareStatus = (name) ->
  if name is 0 or name is "0"
    "Processing"
  else if name is 1 or name is "1"
    "Completed"
  else
    "Failed"

setMargin = ->
  row = $("#compares_datatables_wrapper").children().first()
  row.css("margin-bottom", "-11px")

copyEmbedCode = ->
  $("#compares_datatables").on "click", ".copy-embed-code", ->
    data = $(this).closest('td').prev('td').text()
    $temp = $('<textarea>')
    $('body').append $temp
    $temp.val(data).select()
    document.execCommand 'copy'
    $temp.remove()
    Notification.show("Embed Code has been Copied.")

deleteCompare = ->
  $("#compares_datatables").on "click", ".delete-compare", ->
    $('#ajx-wait').show()
    that = $(this)
    data = {}
    data.id = $(this).data("id")
    $.ajax
      url: '/delete_compare'
      data: data
      dataType: 'json'
      type: 'DELETE'
      success: ->
        $('#ajx-wait').hide()
        that.parent("tr:first").remove()
        Notification.show("Compare has been deleted.")
      error: (xhr, status, error) ->
        Notification.show(xhr.responseText)

downloadLinks = (name) ->
  names = name.split("|")
  "<a href='https://media.evercam.io/v1/cameras/#{names[1]}/compares/#{names[0]}.gif' download='https://media.evercam.io/v1/cameras/#{name[0]}/compares/#{name[1]}.gif'><i class='fa fa-download'></i> GIF</a> |
    <a href='https://media.evercam.io/v1/cameras/#{names[1]}/compares/#{names[0]}.mp4' download='https://media.evercam.io/v1/cameras/#{name[0]}/compares/#{name[1]}.mp4'><i class='fa fa-download'></i> MP4</a>"

initNotify = ->
  Notification.init(".show-notifications")

window.initializeCompares = ->
  initializeDataTable()
  columnsDropdown()
  copyEmbedCode()
  setMargin()
  initNotify
  deleteCompare()
