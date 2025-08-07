class CreateSelfDisclosures < ActiveRecord::Migration[7.2]
  # rubocop:disable Metrics/MethodLength
  def change
    create_table :self_disclosure_requests, id: :uuid do |t|
      t.references :job_application, null: false, foreign_key: true, index: { unique: true }, type: :uuid
      t.integer :status

      t.timestamps
    end

    create_table :self_disclosures, id: :uuid do |t|
      t.string :name_ciphertext
      t.string :previous_names_ciphertext
      t.string :address_line_1_ciphertext
      t.string :address_line_2_ciphertext
      t.string :city_ciphertext
      t.string :country_ciphertext
      t.string :postcode_ciphertext
      t.string :phone_number_ciphertext
      t.string :date_of_birth_ciphertext
      t.string :has_unspent_convictions_ciphertext
      t.string :has_spent_convictions_ciphertext
      t.string :is_barred_ciphertext
      t.string :has_been_referred_ciphertext
      t.string :is_known_to_children_services_ciphertext
      t.string :has_been_dismissed_ciphertext
      t.string :has_been_disciplined_ciphertext
      t.string :has_been_disciplined_by_regulatory_body_ciphertext
      t.string :agreed_for_processing_ciphertext
      t.string :agreed_for_criminal_record_ciphertext
      t.string :agreed_for_organisation_update_ciphertext
      t.string :agreed_for_information_sharing_ciphertext
      t.references :self_disclosure_request, null: false, foreign_key: true, index: { unique: true }, type: :uuid

      t.timestamps
    end
  end
  # rubocop:enable Metrics/MethodLength
end
