class RenameSexEducationSubjectToPshe < ActiveRecord::Migration[7.0]
  class JobPreferences < ActiveRecord::Base; end
  class Vacancy < ActiveRecord::Base; end

  def up
    rename_pshe(JobPreferences)
    rename_pshe(Vacancy)
    Subscription.update_all("search_criteria = replace(search_criteria::text, 'Relationships and sex education', 'PSHE')::jsonb")
  end

  private

  def rename_pshe(model, column: :subjects)
    model
      .where("? = ANY(#{column})", "Relationships and sex education")
      .update_all("#{column} = array_replace(#{column}, 'Relationships and sex education', 'PSHE')")
  end
end
