class ConvertJobAlertFeedbacksSearchCriteriaToJson < ActiveRecord::Migration[6.0]
  def change
    # No op because the class JobAlertFeedback has been removed.

    # JobAlertFeedback.all.in_batches(of: 100).each_record do |feedback|
    #   feedback.update_columns(search_criteria: feedback.search_criteria.to_json)
    # end
  end
end
