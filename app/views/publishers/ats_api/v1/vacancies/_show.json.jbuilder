json.id vacancy.id
json.external_advert_url vacancy.external_advert_url
json.publish_on vacancy.publish_on
json.expires_at vacancy.expires_at
json.job_title vacancy.job_title
json.job_advert vacancy.job_advert
json.salary vacancy.salary
json.benefits_details vacancy.benefits_details
json.starts_on vacancy.start_date_type == "specific_date" ? vacancy.starts_on : vacancy.other_start_date_details
json.visa_sponsorship_available vacancy.visa_sponsorship_available
json.is_job_share vacancy.is_job_share
json.external_reference vacancy.external_reference
json.job_roles vacancy.job_roles
json.schools do
  json.school_urns(vacancy.organisations.filter_map(&:urn))
  json.trust_uid(vacancy.trust_uid)
end
json.ect_suitable vacancy.ect_status == "ect_suitable"
json.working_patterns vacancy.working_patterns
json.contract_type vacancy.contract_type
json.phases vacancy.phases
json.key_stages vacancy.key_stages
json.subjects vacancy.subjects
