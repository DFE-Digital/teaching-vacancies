class CopyVacancy
  def initialize(vacancy)
    @vacancy = vacancy
  end

  def call
    new_vacancy = @vacancy.dup
    new_vacancy.status = :draft
    new_vacancy.save
    new_vacancy
  end
end
