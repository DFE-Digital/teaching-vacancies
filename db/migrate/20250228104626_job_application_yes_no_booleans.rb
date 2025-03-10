class JobApplicationYesNoBooleans < ActiveRecord::Migration[7.2]
  # rubocop:disable Rails/ThreeStateBooleanColumn
  def change
    # all these columns are optional (as the application is saved along the journey) so can be null
    %i[is_statutory_induction_complete is_support_needed has_close_relationships has_right_to_work_in_uk has_safeguarding_issue].each do |column_name|
      add_column :job_applications, column_name, :boolean
    end

    # This is just being renamed
    add_column :personal_details, :has_right_to_work_in_uk, :boolean
    add_column :jobseeker_profiles, :is_statutory_induction_complete, :boolean
  end
  # rubocop:enable Rails/ThreeStateBooleanColumn
end
