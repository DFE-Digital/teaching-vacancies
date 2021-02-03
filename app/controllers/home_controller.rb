class HomeController < ApplicationController
  def index
    @jobs_search_form = Jobseekers::SearchForm.new
    @vacancy_facets = VacancyFacets.new
  end

  private

  def set_headers
    response.set_header("X-Robots-Tag", "index, nofollow")
  end
end
