json.advertUrl vacancy.external_advert_url
json.publishOn vacancy.publish_on
json.expiresAt vacancy.expires_at
json.jobTitle vacancy.job_title
json.jobAdvert vacancy.skills_and_experience
json.salaryRange vacancy.salary
json.additionalAllowances vacancy.benefits_details
json.jobRoles vacancy.job_roles
json.schoolUrns vacancy.organisations.map(&:urn).map(&:to_i)
json.ectSuitable vacancy.ect_status == "ect_suitable"
json.workingPatterns vacancy.working_patterns
json.contractType vacancy.contract_type
json.phase vacancy.phases.first
if vacancy.key_stages.any?
  json.keyStages vacancy.key_stages
end
json.subjects vacancy.subjects
# json.datePosted vacancy.publish_on.to_time.iso8601
# json.description vacancy.skills_and_experience.present? ? vacancy.skills_and_experience : vacancy.job_advert
# json.occupationalCategory vacancy.job_roles.first
# json.directApply vacancy.enable_job_applications

# json.employmentType vacancy.working_patterns_for_job_schema

# json.industry "Education"
# json.jobLocation do
#   json.set! "@type", "Place"
#   json.address do
#     json.set! "@type", "PostalAddress"
#     json.addressLocality vacancy.organisation&.town
#     json.addressRegion vacancy.organisation&.region
#     json.streetAddress vacancy.organisation&.address
#     json.postalCode vacancy.organisation&.postcode
#     json.addressCountry "GB"
#   end
# end

# json.url job_url(vacancy)

# json.hiringOrganization do
#   json.set! "@type", "Organization"
#   json.name vacancy.organisation&.name
#   json.identifier vacancy.organisation&.urn || vacancy.organisation&.uid
#   json.description vacancy.about_school
# end

# json.validThrough vacancy.expires_at.iso8601
