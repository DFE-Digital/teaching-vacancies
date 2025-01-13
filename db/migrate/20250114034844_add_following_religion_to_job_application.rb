class AddFollowingReligionToJobApplication < ActiveRecord::Migration[7.1]
  def change
    # we might need to know if this boolean is unknown - so it needs to be tri-state
    # rubocop:disable Rails/ThreeStateBooleanColumn
    add_column :job_applications, :following_religion, :boolean
    # rubocop:enable Rails/ThreeStateBooleanColumn
    add_column :job_applications, :religious_reference_type, :integer
    add_column :job_applications, :faith_ciphertext, :string
    add_column :job_applications, :place_of_worship_ciphertext, :string
    add_column :job_applications, :religious_referee_name_ciphertext, :string
    add_column :job_applications, :religious_referee_address_ciphertext, :string
    add_column :job_applications, :religious_referee_role_ciphertext, :string
    add_column :job_applications, :religious_referee_email_ciphertext, :string
    add_column :job_applications, :religious_referee_phone_ciphertext, :string
    add_column :job_applications, :baptism_address_ciphertext, :string
    # This is a date, but lockbox needs all encrypted storage to be strings
    add_column :job_applications, :baptism_date_ciphertext, :string
  end
end
