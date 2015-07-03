(function() {
  var updateCode;

  updateCode = function() {
    var api_credentials, baseText, camera, camera_name, offline, pre_auth, priv, refresh, url, width;
    camera = $('#widget-camera').val();
    refresh = $('#widget-refresh-rate').val();
    width = $('#widget-camera-width').val();
    pre_auth = $('#widget-authenticate').val();
    url = window.location.origin;
    camera_name = $('#widget-camera option:selected').text();
    offline = camera_name.indexOf('(Offline)') !== -1;
    priv = camera_name.indexOf('(Private)') === -1 ? 'false' : 'true';
    api_credentials = pre_auth === 'true' ? "&api_id=" + window.api_credentials.api_id + "&api_key=" + window.api_credentials.api_key : '';
    baseText = "<div id='ec-container-" + camera + "' style='width: " + width + "px'></div> <script src='" + url + "/live.view.widget.js?refresh=" + refresh + "&camera=" + camera + "&private=" + priv + api_credentials + "' async></script>";
    $('#code').text(baseText);
    document.removeEventListener("visibilitychange", window.ec_vis_handler, false);
    if (window.ec_watcher != null) {
      clearTimeout(window.ec_watcher);
    }
    if (!offline) {
      $('.preview').html(baseText);
    }
    return true;
  };

  $(function() {
    updateCode();
    $('#widget-camera-width').change(updateCode);
    $('#widget-refresh-rate').change(updateCode);
    $('#widget-camera').change(updateCode);
    return $('#widget-authenticate').change(updateCode);
  });

}).call(this);
