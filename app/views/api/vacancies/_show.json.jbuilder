json.set! '@context', 'http://schema.org'
json.set! '@type', 'JobPosting'

json.title vacancy.job_title
json.jobBenefits vacancy.benefits
json.datePosted vacancy.publish_on.to_time.iso8601
json.description vacancy.job_description

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

json.baseSalary do
  json.set! '@type', 'MonetaryAmount'
  json.currency 'GBP'
  json.value do
    json.set! '@type', 'QuantitativeValue'
    if vacancy.minimum_salary && vacancy.maximum_salary.blank?
      json.value vacancy.minimum_salary
    else
      json.minValue vacancy.minimum_salary
      json.maxValue vacancy.maximum_salary
    end
    json.unitText 'YEAR'
  end
end

json.hiringOrganization do
  json.set! '@type', 'School'
  json.name vacancy.school.name
  json.identifier vacancy.school.urn
end

json.validThrough vacancy.expires_on.to_time.iso8601
json.workHours vacancy.weekly_hours if vacancy.weekly_hours?
