class CollegesController < ApplicationController
  def index
    @search_form = CollegeSearchForm.new(search_params)
    @college_search = Search::CollegeSearch.new(@search_form.to_h, scope: School.kept.colleges.visible_to_jobseekers)
    @pagy, @colleges = pagy(@college_search.organisations.order(:name))
  end

  private

  def search_params
    params.fetch(:college_search_form, {}).permit(:name, :location, :radius, job_availability: [])
  end
end
