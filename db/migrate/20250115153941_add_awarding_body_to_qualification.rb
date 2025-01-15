class AddAwardingBodyToQualification < ActiveRecord::Migration[7.2]
  def change
    add_column :qualifications, :awarding_body, :string
  end
end
