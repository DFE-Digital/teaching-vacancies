class PublishVacancy
  attr_accessor :current_organisation, :current_user, :vacancy

  def initialize(vacancy, current_user, current_organisation)
    @current_organisation = current_organisation
    @current_user = current_user
    @vacancy = vacancy
  end

  def call
    return false unless vacancy.valid?

    vacancy.publisher_organisation = current_organisation
    vacancy.publisher_user = current_user
    vacancy.status = :published
    vacancy.state = "edit_published"
    vacancy.save
  end
end
