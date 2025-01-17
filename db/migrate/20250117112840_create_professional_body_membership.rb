class CreateProfessionalBodyMembership < ActiveRecord::Migration[7.2]
  def change
    create_table :professional_body_memberships, id: :uuid do |t|
      t.timestamps
      t.string :name
      t.string :membership_type
      t.string :membership_number
      t.string :date_membership_obtained
      t.boolean :exam_taken
      t.references :jobseeker_profile, type: :uuid, foreign_key: true
    end
  end
end
