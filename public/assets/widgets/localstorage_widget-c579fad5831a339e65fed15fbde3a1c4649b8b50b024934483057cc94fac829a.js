(function() {
  var FormatNumTo2, initEvents, loadLocalStorage, playbackUrl, showNote;

  playbackUrl = 'https://playback.azurewebsites.net/home/doc/page/main.aspx';

  initEvents = function() {
    var i, option;
    $('#widget-datetime').datetimepicker({
      timepicker: false,
      closeOnDateSelect: 0,
      format: 'd-m-Y'
    });
    loadLocalStorage();
    $('#btn-load-widget').on('click', loadLocalStorage);
    $('#widget-camera').on('change', loadLocalStorage);
    $('#widget-authenticate').on('change', showNote);
    $('#code').on('click', function() {
      this.select();
    });
    i = 0;
    while (i < 60) {
      option = '<option value="' + FormatNumTo2(i) + '">' + FormatNumTo2(i) + '</option>';
      if (i < 24) {
        $('#widget-hour').append(option);
      }
      $('#widget-minutes').append(option);
      $('#widget-seconds').append(option);
      i++;
    }
  };

  FormatNumTo2 = function(n) {
    if (n < 10) {
      return '0' + n;
    } else {
      return n;
    }
  };

  loadLocalStorage = function() {
    var api_credentials, camera, camera_name, date_time, embedCode, iframe, is_private, pre_auth, stringDateTime, url;
    url = window.location.origin;
    camera = $('#widget-camera').val();
    camera_name = $('#widget-camera option:selected').text();
    pre_auth = $('#widget-authenticate').val();
    is_private = camera_name.indexOf('(Private)') === -1 ? 'false' : 'true';
    api_credentials = '';
    date_time = '';
    stringDateTime = '';
    if ($('#widget-datetime').val()) {
      stringDateTime = $('#widget-datetime').val() + 'T' + $('#widget-hour').val() + ':' + $('#widget-minutes').val() + ':' + $('#widget-seconds').val() + 'Z';
      date_time = '&amp;date_time&#61;' + stringDateTime;
    }
    if (pre_auth === 'true') {
      api_credentials = '&amp;api_id&#61;' + Evercam.User.api_id + '&amp;api_key&#61;' + Evercam.User.api_key;
    }
    embedCode = '&lt;div evercam&#61;"localstorage"&gt;&lt;&#47;div&gt;' + '&lt;script type&#61;"text/javascript" src&#61;"' + url + '&#47;hikvision.local.storage.js?camera&#61;' + camera + '&amp;private&#61;' + is_private + api_credentials + date_time + '"&gt;&lt;&#47;script&gt;';
    $('#code').html(embedCode);
    $('.placeholder').empty();
    iframe = jQuery('<iframe />').css({
      'overflow-y': 'hidden',
      'overflow-x': 'scroll',
      'width': '100%',
      'height': '640px'
    }).attr({
      'src': playbackUrl + ("?camera=" + camera + "&date_time=" + stringDateTime + "&api_id=" + Evercam.User.api_id + "&api_key=" + Evercam.User.api_key),
      'frameborder': '0'
    }).appendTo('div[evercam=\'localstorage\']');
  };

  showNote = function() {
    var i, preElements;
    if ($(this).val()) {
      preElements = document.getElementsByClassName('switch');
      i = 0;
      while (i < preElements.length) {
        preElements[i].style.visibility = preElements[i].classList.contains($(this).val()) ? 'visible' : 'hidden';
        i++;
      }
      loadLocalStorage();
    }
  };

  window.initializeLocalStoragewidget = function() {
    return initEvents();
  };

}).call(this);
