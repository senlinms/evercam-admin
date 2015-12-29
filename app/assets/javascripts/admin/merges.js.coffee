merge_table = undefined

initializeDataTable = ->
  merge_table = $("#merge_datatables").DataTable
    aaSorting: [1, "asc"]
    fnRowCallback: (nRow, aData, iDisplayIndex, iDisplayIndexFull) ->
      if aData[3] > 0
        $('td:eq(3)', nRow)
          .html "Y"
          .css { "color": "green", "text-align": "center" }
      else
        $('td:eq(3)', nRow)
          .html "N"
          .css { "color": "Red", "text-align": "center" }
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    columns: [
      {data: "0" },
      {data: "1" },
      {data: "2" },
      {data: "3" },
      {data: "4" },
      {data: "5" }
    ],
    iDisplayLength: 50
    columnDefs: [
      type: "date-uk"
      targets: 'datatable-date'
    ],
    "oLanguage": {
      "sSearch": "Filter:"
    },
    initComplete: ->
      $("#merge-list-row").removeClass('hide')
      $("#merge_datatables_length label").hide()
      $("#div-dropdown-checklist").css('visibility', 'visible')

columnsDropdown = ->
  $(".cameras-column").on "click", ->
    column = merge_table.column($(this).attr("data-val"))
    column.visible !column.visible()

onCameraAction = ->
  host = ''
  port = ''
  jpg  = ''
  $("#merge_datatables").on 'click', '.action-cam', ->
    host = $(this).parents('tr').find('td:nth-child(1)').html()
    port = $(this).parents('tr').find('td:nth-child(2)').html()
    jpg  = $(this).parents('tr').find('td:nth-child(3)').html()
    d = {}
    d.host = host
    d.port = port
    d.jpg = jpg
    $.ajax
      url: 'merge'
      data: d
      type: 'get'
      success: (data) ->
        content = "<table class='table table-striped'>"
        content += "<thead>"
        content += "<tr>"
        content += "<th>Name</th><th>exid</th><th>Online</th><th>Owner Name</th><th>Public</th><th>Shared Count</th><th>Created At</th>"
        content += "</tr>"
        data.forEach (cam) ->
          content += '<tr>
                          <td>' + cam[2] + '</td><td>' + cam[1] + '</td><td>' + colorMe(cam[6]) + '</td><td>' + cam[3] + ' ' + cam[4] + '</td><td>' + colorMe(cam[8]) + '</td><td>' + cam[5] + '</td><td>' + cam[7] + '</td>
                      </tr>'
        content += '</table>'
        $('#dat').append(content);
    $('#add-action').modal('show')

colorMe = (status) ->
  if status is true or status is "t"
    console.log(status)
    return "<span style='color:green;'>Y</span>"
  else
    return "<span style='color:red;'>N</span>"

clearModal = ->
  $('#dat').html("")

onModelClose = ->
  $("#add-action").on "hidden.bs.modal", ->
    clearModal()

window.initializeMerges = ->
  initializeDataTable()
  columnsDropdown()
  onCameraAction()
  onModelClose()
