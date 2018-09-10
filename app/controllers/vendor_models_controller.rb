class VendorModelsController < ApplicationController
  before_action :authorize_admin

  def index
    @total_vendors = Vendor.count
    @total_cameras = Camera.count
    @types = ["poe", "wifi", "onvif", "psia", "audio_io",
              "ptz", "infrared", "varifocal", "sd_card", "upnp"]
  end

  def load_vendor_model
    col_for_order = params[:order]["0"]["column"]
    order_for = params[:order]["0"]["dir"]
    condition = "lower(vendor_models.name) like lower('%#{params[:vendor_model]}%') OR
                 lower(vendors.name) like lower('%#{params[:vendor]}%') "
    vendors_models = VendorModel.joins(:vendor).where(condition).order(sorting(col_for_order, order_for))
    total_records = vendors_models.count
    display_length = params[:length].to_i
    display_length = display_length < 0 ? total_records : display_length
    display_start = params[:start].to_i
    table_draw = params[:draw].to_i

    index_end = display_start + display_length
    index_end = index_end >= total_records ? total_records - 1 : index_end
    records = {:data => [], :draw => table_draw, :recordsTotal => total_records, :recordsFiltered => total_records}

    (display_start..index_end).each do |index|
      records[:data][records[:data].count] = [
        vendors_models[index].vendor.exid,
        vendors_models[index].exid,
        vendors_models[index].vendor.name,
        vendors_models[index].name,
        vendors_models[index].channel,
        vendors_models[index].jpg_url,
        vendors_models[index].h264_url,
        vendors_models[index].mjpg_url,

        vendors_models[index].mpeg4_url,
        vendors_models[index].mobile_url,
        vendors_models[index].lowres_url,

        vendors_models[index].username,
        vendors_models[index].password,
        vendors_models[index].audio_url,
        vendors_models[index].poe,
        vendors_models[index].wifi,
        vendors_models[index].onvif,
        vendors_models[index].psia,
        vendors_models[index].ptz,
        vendors_models[index].infrared,
        vendors_models[index].varifocal,
        vendors_models[index].sd_card,
        vendors_models[index].upnp,
        vendors_models[index].audio_io,
        vendors_models[index].shape,
        vendors_models[index].resolution,
        ""
      ]
    end

    render json: records
  end

  def show
    @vendor_model = VendorModel.includes(:vendor).find(params[:id])
    @total_cameras = Camera.where(model_id: params[:id])
  end

  def create
    vendor = Vendor.find_by_exid(params[:vendor_id])
    vendor_model = VendorModel.new(
      exid: params[:id],
      name: params[:name],
      vendor: vendor,
      channel: params['channel'],
      jpg_url: params[:jpg_url],
      mjpg_url: get_url(params[:mjpg_url]),
      h264_url: get_url(params[:h264_url]),
      mpeg4_url: get_url(params[:mpeg4_url]),
      mobile_url: get_url(params[:mobile_url]),
      lowres_url: get_url(params[:lowres_url]),
      audio_url: params['audio_url'],
      poe: params['poe'],
      wifi: params['wifi'],
      onvif: params['onvif'],
      psia: params['psia'],
      audio_io: params['audio_io'],
      ptz: params['ptz'],
      infrared: params['infrared'],
      varifocal: params['varifocal'],
      sd_card: params['sd_card'],
      upnp: params['upnp'],
      resolution: params['resolution'],
      username: params[:default_username],
      password: params[:default_password],
    )

    respond_to do |format|
      if vendor_model.save
        format.html { redirect_to vendor_models_path, notice: 'Model successfully created' }
        format.json { render json: vendor_model }
      else
        format.html { redirect_to vendor_models_path }
        format.json { render json: vendor_model.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def update
    saved = false
    begin
      vendor = Vendor.find_by_exid(params[:vendor_id])
      vendor_model = VendorModel.find_by_exid(params[:id])
      
      vendor_model.update_attributes(
        name: params['name'],
        vendor: vendor,
        channel: params['channel'],
        jpg_url: params['jpg_url'],
        h264_url: get_url(params[:h264_url]),
        mjpg_url: get_url(params[:mjpg_url]),
        mpeg4_url: get_url(params[:mpeg4_url]),
        mobile_url: get_url(params[:mobile_url]),
        lowres_url: get_url(params[:lowres_url]),
        audio_url: params['audio_url'],
        poe: params['poe'],
        wifi: params['wifi'],
        onvif: params['onvif'],
        psia: params['psia'],
        audio_io: params['audio_io'],
        ptz: params['ptz'],
        infrared: params['infrared'],
        varifocal: params['varifocal'],
        sd_card: params['sd_card'],
        upnp: params['upnp'],
        resolution: params['resolution'],
        username: params[:default_username],
        password: params[:default_password]
      )

      message = 'Model updated successfully'
      saved = true
    rescue => error
      message = error.message
    end
    respond_to do |format|
      if saved
        format.html { redirect_to vendor_models_path, notice: message }
        format.json { render json: vendor_model }
      else
        format.html { redirect_to vendor_models_path }
        format.json { render json: message, status: :unprocessable_entity }
      end
    end
  end

  def delete
    message = "Model has been deleted!"
    errors = "Some error has been occured"
    if params[:exid]
      begin
        VendorModel.find_by_exid(params[:exid]).destroy
        render json: message
      rescue
        render json: errors
      end
    end
  end

  private

  def get_url(url)
    if url
      url
    else
      ""
    end
  end

  def sorting(col, order)
    case col
    when "1"
      "vendor_models.exid #{order}"
    when "2"
      "vendors.name #{order}"
    when "3"
      "vendor_models.name #{order}"
    when "4"
      "vendor_models.jpg_url #{order}"
    when "5"
      "vendor_models.h264_url #{order}"
    when "6"
      "vendor_models.mjpg_url #{order}"
    when "7"
      "vendor_models.mpeg4_url #{order}"
    when "8"
      "vendor_models.mobile_url #{order}"
    when "9"
      "vendor_models.lowres_url #{order}"
    when "10"
      "vendor_models.username #{order}"
    when "11"
      "vendor_models.password #{order}"
    when "12"
      "vendor_models.audio_url #{order}"
    when "13"
      "vendor_models.poe #{order}"
    when "14"
      "vendor_models.wifi #{order}"
    when "15"
      "vendor_models.onvif #{order}"
    when "16"
      "vendor_models.psia #{orders}"
    when "17"
      "vendor_models.ptz #{order}"
    when "18"
      "vendor_models.infrared #{order}"
    when "19"
      "vendor_models.varifocal #{order}"
    when "20"
      "vendor_models.sd_card #{order}"
    when "21"
      "vendor_models.upnp"
    when "22"
      "vendor_models.audio_io"
    when "23"
      "vendor_models.shape"
    when "24"
      "vendor_models.resolution"
    end
  end
end
