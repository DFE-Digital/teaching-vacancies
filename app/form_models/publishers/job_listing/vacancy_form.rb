class Publishers::JobListing::VacancyForm < BaseForm
  # so that these can be passed through the 'params' hash
  attr_writer :completed_steps

  def initialize(params = {}, vacancy = nil)
    @params = params
    @vacancy = vacancy

    super(params)
  end

  def params_to_save
    params
  end

  # Some forms may cause some previously completed steps in the Vacancy to be marked as incomplete again after updating
  # the form value.
  # This method should return an array of step names (as strings or symbols) that need to be reset (if previously listed
  # as completed) when the form is successfully submitted.
  # Defined here as an empty array by default. Override in the Form subclass if needed.
  def steps_to_reset
    []
  end

  class << self
    # rubocop:disable Lint/UnusedMethodArgument
    def load_from_model(vacancy, current_publisher:)
      new(vacancy.slice(*fields), vacancy)
    end

    def load_from_params(form_params, vacancy, current_publisher:)
      new(form_params, vacancy)
    end
    # rubocop:enable Lint/UnusedMethodArgument
  end

  private

  attr_reader :params, :vacancy
end
