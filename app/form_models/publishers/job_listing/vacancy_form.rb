class Publishers::JobListing::VacancyForm
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor :params, :vacancy, :completed_step

  def initialize(params = {}, vacancy = nil)
    @params = params
    @vacancy = vacancy

    super(params)
  end

  def params_to_save
    params.except(:current_organisation)
  end

  # This method is only necessary for forms with specific error messages for date inputs.
  def complete_and_valid?
    existing_errors = errors.dup
    is_valid = valid?
    existing_errors.messages.each do |field, error_array|
      error_array.each do |error|
        errors.add(field, error)
      end
    end
    errors.none? && is_valid
  end
end
