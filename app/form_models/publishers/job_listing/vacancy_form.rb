class Publishers::JobListing::VacancyForm
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor :params, :vacancy

  delegate(*Vacancy.attribute_names.map { |attr| [attr, "#{attr}=", "#{attr}?"] }.flatten, to: :vacancy)

  validates :state, inclusion: { in: %w[copy create edit edit_published review] }

  def initialize(params = {})
    @params = params
    @vacancy = Vacancy.new(params.except(:documents_attributes, :expires_at_hh, :expires_at_mm, :expires_at_meridiem, :current_organisation))
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
