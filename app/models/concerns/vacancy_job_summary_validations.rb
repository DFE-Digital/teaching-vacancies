module VacancyJobSummaryValidations
  extend ActiveSupport::Concern

  included do
    validates :job_summary, presence: true
    validates :about_organisation, presence: true
  end
end
