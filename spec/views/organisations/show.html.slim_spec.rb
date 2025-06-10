require "rails_helper"

RSpec.describe "organisations/show", type: :view do
  before do
    assign :organisation, organisation
    assign :vacancies, vacancies
    render
  end

  describe "displaying salaries" do
    let(:vacancies) { [vacancy] }
    let(:organisation) { build_stubbed(:school, vacancies: vacancies) }

    context "with salary" do
      let(:vacancy) { build_stubbed(:vacancy, :without_any_money, salary: Faker::Alphanumeric.alpha(number: 7)) }

      it "shows salary" do
        expect(rendered).to have_content(vacancy.salary)
      end
    end

    context "with actual salary" do
      let(:vacancy) { build_stubbed(:vacancy, :without_any_money, actual_salary: Faker::Number.number(digits: 5)) }

      it "shows actual salary" do
        expect(rendered).to have_content(vacancy.actual_salary)
      end
    end

    context "with hourly rate" do
      let(:vacancy) { build_stubbed(:vacancy, :without_any_money, hourly_rate: Faker::Alphanumeric.alpha(number: 7)) }

      it "shows hourly rate" do
        expect(rendered).to have_content(vacancy.hourly_rate)
      end
    end

    context "with pay scale" do
      let(:vacancy) { build_stubbed(:vacancy, :without_any_money, pay_scale: Faker::Alphanumeric.alpha(number: 7)) }

      it "shows pay scale" do
        expect(rendered).to have_content(vacancy.pay_scale)
      end
    end

    context "with all" do
      let(:vacancy) { build_stubbed(:vacancy) }

      it "shows salary" do
        expect(rendered).to have_content(vacancy.salary)
      end

      it "shows actual salary" do
        expect(rendered).to have_content(vacancy.actual_salary)
      end

      it "shows hourly rate" do
        expect(rendered).to have_content(vacancy.hourly_rate)
      end

      it "shows pay scale" do
        expect(rendered).to have_content(vacancy.pay_scale)
      end
    end
  end

  context "when the organisation is part of a school group" do
    let(:school_group) { create(:trust) }
    let(:organisation) { create(:school, school_groups: [school_group]) }
    let(:vacancy) { create(:vacancy, organisations: [organisation]) }
    let(:vacancy_without_apply) { create(:vacancy, :no_tv_applications, organisations: [organisation]) }
    let(:vacancies) { [vacancy, vacancy_without_apply] }

    it "displays a profile summary" do
      has_profile_summary?(rendered, organisation)
    end

    it "displays the organisation's description" do
      expect(rendered).to have_content(organisation.description)
    end

    it "displays the organisation's safeguarding information" do
      expect(rendered).to have_content(organisation.safeguarding_information)
    end

    it "has a list of live jobs at the organisation" do
      has_list_of_live_jobs?(rendered, organisation.vacancies)
    end

    it "has a map showing the organisation's location" do
      expect(rendered).to have_content(I18n.t("organisations.map.heading"))
    end

    it "can create a job alert for jobs at the organisation" do
      has_button_to_create_job_alert?(rendered, organisation)
    end

    it "has a link to the school group's profile" do
      expect(rendered).to have_link(href: organisation_path(school_group))
    end
  end
end
