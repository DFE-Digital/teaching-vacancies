require "rails_helper"

RSpec.describe VacanciesHelper do
  describe "#humanize_array" do
    subject { helper.humanize_array(items) }

    context "when the array is empty" do
      let(:items) { [] }

      it "returns an empty string" do
        expect(subject).to eq("")
      end
    end

    context "when the array contains items" do
      let(:items) { %w[maths science physics] }

      it "returns a humanized list of items" do
        expect(subject).to eq("Maths, Science, Physics")
      end
    end

    context "when the array contains empty or null elements" do
      let(:items) { ["", nil, "maths", "science", "physics"] }

      it "returns a humanized list of items without the empty or null elements" do
        expect(subject).to eq("Maths, Science, Physics")
      end
    end
  end

  describe "#page_title_prefix" do
    subject { helper.page_title_prefix(step_process, form_object) }

    let(:step_process) { double(:step_process, vacancy: vacancy, current_step: :job_title, current_step_group_number: 1) }
    let(:form_object) { double(:form_object, errors: errors) }

    context "when the vacancy is published" do
      let(:vacancy) { build_stubbed(:vacancy) }

      context "when there are errors" do
        let(:errors) { ["test error"] }

        it "returns the correct page title" do
          expect(subject).to eq("Error: Job title - Change job listing - [Section 1 of 4] - Teaching Vacancies - GOV.UK")
        end
      end

      context "when there are no errors" do
        let(:errors) { [] }

        it "returns the correct page title" do
          expect(subject).to eq("Job title - Change job listing - [Section 1 of 4] - Teaching Vacancies - GOV.UK")
        end
      end
    end

    context "when the vacancy is not published" do
      let(:vacancy) { build_stubbed(:draft_vacancy) }

      context "when there are errors" do
        let(:errors) { ["test error"] }

        it "returns the correct page title" do
          expect(subject).to eq("Error: Job title - Create job listing - [Section 1 of 4] - Teaching Vacancies - GOV.UK")
        end
      end

      context "when there are no errors" do
        let(:errors) { [] }

        it "returns the correct page title" do
          expect(subject).to eq("Job title - Create job listing - [Section 1 of 4] - Teaching Vacancies - GOV.UK")
        end
      end
    end
  end

  describe "#review_page_title_prefix" do
    subject { helper.review_page_title_prefix(vacancy) }

    let(:vacancy) { build_stubbed(:draft_vacancy, publish_on: publish_on) }

    context "when publish_on is in the future" do
      let(:publish_on) { 2.days.from_now }

      it "returns the correct page title" do
        expect(subject).to eq("Check details and schedule job listing - Create job listing - Teaching Vacancies - GOV.UK")
      end
    end

    context "when publish_on is not in the future" do
      let(:publish_on) { Date.today }

      it "returns the correct page title" do
        expect(subject).to eq("Check details and publish job listing - Create job listing - Teaching Vacancies - GOV.UK")
      end
    end
  end

  describe "#publishers_show_page_title_prefix" do
    subject { helper.publishers_show_page_title_prefix(vacancy) }

    let(:vacancy) { build_stubbed(:vacancy, job_title: "Test job title") }

    it "returns the correct page title" do
      expect(subject).to eq("Test job title - Teaching Vacancies - GOV.UK")
    end
  end

  describe "#vacancy_full_job_location" do
    subject { helper.vacancy_full_job_location(vacancy) }

    context "when the vacancy is at multiple schools" do
      let(:school_group) { create(:school_group) }
      let(:school) { create(:school, school_groups: [school_group]) }
      let(:school2) { create(:school, school_groups: [school_group]) }
      let(:vacancy) { build(:vacancy, organisations: [school, school2]) }

      it "returns the multiple schools location" do
        expect(subject).to eq("More than one location, #{vacancy.organisation.name}")
      end
    end

    context "when the vacancy is not at multiple schools" do
      let(:school) { build(:school, name: "Magic School", town: "Cool Town", county: "Orange County", postcode: "SW1A") }
      let(:vacancy) { build(:vacancy, organisations: [school]) }

      it "returns the full location" do
        expect(subject).to eq("#{vacancy.organisation.name}, Cool Town, Orange County, SW1A")
      end
    end
  end

  describe "#vacancy_breadcrumbs" do
    subject(:breadcrumbs) { vacancy_breadcrumbs(vacancy).to_a }

    let(:vacancy) { build_stubbed(:vacancy, job_roles: ["teacher"], job_title: "A Job") }
    let(:request) { double("request", host: "example.com", referrer: referrer) }
    let(:referrer) { "http://www.example.com/foo" }
    let(:landing_page) { instance_double(LandingPage, title: "Landing Page", slug: "landing") }

    before do
      allow(helper).to receive(:request).and_return(request)
      allow(LandingPage).to receive(:matching).with(job_roles: %w[teacher]).and_return(landing_page)
    end

    it "has the homepage as its first breadcrumb" do
      expect(breadcrumbs[0].last).to eq(root_path)
    end

    context "when coming from a landing page" do
      it "has the landing page as its second breadcrumb" do
        expect(breadcrumbs[1]).to eq(["Landing Page", landing_page_path("landing")])
      end

      context "when coming from an organisation landing page" do
        let(:organisation_slug) { "organisation-slug" }
        let(:referrer) { organisation_landing_page_url(organisation_landing_page_name: organisation_slug, host: "example.com") }
        let(:organisation_landing_page) { instance_double(OrganisationLandingPage, slug: organisation_slug, name: "Organisation Landing Page") }

        before do
          allow(LandingPage).to receive(:matching).with(job_roles: %w[teacher]).and_return(nil)
          allow(OrganisationLandingPage).to receive(:exists?).with(organisation_slug).and_return(true)
          allow(OrganisationLandingPage).to receive(:[]).with(organisation_slug).and_return(organisation_landing_page)
        end

        it "has the organisation landing page as its second breadcrumb" do
          expect(breadcrumbs[1]).to eq(["Organisation Landing Page", organisation_landing_page_path(organisation_slug)])
        end
      end

      context "when there is no referrer" do
        let(:request) { double("request", host: "example.com", referrer: nil) }

        it "has the homepage as its first breadcrumb" do
          expect(breadcrumbs[0].last).to eq(root_path)
        end

        it "has the landing page as its second breadcrumb" do
          expect(breadcrumbs[1]).to eq(["Landing Page", landing_page_path("landing")])
        end
      end

      context "when the referrer is not a valid URI" do
        let(:request) { double("request", host: "example.com", referrer: "\"") }

        it "has the homepage as its first breadcrumb" do
          expect(breadcrumbs[0].last).to eq(root_path)
        end

        it "has the landing page as its second breadcrumb" do
          expect(breadcrumbs[1]).to eq(["Landing Page", landing_page_path("landing")])
        end
      end
    end

    context "when the user comes from the search page" do
      let(:referrer) { jobs_url(foo: "bar", host: "example.com") }

      it "has the search as its second breadcrumb" do
        expect(breadcrumbs[1]).to eq([t("breadcrumbs.jobs"), referrer])
      end
    end

    context "when there is no landing page" do
      let(:landing_page) { nil }

      it "has the expected parent breadcrumb" do
        expect(breadcrumbs[1]).to eq([t("breadcrumbs.jobs"), jobs_path])
      end

      context "when there is no referrer" do
        let(:request) { double("request", host: "example.com", referrer: nil) }

        it "has the homepage as its first breadcrumb" do
          expect(breadcrumbs[0].last).to eq(root_path)
        end

        it "has the expected parent breadcrumb" do
          expect(breadcrumbs[1]).to eq([t("breadcrumbs.jobs"), jobs_path])
        end
      end

      context "when the referrer is not a valid URI" do
        let(:request) { double("request", host: "example.com", referrer: "\"") }

        it "has the homepage as its first breadcrumb" do
          expect(breadcrumbs[0].last).to eq(root_path)
        end

        it "has the expected parent breadcrumb" do
          expect(breadcrumbs[1]).to eq([t("breadcrumbs.jobs"), jobs_path])
        end
      end
    end
  end

  describe "#vacancy_activity_log_item" do
    subject { vacancy_activity_log_item(attribute, new_value, organisation_type) }
    let(:vacancy) { create(:vacancy, organisations: [school], publisher_organisation: school) }
    let(:school) { create(:school) }
    let(:organisation_type) { organisation_type_basic(vacancy.organisation) }

    context "when the translation requires a count" do
      let(:attribute) { "subjects" }
      let(:new_value) { %w[Maths Science Physics] }

      it "returns the correct pluralised translation" do
        expect(subject).to eq(I18n.t("publishers.activity_log.#{attribute}", new_value: new_value.to_sentence,
                                                                             count: new_value.count))
      end
    end

    context "when the attribute is an array enum" do
      let(:attribute) { "working_patterns" }
      let(:new_value) { [0, 100] }

      it "returns the correct pluralised translation" do
        expect(subject).to eq(I18n.t("publishers.activity_log.#{attribute}", new_value: new_value.to_sentence,
                                                                             count: new_value.count))
      end
    end

    context "when the new value is a date" do
      let(:attribute) { "starts_on" }

      context "when the new value is nil" do
        let(:new_value) { nil }

        it "returns the correct translation" do
          expect(subject).to eq(I18n.t("publishers.activity_log.#{attribute}.deleted"))
        end
      end

      context "when the new value is not nil" do
        let(:new_value) { "2022-08-11T12:00:00.000+01:00" }

        it "returns the correct translation with the date formatted" do
          expect(subject).to eq(I18n.t("publishers.activity_log.#{attribute}.changed", new_value: format_date(new_value.to_date)))
        end
      end
    end

    context "when the attribute is 'school_visits'" do
      let(:attribute) { "school_visits" }
      let(:new_value) { "Information on visiting the school" }

      it "returns the correct translation" do
        expect(subject).to eq(I18n.t("publishers.activity_log.school_visits", organisation_type: organisation_type.capitalize,
                                                                              new_value: new_value))
      end
    end

    context "when the attribute is 'other_start_date_details'" do
      let(:attribute) { "other_start_date_details" }

      context "when the new value is nil" do
        let(:new_value) { nil }

        it "returns the correct translation" do
          expect(subject).to eq(I18n.t("publishers.activity_log.#{attribute}.deleted"))
        end
      end

      context "when the new value is not nil" do
        let(:new_value) { "Example start date" }

        it "returns the correct translation" do
          expect(subject).to eq(I18n.t("publishers.activity_log.#{attribute}.changed", new_value: new_value))
        end
      end
    end

    context "when none of the contexts above apply" do
      let(:attribute) { "how_to_apply" }
      let(:new_value) { "Show us if you can do the worm" }

      it "returns the correct translation" do
        expect(subject).to eq(I18n.t("publishers.activity_log.#{attribute}", new_value: new_value.humanize))
      end
    end
  end

  describe "#vacancy_working_patterns" do
    subject { vacancy_working_patterns(vacancy) }
    context "when vacancy does is not a job share" do
      context "when the vacancy does not contain working patterns details" do
        let(:vacancy) { build_stubbed(:vacancy, working_patterns: %w[full_time part_time], working_patterns_details: nil, is_job_share: false) }

        it "returns a summary of the working patterns" do
          expect(subject).to eq("<li>Full time, part time</li>")
        end
      end

      context "when the vacancy contains working patterns details" do
        let(:vacancy) { build_stubbed(:vacancy, working_patterns: %w[full_time part_time], working_patterns_details: "Between 10 and 36 hours", is_job_share: false) }

        it "returns the working patterns with details for each working pattern" do
          expect(subject).to eq("<li>Full time, part time: Between 10 and 36 hours</li>")
        end
      end
    end

    context "when vacancy does is a job share" do
      context "when the vacancy does not contain working patterns details" do
        let(:vacancy) { build_stubbed(:vacancy, working_patterns: %w[full_time part_time], working_patterns_details: nil, is_job_share: true) }

        it "returns a summary of the working patterns" do
          expect(subject).to eq("<li>Full time, part time, open to job share</li>")
        end
      end

      context "when the vacancy contains working patterns details" do
        let(:vacancy) { build_stubbed(:vacancy, working_patterns: %w[full_time part_time], working_patterns_details: "Between 10 and 36 hours", is_job_share: true) }

        it "returns the working patterns with details for each working pattern" do
          expect(subject).to eq("<li>Full time, part time, open to job share: Between 10 and 36 hours</li>")
        end
      end
    end
  end

  describe "#vacancy_review_form_heading_inset_text" do
    subject { helper.vacancy_review_form_heading_inset_text(vacancy, status) }

    context "when the job has been published" do
      let(:vacancy) { create(:vacancy, :published) }
      let(:status) { "published" }

      it "returns the correct text" do
        expect(subject).to eq(t("publishers.vacancies.show.heading_component.inset_text.published", publish_date: format_date(vacancy.publish_on),
                                                                                                    expiry_time: format_time_to_datetime_at(vacancy.expires_at)))
      end
    end

    context "when the job is a draft" do
      context "when the draft has been completed" do
        let(:status) { "complete_draft" }
        let(:vacancy) { create(:draft_vacancy) }

        it "returns the correct text" do
          expect(subject).to eq(t("publishers.vacancies.show.heading_component.inset_text.complete_draft"))
        end

        context "when the publish on date is in the future" do
          let(:vacancy) { create(:draft_vacancy, publish_on: Date.tomorrow) }

          it "returns the correct text" do
            expect(subject).to eq(t("publishers.vacancies.show.heading_component.inset_text.scheduled_complete_draft"))
          end
        end
      end

      context "when the draft is incomplete" do
        let(:vacancy) { create(:vacancy, :published) }
        let(:status) { "incomplete_draft" }

        it "returns the correct text" do
          expect(subject).to eq(t("publishers.vacancies.show.heading_component.inset_text.incomplete_draft"))
        end
      end

      context "when the job has closed" do
        let(:vacancy) { create(:vacancy, :expired) }
        let(:status) { "closed" }

        it "returns the correct text" do
          expect(subject).to eq(t("publishers.vacancies.show.heading_component.inset_text.closed", publish_date: format_date(vacancy.publish_on),
                                                                                                   expiry_time: format_time_to_datetime_at(vacancy.expires_at)))
        end
      end

      context "when the job has been scheduled" do
        let(:vacancy) { create(:vacancy, :future_publish) }
        let(:status) { "scheduled" }

        it "returns the correct text" do
          expect(subject).to eq(t("publishers.vacancies.show.heading_component.inset_text.scheduled", publish_date: format_date(vacancy.publish_on),
                                                                                                      expiry_time: format_time_to_datetime_at(vacancy.expires_at)))
        end
      end
    end
  end

  describe "#vacancy_complete_action_link" do
    subject { helper.vacancy_complete_action_link(vacancy, :working_patterns) }
    let(:link) { helper.govuk_button_link_to(t("publishers.vacancies.show.heading_component.action.complete"), organisation_job_build_path(vacancy.id, :working_patterns, back_to_show: "true"), class: "govuk-!-margin-bottom-0") }
    let(:vacancy) { create(:vacancy) }

    it "returns the correct link" do
      expect(subject).to eq(link)
    end
  end
end
