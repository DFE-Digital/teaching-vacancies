module VacancyCandidateSpecificationValidations
  extend ActiveSupport::Concern

  included do
    validates :essential_requirements, presence: true
  end
end
