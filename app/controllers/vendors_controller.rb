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
    known_macs = ['']
    if params.include?(:known_macs) && params[:known_macs]
      known_macs = params[:known_macs].split(",").inject([]) { |list, entry| list << entry.strip }
    end
    if !validateMac(known_macs)
      respond_to do |format|
        format.html { redirect_to vendors_path }
        format.json { render json: ["Mac address is invalid"], status: :unprocessable_entity }
      end
    elsif !validateId(params[:exid])
      respond_to do |format|
        format.html { redirect_to vendors_path }
        format.json { render json: ["Id is invalid"], status: :unprocessable_entity }
      end
    else
      @vendor = Vendor.new(
        exid: params[:exid],
        name: params[:name],
        known_macs: known_macs
      )
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
  end

  def update
    begin
      known_macs = ['']
      saved = true
      message = ['Vendor updated successfully']
      if params.include?(:known_macs) && params[:known_macs]
        known_macs = params[:known_macs].split(",").inject([]) { |list, entry| list << entry.strip }
      end
      unless validateMac(known_macs)
        saved = false
        message = ["Mac address is invalid"]
      else
        vendor = Vendor.find_by_exid(params[:exid])
        vendor.update_attributes(
          name: params[:name],
          known_macs: known_macs
        )
        pry
      end
    rescue => error
      message = error.message
    end
    respond_to do |format|
      if saved
        format.html { redirect_to vendors_path, notice: message }
        format.json { render json: @vendor }
      else
        format.html { redirect_to vendors_path }
        format.json { render json: message, status: :unprocessable_entity }
      end
    end
  end

  private

  def validate_mac(known_macs)
    is_valid_mac = true
    unless known_macs.blank?
      known_macs.each do |resource|
        if resource && resource != '' && !(resource =~ /^([0-9A-Fa-f]{2}[:-]){2}([0-9A-Fa-f]{2})$/)
          is_valid_mac = false
        end
      end
    end
    is_valid_mac
  end
  
  def validate_id(exid)
    is_valid_id = true
    if exid =~ /[+*?. ]/
      is_valid_id = false
    end
    is_valid_id
  end
end