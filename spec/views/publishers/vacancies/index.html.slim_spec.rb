require "rails_helper"

RSpec.describe "publishers/vacancies/index" do
  let(:organisation) { build_stubbed(:school, name: "Salisbury School") }
  let(:publisher) { build_stubbed(:publisher) }

  before do
    allow(view).to receive(:current_organisation).and_return(organisation)
    sign_in(publisher, scope: :publisher)
    assign :organisation, organisation
    assign :selected_type, :live
    assign :vacancy_types, []
    assign :vacancies, []
    assign :count, 0
    assign :sort, Publishers::VacancySort.new(organisation, :live)
    assign :publisher_preference, build_stubbed(:publisher_preference, organisation: organisation)
    assign :selected_organisation_ids, []
    render
  end

  after { sign_out publisher }

  it "has the school name on the page" do
    expect(rendered).to have_content("Salisbury School")
  end

  it "has a start page link" do
    expect(rendered).to have_link I18n.t("buttons.create_job"), href: organisation_jobs_start_path
  end
end
