class AddQtsDetailsToProfile < ActiveRecord::Migration[7.2]
  def change
    add_column :jobseeker_profiles, :qualified_teacher_status_details, :text
  end
end
