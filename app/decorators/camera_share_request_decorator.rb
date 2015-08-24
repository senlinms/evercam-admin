class CameraShareRequestDecorator < Draper::Decorator
  delegate :camera,
           :user,
           :email,
           :status,
           :rights,
           :message,
           :created_at,
           :update_at

  def user_status
    if object.status.equal?(CameraShareRequest::PENDING)
      "Pending"
    elsif object.status.equal?(CameraShareRequest::CANCELLED)
      "Cancelled"
    elsif object.status.equal?(CameraShareRequest::USED)
      "Used"
    end
  end

  def share_rights
    rights = []
    if object.rights.eql?('list,snapshot')
      "Read Only"
    else
      "Full Rights"
    end
  end

  def share_created_at
    object.created_at.strftime("%d/%m/%y")
  end
end