class AddFieldsToEqualOpportunitiesReport < ActiveRecord::Migration[6.1]
  def change
    add_column :equal_opportunities_reports, :age_under_twenty_five, :integer, default: 0, null: false
    add_column :equal_opportunities_reports, :age_twenty_five_to_twenty_nine, :integer, default: 0, null: false
    add_column :equal_opportunities_reports, :age_prefer_not_to_say, :integer, default: 0, null: false
    add_column :equal_opportunities_reports, :age_thirty_to_thirty_nine, :integer, default: 0, null: false
    add_column :equal_opportunities_reports, :age_forty_to_forty_nine, :integer, default: 0, null: false
    add_column :equal_opportunities_reports, :age_fifty_to_fifty_nine, :integer, default: 0, null: false
    add_column :equal_opportunities_reports, :age_sixty_and_over, :integer, default: 0, null: false
  end
end
