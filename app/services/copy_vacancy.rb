class CopyVacancy
  def initialize(proposed_vacancy:)
    @proposed_vacancy = proposed_vacancy
  end

  def call
    new_vacancy = @proposed_vacancy.deep_clone(include: :working_patterns)
    new_vacancy.job_title = @proposed_vacancy.job_title
    new_vacancy.starts_on = @proposed_vacancy.starts_on
    new_vacancy.ends_on = @proposed_vacancy.ends_on
    new_vacancy.expires_on = @proposed_vacancy.expires_on
    new_vacancy.publish_on = @proposed_vacancy.publish_on
    new_vacancy.status = :draft
    new_vacancy.save
    new_vacancy
  end
end
