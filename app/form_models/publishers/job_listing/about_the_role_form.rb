class Publishers::JobListing::AboutTheRoleForm < Publishers::JobListing::VacancyForm
  validates :ect_status, inclusion: { in: Vacancy.ect_statuses.keys }, if: -> { vacancy&.job_role == "teacher" }
  validate :job_advert_presence, if: -> { vacancy.job_advert.present? }
  validate :about_school_presence, if: -> { vacancy.about_school.present? }
  validate :skills_and_experience_presence, unless: -> { vacancy.job_advert.present? }
  validate :skills_and_experience_does_not_exceed_maximum_words, unless: -> { vacancy.job_advert.present? }
  validate :school_offer_presence, unless: -> { vacancy.about_school.present? }
  validate :school_offer_does_not_exceed_maximum_words, unless: -> { vacancy.about_school.present? }
  validates :safeguarding_information_provided, inclusion: { in: [true, false, "true", "false"] }, unless: -> { vacancy.job_advert.present? || vacancy.about_school.present? }
  validate :safeguarding_information_presence, if: -> { safeguarding_information_provided == "true" }, unless: -> { vacancy.job_advert.present? || vacancy.about_school.present? }
  validate :safeguarding_information_does_not_exceed_maximum_words, if: -> { safeguarding_information_provided == "true" }, unless: -> { vacancy.job_advert.present? || vacancy.about_school.present? }
  validates :further_details_provided, inclusion: { in: [true, false, "true", "false"] }, unless: -> { vacancy.job_advert.present? || vacancy.about_school.present? }
  validate :further_details_presence, if: -> { further_details_provided == "true" }, unless: -> { vacancy.job_advert.present? || vacancy.about_school.present? }
  validate :further_details_does_not_exceed_maximum_words, if: -> { further_details_provided == "true" }, unless: -> { vacancy.job_advert.present? || vacancy.about_school.present? }

  def self.fields
    %i[
      job_advert
      about_school
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
    return if remove_html_tags(school_offer).present?

    errors.add(:school_offer, :blank, organisation: organisation_type)
  end

  def school_offer_does_not_exceed_maximum_words
    errors.add(:school_offer, :length, organisation: organisation_type.capitalize) if number_of_words_exceeds_permitted_length?(150, school_offer)
  end

  def skills_and_experience_presence
    return if remove_html_tags(skills_and_experience).present?

    errors.add(:skills_and_experience, :blank)
  end

  def skills_and_experience_does_not_exceed_maximum_words
    errors.add(:skills_and_experience, :length) if number_of_words_exceeds_permitted_length?(150, skills_and_experience)
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

  def further_details_does_not_exceed_maximum_words
    errors.add(:further_details, :length) if number_of_words_exceeds_permitted_length?(100, further_details)
  end

  def about_school_presence
    return if about_school.present?

    errors.add(:about_school, :blank, organisation: organisation_type)
  end

  def job_advert_presence
    return if remove_html_tags(job_advert).present?

    errors.add(:job_advert, :blank)
  end

  def remove_html_tags(field)
    regex = /<("[^"]*"|'[^']*'|[^'">])*>/

    field&.gsub(regex, "")
  end

  def number_of_words_exceeds_permitted_length?(number, attribute)
    remove_html_tags(attribute)&.split&.length&.>(number)
  end
end
