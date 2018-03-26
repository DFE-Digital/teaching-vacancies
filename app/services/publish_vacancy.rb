class PublishVacancy
  def initialize(vacancy:)
    @vacancy = vacancy
  end

  def call
    @vacancy.update_attribute(:status, :published)
  end
end
