class JobSpecificationForm < VacancyForm
  validates :job_title, :job_description, :headline, \
            :minimum_salary, :working_pattern, presence: true

  validate :minimum_salary_lower_than_maximum, :working_hours

  delegate *['id', 'benefits', 'job_title', 'job_description', 'headline', 'leadership',
             'starts_on_yyyy', 'starts_on_mm', 'starts_on_dd', 'ends_on_dd', 'ends_on_mm',
             'ends_on_yyyy', 'school_id', 'working_pattern', 'minimum_salary', 'maximum_salary',
             'pay_scale', 'subject', 'weekly_hours'].map { |attr| [attr, "#{attr}="] }.flatten, to: :vacancy

  def initialize(params = {})
    subject = params.delete(:subject)
    pay_scale = params.delete(:pay_scale)
    leadership = params.delete(:leadership)
    params.merge(subject_id: subject) if subject.present?
    params.merge(pay_scale: pay_scale) if pay_scale.present?
    params.merge(leadership: leadership) if leadership.present?

    @vacancy = ::Vacancy.new(params)
  end

  def minimum_salary_lower_than_maximum
    errors.add(:minimum_salary, 'must be lower than the maximum salary') if minimum_higher_than_maximum_salary
  end

  def working_hours
    return if weekly_hours.blank?
    begin
      !!BigDecimal.new(weekly_hours)
      errors.add(:weekly_hours, 'cannot be negative') if BigDecimal.new(weekly_hours).negative?
    rescue
      errors.add(:weekly_hours, 'must be a valid number') && return
    end
  end

  private

  def minimum_higher_than_maximum_salary
    maximum_salary && minimum_salary > maximum_salary
  end
end
