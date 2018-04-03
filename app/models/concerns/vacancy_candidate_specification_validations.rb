module VacancyCandidateSpecificationValidations
  extend ActiveSupport::Concern

  included do
    validates :experience, :education, :qualifications, presence: true
    validates :experience, length: { minimum: 10 },
                           if: proc { |model| model.experience.present? }
    validates :education, length: { minimum: 10 },
                          if: proc { |model| model.education.present? }
    validates :qualifications, length: { minimum: 10 },
                               if: proc { |model| model.qualifications.present? }
  end
end
