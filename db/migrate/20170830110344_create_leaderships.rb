class CreateLeaderships < ActiveRecord::Migration[5.1]
  def change
    create_table :leaderships, id: :uuid do |t|
      t.string :title, null: false, unique: true
    end
  end
end
