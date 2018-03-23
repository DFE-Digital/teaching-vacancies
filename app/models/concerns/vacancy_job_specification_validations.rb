module VacancyJobSpecificationValidations
  extend ActiveSupport::Concern

  included do
    validates :job_title, :job_description, :headline,
              :minimum_salary, :working_pattern, presence: true

    validate :minimum_salary_lower_than_maximum, :working_hours
  end

  def minimum_salary_lower_than_maximum
    errors.add(:minimum_salary, 'must be lower than the maximum salary') if minimum_higher_than_maximum_salary?
  end

  def working_hours
    return if weekly_hours.blank?

    begin
      !!BigDecimal(weekly_hours)
      errors.add(:weekly_hours, 'cannot be negative') if BigDecimal(weekly_hours).negative?
    rescue
      errors.add(:weekly_hours, 'must be a valid number') && return
    end
  end

  private

  def minimum_higher_than_maximum_salary?
    maximum_salary && minimum_salary > maximum_salary
  end
end
