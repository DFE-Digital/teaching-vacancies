class CreateTransactionAuditors < ActiveRecord::Migration[5.1]
  def change
    create_table :transaction_auditors, id: :uuid do |t|
      t.string :task
      t.boolean :success
      t.date :date

      t.timestamps
    end

    add_index :transaction_auditors, [:task, :date], unique: true
  end
end
