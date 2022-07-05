class Publishers::JobListing::JobLocationForm < Publishers::JobListing::VacancyForm
  attr_accessor :readable_job_location, :organisation_ids, :status

  validates :organisation_ids, presence: true

  def self.fields
    %i[organisation_ids]
  end

  def initialize(params, vacancy)
    @organisation_ids = if params[:organisation_ids].is_a?(Array)
                          params[:organisation_ids].first
                        else
                          params[:organisation_ids]
                        end
    super
  end
end
