class CreatePayScales < ActiveRecord::Migration[5.1]
  def change
    create_table :pay_scales do |t|
      t.string :label, null: false
    end
  end
end
