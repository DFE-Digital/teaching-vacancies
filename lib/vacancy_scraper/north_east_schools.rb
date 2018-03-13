module VacancyScraper::NorthEastSchools
  BASE_URL = 'https://www.jobsinschoolsnortheast.com'.freeze
  SUBJECTS = Subject.pluck(:name).join('|')
end
