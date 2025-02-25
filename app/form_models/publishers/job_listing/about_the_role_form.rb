class Publishers::JobListing::AboutTheRoleForm < Publishers::JobListing::VacancyForm
  include ActiveModel::Attributes

  validates :ect_status, inclusion: { in: Vacancy.ect_statuses.keys }, if: -> { vacancy&.job_roles&.include?("teacher") }
  validate :job_advert_presence, if: -> { vacancy.job_advert.present? }
  validate :about_school_presence, if: -> { vacancy.about_school.present? }
  validate :skills_and_experience_presence, unless: -> { vacancy.job_advert.present? }
  validate :school_offer_presence, unless: -> { vacancy.about_school.present? }
  validates :safeguarding_information_provided, inclusion: { in: [true, false, "true", "false"] }, if: -> { vacancy.safeguarding_information.present? }, unless: -> { vacancy.job_advert.present? || vacancy.about_school.present? }
  validate :safeguarding_information_presence, if: -> { vacancy.safeguarding_information.present? && safeguarding_information_provided == "true" }, unless: -> { vacancy.job_advert.present? || vacancy.about_school.present? }
  validate :safeguarding_information_does_not_exceed_maximum_words, if: -> { safeguarding_information_provided == "true" }, unless: -> { vacancy.job_advert.present? || vacancy.about_school.present? }
  validates :further_details_provided, inclusion: { in: [true, false, "true", "false"] }, unless: -> { vacancy.job_advert.present? || vacancy.about_school.present? }
  validate :further_details_presence, if: -> { further_details_provided == "true" }, unless: -> { vacancy.job_advert.present? || vacancy.about_school.present? }
  validates :flexi_working_details_provided, inclusion: { in: [true, false] }
  validate :flexi_working_presence, if: -> { flexi_working_details_provided == true }

  attribute :flexi_working_details_provided, :boolean
  attribute :job_advert
  attribute :about_school
  attribute :ect_status
  attribute :skills_and_experience
  attribute :school_offer
  attribute :flexi_working
  attribute :safeguarding_information_provided
  attribute :safeguarding_information
  attribute :further_details_provided
  attribute :further_details

  class << self
    # Overriding load_form because we use attributes in this form rather than defining the fields like we do in other forms.
    # This is necessary as we need to define flexi_working_details_provided explicitly as a boolean.
    def load_form(model)
      model.slice(*attribute_names)
    end
  end
  def params_to_save
    {
      job_advert:,
      about_school:,
      ect_status:,
      skills_and_experience:,
      school_offer:,
      flexi_working: normalize_flexi_working,
      safeguarding_information_provided:,
      safeguarding_information:,
      further_details_provided:,
      further_details:,
      flexi_working_details_provided:,
    }
  end

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
    return if remove_html_tags(school_offer).present?

    errors.add(:school_offer, :blank, organisation: organisation_type)
  end

  def skills_and_experience_presence
    return if remove_html_tags(skills_and_experience).present?

    errors.add(:skills_and_experience, :blank)
  end

  def safeguarding_information_presence
    return if remove_html_tags(safeguarding_information).present?

    errors.add(:safeguarding_information, :blank)
  end

  def safeguarding_information_does_not_exceed_maximum_words
    errors.add(:safeguarding_information, :length) if number_of_words_exceeds_permitted_length?(100, safeguarding_information)
  end

  def further_details_presence
    return if remove_html_tags(further_details).present?

    errors.add(:further_details, :blank)
  end

  def flexi_working_presence
    return if remove_html_tags(flexi_working).present?

    errors.add(:flexi_working, :blank)
  end

  def about_school_presence
    return if about_school.present?

    errors.add(:about_school, :blank, organisation: organisation_type)
  end

  def job_advert_presence
    return if remove_html_tags(job_advert).present?

    errors.add(:job_advert, :blank)
  end

  def normalize_flexi_working
    stripped_value = remove_html_tags(flexi_working)&.strip

    self.flexi_working = stripped_value.present? ? flexi_working : nil
  end
end
