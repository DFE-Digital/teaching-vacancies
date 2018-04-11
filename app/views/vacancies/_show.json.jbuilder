json.set! '@context', 'http://schema.org'
json.set! '@type', 'JobPosting'

json.title vacancy.job_title
json.jobBenefits vacancy.benefits
json.datePosted vacancy.publish_on.to_s(:db)
json.description vacancy.job_description

json.educationRequirements vacancy.education
json.qualifications vacancy.qualifications
json.experienceRequirements vacancy.experience

json.employmentType vacancy.working_pattern&.titleize

json.industry 'Education'
json.jobLocation do
  json.set! '@type', 'Place'
  json.address do
    json.set! '@type', 'PostalAddress'
    json.addressLocality vacancy.school.town
    json.addressRegion vacancy.school.county
    json.streetAddress vacancy.school.address
    json.postalCode vacancy.school.postcode
  end
end

json.url vacancy_url(vacancy)

json.baseSalary do
  json.set! '@type', 'MonetaryAmount'
  json.minValue vacancy.minimum_salary
  json.maxValue vacancy.maximum_salary
  json.currency 'GBP'
  json.unitText 'YEAR'
end

json.hiringOrganization do
  json.set! '@type', 'Organization'
  json.name vacancy.school.name
end

json.validThrough vacancy.expires_on.to_s(:db)
json.workHours vacancy.weekly_hours
