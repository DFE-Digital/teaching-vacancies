class FixFeedbackStringSearchCriteria < ActiveRecord::Migration[6.1]
  def change
    Feedback.find_each do |f|
      next unless f.search_criteria.is_a?(String)

      f.update_columns(search_criteria: JSON.parse(f.search_criteria))
    rescue JSON::ParserError
      f.update_columns(search_criteria: nil)
    end
  end
end
