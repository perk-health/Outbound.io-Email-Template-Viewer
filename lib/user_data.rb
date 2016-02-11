class UserData < Struct.new(
    :first_name, :last_name, :openness, :conscientiousness, :extraversion, :agreeableness,
    :neuroticism, :last_behavior_created_at, :last_behavior_display_string
  )

  def liquid_hash
    {
      'first_name' => self.first_name.to_s,
      'last_name' => self.last_name.to_s,
      'openness' => self.openness.to_i,
      'conscientiousness' => self.conscientiousness.to_i,
      'extraversion' => self.extraversion.to_i,
      'agreeableness' => self.agreeableness.to_i,
      'neuroticism' => self.neuroticism.to_i,
      'last_behavior_created_at' => self.last_behavior_created_at.to_s,
      'last_behavior_display_string' => self.last_behavior_display_string.to_s,
    }
  end

  def name
    self.first_name.to_s + self.last_name.to_s
  end
end
