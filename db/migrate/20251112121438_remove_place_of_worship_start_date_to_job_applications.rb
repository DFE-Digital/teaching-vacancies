class RemovePlaceOfWorshipStartDateToJobApplications < ActiveRecord::Migration[8.0]
  def change
    safety_assured { remove_column :job_applications, :place_of_worship_start_date, :date }
  end
end
