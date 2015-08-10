class VendorsController < ApplicationController
  before_action :authorize_admin

  def index
    @vendors = Vendor.all
    respond_to do |format|
      format.html
      format.json { render json: @vendors.to_json }
    end
  end

  def create
    @vendor = Vendor.new(vendor_params)
    respond_to do |format|
      if @vendor.save
        format.html { redirect_to vendors_path, notice: 'Vendor successfully created' }
        format.json { render json: @vendor }
      else
        format.html { redirect_to vendors_path }
        format.json { render json: @vendor.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  private

  def vendor_raw_params
    params.require(:vendor).permit(:exid, :name, :known_macs)
  end

  def vendor_params
    vendor_raw_params.merge(known_macs: known_macs)
  end

  def known_macs
    if params[:known_macs]
      vendor_raw_params[:known_macs].try(:split,',')
    else
      ['']
    end
  end
end