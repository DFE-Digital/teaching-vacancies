json.external_advert_url vacancy.external_advert_url
json.publish_on vacancy.publish_on
json.expires_at vacancy.expires_at
json.job_title vacancy.job_title
json.job_advert vacancy.job_advert
json.salary vacancy.salary
json.benefits_details vacancy.benefits_details
json.starts_on vacancy.starts_on if vacancy.starts_on.present?
json.visa_sponsorship_available vacancy.visa_sponsorship_available
json.is_job_share vacancy.is_job_share if vacancy.is_job_share.present?
json.external_reference vacancy.external_reference
json.job_roles vacancy.job_roles
json.schools do
  json.school_urns(vacancy.organisations.map(&:urn))
end
json.ect_suitable vacancy.ect_status == "ect_suitable"
json.working_patterns vacancy.working_patterns
json.contract_type vacancy.contract_type
json.phases vacancy.phases
if vacancy.key_stages.any?
  json.key_stages vacancy.key_stages
end
json.subjects vacancy.subjects if vacancy.subjects.any?
