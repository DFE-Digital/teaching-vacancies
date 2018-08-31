json.teaching_jobs do
  json.summary @audit_summary
  json.last_updated_at Time.zone.now
end
