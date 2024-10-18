json.advertUrl vacancy.external_advert_url
json.publishOn vacancy.publish_on
json.expiresAt vacancy.expires_at
json.jobTitle vacancy.job_title
json.jobAdvert vacancy.skills_and_experience
json.salaryRange vacancy.salary
json.additionalAllowances vacancy.benefits_details
json.startDate vacancy.starts_on
json.contactNumber vacancy.contact_number
json.contactEmail vacancy.application_email unless vacancy.application_email.nil?
json.visaSponsorshipAvailable vacancy.visa_sponsorship_available
json.isJobShare vacancy.is_job_share
json.isParentalLeaveCover vacancy.is_parental_leave_cover unless vacancy.is_parental_leave_cover.nil?
json.jobRoles vacancy.job_roles
json.schoolUrns(vacancy.organisations.map { |x| x.urn.to_i })
json.ectSuitable vacancy.ect_status == "ect_suitable"
json.workingPatterns vacancy.working_patterns
json.contractType vacancy.contract_type
json.phase vacancy.phases.first
if vacancy.key_stages.any?
  json.keyStages vacancy.key_stages
end
json.subjects vacancy.subjects
