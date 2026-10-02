class CollegesController < ApplicationController
  def index
    @search_form = CollegeSearchForm.new(search_params)
    @college_search = Search::CollegeSearch.new(@search_form.to_h, scope: School.colleges.schools_visible_to_jobseekers)
    @wider_search_suggestions = Search::WiderSuggestionsBuilder.call(@college_search)
    @pagy, @colleges = pagy(@college_search.organisations.order(:name))
  end

  private

  # we accept params directly from the URL, not in a form scope
  def search_params
    params.permit(:name, :location, :radius, job_availability: [])
  end
end
