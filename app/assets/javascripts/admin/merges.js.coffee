merge_table = undefined
count = 0
action = undefined

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
    $('#loading-popup').show()
    host = $(this).parents('tr').find('td:nth-child(1)').text()
    port = $(this).parents('tr').find('td:nth-child(2)').text()
    jpg  = $(this).parents('tr').find('td:nth-child(3)').text()
    count = parseInt($(this).parents('tr').find('td:nth-child(5)').text(),10)
    action = $(this).parents('tr')
    d = {}
    d.host = host
    d.port = port
    d.jpg = jpg
    $.ajax
      url: 'merge'
      data: d
      type: 'get'
      success: (data) ->
        $('#loading-popup').hide()
        content = "<table class='table table-striped'>"
        content += "<thead>"
        content += "<tr>"
        content += "<th>Name</th><th>exid</th><th>Online</th><th>Owner Name</th><th>Public</th><th>Shared Count</th><th>Created At</th><th class='center'>Action</th>"
        content += "</tr>"
        content += "</thead>"
        content += "<tbody>"
        data.forEach (cam) ->
          content += '<tr>
                          <td><a href="/cameras/'+ cam[0] + '">' + cam[2] + '</a></td><td>' + cam[1] + '</td><td>' + colorMe(cam[6]) + '</td><td><a href="/users/'+ cam[9] + '">' + cam[3] + ' ' + cam[4] + '</a></td><td>' + colorMe(cam[8]) + '</td><td>' + cam[5] + '</td><td>' + cam[7] + '</td><td class="center"><i class="fa fa-trash-o delete-cam"></i></td>
                      </tr>'
        content += "</tbody>"
        content += '</table>'
        $('#dat').append content
    $('#add-action').modal('show')

onCameraDelete = ->
  exid = ''
  tr = ''
  $("#dat").on 'click', '.delete-cam', ->
    $('#deleteModal').modal('show')
    tr = $(this).parents('tr')
    exid = tr.find('td:nth-child(2)').text()
    $(".col-md-12 > p > #id").append exid
  $("#delete-camera").on "click", ->
    if exid == $("#camera_specified_id").val()
      $('#deleteModal').modal('hide')
      del = {}
      del.exid = exid
      $.ajax
        url: 'merge'
        data: del
        type: 'get'
        success: ->
          tr.remove()
          count--
          action.find('td:nth-child(5)').text(count)
        error: (xhr, status, error) ->
          $(".alert-danger").text(xhr.responseText)
    else if $("#camera_specified_id").val() is ""
        $(".alert-danger")
        .text("Please specify your camera id!")
        .delay(200)
        .fadeIn()
        .delay(4000)
        .fadeOut()
    else
        $(".alert-danger")
        .text("Invalid camera id!")
        .delay(200)
        .fadeIn()
        .delay(4000)
        .fadeOut()

colorMe = (status) ->
  if status is true or status is "t"
    return "<span style='color:green;'>Y</span>"
  else
    return "<span style='color:red;'>N</span>"

clearModal = ->
  $('#dat').html("")

clearFeilds = ->
  $(".col-md-12 > p > #id").text("")
  $("#camera_specified_id").val("")

onModelClose = ->
  $("#add-action").on "hidden.bs.modal", ->
    clearModal()
  $("#deleteModal").on "hidden.bs.modal", ->
    clearFeilds()

window.initializeMerges = ->
  initializeDataTable()
  columnsDropdown()
  onCameraAction()
  onCameraDelete()
  onModelClose()
