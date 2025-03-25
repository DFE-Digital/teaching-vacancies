class CreateVacancyAnalytics < ActiveRecord::Migration[7.2]
  def change
    create_table :vacancy_analytics, id: :uuid do |t|
      t.uuid :vacancy_id, null: false
      t.integer :view_count, default: 0
      t.jsonb :referrer_counts, default: {}

      t.timestamps
    end
  end
end
