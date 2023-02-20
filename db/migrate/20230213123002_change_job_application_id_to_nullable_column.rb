class ChangeJobApplicationIdToNullableColumn < ActiveRecord::Migration[7.0]
  def change
    change_column_null :employments, :job_application_id, true
  end
end
