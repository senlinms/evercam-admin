class CameraDecorator < Draper::Decorator
  delegate :exid, :name, :user, :thumbnail_url, :config, :mac_address

  def vendor_model_name
    camera.vendor_model.try(:name)
  end

  def vendor_name
    camera.vendor_model.vendor.name if camera.vendor_model.present?
  end

  def creation_date
    object.created_at.strftime("%d/%m/%y %I:%M %p")
  end

  def last_poll_date
    object.last_polled_at.strftime("%d/%m/%y") if object.last_polled_at.present?
  end

  def is_online
    h.human_boolean(object.is_online?)
  end

  def is_public
    h.human_boolean(camera.is_public?)
  end

  def is_discoverable
    h.human_boolean(camera.discoverable?)
  end
end
