class VendorsController < ApplicationController
  def index
    @vendors = Vendor.all
  end

  def create
    @vendor = Vendor.new(vendor_params)

    if @vendor.save
      redirect_to vendors_path, notice: 'Vendor successfully created'
    else
      redirect_to vendors_path
    end
  end

  private

  def vendor_params
    params.require(:vendor).permit(:exid, :name, :known_macs)
  end
end