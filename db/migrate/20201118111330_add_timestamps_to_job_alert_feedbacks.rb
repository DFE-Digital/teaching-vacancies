class AddTimestampsToJobAlertFeedbacks < ActiveRecord::Migration[6.0]
  def change
    add_timestamps :job_alert_feedbacks, default: Time.new(2020, 10, 16)
    change_column_default :job_alert_feedbacks, :created_at, from: Time.new(2020, 10, 16), to: nil
    change_column_default :job_alert_feedbacks, :updated_at, from: Time.new(2020, 10, 16), to: nil
  end
end
