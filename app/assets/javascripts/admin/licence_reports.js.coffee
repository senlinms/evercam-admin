licences_table = undefined

initializeDataTable = ->
  licences_table = $("#licences_datatables").DataTable
    aaSorting: [1, "asc"]
    aLengthMenu: [
      [25, 50, 100, 200, -1]
      [25, 50, 100, 200, "All"]
    ]
    columns: [
      {data: "0" },
      {data: "1" },
      {data: "2" },
      {data: "3" },
      {data: "4", "sClass": "right" },
      {data: "5", "sClass": "right" },
      {data: "6" },
      {data: "7" },
      {data: "8" },
      {data: "9", "sClass": "right" },
      {data: "10", visible: false }
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
      $("#licences-list-row").removeClass('hide')
      $("#licences_datatables_length label").hide()
      $("#div-dropdown-checklist").css('visibility', 'visible')

columnsDropdown = ->
  $(".licences-column").on "click", ->
    column = licences_table.column($(this).attr("data-val"))
    column.visible !column.visible()

initChosen = ->
  $('.chose-select').chosen()
  $("#total-cameras").NumericUpDown()

onModelShow = ->
  $("#modal-add-licence").on "show.bs.modal", ->
    $(".chosen-container").width("100%");

twoDigitDecimal = ->
  $("#licence-amount").on "change", ->
    if $("#licence-amount").val() is "" || $("#licence-amount").val() is "0.00"
      return;
    num = parseFloat($("#licence-amount").val());
    if isNaN(num.toFixed(2))
      Notification.show("Please enter valid licence amount.")
      $("#licence-amount").focus();
      $("#"+msgId).show('');
      return;
    $("#licence-amount").val(num.toFixed(2));

initNotify = ->
  Notification.init("bb-alert");

initDateTime = ->
  $('.licence-date').datetimepicker
    format: 'Y/m/d'
    timepicker: false

window.initializeLicences = ->
  initChosen()
  onModelShow()
  columnsDropdown()
  initializeDataTable()
  initNotify()
  twoDigitDecimal()
  initDateTime()
