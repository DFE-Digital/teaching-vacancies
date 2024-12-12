class WorkHistoryErrorSummaryPresenter
  WORK_HISTORY_FIELD = "#jobseekers-job-application-employment-history-form-base-field-error".freeze

  def initialize(error_messages)
    @error_messages = error_messages
  end

  def formatted_error_messages
    @error_messages.flat_map do |attribute, messages|
      if attribute == :base
        messages.map { |message| [attribute, message, WORK_HISTORY_FIELD] }
      else
        [[attribute, messages.first]]
      end
    end
  end
end
