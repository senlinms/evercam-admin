class VendorModelsController < ApplicationController
  before_action :authorize_admin

  def index
    @total_vendors = Vendor.count
    @total_cameras = Camera.count
    @types = ["poe", "wifi", "onvif", "psia", "audio_io",
              "ptz", "infrared", "varifocal", "sd_card", "upnp"]
  end

  def load_vendor_model
    condition = "lower(vendor_models.name) like lower('%#{params[:vendor_model]}%') OR
                 lower(vendors.name) like lower('%#{params[:vendor]}%') "
    vendors_models = VendorModel.joins(:vendor).where(condition).order('vendor_models.name')
    total_records = vendors_models.count
    display_length = params[:length].to_i
    display_length = display_length < 0 ? total_records : display_length
    display_start = params[:start].to_i
    table_draw = params[:draw].to_i

    index_end = display_start + display_length
    index_end = index_end > total_records ? total_records - 1 : index_end
    records = {:data => [], :draw => table_draw, :recordsTotal => total_records, :recordsFiltered => total_records}

    (display_start..index_end).each do |index|
      records[:data][records[:data].count] = [
        vendors_models[index].vendor.exid,
        vendors_models[index].exid,
        vendors_models[index].vendor.name,
        vendors_models[index].name,
        vendors_models[index].config.deep_fetch('snapshots', 'jpg') { '' },
        vendors_models[index].config.deep_fetch('snapshots', 'h264') { '' },
        vendors_models[index].config.deep_fetch('snapshots', 'mjpg') { '' },
        vendors_models[index].config.deep_fetch('snapshots', 'mpeg4') { '' },
        vendors_models[index].config.deep_fetch('snapshots', 'mobile') { '' },
        vendors_models[index].config.deep_fetch('snapshots', 'lowres') { '' },
        vendors_models[index].config.deep_fetch('auth', 'basic', 'username') { '' },
        vendors_models[index].config.deep_fetch('auth', 'basic', 'password') { '' },

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
      jpg_url: params[:jpg_url],
      mjpg_url: params[:mjpg_url],
      h264_url: params[:h264_url],
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
      config: {}
    )

    [:jpg, :mjpg, :mpeg4, :mobile, :h264, :lowres].each do |resource|
      url_name = "#{resource}_url"
      unless params[url_name].blank?
        if vendor_model.config.has_key?('snapshots')
          vendor_model.config['snapshots'].merge!({resource => params[url_name]})
        else
          vendor_model.config.merge!({'snapshots' => { resource => params[url_name]}})
        end
      end
    end
    if params[:default_username] or params[:default_password]
      vendor_model.config.merge!({'auth' => {'basic' => {'username' => params[:default_username], 'password' => params[:default_password] }}})
    end

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
      config = {}
      [:jpg, :mjpg, :mpeg4, :mobile, :h264, :lowres].each do |resource|
        url_name = "#{resource}_url"
        unless params[url_name].blank?
          if config.has_key?('snapshots')
            config['snapshots'].merge!({resource => params[url_name]})
          else
            config.merge!({'snapshots' => { resource => params[url_name]}})
          end
        end
      end
      if params[:default_username] or params[:default_password]
        config.merge!({'auth' => {'basic' => {'username' => params[:default_username], 'password' => params[:default_password] }}})
      end
      vendor = Vendor.find_by_exid(params[:vendor_id])
      vendor_model = VendorModel.find_by_exid(params[:id])
      vendor_model.update_attributes(
        name: params['name'],
        vendor: vendor,
        jpg_url: params['jpg_url'],
        h264_url: params['h264_url'],
        mjpg_url: params['mjpg_url'],
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
        config: config
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
end
