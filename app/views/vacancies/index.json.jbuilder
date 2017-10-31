json.vacancies @vacancies do |vacancy|
  json.partial! 'show.json.jbuilder', vacancy: vacancy
end
