json.array! vacancies.select do |vacancy|
  json.school vacancy.school.name
  json.job_title vacancy.job_title
  json.link job_path(vacancy)
  json.lat vacancy.school.latitude
  json.lng vacancy.school.longitude
end
