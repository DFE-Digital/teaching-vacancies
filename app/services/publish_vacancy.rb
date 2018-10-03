class PublishVacancy
  def initialize(vacancy:)
    @vacancy = vacancy
  end

  def call
    return false unless @vacancy.valid?

    @vacancy.status = :published
    @vacancy.save
  end
end
