json.set! "@context", "http://schema.org"
json.set! "@type", "JobPosting"

json.title vacancy.job_title
# not supported by Google https://developers.google.com/search/docs/appearance/structured-data/job-posting
json.jobBenefits vacancy.benefits_details
json.datePosted vacancy.publish_on.iso8601
json.description vacancy.skills_and_experience.present? ? vacancy.skills_and_experience : vacancy.job_advert
# not supported by Google https://developers.google.com/search/docs/appearance/structured-data/job-posting
json.occupationalCategory vacancy.job_roles.first
json.directApply true

json.employmentType vacancy.working_patterns_for_job_schema

json.industry "Education"
json.jobLocation do
  json.set! "@type", "Place"
  json.address do
    json.set! "@type", "PostalAddress"
    json.addressLocality vacancy.organisation&.town
    json.addressRegion vacancy.organisation&.region
    json.streetAddress vacancy.organisation&.address
    json.postalCode vacancy.organisation&.postcode
    json.addressCountry "GB"
  end
end

if vacancy.hourly_rate?
  json.baseSalary do
    json.set! "@type", "MonetaryAmount"
    json.currency "GBP"
    json.value do
      json.set! "@type", "QuantitativeValue"
      json.value vacancy.hourly_rate
      json.unitText "HOUR"
    end
  end
elsif vacancy.salary?
  json.baseSalary do
    json.set! "@type", "MonetaryAmount"
    json.currency "GBP"
    json.value do
      json.set! "@type", "QuantitativeValue"
      json.value vacancy.salary
      json.unitText "YEAR"
    end
  end
end

json.url job_url(vacancy)

json.hiringOrganization do
  json.set! "@type", "Organization"
  json.name vacancy.organisation&.name
  # This should at least put the school logo (from Google) next to the advert
  json.sameAs vacancy.organisation.url
  json.identifier vacancy.organisation&.urn || vacancy.organisation&.uid
  json.description vacancy.about_school
  json.logo image_path("images/govuk-icon-180.png")
end

json.validThrough vacancy.expires_at.iso8601
