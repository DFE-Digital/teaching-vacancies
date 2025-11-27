require "rails_helper"

RSpec.describe "support_users/publisher_ats_api_clients/index" do
  let(:organisation) { create(:school) }
  let(:vacancy_one) { create(:vacancy, :external, organisations: [organisation], created_at: 2.days.ago) }
  let(:vacancy_two) { create(:vacancy, :external, organisations: [organisation], created_at: 1.day.ago) }
  let(:api_client) { create(:publisher_ats_api_client, vacancies: [vacancy_one, vacancy_two], created_at: 3.days.ago) }

  before do
    assign :api_clients, [api_client]

    render
  end

  it "shows some data" do
    expect(rendered.html.css("td").map(&:text))
      .to eq(
        ["Big MAT ATS",
         vacancy_one.created_at.to_fs,
         "2",
         "1",
         api_client.created_at.to_fs,
         " 6 November 2024 2:31pm"],
      )
  end
end
