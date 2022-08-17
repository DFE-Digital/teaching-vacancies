class Publishers::JobListing::AboutTheRoleForm < Publishers::JobListing::VacancyForm
  validates :ect_status, inclusion: { in: Vacancy.ect_statuses.keys }, if: -> { vacancy&.job_role == "teacher" }
  validates :skills_and_experience, presence: true
  validate :school_offer_presence
  validates :safeguarding_information_provided, inclusion: { in: [true, false, "true", "false"] }
  validates :safeguarding_information, presence: true, if: -> { safeguarding_information_provided == "true" }
  validates :further_details_provided, inclusion: { in: [true, false, "true", "false"] }
  validates :further_details, presence: true, if: -> { further_details_provided == "true" }

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

  def school_offer_presence
    return if school_offer.present?

    organisation = if vacancy&.central_office?
                     "trust"
                   elsif vacancy&.organisations&.many?
                     "schools"
                   else
                     "school"
                   end

    errors.add(:school_offer, I18n.t("about_the_role_errors.school_offer.blank", organisation: organisation))
  end
end
