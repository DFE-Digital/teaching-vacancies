class Publishers::VacancyFilterForm
  include ActiveModel::Model

  attr_reader :organisation_ids

  def initialize(params = {})
    @organisation_ids = params[:organisation_ids] || []
  end

  def to_hash
    {
      organisation_ids: @organisation_ids,
    }.delete_if { |_k, v| v.blank? }
  end
end
