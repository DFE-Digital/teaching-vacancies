class SchoolForm < VacancyForm
  attr_accessor :organisation_id

  validates :organisation_id, presence: true

  def initialize(params = {})
    @organisation_id = params[:organisation_id]
    super
  end
end
