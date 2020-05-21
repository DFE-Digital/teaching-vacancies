class PublishVacancy
  def initialize(vacancy, current_user)
    @vacancy = vacancy
    @current_user = current_user
  end

  def call
    return false unless @vacancy.valid?

    @vacancy.publisher_user_id = @current_user.id
    @vacancy.status = :published
    @vacancy.state = 'edit_published'
    @vacancy.save
  end
end
