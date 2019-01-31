class CopyVacancy
  def initialize(original:, new:)
    @original = original
    @new = new
  end

  def call
    new_vacancy = @original.dup
    new_vacancy.job_title = @new.job_title
    new_vacancy.starts_on = @new.starts_on
    new_vacancy.ends_on = @new.ends_on
    new_vacancy.expires_on = @new.expires_on
    new_vacancy.publish_on = @new.publish_on
    new_vacancy.status = :draft
    new_vacancy.save
    new_vacancy
  end
end
