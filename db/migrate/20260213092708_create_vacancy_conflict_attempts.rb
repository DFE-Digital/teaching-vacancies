class CreateVacancyConflictAttempts < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      create_table :vacancy_conflict_attempts, id: :uuid do |t|
        t.references :publisher_ats_api_client, null: false, type: :uuid, index: false, foreign_key: true
        t.references :conflicting_vacancy, null: false, type: :uuid, foreign_key: { to_table: :vacancies }
        t.integer :attempts_count, null: false, default: 1
        t.string :conflict_type, null: false
        t.datetime :first_attempted_at, null: false
        t.datetime :last_attempted_at, null: false

        t.timestamps
      end

      add_index :vacancy_conflict_attempts,
                %i[publisher_ats_api_client_id conflicting_vacancy_id],
                unique: true,
                name: "idx_conflict_attempts_on_client_and_vacancy"

      add_index :vacancy_conflict_attempts,
                %i[publisher_ats_api_client_id last_attempted_at],
                name: "idx_conflict_attempts_on_client_and_last_attempt"
    end
  end
end
