class DropInvitationToApplies < ActiveRecord::Migration[7.0]
  def change
    drop_table :invitation_to_applies do |t|
      t.references :jobseeker, index: true, type: :uuid, null: false
      t.references :vacancy, index: true, type: :uuid, null: false
      t.references :invited_by, index: true, type: :uuid, null: false

      t.timestamps
    end
  end
end
