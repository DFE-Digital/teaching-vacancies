class VacancyPageView
  def initialize(vacancy)
    @vacancy = vacancy
  end

  def track
    @vacancy.page_view_counter.increment
  end

  def persist!
    @vacancy.total_pageviews = @vacancy.total_pageviews.to_i + @vacancy.page_view_counter.to_i
    @vacancy.total_pageviews_updated_at = Time.zone.now
    reset_counter if @vacancy.save
  end

  private

  def reset_counter
    @vacancy.page_view_counter.reset
  end
end
