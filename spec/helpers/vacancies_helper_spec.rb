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

    # TODO: Working Patterns: Remove this context once all vacancies with legacy working patterns & working_pattern_details have expired
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
        expect(subject).to eq("<div>Full time - #{vacancy.full_time_details}</div><div>Part time - #{vacancy.part_time_details}</div>")
      end
    end
  end

  describe "#vacancy_review_heading_inset_text" do
    subject { helper.vacancy_review_heading_inset_text(vacancy, status) }

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
        let(:vacancy) { create(:vacancy, :draft) }

        it "returns the correct text" do
          expect(subject).to eq(t("publishers.vacancies.show.heading_component.inset_text.complete_draft"))
        end

        context "when the publish on date is in the future" do
          let(:vacancy) { create(:vacancy, :draft, publish_on: Date.tomorrow) }

          it "returns the correct text" do
            expect(subject).to eq(t("publishers.vacancies.show.heading_component.inset_text.scheduled_complete_draft"))
          end
        end
      end

      context "when the draft is incomplete" do
        let(:vacancy) { create(:vacancy, :published, job_advert: nil) }
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

  describe "#vacancy_review_heading_action_link" do
    subject { helper.vacancy_review_heading_action_link(vacancy, action) }

    let(:vacancy) { create(:vacancy) }

    context "when the action is view" do
      let(:action) { "view" }
      let(:link) { helper.open_in_new_tab_link_to(t("publishers.vacancies.show.heading_component.action.view"), job_path(vacancy.id), class: "govuk-!-margin-bottom-0") }

      it "returns the correct link" do
        expect(subject).to eq(link)
      end
    end

    context "when the action is copy" do
      let(:action) { "copy" }
      let(:link) { helper.govuk_link_to(t("publishers.vacancies.show.heading_component.action.copy"), organisation_job_copy_path(vacancy.id), class: "govuk-!-margin-bottom-0", method: :post) }

      it "returns the correct link" do
        expect(subject).to eq(link)
      end
    end

    context "when the action is close_early" do
      let(:action) { "close_early" }
      let(:link) { helper.govuk_link_to(t("publishers.vacancies.show.heading_component.action.close_early"), organisation_job_end_listing_path(vacancy.id), class: "govuk-!-margin-bottom-0") }

      it "returns the correct link" do
        expect(subject).to eq(link)
      end
    end

    context "when the action is extend_closing_date" do
      let(:action) { "extend_closing_date" }
      let(:link) { helper.govuk_link_to(t("publishers.vacancies.show.heading_component.action.extend_closing_date"), organisation_job_extend_deadline_path(vacancy.id), class: "govuk-!-margin-bottom-0") }

      it "returns the correct link" do
        expect(subject).to eq(link)
      end
    end

    context "when the action is publish" do
      let(:action) { "publish" }
      let(:link) { helper.govuk_button_link_to(t("publishers.vacancies.show.heading_component.action.publish"), organisation_job_publish_path(vacancy.id), class: "govuk-!-margin-bottom-0") }

      it "returns the correct link" do
        expect(subject).to eq(link)
      end
    end

    context "when the action is preview" do
      let(:action) { "preview" }
      let(:link) { helper.open_in_new_tab_link_to(t("publishers.vacancies.show.heading_component.action.preview"), organisation_job_preview_path(vacancy.id), class: "govuk-!-margin-bottom-0") }

      it "returns the correct link" do
        expect(subject).to eq(link)
      end
    end

    context "when the action is delete" do
      let(:action) { "delete" }
      let(:link) { helper.govuk_link_to(t("publishers.vacancies.show.heading_component.action.delete"), organisation_job_confirm_destroy_path(vacancy.id), class: "govuk-!-margin-bottom-0") }

      it "returns the correct link" do
        expect(subject).to eq(link)
      end
    end

    context "when the action is complete" do
      let(:action) { "complete" }
      let(:link) { helper.govuk_button_link_to(t("publishers.vacancies.show.heading_component.action.complete"), organisation_job_build_path(vacancy.id, next_invalid_step, back_to_review: "true"), class: "govuk-!-margin-bottom-0") }

      before do
        # Helper uses next_invalid_step which is a helper method defined in Publishers::Vacancies::BaseController. This helper
        # is not available in the context of the test, so I did the below. TODO: Other solutions involve moving these helpers out into
        # a separate module and including that in the controller, but this was the quickest fix for now.
        VacanciesHelper.instance_eval do
          define_method(:next_invalid_step) { :working_patterns }
        end
      end

      it "returns the correct link" do
        expect(subject).to eq(link)
      end
    end

    context "when the action is convert_to_draft" do
      let(:action) { "convert_to_draft" }
      let(:link) { helper.govuk_link_to(t("publishers.vacancies.show.heading_component.action.convert_to_draft"), organisation_job_convert_to_draft_path(vacancy.id), class: "govuk-!-margin-bottom-0") }

      it "returns the correct link" do
        expect(subject).to eq(link)
      end
    end
  end
end
