class Publishers::CandidateMessagesSearchForm
  include ActiveModel::Model

  attr_reader :keyword

  def initialize(params = {})
    @keyword = params[:keyword].to_s.strip if params[:keyword].present?
  end

  def to_hash
    {
      keyword: @keyword,
    }.compact_blank
  end

  def active_criteria?
    to_hash.any?
  end

  def clear_filters_params
    {}
  end
end
