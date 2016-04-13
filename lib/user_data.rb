class UserData < Struct.new(
    :first_name, :last_name, :success_count,
    :openness, :conscientiousness, :extraversion, :agreeableness, :neuroticism,
    :last_behavior_created_at, :last_behavior_display_string,
    :actor_first_name, :actor_last_name, :actor_full_name,
    :message_body, :kudo_display_string, :target_display_string,
  )

  def self.attributes
    members.map(&:to_s)
  end

  def liquid_hash
    res = {}
    members.each do |member|
      val = send(member)

      is_number = true if Float(val) rescue false

      if is_number
        res[member.to_s] = val.to_f
      else
        res[member.to_s] = val.to_s
      end
    end
    res['actor_full_name'] = "#{res['actor_first_name']} #{res['actor_last_name']}"
    res
  end

  def name
    self.first_name.to_s + self.last_name.to_s
  end
end
