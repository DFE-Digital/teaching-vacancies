require "rails_helper"

RSpec.describe Publishers::VacanciesComponent, type: :component do
  let(:sort) { Publishers::VacancySort.new(organisation, selected_type).update(column: "job_title") }
  let(:selected_type) { "published" }
  let(:filters) { {} }
  let(:filters_form) { Publishers::ManagedOrganisationsForm.new(filters) }
  let(:sort_form) { SortForm.new(sort.column) }
  let(:email) { "publisher@email.com" }

  subject do
    described_class.new(
      organisation: organisation, sort: sort, selected_type: selected_type, filters: filters, filters_form: filters_form, sort_form: sort_form, email: email,
    )
  end

  context "when organisation has no active vacancies" do
    let(:organisation) { create(:school, name: "A school with no published or draft jobs") }
    let!(:vacancy) { create(:vacancy, :trashed, organisation_vacancies_attributes: [{ organisation: organisation }]) }

    before { render_inline(subject) }

    it "does not render the vacancies component" do
      expect(rendered_component).to be_blank
    end
  end

  context "when organisation has active vacancies" do
    context "when organisation is a school" do
      let(:organisation) { create(:school, name: "A school with jobs") }
      let(:vacancy) { create(:vacancy, :published) }

      before { vacancy.organisation_vacancies.create(organisation: organisation) }

      let!(:inline_component) { render_inline(subject) }

      it "renders the vacancies component" do
        expect(inline_component.css(".moj-filter-layout__content").to_html).not_to be_blank
      end

      it "renders the number of jobs in the heading" do
        expect(inline_component.css("h1.govuk-heading-l").text).to include("Published jobs (1)")
      end

      it "renders the vacancy job title in the table" do
        expect(inline_component.css(".card-component").to_html).to include(vacancy.job_title)
      end

      it "does not render the vacancy readable job location in the table" do
        expect(inline_component.css(".card-component #vacancy_location").to_html).to be_blank
      end

      it "does not render the filters sidebar" do
        expect(inline_component.css('.new_publishers_managed_organisations_form input[type="submit"]')).to be_blank
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
      let!(:vacancy) do
        create(:vacancy, :published, :central_office,
               organisation_vacancies_attributes: [{ organisation: organisation }])
      end
      let(:filters) { { managed_school_ids: [], managed_organisations: "all" } }

      before do
        organisation.school_group_memberships.create(school: open_school)
        organisation.school_group_memberships.create(school: closed_school)
      end

      let!(:inline_component) { render_inline(subject) }

      it "renders the vacancies component" do
        expect(inline_component.css(".moj-filter-layout__content").to_html).not_to be_blank
      end

      it "renders the number of jobs in the heading" do
        expect(inline_component.css("h1.govuk-heading-l").text).to include("Published jobs (1)")
      end

      it "renders the vacancy job title in the table" do
        expect(inline_component.css(".card-component").to_html).to include(vacancy.job_title)
      end

      it "renders the vacancy readable job location in the table" do
        expect(
          inline_component.css(".card-component__header").to_html,
        ).to include(vacancy.readable_job_location)
      end

      it "renders the filters sidebar" do
        expect(
          inline_component.css('.new_publishers_managed_organisations_form input[type="submit"]').attribute("value").value,
        ).to eq(I18n.t("buttons.apply_filters"))
      end

      it "renders the trust head office as a filter option" do
        expect(inline_component.css(".new_publishers_managed_organisations_form").to_html).to include("Trust head office")
      end

      it "renders the open school as a filter option" do
        expect(inline_component.css(".new_publishers_managed_organisations_form").to_html).to include("Open school")
      end

      it "does not render the closed school as a filter option" do
        expect(inline_component.css(".new_publishers_managed_organisations_form").to_html).not_to include("Closed school")
      end
    end

    context "when the organisation is a local authority" do
      let(:organisation) { create(:local_authority) }
      let(:open_school) { create(:school, name: "Open school") }
      let(:closed_school) { create(:school, :closed, name: "Closed school") }
      let!(:vacancy) do
        create(:vacancy, :published, :at_one_school,
               organisation_vacancies_attributes: [{ organisation: open_school }])
      end
      let(:filters) { { managed_school_ids: [], managed_organisations: "all" } }

      before do
        organisation.school_group_memberships.create(school: open_school)
        organisation.school_group_memberships.create(school: closed_school)
      end

      let!(:inline_component) { render_inline(subject) }

      it "renders the vacancies component" do
        expect(inline_component.css(".moj-filter-layout__content").to_html).not_to be_blank
      end

      it "renders the number of jobs in the heading" do
        expect(inline_component.css("h1.govuk-heading-l").text).to include("Published jobs (1)")
      end

      it "renders the vacancy job title in the table" do
        expect(inline_component.css(".card-component").to_html).to include(vacancy.job_title)
      end

      it "renders the vacancy readable job location in the table" do
        expect(
          inline_component.css(".card-component__header").to_html,
        ).to include(vacancy.readable_job_location)
      end

      it "renders the filters sidebar" do
        expect(
          inline_component.css('.new_publishers_managed_organisations_form input[type="submit"]').attribute("value").value,
        ).to eq(I18n.t("buttons.apply_filters"))
      end

      it "does not render the trust head office as a filter option" do
        expect(inline_component.css(".new_publishers_managed_organisations_form").to_html).not_to include("Trust head office")
      end

      it "renders the open school as a filter option" do
        expect(inline_component.css(".new_publishers_managed_organisations_form").to_html).to include("Open school")
      end

      it "does not render the closed school as a filter option" do
        expect(inline_component.css(".new_publishers_managed_organisations_form").to_html).not_to include("Closed school")
      end

      context "when there are no jobs within the selected vacancy type" do
        let(:selected_type) { "draft" }

        it "uses the correct 'no jobs' text ('no filters')" do
          expect(rendered_component).to include(I18n.t("jobs.manage.draft.no_jobs.no_filters"))
        end
      end
    end
  end

  context "when filtering results" do
    let(:organisation) { create(:trust) }
    let(:school_oxford) { create(:school, name: "Oxford") }
    let(:school_cambridge) { create(:school, name: "Cambridge") }
    let(:filters) { { managed_school_ids: [school_oxford.id], managed_organisations: "" } }
    let!(:vacancy_cambridge) do
      create(:vacancy, :published, :at_one_school,
             organisation_vacancies_attributes: [{ organisation: organisation }, { organisation: school_cambridge }],
             readable_job_location: school_cambridge.name)
    end

    context "when a relevant job exists" do
      let!(:vacancy_oxford) do
        create(:vacancy, :published, :at_one_school,
               organisation_vacancies_attributes: [{ organisation: school_oxford }],
               readable_job_location: school_oxford.name)
      end

      let!(:inline_component) { render_inline(subject) }

      it "renders the vacancy in Oxford" do
        expect(rendered_component).to include(school_oxford.name)
      end

      it "does not render the vacancy in Cambridge" do
        expect(rendered_component).not_to include(school_cambridge.name)
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
