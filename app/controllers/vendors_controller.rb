class VendorsController < ApplicationController
  def index
    @vendors = Vendor.all
  end

  def create
    @vendor = Vendor.new(vendor_params)
    respond_to do |format|
      if @vendor.save
        format.html { redirect_to vendors_path, notice: 'Vendor successfully created' }
        format.json
      else
        # TODO: decide whether to use this json thing
        # or use jquery only for validations but creation on rails form
        # puts @vendor.errors.full_messages
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def vendor_params
    params.require(:vendor).permit(:exid, :name).merge(known_macs: known_macs.split(','))
  end

  def known_macs
    params.require(:vendor)[:known_macs]
  end
end