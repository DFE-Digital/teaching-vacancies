class Publishers::JobListing::AboutTheRoleForm < Publishers::JobListing::VacancyForm
  include ActiveModel::Attributes

  validates :ect_suitable, inclusion: { in: [true, false] }, if: -> { vacancy&.job_roles&.include?("teacher") && needs_qts_status }
  validate :skills_and_experience_presence
  validate :school_offer_presence
  validates :further_details_provided, inclusion: { in: [true, false] }
  validate :further_details_presence, if: -> { further_details_provided }
  validates :flexi_working_details_provided, inclusion: { in: [true, false] }
  validate :flexi_working_presence, if: -> { flexi_working_details_provided }
  validates :needs_qts_status, inclusion: { in: [true, false] }

  attribute :flexi_working_details_provided, :boolean
  attribute :needs_qts_status, :boolean
  attribute :ect_suitable, :boolean
  attribute :skills_and_experience
  attribute :school_offer
  attribute :flexi_working
  attribute :further_details_provided, :boolean
  attribute :further_details

  attr_accessor :organisation_type

  class << self
    def fields
      %i[flexi_working_details_provided
         needs_qts_status
         ect_suitable
         skills_and_experience
         school_offer
         flexi_working
         further_details_provided
         further_details]
    end

    def load_from_model(vacancy, current_publisher:) # rubocop:disable Lint/UnusedMethodArgument
      new(vacancy.slice(:flexi_working_details_provided, :skills_and_experience,
                        :school_offer, :flexi_working, :further_details_provided, :further_details)
                 .merge(ect_suitable: vacancy.ect_status.nil? ? nil : (vacancy.ect_suitable? || vacancy.suitable_for_non_teachers?),
                        needs_qts_status: vacancy.ect_status.nil? ? nil : (vacancy.ect_suitable? || vacancy.ect_unsuitable?)), vacancy)
    end

    def load_from_params(form_params, vacancy, current_publisher:)
      super(form_params.merge(organisation_type: organisation_type(vacancy)), vacancy, current_publisher: current_publisher)
    end

    private

    def organisation_type(vacancy)
      if vacancy.central_office?
        "trust"
      elsif vacancy.for_multiple_organisations?
        "schools"
      elsif vacancy.for_an_fe_college?
        "college"
      else
        "school"
      end
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

  def ect_status
    if needs_qts_status
      if ect_suitable
        :ect_suitable
      else
        :ect_unsuitable
      end
    else
      :suitable_for_non_teachers
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
