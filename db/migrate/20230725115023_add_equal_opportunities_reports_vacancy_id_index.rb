class AddEqualOpportunitiesReportsVacancyIdIndex < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :equal_opportunities_reports, ["vacancy_id"], name: :index_equal_opportunities_reports_vacancy_id, unique: true, algorithm: :concurrently
    remove_index :equal_opportunities_reports, name: :index_equal_opportunities_reports_on_vacancy_id, algorithm: :concurrently
  end
end
