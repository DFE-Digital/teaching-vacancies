require "rails_helper"

RSpec.describe Jobseekers::VacancySummaryComponent, type: :component do
  let(:vacancy_presenter) { VacancyPresenter.new(vacancy) }

  context "when vacancy job_location is at_one_school" do
    let(:vacancy) do
      create(:vacancy, :at_one_school, organisation_vacancies_attributes: [{ organisation: organisation }])
    end

    before do
      render_inline(described_class.new(vacancy: vacancy_presenter))
    end

    context "when vacancy parent_organisation is a School" do
      let(:organisation) { create(:school) }

      it "renders the title" do
        expect(rendered_component).to include(vacancy_presenter.job_title)
      end

      it "renders the salary" do
        expect(rendered_component).to include(vacancy_presenter.salary)
      end

      it "renders the address" do
        expect(rendered_component).to include(location(vacancy.parent_organisation))
      end

      it "renders the school type label" do
        expect(rendered_component).to include(I18n.t("jobs.school_type"))
      end

      it "renders the school type" do
        expect(rendered_component).to include(organisation_type(vacancy.organisation))
      end

      it "renders the working pattern" do
        expect(rendered_component).to include(vacancy_presenter.working_patterns)
      end

      context "when expires_at is nil" do
        let(:vacancy) do
          create(:vacancy, :at_one_school, expires_at: nil, organisation_vacancies_attributes: [
            { organisation: organisation },
          ])
        end

        it "renders the date it expires on but not the time" do
          expect(rendered_component).to include(format_date(vacancy.expires_on))
        end
      end

      context "when expiry time is not nil" do
        it "renders the date and time it expires at" do
          expect(rendered_component).to include(expiry_date_and_time(vacancy))
        end
      end
    end
  end

  context "when vacancy job_location is at_multiple_schools" do
    let(:organisation) { create(:trust) }
    let(:school1) { create(:school, :catholic, school_type: "Academy") }
    let(:school2) { create(:school, :catholic, school_type: "Academy") }
    let(:school3) { create(:school, :catholic, school_type: "Academy", minimum_age: 16) }
    let(:vacancy) do
      create(:vacancy, :at_multiple_schools, organisation_vacancies_attributes: [
        { organisation: school1 }, { organisation: school2 }, { organisation: school3 }
      ])
    end

    before do
      SchoolGroupMembership.find_or_create_by(school_id: school1.id, school_group_id: organisation.id)
      SchoolGroupMembership.find_or_create_by(school_id: school2.id, school_group_id: organisation.id)
      SchoolGroupMembership.find_or_create_by(school_id: school3.id, school_group_id: organisation.id)
      render_inline(described_class.new(vacancy: vacancy_presenter))
    end

    it "renders the job location" do
      expect(rendered_component).to include(location(vacancy.parent_organisation, job_location: "at_multiple_schools"))
    end

    it "renders the unique school types" do
      organisation_types(vacancy.organisations).each { |school_type| expect(rendered_component).to include(school_type) }
    end
  end

  context "when vacancy job_location is central_office" do
    let(:organisation) { create(:trust) }
    let(:vacancy) do
      create(:vacancy, :central_office, organisation_vacancies_attributes: [{ organisation: organisation }])
    end

    before do
      render_inline(described_class.new(vacancy: vacancy_presenter))
    end

    it "renders the address" do
      assert_includes rendered_component, location(vacancy.parent_organisation)
    end

    it "renders the trust type label" do
      expect(rendered_component).to include(I18n.t("jobs.trust_type"))
    end

    it "renders the trust type" do
      expect(rendered_component).to include(vacancy.parent_organisation.group_type)
    end
  end
end
