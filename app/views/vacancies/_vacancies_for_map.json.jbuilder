json.array! vacancies.select(&:school_or_school_group_geolocation) do |vacancy|
  json.school vacancy.school.name
  json.job_title vacancy.job_title
  json.link job_path(vacancy)
  json.lat vacancy.school.geolocation.x
  json.lng vacancy.school.geolocation.y
end
