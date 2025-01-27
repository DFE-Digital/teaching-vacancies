class AddProfessionalBodyMembershipSectionCompletedToJobApplications < ActiveRecord::Migration[7.2]
  # rubocop:disable Rails/ThreeStateBooleanColumn
  def change
    add_column :job_applications, :professional_body_membership_section_completed, :boolean
  end
  # rubocop:enable Rails/ThreeStateBooleanColumn
end
