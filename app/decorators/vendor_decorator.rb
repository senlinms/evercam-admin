class VendorDecorator < Draper::Decorator
  delegate :exid, :name, :known_macs

  def macs
    object.known_macs.join(' ')
  end

  def image_src
    "http://evercam-public-assets.s3.amazonaws.com/#{object.exid}/logo.jpg}"
  end

end
