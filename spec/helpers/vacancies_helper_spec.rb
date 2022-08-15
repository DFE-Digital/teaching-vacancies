require "rails_helper"

RSpec.describe VacanciesHelper do
  describe "#vacancy_full_job_location" do
    subject { helper.vacancy_full_job_location(vacancy) }
    let(:organisation_link) { helper.govuk_link_to(vacancy.organisation.name, organisation_landing_page_path(vacancy.organisation.slug)) }

    context "when the vacancy is at multiple schools" do
      let(:school_group) { create(:school_group) }
      let(:school) { create(:school, school_groups: [school_group]) }
      let(:school2) { create(:school, school_groups: [school_group]) }
      let(:vacancy) { build(:vacancy, organisations: [school, school2]) }

      it "returns the multiple schools location" do
        expect(subject).to eq("More than one location, #{organisation_link}")
      end
    end

    context "when the vacancy is not at multiple schools" do
      let(:school) { build(:school, name: "Magic School", town: "Cool Town", county: "Orange County", postcode: "SW1A") }
      let(:vacancy) { build(:vacancy, organisations: [school]) }

      it "returns the full location" do
        expect(subject).to eq("#{organisation_link}, Cool Town, Orange County, SW1A")
      end
    end
  end

  describe "#vacancy_breadcrumbs" do
    subject { vacancy_breadcrumbs(vacancy).to_a }
    let(:vacancy) { build_stubbed(:vacancy, :teacher, job_title: "A Job") }
    let(:request) { double("request", host: "example.com", referrer: referrer) }
    let(:referrer) { "http://www.example.com/foo" }
    let(:landing_page) { instance_double(LandingPage, title: "Landing Page", slug: "landing") }

    before do
      allow(helper).to receive(:request).and_return(request)
      allow(LandingPage).to receive(:matching).with(job_roles: %w[teacher]).and_return(landing_page)
    end

    it "has the homepage as its first breadcrumb" do
      expect(subject[0].last).to eq(root_path)
    end

    context "when coming from a landing page" do
      it "has the landing page as its second breadcrumb" do
        expect(subject[1]).to eq(["Landing Page", landing_page_path("landing")])
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
          expect(subject[1]).to eq(["Organisation Landing Page", organisation_landing_page_path(organisation_slug)])
        end
      end
    end

    context "when the user comes from the search page" do
      let(:referrer) { jobs_url(foo: "bar", host: "example.com") }

      it "has the search as its second breadcrumb" do
        expect(subject[1]).to eq([t("breadcrumbs.jobs"), referrer])
      end
    end

    context "when there is no landing page" do
      let(:landing_page) { nil }

      it "has the expected parent breadcrumb" do
        expect(subject[1]).to eq([t("breadcrumbs.jobs"), jobs_path])
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

    context "when the translation requires the organisation type" do
      let(:attribute) { "about_school" }
      let(:new_value) { "This is a school description" }

      it "returns the correct translation" do
        expect(subject).to eq(I18n.t("publishers.activity_log.#{attribute}", organisation_type: organisation_type))
      end
    end

    context "when the attribute is an array enum" do
      let(:attribute) { "working_patterns" }
      let(:new_value) { [0, 100, 104] }

      it "returns the correct pluralised translation" do
        expect(subject).to eq(I18n.t("publishers.activity_log.#{attribute}", new_value: new_value.to_sentence,
                                                                             count: new_value.count))
      end
    end

    context "when the new value is a date" do
      let(:attribute) { "expires_at" }
      let(:new_value) { "2022-08-11T12:00:00.000+01:00" }

      it "returns the correct translation with the date formatted" do
        expect(subject).to eq(I18n.t("publishers.activity_log.#{attribute}", new_value: format_date(new_value.to_date)))
      end
    end

    context "when the expected start date has been changed to 'As soon as possible'" do
      let(:attribute) { "starts_on" }
      let(:new_value) { nil }

      it "returns the correct translation" do
        expect(subject).to eq(I18n.t("publishers.activity_log.#{attribute}", new_value: t("jobs.starts_asap")))
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

    # TODO Working Patterns: Remove this context once all vacancies with legacy working patterns & working_pattern_details have expired
    context "when the vacancy was created before the addition of full_time_details and part_time_details" do
      before do
        allow(vacancy).to receive(:full_time_details).and_return(nil)
        allow(vacancy).to receive(:part_time_details).and_return(nil)
      end

      let(:vacancy) { build(:vacancy, working_patterns: %w[full_time]) }

      it "returns a summary of the working patterns" do
        expect(subject).to eq("Full time")
      end
    end

    context "when the vacancy was created after the addition of full_time_details and part_time_details" do
      let(:vacancy) { build(:vacancy, working_patterns: %w[full_time part_time]) }

      it "returns the working patterns with details for each working pattern" do
        expect(subject).to eq("<li>Full time - #{vacancy.full_time_details}</li><li>Part time - #{vacancy.part_time_details}</li>")
      end
    end
  end
end
