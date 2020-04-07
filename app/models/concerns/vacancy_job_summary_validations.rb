module VacancyJobSummaryValidations
  extend ActiveSupport::Concern
  include ApplicationHelper

  included do
    validates :job_summary, presence: true
    validates :about_school, presence: true
  end
end
