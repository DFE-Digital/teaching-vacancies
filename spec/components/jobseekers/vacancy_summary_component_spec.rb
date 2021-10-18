require "rails_helper"

RSpec.describe Jobseekers::VacancySummaryComponent, type: :component do
  let(:vacancy_presenter) { VacancyPresenter.new(vacancy) }

  context "when vacancy job_location is at_one_school" do
    let(:vacancy) { create(:vacancy, :at_one_school, working_patterns: ["part_time"], organisations: [organisation]) }

    before { render_inline(described_class.new(vacancy: vacancy_presenter)) }

    context "when vacancy parent_organisation is a School" do
      let(:organisation) { create(:school) }

      it "renders the title" do
        expect(rendered_component).to include(vacancy_presenter.job_title)
      end

      it "renders the annual salary" do
        expect(rendered_component).to include(I18n.t("jobs.annual_salary"))
        expect(rendered_component).to include(vacancy_presenter.salary)
      end

      it "renders the actual salary" do
        expect(rendered_component).to include(I18n.t("jobs.actual_salary"))
        expect(rendered_component).to include(vacancy_presenter.actual_salary)
      end

      it "renders the address" do
        expect(rendered_component).to include(vacancy_full_job_location(vacancy))
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

      it "renders the date and time it expires at" do
        expect(rendered_component).to include(format_time_to_datetime_at(vacancy.expires_at))
      end

      context "when vacancy has actual_salary not defined" do
        let(:vacancy) { create(:vacancy, :at_one_school, working_patterns: ["full_time"], actual_salary: "", organisations: [organisation]) }

        it "does not renders the actual salary" do
          expect(rendered_component).to include(I18n.t("jobs.salary"))
          expect(rendered_component).not_to include(I18n.t("jobs.annual_salary"))
        end
      end
    end
  end

  context "when vacancy job_location is at_multiple_schools" do
    let!(:organisation) { create(:trust, schools: [school1, school2, school3]) }
    let(:school1) { create(:school, :catholic, school_type: "Academy") }
    let(:school2) { create(:school, :catholic, school_type: "Academy") }
    let(:school3) { create(:school, :catholic, school_type: "Academy", minimum_age: 16) }
    let(:vacancy) { create(:vacancy, :at_multiple_schools, organisations: [school1, school2, school3]) }

    before { render_inline(described_class.new(vacancy: vacancy_presenter)) }

    it "renders the job location" do
      expect(rendered_component).to include("#{I18n.t('publishers.organisations.readable_job_location.at_multiple_schools')}, #{organisation.name}")
    end

    it "renders the unique school types" do
      organisation_types(vacancy.organisations).each { |school_type| expect(rendered_component).to include(school_type) }
    end
  end

  context "when vacancy job_location is central_office" do
    let(:organisation) { create(:trust) }
    let(:vacancy) do
      create(:vacancy, :central_office, organisations: [organisation])
    end

    before do
      render_inline(described_class.new(vacancy: vacancy_presenter))
    end

    it "renders the address" do
      assert_includes rendered_component, vacancy_full_job_location(vacancy)
    end

    it "renders the trust type label" do
      expect(rendered_component).to include(I18n.t("jobs.trust_type"))
    end

    it "renders the trust type" do
      expect(rendered_component).to include(vacancy.parent_organisation.group_type)
    end
  end
end
