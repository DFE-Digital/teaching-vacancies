class Publishers::JobListing::VacancyForm < Publishers::JobListing::BaseForm
  attr_accessor :completed_steps, :current_organisation
  # so that 'vacancy' can be passed through the 'params' hash
  attr_writer :vacancy

  def initialize(params = {}, vacancy = nil)
    @params = params
    @vacancy = vacancy

    super(params)
  end

  def params_to_save
    params.except(:current_organisation, :vacancy, :wizard)
  end

  class << self
    def load_form(model)
      model.slice(*fields)
    end

    def permitted_params
      fields
    end

    def extra_params(vacancy, _form_params)
      { vacancy: vacancy }
    end

    def route_name
      nil
    end
  end

  def next_step_path_arguments
    { job_id: @vacancy.id, id: next_step }
  end

  private

  attr_reader :params, :vacancy
end
