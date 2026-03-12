module Backfills
  class VacancySearchableContent
    def self.call
      Vacancy.where(searchable_content: nil).find_each do |v|
        v.save!(touch: false, validate: false)
      end
    end
  end
end
