json.set! "@context", "http://schema.org"
json.set! "@type", "JobPosting"

json.title vacancy.job_title
json.jobBenefits vacancy.benefits
json.datePosted vacancy.publish_on.to_time.iso8601
json.description vacancy.job_advert
json.occupationalCategory vacancy.job_roles&.join(", ")
json.directApply vacancy.enable_job_applications

json.employmentType vacancy.working_patterns_for_job_schema

json.industry "Education"
json.jobLocation do
  json.set! "@type", "Place"
  json.address do
    json.set! "@type", "PostalAddress"
    json.addressLocality vacancy.parent_organisation&.town
    json.addressRegion vacancy.parent_organisation&.region
    json.streetAddress vacancy.parent_organisation&.address
    json.postalCode vacancy.parent_organisation&.postcode
  end
end

json.url job_url(vacancy)

json.hiringOrganization do
  json.set! "@type", "Organization"
  json.name vacancy.parent_organisation&.name
  json.identifier vacancy.parent_organisation&.urn || vacancy.parent_organisation&.uid
  json.description vacancy.about_school
end

json.validThrough vacancy.expires_at.iso8601
