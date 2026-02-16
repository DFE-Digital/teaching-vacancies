desc "Backfill vacancy searchable content"
task backfill_vacancy_searchable_content: :environment do
  Vacancy.where(searchable_content: nil).find_each do |v|
    v.save!(touch: false, validate: false)
  end
end
