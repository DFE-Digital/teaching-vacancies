json.teaching_jobs do
  json.summary @stats
  json.last_updated_at Time.zone.now
end
