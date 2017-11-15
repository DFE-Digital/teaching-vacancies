json.array! vacancies.select(&:school_geolocation) do |vacancy|
  json.school vacancy.school.name
  json.job_title vacancy.job_title
  json.link vacancy_path(vacancy)
  json.lat vacancy.school.geolocation.x
  json.lng vacancy.school.geolocation.y
end