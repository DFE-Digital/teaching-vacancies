class Publishers::VacancyFilterForm
  include ActiveModel::Model

  attr_accessor :organisation_ids, :job_roles

  def initialize(organisation_ids: [], job_roles: [])
    @organisation_ids = organisation_ids
    @job_roles = job_roles
  end

  def to_hash
    {
      organisation_ids: @organisation_ids,
      job_roles: @job_roles,
    }.compact_blank!
  end
end
