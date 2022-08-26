class Publishers::JobListing::PayPackageForm < Publishers::JobListing::VacancyForm
  include ActionView::Helpers::SanitizeHelper

  SALARIES = {
    salary: "full_time",
    actual_salary: "part_time",
    pay_scale: "pay_scale",
  }.freeze

  validate :salary_presence
  SALARIES.each do |key, value|
    validates key, presence: true, length: { minimum: 1, maximum: 256 }, if: -> { params[:salary_types]&.include?(value) }
  end
  validates :benefits, inclusion: { in: [true, false, "true", "false"] }
  validates :benefits_details, presence: true, length: { minimum: 1, maximum: 256 }, if: -> { benefits == "true" }

  def self.fields
    %i[actual_salary salary pay_scale benefits benefits_details salary_types]
  end
  attr_accessor(*fields)

  def params_to_save
    SALARIES.each { |salary, salary_type| params[salary] = nil unless params[:salary_types]&.include? salary_type }
    params.except(:salary_types)
  end

  private

  def salary_presence
    errors.add(:salary_types) if params[:salary_types].blank? || salary_types.none?
  end
end
