class ReindexVacanciesAfterChangingMaxSalaryType < ActiveRecord::Migration[5.2]
  def change
    # noop
    # This method used to run an ElasticSearch task.
    # We no longer use ElasticSearch.
  end
end
