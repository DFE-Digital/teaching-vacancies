require "rails_helper"

RSpec.describe Publishers::VacanciesComponent, type: :component do
  let(:publisher) { create(:publisher) }
  let(:sort) { Publishers::VacancySort.new(organisation, selected_type).update(column: "job_title") }
  let(:selected_type) { "published" }
  let(:publisher_preference) { create(:publisher_preference, publisher: publisher, organisation: organisation) }
  let(:sort_form) { SortForm.new(sort.column) }
  let(:email) { "publisher@email.com" }

  subject do
    described_class.new(
      organisation: organisation, sort: sort, selected_type: selected_type, publisher_preference: publisher_preference, sort_form: sort_form, email: email,
    )
  end

  context "when organisation has no active vacancies" do
    let(:organisation) { create(:school, name: "A school with no published or draft jobs") }
    let!(:vacancy) { create(:vacancy, :trashed, organisations: [organisation]) }

    before { render_inline(subject) }

    it "does not render the vacancies component" do
      expect(rendered_component).to be_blank
    end
  end

  context "when organisation has active vacancies" do
    context "when job applications have been received" do
      context "when organisation is a school" do
        let(:organisation) { create(:school, name: "A school with jobs") }
        let(:vacancy) { create(:vacancy, :published) }
        let!(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }

        before { vacancy.organisation_vacancies.create(organisation: organisation) }

        let!(:inline_component) { render_inline(subject) }

        it "renders the vacancies component" do
          expect(inline_component.css(".vacancies-component__content").to_html).not_to be_blank
        end

        it "renders the number of jobs in the heading" do
          expect(inline_component.css("h1.govuk-heading-l").text).to include("Active jobs (1)")
        end

        it "renders the vacancy job title in the table" do
          expect(inline_component.css(".card-component").to_html).to include(vacancy.job_title)
        end

        it "renders the link to view applicants" do
          expect(rendered_component).to include(I18n.t("jobs.manage.view_applicants", count: 1))
          expect(rendered_component).to include(Rails.application.routes.url_helpers.organisation_job_job_applications_path(vacancy.id))
        end

        context "when withdrawn applications have also been received" do
          let(:withdrawn_job_application) { create(:job_application, :status_withdrawn, vacancy: vacancy) }

          it "does not affect the count" do
            expect(rendered_component).to include(I18n.t("jobs.manage.view_applicants", count: 1))
            expect(rendered_component).to include(Rails.application.routes.url_helpers.organisation_job_job_applications_path(vacancy.id))
          end
        end

        it "does not render the vacancy readable job location in the table" do
          expect(inline_component.css(".card-component #vacancy_location").to_html).to be_blank
        end

        it "does not render the filters sidebar" do
          expect(inline_component.css('.edit_publisher_preference button[type="submit"]')).to be_blank
        end

        context "when there are no jobs within the selected vacancy type" do
          let(:selected_type) { "draft" }

          it "uses the correct 'no jobs' text ('no filters')" do
            expect(rendered_component).to include(I18n.t("jobs.manage.draft.no_jobs.no_filters"))
          end
        end
      end

      context "when organisation is a trust" do
        let(:organisation) { create(:trust) }
        let(:open_school) { create(:school, name: "Open school") }
        let(:closed_school) { create(:school, :closed, name: "Closed school") }
        let!(:vacancy) { create(:vacancy, :published, :central_office, organisations: [organisation]) }
        let!(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }

        before do
          organisation.school_group_memberships.create(school: open_school)
          organisation.school_group_memberships.create(school: closed_school)
        end

        let!(:inline_component) { render_inline(subject) }

        it "renders the vacancies component" do
          expect(inline_component.css(".vacancies-component__content").to_html).not_to be_blank
        end

        it "renders the number of jobs in the heading" do
          expect(inline_component.css("h1.govuk-heading-l").text).to include("Active jobs (1)")
        end

        it "renders the vacancy job title in the table" do
          expect(inline_component.css(".card-component").to_html).to include(vacancy.job_title)
        end

        it "renders the vacancy readable job location in the table" do
          expect(
            inline_component.css(".card-component__header").to_html,
          ).to include(vacancy.readable_job_location)
        end

        it "renders the link to view applicants" do
          expect(rendered_component).to include(I18n.t("jobs.manage.view_applicants", count: 1))
          expect(rendered_component).to include(Rails.application.routes.url_helpers.organisation_job_job_applications_path(vacancy.id))
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
        let(:organisation) { create(:local_authority) }
        let(:open_school) { create(:school, name: "Open school") }
        let(:closed_school) { create(:school, :closed, name: "Closed school") }
        let(:publisher_preference) { create(:publisher_preference, publisher: publisher, organisation: organisation) }
        let!(:vacancy) { create(:vacancy, :published, :at_one_school, organisations: [open_school]) }
        let!(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }

        before do
          organisation.school_group_memberships.create(school: open_school)
          organisation.school_group_memberships.create(school: closed_school)
          publisher_preference.local_authority_publisher_schools.create(school_id: open_school.id)
        end

        let!(:inline_component) { render_inline(subject) }

        it "renders the vacancies component" do
          expect(inline_component.css(".vacancies-component__content").to_html).not_to be_blank
        end

        it "renders the number of jobs in the heading" do
          expect(inline_component.css("h1.govuk-heading-l").text).to include("Active jobs (1)")
        end

        it "renders the vacancy job title in the table" do
          expect(inline_component.css(".card-component").to_html).to include(vacancy.job_title)
        end

        it "does not render the link to view applicants" do
          expect(rendered_component).not_to include(I18n.t("jobs.manage.view_applicants", count: 1))
        end

        it "renders the vacancy readable job location in the table" do
          expect(
            inline_component.css(".card-component__header").to_html,
          ).to include(vacancy.readable_job_location)
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
            expect(rendered_component).to include(I18n.t("jobs.manage.draft.no_jobs.no_filters"))
          end
        end
      end
    end

    context "when job applications have not been received" do
      let(:organisation) { create(:school, name: "A school with jobs") }
      let(:vacancy) { create(:vacancy, :published) }

      before do
        vacancy.organisation_vacancies.create(organisation: organisation)
        render_inline(subject)
      end

      it "renders plain text of 0 applicants" do
        expect(rendered_component).to include(I18n.t("jobs.manage.view_applicants", count: 0))
        expect(rendered_component).not_to include(Rails.application.routes.url_helpers.organisation_job_job_applications_path(vacancy.id))
      end
    end
  end

  context "when filtering results" do
    let(:organisation) { create(:trust) }
    let(:school_oxford) { create(:school, name: "Oxford", school_groups: [organisation]) }
    let(:school_cambridge) { create(:school, name: "Cambridge", school_groups: [organisation]) }
    let!(:organisation_publisher_preference) { OrganisationPublisherPreference.create(organisation: school_oxford, publisher_preference: publisher_preference) }
    let!(:vacancy_cambridge) { create(:vacancy, :published, :at_one_school, organisations: [school_cambridge], readable_job_location: school_cambridge.name) }

    context "when a relevant job exists" do
      let!(:vacancy_oxford) { create(:vacancy, :published, :at_one_school, organisations: [school_oxford], readable_job_location: school_oxford.name) }

      let!(:inline_component) { render_inline(subject) }

      it "renders the vacancy in Oxford" do
        expect(rendered_component).to include(vacancy_oxford.job_title)
      end

      it "does not render the vacancy in Cambridge" do
        expect(rendered_component).not_to include(vacancy_cambridge.job_title)
      end
    end

    context "when there are no jobs within the selected filters" do
      let!(:inline_component) { render_inline(subject) }

      it "uses the correct no jobs text ('with filters')" do
        expect(rendered_component).to include(I18n.t("jobs.manage.published.no_jobs.with_filters"))
      end
    end
  end
end
