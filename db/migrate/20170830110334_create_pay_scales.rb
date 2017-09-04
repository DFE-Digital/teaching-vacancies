class CreatePayScales < ActiveRecord::Migration[5.1]
  def change
    create_table :pay_scales, id: :uuid do |t|
      t.string :label, null: false, unique: true
    end
  end
end
