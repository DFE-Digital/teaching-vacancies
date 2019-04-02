class VacancyGetMoreInfoClick < Counter
  @redis_counter_name = :get_more_info_counter
  @persisted_column = :total_get_more_info_clicks

  def initialize(vacancy)
    @model = vacancy
  end
end
