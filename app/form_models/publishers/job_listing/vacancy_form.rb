class Publishers::JobListing::VacancyForm < Publishers::JobListing::BaseForm
  attr_accessor :completed_steps, :current_organisation

  def initialize(params = {}, vacancy = nil)
    @params = params
    @vacancy = vacancy

    super(params)
  end

  def params_to_save
    params.except(:current_organisation)
  end

  class << self
    def load_form(model)
      model.slice(*fields)
    end

    def permitted_params
      fields
    end
  end

  private

  attr_reader :params, :vacancy
end
