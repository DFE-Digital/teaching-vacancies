class VacancyPageView
  def initialize(vacancy)
    @vacancy = vacancy
  end

  def track
    @vacancy.page_view_counter.increment
  end
end
