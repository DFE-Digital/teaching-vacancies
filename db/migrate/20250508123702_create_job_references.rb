class CreateJobReferences < ActiveRecord::Migration[7.2]
  RATINGS = %i[punctuality
               working_relationships
               customer_care
               adapt_to_change
               deal_with_conflict
               prioritise_workload
               team_working
               communication
               problem_solving
               general_attitude
               technical_competence
               leadership].freeze

  REFEREE_DETAILS = %i[name job_title phone_number email organisation].freeze

  REFERENCE_INFO_FIELDS = %i[under_investigation warnings allegations not_fit_to_practice able_to_undertake_role].freeze

  # rubocop:disable Metrics/MethodLength
  def change
    create_table :job_references, id: :uuid do |t|
      t.references :reference, foreign_key: true, index: { unique: true }, type: :uuid, null: false

      t.boolean :complete, null: false, default: false
      # default to true so that we can bail when it is set to false by user
      t.boolean :can_give_reference, null: false, default: true
      t.boolean :is_reference_sharable, null: false, default: false

      t.text :how_do_you_know_the_candidate
      # an encrypted date
      t.string :employment_start_date_ciphertext
      t.boolean :currently_employed, null: false, default: false
      t.text :reason_for_leaving
      t.boolean :would_reemploy_current, null: false, default: false
      t.text :would_reemploy_current_reason
      t.boolean :would_reemploy_any, null: false, default: false
      t.text :would_reemploy_any_reason

      RATINGS.each do |field|
        t.string "#{field}_ciphertext"
      end

      REFEREE_DETAILS.each do |field|
        t.string field
      end

      REFERENCE_INFO_FIELDS.each do |field|
        t.string "#{field}_ciphertext"
      end

      t.timestamps
    end

    create_table :reference_requests, id: :uuid do |t|
      t.references :reference, foreign_key: true, index: { unique: true }, type: :uuid, null: false

      t.uuid :token, null: false
      t.integer :status, null: false
      t.boolean :marked_as_complete, null: false, default: false

      t.timestamps
    end
  end
  # rubocop:enable Metrics/MethodLength
end
