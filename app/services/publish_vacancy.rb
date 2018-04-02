class PublishVacancy
  def initialize(vacancy:)
    @vacancy = vacancy
  end

  def call
    @vacancy.status = :published
    @vacancy.save
  end
end
