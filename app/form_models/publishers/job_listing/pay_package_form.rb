class Publishers::JobListing::PayPackageForm < Publishers::JobListing::VacancyForm
  include ActiveModel::Attributes

  include ActionView::Helpers::SanitizeHelper

  SALARIES = {
    salary: "full_time",
    actual_salary: "part_time",
    pay_scale: "pay_scale",
    hourly_rate: "hourly_rate",
  }.freeze

  validate :salary_presence
  SALARIES.each do |key, value|
    validates key, presence: true, length: { minimum: 1, maximum: 256 }, if: -> { params[:salary_types]&.include?(value) }
  end
  validates :benefits, inclusion: { in: [true, false] }
  validates :benefits_details, presence: true, length: { minimum: 1, maximum: 256 }, if: -> { benefits }

  FIELDS = %i[actual_salary salary pay_scale benefits_details salary_types hourly_rate].freeze

  def self.fields
    FIELDS + %i[benefits]
  end
  attr_accessor(*FIELDS)

  attribute :benefits, :boolean

  def params_to_save
    SALARIES.each { |salary, salary_type| params[salary] = nil unless params[:salary_types]&.include? salary_type }
    super.except(:salary_types)
  end

  private

  def salary_presence
    errors.add(:salary_types) if params[:salary_types].blank? || salary_types.none?
  end
end
