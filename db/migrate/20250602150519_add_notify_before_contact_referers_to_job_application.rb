class AddNotifyBeforeContactReferersToJobApplication < ActiveRecord::Migration[7.2]
  # rubocop:disable Rails/ThreeStateBooleanColumn
  def change
    add_column :job_applications, :notify_before_contact_referers, :boolean
  end
  # rubocop:enable Rails/ThreeStateBooleanColumn
end
