require "rails_helper"

RSpec.describe "vacancies/show" do
  let(:current_jobseeker) { nil }

  before do
    allow(view).to receive(:current_jobseeker).and_return(current_jobseeker)
    assign :vacancy, VacancyPresenter.new(vacancy)
    render
  end

  describe "How to apply button" do
    context "when vacancy expired" do
      let(:vacancy) { create(:vacancy, :expired, enable_job_applications: true) }

      it "renders expiration notification" do
        expect(rendered).to have_content(I18n.t("jobs.expired_listing.notification"))
        expect(rendered).to have_no_link(I18n.t("jobseekers.job_applications.apply.apply"))
      end
    end

    context "when applying with TV" do
      let(:vacancy) { create(:vacancy, enable_job_applications: true) }

      it "renders apply online details" do
        expect(rendered).to have_content(I18n.t("jobseekers.job_applications.applying_for_the_job_paragraph"))
        expect(rendered).to have_link(I18n.t("jobseekers.job_applications.apply.apply"))
      end
    end

    context "when applying downloaded application form email back to school" do
      let(:vacancy) { create(:vacancy, :with_application_form) }

      context "when jobseeker logged in" do
        let(:current_jobseeker) { true }

        it "renders apply for application form sent via email" do
          expect(rendered).to have_content(I18n.t("jobs.apply_via_email_html", email: vacancy.application_email))
          expect(rendered).to have_link(I18n.t("buttons.download_application_form", size: number_to_human_size(vacancy.application_form.byte_size)), href: job_document_path(vacancy, vacancy.application_form.id))
        end
      end

      context "when jobseeker logged out" do
        it "renders sign-in link" do
          expect(rendered).to have_content(I18n.t("jobs.apply_via_email_html", email: vacancy.application_email))
          expect(rendered).to have_link(I18n.t("buttons.sign_in_to_download"), href: new_jobseeker_session_path(redirected: true))
        end
      end
    end

    context "when applying with school website application link" do
      let(:vacancy) { create(:vacancy, :no_tv_applications) }

      it "renders apply via school link" do
        expect(rendered).to have_content(I18n.t("jobs.apply_via_website"))
        expect(rendered).to have_link(I18n.t("jobs.view_advert.school"), href: vacancy.application_link, target: "_blank")
      end
    end

    context "when applyng with external application link" do
      let(:vacancy) { create(:vacancy, :external) }

      it "renders apply via external link" do
        expect(rendered).to have_content(I18n.t("jobs.external.notice"))
        expect(rendered).to have_link(I18n.t("jobs.view_advert.external"), href: vacancy.external_advert_url, target: "_blank")
      end
    end
  end

  describe "job posting metadata" do
    let(:json_ld) { JSON.parse(rendered.html.css("script.jobref").inner_text, symbolize_names: true) }
    let(:vacancy) { create(:vacancy, hourly_rate: hourly_rate, salary: salary) }

    context "with hourly rate" do
      let(:hourly_rate) { 25 }
      let(:salary) { "27000" }

      it "has hourly rate as salary" do
        expect(json_ld.fetch(:baseSalary)).to eq({ :@type => "MonetaryAmount", :currency => "GBP", :value => { :@type => "QuantitativeValue", :unitText => "HOUR", :value => "25" } })
      end
    end

    context "without hourly rate" do
      let(:hourly_rate) { nil }
      let(:salary) { "27000" }

      it "has salary instead" do
        expect(json_ld.fetch(:baseSalary)).to eq({ :@type => "MonetaryAmount", :currency => "GBP", :value => { :@type => "QuantitativeValue", :unitText => "YEAR", :value => "27000" } })
      end
    end

    context "without money" do
      let(:hourly_rate) { nil }
      let(:salary) { nil }

      it "has no salary" do
        expect(json_ld.key?(:baseSalary)).to be(false)
      end
    end
  end
end
