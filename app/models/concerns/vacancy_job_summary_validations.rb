module VacancyJobSummaryValidations
  extend ActiveSupport::Concern
  include ApplicationHelper

  included do
    validates :job_summary, presence: true
    validates :about_school, presence: true
  end

  def job_summary=(value)
    super(sanitize(value))
  end

  def about_school=(value)
    super(sanitize(value))
  end
end
