json.set! '@context', 'http://schema.org'
json.set! '@type', 'JobPosting'

json.title vacancy.job_title
json.salary vacancy.salary
json.jobBenefits vacancy.benefits
json.datePosted vacancy.publish_on.to_time.iso8601
json.description vacancy.job_summary
json.occupationalCategory vacancy.job_roles&.join(', ')

json.educationRequirements vacancy.education
json.qualifications vacancy.qualifications
json.experienceRequirements vacancy.experience

json.employmentType vacancy.working_patterns_for_job_schema

json.industry 'Education'
json.jobLocation do
  json.set! '@type', 'Place'
  json.address do
    json.set! '@type', 'PostalAddress'
    json.addressLocality vacancy.organisation&.town
    json.addressRegion (vacancy.organisation&.region&.name if vacancy.organisation.is_a?(School))
    json.streetAddress vacancy.organisation&.address
    json.postalCode vacancy.organisation&.postcode
  end
end

json.url job_url(vacancy)

json.hiringOrganization do
  json.set! '@type', 'School'
  json.name vacancy.organisation&.name
  json.identifier (vacancy.organisation&.urn || vacancy.organisation&.uid)
  json.description vacancy.about_school
end

json.validThrough vacancy.expires_on.end_of_day.to_time.iso8601
