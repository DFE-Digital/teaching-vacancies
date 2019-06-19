class CopyVacancy
  def initialize(vacancy)
    @vacancy = vacancy
  end

  def call
    new_vacancy = @vacancy.dup
    new_vacancy.status = :draft
    new_vacancy.weekly_pageviews = 0
    new_vacancy.total_pageviews = 0
    new_vacancy.total_get_more_info_clicks = 0
    new_vacancy.save
    new_vacancy
  end
end
