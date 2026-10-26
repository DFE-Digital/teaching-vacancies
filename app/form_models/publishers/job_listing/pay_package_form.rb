class Publishers::JobListing::PayPackageForm < Publishers::JobListing::VacancyForm
  include ActiveModel::Attributes

  include ActionView::Helpers::SanitizeHelper

  FIELDS = %i[actual_salary salary pay_scale benefits_details salary_types hourly_rate].freeze

  class << self
    def fields
      [:actual_salary, :benefits, :benefits_details, :salary, :pay_scale, :hourly_rate, { salary_types: [] }]
    end

    def field_list
      FIELDS + %i[benefits]
    end
  end
  attr_accessor(*FIELDS)

  attribute :benefits, :boolean

  def params_to_save
    salaries = slice(*InternalVacancy::SALARIES.select { |_salary, salary_type| salary_types.include? salary_type }.map(&:first))
    benefits_values = if benefits
                        slice(:benefits, :benefits_details)
                      else
                        slice(:benefits).merge(benefits_details: nil)
                      end
    salaries.merge(benefits_values)
  end
end
