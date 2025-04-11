class CreateVacancyAnalytics < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    create_table :vacancy_analytics, id: :uuid do |t|
      t.references :vacancy, null: false, foreign_key: true, type: :uuid, index: { unique: true }
      t.jsonb :referrer_counts, null: false, default: {}

      t.timestamps
    end

    add_index :vacancy_analytics, :referrer_counts, using: :gin, algorithm: :concurrently
  end
end
