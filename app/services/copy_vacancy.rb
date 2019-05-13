class CopyVacancy
  def initialize(proposed_vacancy:)
    @proposed_vacancy = proposed_vacancy
  end

  def call
    new_vacancy = @proposed_vacancy.dup
    new_vacancy.status = :draft
    new_vacancy.save
    new_vacancy
  end
end
