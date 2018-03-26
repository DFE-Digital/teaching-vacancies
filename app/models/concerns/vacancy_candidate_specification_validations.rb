module VacancyCandidateSpecificationValidations
  extend ActiveSupport::Concern

  included do
    validates :experience, presence: true
    validates :education, presence: true
    validates :qualifications, presence: true
  end
end
