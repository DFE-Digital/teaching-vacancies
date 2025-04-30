namespace :db do
  desc "update draft vacancies type column"
  task update_draft_vacancy_type: :environment do
    Vacancy.draft.find_each do |v|
      if v.discarded?
        v.destroy!
      else
        v.update_column(:type, "DraftVacancy")
      end
    end
  end
end
