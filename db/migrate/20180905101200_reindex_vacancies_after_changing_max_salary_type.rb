class ReindexVacanciesAfterChangingMaxSalaryType < ActiveRecord::Migration[5.2]
  def change
    Rake::Task['elasticsearch:vacancies:index'].invoke
  end
end
