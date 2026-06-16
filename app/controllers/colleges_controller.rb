class CollegesController < ApplicationController
  def index
    @search_form = CollegeSearchForm.new(search_params)
    @college_search = Search::CollegeSearch.new(@search_form.to_h, scope: School.not_closed.colleges)
    @pagy, @colleges = pagy(@college_search.organisations.order(:name))
  end

  private

  def search_params
    params.fetch(:college_search_form, {}).permit(:name, :location, :radius, job_availability: [])
  end
end
