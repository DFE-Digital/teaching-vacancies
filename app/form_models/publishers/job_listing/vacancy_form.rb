class Publishers::JobListing::VacancyForm < BaseForm
  # so that these can be passed through the 'params' hash
  attr_writer :completed_steps, :current_organisation

  include ActiveModel::Attributes

  def initialize(params = {}, vacancy = nil, current_publisher = nil)
    @params = params
    @vacancy = vacancy
    @current_publisher = current_publisher

    super(params)
  end

  def params_to_save
    params.except(:current_organisation)
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
    def load_form(model)
      model.slice(*fields)
    end
  end

  private

  attr_reader :params, :vacancy
end
