class Api::OrganisationsController < Api::ApplicationController
  before_action :verify_json_request, only: %i[index]
  before_action :check_valid_params, only: %i[index]

  MAX_RESULTS = 100

  def index
    suggestions = Search::SchoolSearch.new({ name: query }, scope: search_scope)
      .organisations.limit(MAX_RESULTS).pluck(:name)

    render json: { query:, suggestions: }
  end

  private

  def query
    params[:query]
  end

  def search_scope
    Organisation.visible_to_jobseekers.order(:name)
  end

  def check_valid_params
    return render(json: { error: "Missing query" }, status: :bad_request) if query.nil?
    return render(json: { error: "Insufficient query" }, status: :bad_request) if query.length < 3
  end
end
