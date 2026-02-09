class Publishers::VacancyFilterForm
  include ActiveModel::Model

  attr_accessor :organisation_ids, :job_roles

  def initialize(params = {})
    @organisation_ids = params[:organisation_ids] || []
    @job_roles = params[:job_roles] || []
  end

  def to_hash
    {
      organisation_ids: @organisation_ids,
      job_roles: @job_roles,
    }.compact_blank!
  end
end
