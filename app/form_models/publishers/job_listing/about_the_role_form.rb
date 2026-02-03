class Publishers::JobListing::AboutTheRoleForm < Publishers::JobListing::VacancyForm
  include ActiveModel::Attributes

  validates :ect_status, inclusion: { in: Vacancy.ect_statuses.keys }, if: -> { vacancy&.job_roles&.include?("teacher") }
  validate :skills_and_experience_presence
  validate :school_offer_presence
  validates :further_details_provided, inclusion: { in: [true, false] }
  validate :further_details_presence, if: -> { further_details_provided }
  validates :flexi_working_details_provided, inclusion: { in: [true, false] }
  validate :flexi_working_presence, if: -> { flexi_working_details_provided }

  attribute :flexi_working_details_provided, :boolean
  attribute :ect_status
  attribute :skills_and_experience
  attribute :school_offer
  attribute :flexi_working
  attribute :further_details_provided, :boolean
  attribute :further_details

  class << self
    def fields
      %i[flexi_working_details_provided
         ect_status
         skills_and_experience
         school_offer
         flexi_working
         further_details_provided
         further_details]
    end
  end

  def params_to_save
    {
      ect_status:,
      skills_and_experience:,
      school_offer:,
      flexi_working: normalize_flexi_working,
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

  def further_details_presence
    return if remove_html_tags(further_details).present?

    errors.add(:further_details, :blank)
  end

  def flexi_working_presence
    return if remove_html_tags(flexi_working).present?

    errors.add(:flexi_working, :blank)
  end

  def normalize_flexi_working
    stripped_value = remove_html_tags(flexi_working)&.strip

    self.flexi_working = stripped_value.present? ? flexi_working : nil
  end
end
