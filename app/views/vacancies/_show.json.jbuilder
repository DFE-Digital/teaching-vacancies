json.set! '@context', 'http://schema.org'
json.set! '@type', 'JobPosting'
json.jobBenefits vacancy.benefits
json.datePosted vacancy.publish_on.to_s(:db)
json.description vacancy.headline
json.educationRequirements vacancy.education
json.employmentType vacancy.working_pattern&.titleize
json.experienceRequirements vacancy.essential_requirements
json.industry 'Education'
json.jobLocation do
  json.set! '@type', 'Place'
  json.address do
    json.set! '@type', 'PostalAddress'
    json.addressLocality vacancy.school.town
    json.addressRegion vacancy.school.county
    json.address vacancy.school.address
    json.postalCode vacancy.school.postcode
  end
end
json.responsibilities vacancy.job_description

json.title vacancy.job_title
json.url vacancy_url(vacancy)

json.baseSalary do
  json.set! '@type', 'MonetaryAmount'
  json.minValue vacancy.minimum_salary
  json.maxValue vacancy.maximum_salary
  json.currency 'GBP'
end

json.hiringOrganization do
  json.set! '@type', 'Organization'
  json.name vacancy.school.name
end

json.validThrough vacancy.expires_on.to_s(:db)
json.workHours vacancy.weekly_hours
