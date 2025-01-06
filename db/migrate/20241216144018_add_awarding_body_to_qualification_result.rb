class AddAwardingBodyToQualificationResult < ActiveRecord::Migration[7.2]
  def change
    add_column :qualification_results, :awarding_body, :string
  end
end
