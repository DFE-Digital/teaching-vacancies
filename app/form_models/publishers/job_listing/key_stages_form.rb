class Publishers::JobListing::KeyStagesForm < Publishers::JobListing::JobListingForm
  validate :key_stages_in_phase

  def self.fields
    %i[key_stages]
  end
  attr_accessor(*fields, :valid_key_stages)

  class << self
    # rubocop:disable Lint/UnusedMethodArgument
    def load_from_model(vacancy, current_publisher: nil)
      new(vacancy.slice(*fields).merge(valid_key_stages: vacancy.key_stages_for_phases))
    end

    def load_from_params(form_params, vacancy, current_publisher: nil)
      new(form_params.merge(valid_key_stages: vacancy.key_stages_for_phases))
    end
    # rubocop:enable Lint/UnusedMethodArgument
  end

  private

  def key_stages_in_phase
    return if key_stages.present? && key_stages.all? { |ks| valid_key_stages.include? ks.to_sym }

    errors.add(:key_stages, :inclusion)
  end
end
