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

  def self.fields
    %i[actual_salary salary pay_scale]
  end
  attr_accessor(*fields)
  attr_writer :salary_types

  def salary_types
    SALARIES.map { |key, value| value if public_send(key).present? || params[:salary_types]&.include?(value) }
  end

  def params_to_save
    SALARIES.each { |salary, salary_type| params[salary] = nil unless params[:salary_types]&.include? salary_type }
    params.except(:salary_types)
  end

  private

  def salary_presence
    errors.add(:salary_types) if params[:salary_types].empty?
  end
end
