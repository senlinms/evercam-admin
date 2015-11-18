module ApplicationHelper
  def human_boolean(boolean)
    boolean ? 'Yes' : 'No'
  end

  def avatar_url
    gravatar_id = Digest::MD5.hexdigest(current_user.email.downcase)
    "http://gravatar.com/avatar/#{gravatar_id}1.png"
  end

  def get_hours(schedule)
    total_hours = 0
    if schedule
      hours = schedule["Monday"].first.to_s.split("-")
      if hours.present?
        from = Time.parse(hours.first)
        to = Time.parse(hours[1])
        total_hours += ((to - from) / 1.hour).round
      end
      hours = schedule["Tuesday"].first.to_s.split("-")
      if hours.present?
        from = Time.parse(hours.first)
        to = Time.parse(hours[1])
        total_hours += ((to - from) / 1.hour).round
      end
      hours = schedule["Wednesday"].first.to_s.split("-")
      if hours.present?
        from = Time.parse(hours.first)
        to = Time.parse(hours[1])
        total_hours += ((to - from) / 1.hour).round
      end
      hours = schedule["Thursday"].first.to_s.split("-")
      if hours.present?
        from = Time.parse(hours.first)
        to = Time.parse(hours[1])
        total_hours += ((to - from) / 1.hour).round
      end
      hours = schedule["Friday"].first.to_s.split("-")
      if hours.present?
        from = Time.parse(hours.first)
        to = Time.parse(hours[1])
        total_hours += ((to - from) / 1.hour).round
      end
      hours = schedule["Saturday"].first.to_s.split("-")
      if hours.present?
        from = Time.parse(hours.first)
        to = Time.parse(hours[1])
        total_hours += ((to - from) / 1.hour).round
      end
      hours = schedule["Sunday"].first.to_s.split("-")
      if hours.present?
        from = Time.parse(hours.first)
        to = Time.parse(hours[1])
        total_hours += ((to - from) / 1.hour).round
      end
    end
    total_hours
  end
end
