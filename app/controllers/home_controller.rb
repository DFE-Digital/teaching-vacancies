class HomeController < ApplicationController
  def index
    @jobs_search_form = VacancyAlgoliaSearchForm.new
    @vacancy_facets = VacancyFacets.new
    @job_roles_facets = @vacancy_facets.get(:job_roles)
    @subjects_facets = @vacancy_facets.get(:subjects)
    @cities_facets = @vacancy_facets.get(:cities)
    @counties_facets = @vacancy_facets.get(:counties)
  end

private

  def set_headers
    response.set_header("X-Robots-Tag", "index, nofollow")
  end
end
