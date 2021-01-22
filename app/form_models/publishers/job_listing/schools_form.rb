class Publishers::JobListing::SchoolsForm < Publishers::JobListing::VacancyForm
  attr_accessor :organisation_ids

  validates :organisation_ids, presence: true
  validate :more_than_one_school_present_multiple_schools, if: proc { |_v| organisation_ids.present? }

  def initialize(params = {})
    @organisation_ids = if params[:job_location] == "at_one_school" && params[:organisation_ids].is_a?(Array)
                          params[:organisation_ids].first
                        else
                          params[:organisation_ids]
                        end
    super
  end

  private

  def more_than_one_school_present_multiple_schools
    errors.add(:organisation_ids, I18n.t("schools_errors.organisation_ids.invalid")) if
      vacancy.job_location == "at_multiple_schools" && organisation_ids.count < 2
  end
end
