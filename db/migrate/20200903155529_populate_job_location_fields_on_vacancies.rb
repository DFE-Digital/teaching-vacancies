class PopulateJobLocationFieldsOnVacancies < ActiveRecord::Migration[6.0]
  def change
    Vacancy.where(job_location: nil).in_batches(of: 100).each_record do |vacancy|
      vacancy.update_columns(job_location: 'at_one_school')
    end

    Vacancy.where(readable_job_location: nil).in_batches(of: 100).each_record do |vacancy|
      vacancy.update_columns(readable_job_location: vacancy.parent_organisation_name)
    end
  end
end
