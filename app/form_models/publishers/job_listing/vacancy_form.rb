class Publishers::JobListing::VacancyForm < BaseForm
  # so that these can be passed through the 'params' hash
  attr_writer :completed_steps, :current_organisation

  def initialize(params = {}, vacancy = nil, current_publisher = nil)
    @params = params
    @vacancy = vacancy
    @current_publisher = current_publisher

    super(params)
  end

  def params_to_save
    params.except(:current_organisation)
  end

  class << self
    def load_form(model)
      # causing issues because vacancy doesn't have confirm contact email field
      # is there a better way to do this?
      if fields == [:confirm_contact_email]
        {}
      else
        model.slice(*fields)
      end
    end
  end

  private

  attr_reader :params, :vacancy
end
