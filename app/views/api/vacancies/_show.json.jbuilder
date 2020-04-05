json.set! '@context', 'http://schema.org'
json.set! '@type', 'JobPosting'

json.title vacancy.job_title
json.salary vacancy.salary
json.jobBenefits vacancy.benefits
json.datePosted vacancy.publish_on.to_time.iso8601
json.description vacancy.job_summary

json.educationRequirements vacancy.education
json.qualifications vacancy.qualifications
json.experienceRequirements vacancy.experience

json.employmentType vacancy.working_patterns_for_job_schema

json.industry 'Education'
json.jobLocation do
  json.set! '@type', 'Place'
  json.address do
    json.set! '@type', 'PostalAddress'
    json.addressLocality vacancy.school.town
    json.addressRegion vacancy.school&.region&.name
    json.streetAddress vacancy.school.address
    json.postalCode vacancy.school.postcode
  end
end

json.url job_url(vacancy)

json.hiringOrganization do
  json.set! '@type', 'School'
  json.name vacancy.school.name
  json.identifier vacancy.school.urn
end

json.validThrough vacancy.expires_on.end_of_day.to_time.iso8601
