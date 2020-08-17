class VacancyAlgoliaSearchForm
  include ActiveModel::Model

  attr_reader :keyword,
              :location, :location_category, :radius,
              :job_roles, :phases, :working_patterns,
              :jobs_sort, :page

  def initialize(params = {})
    @keyword = params[:keyword]

    @location = params[:location] || params[:location_category]
    @location_category = params[:location_category]
    @radius = params[:radius] || 10

    @job_roles = params[:job_roles]
    @phases = params[:phases]
    @working_patterns = params[:working_patterns]

    @jobs_sort = params[:jobs_sort]
    @page = params[:page]
  end

  def to_hash
    {
      keyword: @keyword,
      location: @location,
      location_category: @location_category,
      radius: @radius,
      job_roles: @job_roles,
      phases: @phases,
      working_patterns: @working_patterns,
      jobs_sort: @jobs_sort,
      page: @page
    }.delete_if { |k, v| v.blank? || (k.eql?(:radius) && @location.blank?) }
  end
end
