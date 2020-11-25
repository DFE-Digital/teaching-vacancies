class PublishVacancy
  attr_accessor :current_organisation, :current_publisher, :vacancy

  def initialize(vacancy, current_publisher, current_organisation)
    @current_organisation = current_organisation
    @current_publisher = current_publisher
    @vacancy = vacancy
  end

  def call
    vacancy.publisher_organisation = current_organisation
    vacancy.publisher = current_publisher
    vacancy.status = :published
    vacancy.state = "edit_published"
    vacancy.save
  end
end
