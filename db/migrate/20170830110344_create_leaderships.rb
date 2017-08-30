class CreateLeaderships < ActiveRecord::Migration[5.1]
  def change
    create_table :leaderships do |t|
      t.string :title, null: false
    end
  end
end
