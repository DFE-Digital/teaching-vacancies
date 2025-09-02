class Api::OrganisationsController < Api::ApplicationController
  before_action :verify_json_request, only: %i[index]
  before_action :check_valid_params, only: %i[index]

  MAX_RESULTS = 100

  def index
    suggestions = Search::SchoolSearch.new({ name: query })
      .organisations.order(:name).limit(MAX_RESULTS).map { |s| "#{s.name} (#{s.postcode})" }

    render json: { query:, suggestions: }
  end

  private

  def query
    params[:query]
  end

  def check_valid_params
    return render(json: { error: "Missing query" }, status: :bad_request) if query.nil?

    render(json: { error: "Insufficient query" }, status: :bad_request) if query.length < 3
  end
end
