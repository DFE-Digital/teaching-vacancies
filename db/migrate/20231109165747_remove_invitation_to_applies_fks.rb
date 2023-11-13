class RemoveInvitationToAppliesFks < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :invitation_to_applies, :jobseekers
    remove_foreign_key :invitation_to_applies, :vacancies
    remove_foreign_key :invitation_to_applies, :invited_by, to_table: :publishers
  end
end
