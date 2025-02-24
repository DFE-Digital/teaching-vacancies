require "rails_helper"

RSpec.describe "vacancies/show", type: :view do
  let(:salary) { "27000" }
  before do
    assign :vacancy, VacancyPresenter.new(create(:vacancy, hourly_rate: nil, salary: salary))
    render
  end

  it "has salary" do
    expect(rendered).to have_content(salary)
  end

  # def vacancy_json_ld(vacancy)
  #   {
  #     "@context": "http://schema.org",
  #     "@type": "JobPosting",
  #     baseSalary: {
  #       :@type=>"MonetaryAmount",
  #       :currency=>"GBP",
  #       :value=>{:@type=>"QuantitativeValue", :unitText=>"HOUR", :value=>"£25 per hour"}
  #     },
  #     title: vacancy.job_title,
  #     jobBenefits: vacancy.benefits_details,
  #     datePosted: vacancy.publish_on.iso8601,
  #     description: vacancy.skills_and_experience.present? ? vacancy.skills_and_experience : vacancy.job_advert,
  #     occupationalCategory: vacancy.job_roles.first,
  #     directApply: vacancy.enable_job_applications,
  #     employmentType: vacancy.working_patterns_for_job_schema,
  #     industry: "Education",
  #     jobLocation: {
  #       "@type": "Place",
  #       address: {
  #         "@type": "PostalAddress",
  #         addressLocality: vacancy.organisation.town,
  #         addressRegion: vacancy.organisation.region,
  #         streetAddress: vacancy.organisation.address,
  #         postalCode: vacancy.organisation.postcode,
  #         addressCountry: "GB",
  #       },
  #     },
  #     url: job_url(vacancy),
  #     hiringOrganization: {
  #       "@type": "Organization",
  #       logo: image_path("images/govuk-icon-180.png"),
  #       name: vacancy.organisation_name,
  #       sameAs: vacancy.organisation.url,
  #       identifier: vacancy.organisation.urn,
  #       description: vacancy.about_school,
  #     },
  #     validThrough: vacancy.expires_at.to_time.iso8601,
  #   }
  # end


end
