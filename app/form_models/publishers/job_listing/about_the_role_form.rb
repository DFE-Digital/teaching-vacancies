class Publishers::JobListing::AboutTheRoleForm < Publishers::JobListing::VacancyForm
  validates :ect_status, inclusion: { in: Vacancy.ect_statuses.keys }, if: -> { vacancy&.job_role == "teacher" }
  validates :skills_and_experience, presence: true
  validate :skills_and_experience_does_not_exceed_maximum_words
  validate :school_offer_presence
  validate :school_offer_does_not_exceed_maximum_words
  validates :safeguarding_information_provided, inclusion: { in: [true, false, "true", "false"] }
  validates :safeguarding_information, presence: true, if: -> { safeguarding_information_provided == "true" }
  validate :safeguarding_information_does_not_exceed_maximum_words, if: -> { safeguarding_information_provided == "true" }
  validates :further_details_provided, inclusion: { in: [true, false, "true", "false"] }
  validates :further_details, presence: true, if: -> { further_details_provided == "true" }
  validate :further_details_does_not_exceed_maximum_words, if: -> { further_details_provided == "true" }

  def self.fields
    %i[
      ect_status
      skills_and_experience
      school_offer
      safeguarding_information_provided
      safeguarding_information
      further_details_provided
      further_details
    ]
  end
  attr_accessor(*fields)

  private

  def organisation_type
    if vacancy&.central_office?
      "trust"
    elsif vacancy&.organisations&.many?
      "schools"
    else
      "school"
    end
  end

  def school_offer_presence
    return if school_offer.present?

    errors.add(:school_offer, I18n.t("about_the_role_errors.school_offer.blank", organisation: organisation_type))
  end

  def school_offer_does_not_exceed_maximum_words
    errors.add(:school_offer, :school_offer_maximum_words, message: I18n.t("about_the_role_errors.school_offer.maximum_words", organisation: organisation_type.capitalize)) if school_offer&.split&.length&.>(150)
  end

  def skills_and_experience_does_not_exceed_maximum_words
    errors.add(:skills_and_experience, :skills_and_experience_maximum_words, message: I18n.t("about_the_role_errors.skills_and_experience.maximum_words")) if skills_and_experience&.split&.length&.>(150)
  end

  def safeguarding_information_does_not_exceed_maximum_words
    errors.add(:safeguarding_information, :safeguarding_information_maximum_words, message: I18n.t("about_the_role_errors.safeguarding_information.maximum_words")) if safeguarding_information&.split&.length&.>(100)
  end

  def further_details_does_not_exceed_maximum_words
    errors.add(:further_details, :further_details_maximum_words, message: I18n.t("about_the_role_errors.further_details.maximum_words")) if further_details&.split&.length&.>(100)
  end
end
