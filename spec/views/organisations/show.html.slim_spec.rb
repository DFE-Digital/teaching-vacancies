require "rails_helper"

RSpec.describe "organisations/show", type: :view do
  subject(:show_view) { Capybara.string(rendered) }

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
        expect(show_view).to have_content(vacancy.salary)
      end
    end

    context "with actual salary" do
      let(:vacancy) { build_stubbed(:vacancy, :without_any_money, actual_salary: Faker::Number.number(digits: 5)) }

      it "shows actual salary" do
        expect(show_view).to have_content(vacancy.actual_salary)
      end
    end

    context "with hourly rate" do
      let(:vacancy) { build_stubbed(:vacancy, :without_any_money, hourly_rate: Faker::Alphanumeric.alpha(number: 7)) }

      it "shows hourly rate" do
        expect(show_view).to have_content(vacancy.hourly_rate)
      end
    end

    context "with pay scale" do
      let(:vacancy) { build_stubbed(:vacancy, :without_any_money, pay_scale: Faker::Alphanumeric.alpha(number: 7)) }

      it "shows pay scale" do
        expect(show_view).to have_content(vacancy.pay_scale)
      end
    end

    context "with all" do
      let(:vacancy) { build_stubbed(:vacancy) }

      it "shows salary" do
        expect(show_view).to have_content(vacancy.salary)
      end

      it "shows actual salary" do
        expect(show_view).to have_content(vacancy.actual_salary)
      end

      it "shows hourly rate" do
        expect(show_view).to have_content(vacancy.hourly_rate)
      end

      it "shows pay scale" do
        expect(show_view).to have_content(vacancy.pay_scale)
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
      has_profile_summary?(show_view, organisation)
    end

    it "displays the organisation's description" do
      expect(show_view).to have_content(organisation.description.to_plain_text)
    end

    it "displays the organisation's safeguarding information" do
      expect(show_view).to have_content(organisation.safeguarding_information)
    end

    it "has a list of live jobs at the organisation" do
      has_list_of_live_jobs?(show_view, organisation.vacancies)
    end

    it "has a map showing the organisation's location" do
      expect(show_view).to have_content(I18n.t("organisations.map.heading"))
    end

    it "can create a job alert for jobs at the organisation" do
      has_button_to_create_job_alert?(show_view, organisation)
    end

    it "has a link to the school group's profile" do
      expect(show_view).to have_link(href: organisation_path(school_group))
    end

    it "flags the jobs that allow applications through Teaching Vacancies" do
      expect(show_view.find("h3 span", text: vacancy.job_title))
        .to have_sibling("strong.govuk-tag--green", text: I18n.t("vacancies.listing.enable_job_applications_tag"))
      expect(show_view.find("h3 span", text: vacancy_without_apply.job_title))
        .to have_no_sibling("strong.govuk-tag--green", text: I18n.t("vacancies.listing.enable_job_applications_tag"))
    end

    context "when the trust has no extra live vacancies" do
      it "doesn't show the trust hyperlink to vacancies outside the school" do
        expect(show_view).to have_no_link("View #{vacancies.size} jobs across #{school_group.name}", href: organisation_path(school_group))
      end
    end

    context "when the trust has extra live vacancies" do
      before do
        create(:vacancy, organisations: [school_group])
        assign :organisation, organisation
        assign :vacancies, vacancies
        render
      end

      it "shows the trust hyperlink to vacancies outside the school" do
        expect(show_view).to have_link("View 3 jobs across #{school_group.name}", href: organisation_path(school_group))
      end
    end
  end
end
