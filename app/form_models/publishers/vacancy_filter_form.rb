class Publishers::VacancyFilterForm
  include ActiveModel::Model

  attr_accessor :organisation_ids

  def initialize(params = {})
    @organisation_ids = params[:organisation_ids] || []
  end

  def to_hash
    {
      organisation_ids: @organisation_ids,
    }.compact_blank!
  end
end
