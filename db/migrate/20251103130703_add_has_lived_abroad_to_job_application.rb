class AddHasLivedAbroadToJobApplication < ActiveRecord::Migration[8.0]
  # rubocop:disable Rails/ThreeStateBooleanColumn
  def change
    add_column :job_applications, :has_lived_abroad, :boolean
    add_column :job_applications, :life_abroad_details_ciphertext, :text
  end
  # rubocop:enable Rails/ThreeStateBooleanColumn
end
