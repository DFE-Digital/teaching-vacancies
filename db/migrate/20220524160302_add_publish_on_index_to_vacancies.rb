class AddPublishOnIndexToVacancies < ActiveRecord::Migration[6.1]
  def change
    add_index :vacancies, :publish_on
  end
end
