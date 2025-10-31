class AddPlaceOfWorshipStartDateToJobApplications < ActiveRecord::Migration[8.0]
  def change
    add_column :job_applications, :place_of_worship_start_date, :date
  end
end
