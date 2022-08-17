class Publishers::JobListing::KeyStagesForm < Publishers::JobListing::VacancyForm
  validate :key_stages_in_phase

  def self.fields
    %i[key_stages]
  end
  attr_accessor(*fields)

  private

  def key_stages_in_phase
    return unless vacancy&.allow_key_stages?
    return if key_stages&.any? && key_stages&.all? { |ks| vacancy.key_stages_for_phases.include? ks.to_sym }

    errors.add(:key_stages, :inclusion)
  end
end
