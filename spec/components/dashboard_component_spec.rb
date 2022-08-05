require "rails_helper"

RSpec.describe DashboardComponent, type: :component do
  let(:publisher) { create(:publisher) }
  let(:sort) { Publishers::VacancySort.new(organisation, selected_type).update(sort_by: "job_title") }
  let(:selected_type) { "published" }
  let(:publisher_preference) { create(:publisher_preference, publisher: publisher, organisation: organisation) }

  subject do
    described_class.new(
      organisation: organisation, sort: sort, selected_type: selected_type, publisher_preference: publisher_preference,
    )
  end

  context "when organisation has no active vacancies" do
    let(:organisation) { create(:school, name: "A school with no published or draft jobs") }
    let!(:vacancy) { create(:vacancy, :trashed, organisations: [organisation]) }

    before { render_inline(subject) }

    it "renders the Create a job listing button that skips the copy existing page" do
      expect(page).to have_link(href: Rails.application.routes.url_helpers.organisation_jobs_path)
    end
  end

  context "when organisation has active vacancies" do
    context "when job applications have been received" do
      context "when organisation is a school" do
        let(:organisation) { create(:school, name: "A school with jobs") }
        let(:vacancy) { create(:vacancy, :published, organisations: [organisation]) }
        let!(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }

        let!(:inline_component) { render_inline(subject) }

        it "renders the Create a job listing button that does not skip the copy existing page" do
          expect(page).to have_link(href: Rails.application.routes.url_helpers.create_or_copy_organisation_jobs_path)
        end

        it "renders the number of jobs in the heading" do
          expect(inline_component.css("h1.govuk-heading-l").text).to include("Active jobs (1)")
        end

        it "renders the vacancy job title in the table" do
          expect(inline_component.css(".govuk-summary-list").to_html).to include(vacancy.job_title)
        end

        it "renders the link to view applicants" do
          expect(page).to have_content(I18n.t("jobs.manage.view_applicants", count: 1))
          expect(page).to have_link(href: Rails.application.routes.url_helpers.organisation_job_job_applications_path(vacancy.id))
        end

        context "when withdrawn applications have also been received" do
          let(:withdrawn_job_application) { create(:job_application, :status_withdrawn, vacancy: vacancy) }

          it "does not affect the count" do
            expect(page).to have_content(I18n.t("jobs.manage.view_applicants", count: 1))
            expect(page).to have_link(href: Rails.application.routes.url_helpers.organisation_job_job_applications_path(vacancy.id))
          end
        end

        it "does not render the vacancy readable job location in the table" do
          expect(inline_component.css(".govuk-summary-list #vacancy_location").to_html).to be_blank
        end

        it "does not render the filters sidebar" do
          expect(inline_component.css('.edit_publisher_preference button[type="submit"]')).to be_blank
        end

        context "when there are no jobs within the selected vacancy type" do
          let(:selected_type) { "draft" }

          it "uses the correct 'no jobs' text ('no filters')" do
            expect(page).to have_content(I18n.t("jobs.manage.draft.no_jobs.no_filters"))
          end
        end
      end

      context "when organisation is a trust" do
        let(:organisation) { create(:trust, schools: [open_school, closed_school]) }
        let(:open_school) { create(:school, name: "Open school") }
        let(:closed_school) { create(:school, :closed, name: "Closed school") }
        let!(:vacancy) { create(:vacancy, :published, organisations: [organisation]) }
        let!(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }

        let!(:inline_component) { render_inline(subject) }

        it "renders the number of jobs in the heading" do
          expect(inline_component.css("h1.govuk-heading-l").text).to include("Active jobs (1)")
        end

        it "renders the vacancy job title in the table" do
          expect(inline_component.css(".govuk-summary-list").to_html).to include(vacancy.job_title)
        end

        it "renders the trust's name in the table" do
          expect(
            inline_component.css(".govuk-summary-list__key").to_html,
          ).to include(I18n.t("organisations.job_location_summary.central_office"))
        end

        it "renders the link to view applicants" do
          expect(page).to have_content(I18n.t("jobs.manage.view_applicants", count: 1))
          expect(page).to have_link(href: Rails.application.routes.url_helpers.organisation_job_job_applications_path(vacancy.id))
        end

        it "renders the filters sidebar" do
          expect(
            inline_component.css('.edit_publisher_preference button[type="submit"]').first.text,
          ).to eq(I18n.t("buttons.apply_filters"))
        end

        it "renders the trust head office as a filter option" do
          expect(inline_component.css(".edit_publisher_preference").to_html).to include("Trust head office")
        end

        it "renders the open school as a filter option" do
          expect(inline_component.css(".edit_publisher_preference").to_html).to include("Open school")
        end

        it "does not render the closed school as a filter option" do
          expect(inline_component.css(".edit_publisher_preference").to_html).not_to include("Closed school")
        end
      end

      context "when the organisation is a local authority" do
        let(:organisation) { create(:local_authority, schools: [open_school, closed_school]) }
        let(:open_school) { create(:school, name: "Open school") }
        let(:closed_school) { create(:school, :closed, name: "Closed school") }
        let(:publisher_preference) { create(:publisher_preference, publisher: publisher, organisation: organisation, schools: [open_school]) }
        let!(:vacancy) { create(:vacancy, :published, organisations: [open_school]) }
        let!(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }

        let!(:inline_component) { render_inline(subject) }

        it "renders the number of jobs in the heading" do
          expect(inline_component.css("h1.govuk-heading-l").text).to include("Active jobs (1)")
        end

        it "renders the vacancy job title in the table" do
          expect(inline_component.css(".govuk-summary-list").to_html).to include(vacancy.job_title)
        end

        it "does not render the link to view applicants" do
          expect(page).not_to have_content(I18n.t("jobs.manage.view_applicants", count: 1))
        end

        it "renders the local authority's name in the table" do
          expect(
            inline_component.css(".govuk-summary-list__key").to_html,
          ).to include(vacancy.organisation_name)
        end

        it "renders the filters sidebar" do
          expect(
            inline_component.css('.edit_publisher_preference button[type="submit"]').first.text,
          ).to eq(I18n.t("buttons.apply_filters"))
        end

        it "does not render the trust head office as a filter option" do
          expect(inline_component.css(".edit_publisher_preference").to_html).not_to include("Trust head office")
        end

        it "renders the open school as a filter option" do
          expect(inline_component.css(".edit_publisher_preference").to_html).to include("Open school")
        end

        it "does not render the closed school as a filter option" do
          expect(inline_component.css(".edit_publisher_preference").to_html).not_to include("Closed school")
        end

        context "when there are no jobs within the selected vacancy type" do
          let(:selected_type) { "draft" }

          it "uses the correct 'no jobs' text ('no filters')" do
            expect(page).to have_content(I18n.t("jobs.manage.draft.no_jobs.no_filters"))
          end
        end
      end
    end

    context "when job applications have not been received" do
      let(:organisation) { create(:school, name: "A school with jobs") }
      let!(:vacancy) { create(:vacancy, :published, organisations: [organisation]) }

      before { render_inline(subject) }

      it "renders plain text of 0 applicants" do
        expect(page).to have_content(I18n.t("jobs.manage.view_applicants", count: 0))
        expect(page).not_to have_link(href: Rails.application.routes.url_helpers.organisation_job_job_applications_path(vacancy.id))
      end
    end
  end

  context "when filtering results" do
    let(:organisation) { create(:trust, schools: [school_oxford, school_cambridge]) }
    let(:school_oxford) { create(:school, name: "Oxford") }
    let(:school_cambridge) { create(:school, name: "Cambridge") }
    let!(:vacancy_cambridge) { create(:vacancy, :published, organisations: [school_cambridge], job_title: "Scientist") }

    before { publisher_preference.update organisations: [school_oxford] }

    context "when a relevant job exists" do
      let!(:vacancy_oxford) { create(:vacancy, :published, organisations: [school_oxford], job_title: "Mathematician") }

      let!(:inline_component) { render_inline(subject) }

      it "renders the vacancy in Oxford" do
        expect(page).to have_content(vacancy_oxford.job_title)
      end

      it "does not render the vacancy in Cambridge" do
        expect(page).not_to have_content(vacancy_cambridge.job_title)
      end
    end

    context "when there are no jobs within the selected filters" do
      let!(:inline_component) { render_inline(subject) }

      it "uses the correct no jobs text ('with filters')" do
        expect(page).to have_content(I18n.t("jobs.manage.published.no_jobs.with_filters"))
      end
    end
  end
end
