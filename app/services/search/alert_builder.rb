class Search::AlertBuilder < Search::SearchBuilder
  MAXIMUM_SUBSCRIPTION_RESULTS = 500

  def initialize(params)
    super(params)
    @keyword ||= build_subscription_keyword
  end

  private

  def build_subscription_keyword
    [params[:subject], params[:job_title]].reject(&:blank?).join(" ")
  end

  def search_params
    super.except(:page).merge(
      hits_per_page: MAXIMUM_SUBSCRIPTION_RESULTS,
      typo_tolerance: false,
    )
  end
end
