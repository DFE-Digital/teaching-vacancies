class Publishers::JobListing::KeyStagesForm < Publishers::JobListing::VacancyForm
  validate :key_stages_in_phase

  FIELDS = %i[key_stages].freeze

  class << self
    def fields
      { key_stages: [] }
    end
  end
  attr_accessor(*FIELDS)

  private

  # :nocov:
  def key_stages_in_phase
    return if key_stages&.any? && key_stages&.all? { |ks| vacancy.key_stages_for_phases.include? ks.to_sym }

    errors.add(:key_stages, :inclusion)
  end
  # :nocov:
end
