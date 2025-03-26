class CreateVacancyAnalytics < ActiveRecord::Migration[7.2]
  def change
    create_table :vacancy_analytics, id: :uuid do |t|
      t.uuid :vacancy_id, null: false, index: true
      t.string :referrer_url, null: false
      t.date :date, null: false
      t.integer :visit_count, default: 0, null: false

      t.timestamps

      # Composite index to speed up querying and enforce uniqueness constraint
      t.index %i[vacancy_id referrer_url date], unique: true, name: "index_vacancy_referrer_stats_on_vacancy_referrer_and_date"
      # Index to speed up querying by date range
      t.index :date
    end
  end
end
