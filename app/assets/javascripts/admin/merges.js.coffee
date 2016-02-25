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
                          <td><a href="/cameras/'+ cam[0] + '">' + cam[2] + '</a></td><td>' + cam[1] + '</td><td>' + colorMe(cam[6]) + '</td><td><a href="/users/'+ cam[9] + '">' + cam[3] + ' ' + cam[4] + '</a></td><td>' + colorMe(cam[8]) + '</td><td>' + cam[5] + '</td><td>' + cam[7] + '</td><td class="center"><input type="checkbox" class="delete-cam" value=""></td><td style="display: none;">' + cam[0] + '</td>
                      </tr>'
        content += "</tbody>"
        content += '</table>'
        $('#dat').append content
    $('#add-action').modal('show')

onCameraDelete = ->
  rows = []
  camids = []
  $("#delete-camera").on "click", ->
    rows = $('.center > input:checkbox:checked').map( ->
      $(this).parents('tr')
    ).get()
    camids = $('.center > input:checkbox:checked').map( ->
      $(this).parents('tr').find('td:last-child').text()
    ).get()
    if rows.length > 0
      $("#deleteModal").modal("show")
    else
      $(".bb-alert")
        .addClass("alert-danger")
        .text("Please select at least one camera for deletion!")
        .delay(200)
        .fadeIn()
        .delay(4000)
        .fadeOut()
  $("#fdelete-camera").on "click", ->
    $("#deleteModal").modal("hide")
    del = {}
    del.camids = camids
    $.ajax
      url: 'merge'
      data: del
      type: 'get'
      success: (data) ->
        rows.forEach (row) ->
          row.remove()
        count -= data
        if count == 1 || count < 1
          action.remove()
        else
          action.find('td:nth-child(5)').text(count)

        if $("#dat > table > tbody").html() == ""
          $("#add-action").modal("hide")

        $(".bb-alert")
          .addClass("alert-success")
          .text("Camera has been deleted!")
          .delay(200)
          .fadeIn()
          .delay(4000)
          .fadeOut()
      error: (xhr, status, error) ->
        $(".alert-danger")
          .text(xhr.responseText)
          .delay(200)
          .fadeIn()
          .delay(4000)
          .fadeOut()

onCameraMerge = ->
  rows = []
  camera_ids = []
  owner_ids = []
  super_cam_index = 0
  merged_row = ""
  $("#merge-camera").on "click", ->
    rows = $('.center > input:checkbox:checked').map( ->
      $(this).parents('tr')
    ).get()
    camera_ids = $('.center > input:checkbox:checked').map( ->
      $(this).parents('tr').find('td:last-child').text()
    ).get()
    owner_ids = $('.center > input:checkbox:checked').map( ->
      $(this).parents('tr').find('td:nth-child(4) > a').attr('href').replace(/\D/g,'')
    ).get()
    if rows.length > 1
      $('#mergeModal').modal('show')
    else
      $(".bb-alert")
        .addClass("alert-danger")
        .text("Please select at least 2 cameras for merge!")
        .delay(200)
        .fadeIn()
        .delay(4000)
        .fadeOut()
    tbl = $('#dat > table > tbody > tr:has(td > input:checkbox:checked)').map((i, v) ->
      $td = $('td', this)
      {
        id: ++i
        camId: $td.eq(8).text()
        camName: $td.eq(0).text()
        exId: $td.eq(1).text()
        sCount: $td.eq(5).text()
      }
    ).get()
    optionsHtml = ''
    tbl.forEach (value) ->
      optionsHtml += '<option value="' + value.camId + '">' + value.camName + ' - share Count (' + value.sCount + ')</option>'
    $('#with-cam').html '<select id="cam-f-id" class="form-control">' + optionsHtml + '</select>'
  $("#mergeModal").on "click", "#fmerge-camera", ->
    $('#api-wait').show()
    super_cam_id = $("#with-cam > #cam-f-id").val()
    super_cam_index = $.inArray(super_cam_id, camera_ids)
    super_cam_owner_id = owner_ids[super_cam_index]
    $('#mergeModal').modal('hide')
    i = 0
    while i < camera_ids.length
      if camera_ids[i] == super_cam_id && owner_ids[i] == super_cam_owner_id
        camera_ids.splice(i,1)
        owner_ids.splice(i,1)
        merged_row = rows[i]
        rows.splice(i,1)
      i++
    mCount = parseInt(merged_row.find('td:nth-child(6)').text(),10)
    merge = {}
    merge.super_cam_id = super_cam_id
    merge.super_cam_owner_id = super_cam_owner_id
    merge.camera_ids = camera_ids
    merge.owner_ids = owner_ids
    $.ajax
      url: 'merge'
      data: merge
      type: 'get'
      success: (data) ->
        $('#api-wait').hide()
        count -= rows.length
        if count == 1 || count < 1
          action.remove()
        else
          action.find('td:nth-child(5)').text(count)
        rows.forEach (row) ->
          row.remove()
        mCount += data
        merged_row.find('td:nth-child(6)').text(mCount)
        merged_row.find('td:nth-child(8) > .delete-cam').prop('checked', false)
        $(".bb-alert")
          .addClass("alert-success")
          .text("Cameras have been successfully merged and Shared with full rights!")
          .delay(200)
          .fadeIn()
          .delay(4000)
          .fadeOut()
      error: (xhr, status, error) ->
        $(".bb-alert")
          .addClass("alert-danger")
          .text(xhr.responseText)
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

clearMergeFeilds = ->
  $("p > #mc").text("")
  $("p > #with-cam").text("")

onModelClose = ->
  $("#add-action").on "hidden.bs.modal", ->
    clearModal()
  $("#deleteModal").on "hidden.bs.modal", ->
    clearFeilds()
  $("#mergeModal").on "hidden.bs.modal", ->
    clearMergeFeilds()

shareOp = (intval) ->
  if intval > 0
    return ' | <i class="icon-camera merge-cam"></i>'
  else
    return ""

appendMe = ->
  $("#merge_datatables_filter > label > input").addClass("label_color")

window.initializeMerges = ->
  initializeDataTable()
  columnsDropdown()
  onCameraAction()
  onCameraDelete()
  onCameraMerge()
  onModelClose()
  appendMe()
