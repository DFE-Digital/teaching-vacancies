module VacancyJobLocationValidations
  extend ActiveSupport::Concern

  included do
    validates :job_location, presence: true
  end
end
