class CreateVacancyTemplates < ActiveRecord::Migration[8.0]
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/BlockLength
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Rails/ThreeStateBooleanColumn
  def change
    create_table :vacancy_templates, id: :uuid do |t|
      t.references :organisation, type: :uuid, null: false, foreign_key: true

      t.string :name, null: false
      t.timestamps
      t.integer :job_roles, array: true
      t.integer :phases, array: true
      t.integer :key_stages, array: true
      t.string :subjects, array: true

      t.integer :contract_type
      t.string :fixed_term_contract_duration
      t.boolean :is_parental_leave_cover
      t.integer :working_patterns, array: true
      t.text :working_patterns_details
      t.boolean :is_job_share

      t.string :actual_salary
      t.string :salary
      t.string :pay_scale
      t.string :hourly_rate
      t.boolean :benefits
      t.text :benefits_details

      t.integer :ect_status
      t.string :skills_and_experience
      t.string :school_offer
      t.boolean :flexi_working_details_provided
      t.string :flexi_working
      t.boolean :further_details_provided
      t.string :further_details
      t.boolean :school_visits
      t.boolean :visa_sponsorship_available

      t.boolean :enable_job_applications
      t.integer :receive_applications
      t.integer :religion_type
      t.boolean :anonymise_applications
    end
  end
  # rubocop:enable Rails/ThreeStateBooleanColumn
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/BlockLength
  # rubocop:enable Metrics/AbcSize
end
