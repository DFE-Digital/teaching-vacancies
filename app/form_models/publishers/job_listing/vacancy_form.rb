class Publishers::JobListing::VacancyForm < BaseForm
  attr_accessor :params, :vacancy, :completed_steps, :current_organisation

  def initialize(params = {}, vacancy = nil)
    @params = params
    @vacancy = vacancy

    super(params)
  end

  def params_to_save
    params.except(:current_organisation)
  end
end
