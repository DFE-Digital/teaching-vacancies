class AddFollowingReligionToJobApplication < ActiveRecord::Migration[7.1]
  def change
    add_column :job_applications, :following_religion, :boolean, null: false, default: false
    add_column :job_applications, :religious_reference_type, :integer
    add_column :job_applications, :faith, :string
    add_column :job_applications, :place_of_worship, :string
    add_column :job_applications, :religious_referee_name, :string
    add_column :job_applications, :religious_referee_address, :string
    add_column :job_applications, :religious_referee_role, :string
    add_column :job_applications, :religious_referee_email, :string
    add_column :job_applications, :religious_referee_phone, :string
    add_column :job_applications, :baptism_address, :string
    add_column :job_applications, :baptism_date, :date
  end
end
