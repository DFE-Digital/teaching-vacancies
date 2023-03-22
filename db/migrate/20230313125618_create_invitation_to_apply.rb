class CreateInvitationToApply < ActiveRecord::Migration[7.0]
  def change
    create_table :invitation_to_applies, id: :uuid do |t|
      t.references :jobseeker, index: true, foregin_key: true, type: :uuid
      t.references :vacancy, index: true, foreign_key: true, type: :uuid
      t.references :invited_by, index: true, foreign_key: { to_table: :publishers }, type: :uuid

      t.timestamps
    end
  end
end
