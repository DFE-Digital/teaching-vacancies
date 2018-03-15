module VacancyScraper::NorthEastSchools
  ROOT_URL = 'https://www.jobsinschoolsnortheast.com'.freeze
  SUBJECTS = Subject.pluck(:name).join('|')
end
