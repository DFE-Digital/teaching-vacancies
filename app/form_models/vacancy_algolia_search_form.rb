class VacancyAlgoliaSearchForm
  include ActiveModel::Model

  attr_accessor :keyword, :location, :radius, :jobs_sort, :location_category, :page

  def initialize(params = {})
    @keyword = params[:keyword]
    @location = params[:location] || params[:location_category]
    @radius = params[:radius] || 10
    @jobs_sort = params[:jobs_sort]
    @location_category = params[:location_category]
    @page = params[:page]
  end
end
