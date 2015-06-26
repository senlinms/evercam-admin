class VendorModelsController < ApplicationController
  def index
    @total_vendors = Vendor.count
    @total_cameras = Camera.count
  end

  def load_vendor_model
    condition = "lower(vendor_models.name) like lower('%#{params[:vendor_model]}%') OR
                 lower(vendors.name) like lower('%#{params[:vendor]}%') "
    vendors_models = VendorModel.joins(:vendor).where(condition)
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
        vendors_models[index].config.deep_fetch('auth', 'basic', 'password') { '' }]
    end

    render json: records
  end

  def show
    @vendor_model = VendorModel.includes(:vendor).find(params[:id])
    @total_cameras = Camera.where(model_id: params[:id])
  end

  def update
    begin
      @vendor_model = VendorModel.find(params[:id])
      @vendor_model.update_attributes(name: params['name'], jpg_url: params['jpg_url'])

      @vendor = Vendor.find(params['vendor_id'])
      @vendor.update_attribute(:name, params['vendor_name'])

      flash[:message] = 'Vendor Model updated successfully'
      redirect_to "/models/#{params['id']}"
    rescue => error
      env["airbrake.error_id"] = notify_airbrake(error)
      Rails.logger.error "Exception caught updating vendor model details.\nCause: #{error}\n" +
                             error.backtrace.join("\n")
      flash[:message] = "An error occurred updating the vendor model details. "\
                        "Please try again and, if this problem persists, contact "\
                        "support."
      redirect_to "/models/#{params['id']}"
    end
  end

end