module ApplicationHelper
  def human_boolean(boolean)
    boolean ? 'Yes' : 'No'
  end

  def avatar_url
    gravatar_id = Digest::MD5.hexdigest(current_user.email.downcase)
    "https://gravatar.com/avatar/#{gravatar_id}1.png"
  end

  def get_user(stripe_customer_id)
    user = User.where(stripe_customer_id: stripe_customer_id).includes(:country).first
    user
  end

  def get_hours(schedule)
    total_hours = 0
    Time.zone = "UTC"
    if schedule
      hours = schedule["Monday"].first.to_s.split("-")
      if hours.present?
        from = Time.zone.parse(hours.first)
        to = Time.zone.parse(hours[1])
        total_hours += ((to - from) / 1.hour).round
      end
      hours = schedule["Tuesday"].first.to_s.split("-")
      if hours.present?
        from = Time.zone.parse(hours.first)
        to = Time.zone.parse(hours[1])
        total_hours += ((to - from) / 1.hour).round
      end
      hours = schedule["Wednesday"].first.to_s.split("-")
      if hours.present?
        from = Time.zone.parse(hours.first)
        to = Time.zone.parse(hours[1])
        total_hours += ((to - from) / 1.hour).round
      end
      hours = schedule["Thursday"].first.to_s.split("-")
      if hours.present?
        from = Time.zone.parse(hours.first)
        to = Time.zone.parse(hours[1])
        total_hours += ((to - from) / 1.hour).round
      end
      hours = schedule["Friday"].first.to_s.split("-")
      if hours.present?
        from = Time.zone.parse(hours.first)
        to = Time.zone.parse(hours[1])
        total_hours += ((to - from) / 1.hour).round
      end
      hours = schedule["Saturday"].first.to_s.split("-")
      if hours.present?
        from = Time.zone.parse(hours.first)
        to = Time.zone.parse(hours[1])
        total_hours += ((to - from) / 1.hour).round
      end
      hours = schedule["Sunday"].first.to_s.split("-")
      if hours.present?
        from = Time.zone.parse(hours.first)
        to = Time.zone.parse(hours[1])
        total_hours += ((to - from) / 1.hour).round
      end
    end
    total_hours
  end
end
