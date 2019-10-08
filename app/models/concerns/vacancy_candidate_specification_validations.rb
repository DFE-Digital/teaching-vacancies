module VacancyCandidateSpecificationValidations
  extend ActiveSupport::Concern
  include ApplicationHelper

  included do
    validates :experience, :education, :qualifications, presence: true
    validates :experience, length: { minimum: 1, maximum: 1000 },
                           if: proc { |model| model.experience.present? }
    validates :education, length: { minimum: 1, maximum: 1000 },
                          if: proc { |model| model.education.present? }
    validates :qualifications, length: { minimum: 1, maximum: 1000 },
                               if: proc { |model| model.qualifications.present? }
  end

  def experience=(value)
    super(sanitize(value))
  end

  def qualifications=(value)
    super(sanitize(value))
  end

  def education=(value)
    super(sanitize(value))
  end
end
