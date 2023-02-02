class ChangeQualificationJobApplicationIdToNullableColumn < ActiveRecord::Migration[7.0]
  def change
    change_column_null :qualifications, :job_application_id, true
  end
end
