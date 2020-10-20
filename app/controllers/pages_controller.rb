class PagesController < ApplicationController
  include HighVoltage::StaticPage

  def home
    @jobs_search_form = VacancyAlgoliaSearchForm.new
    @vacancy_facets = VacancyFacets.new
    @job_roles_facets = @vacancy_facets.get(:job_roles)
    @subjects_facets = @vacancy_facets.get(:subjects)
    @cities_facets = @vacancy_facets.get(:cities)
    @counties_facets = @vacancy_facets.get(:counties)
  end

  def invalid_page
    redirect_to '/404'
  end

  def set_headers
    return super if root_path? || page_path.include?('user-not-authorised') || page_path.include?('home')

    response.set_header('X-Robots-Tag', 'index, nofollow')
  end

  def root_path?
    request.path == root_path
  end
end
