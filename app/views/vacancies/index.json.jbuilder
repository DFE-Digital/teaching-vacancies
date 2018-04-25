json.vacancies @vacancies.decorated_collection do |vacancy|
  json.partial! 'show.json.jbuilder', vacancy: vacancy
end
