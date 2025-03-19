class YyyymmddhhmmssCreateVacancyReferrerStats < ActiveRecord::Migration[6.1]
  def change
    create_table :vacancy_referrer_stats do |t|
      t.references :vacancy, null: false, foreign_key: true, index: true
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
