class WorkHistoryErrorSummaryPresenter
  def initialize(error_messages, unexplained_employment_gaps)
    @error_messages = error_messages
    @unexplained_employment_gaps = unexplained_employment_gaps
  end

  def formatted_error_messages
    @error_messages.flat_map do |attribute, messages|
      if attribute == :unexplained_employment_gaps
        messages.each_with_index.map do |message, index|
          gap = @unexplained_employment_gaps.values[index]
          gap_id = "gap-#{gap[:started_on].strftime('%Y%m%d')}-#{gap[:ended_on].strftime('%Y%m%d')}"
          [attribute, message, "##{gap_id}"]
        end
      else
        [[attribute, messages.first]]
      end
    end
  end
end
