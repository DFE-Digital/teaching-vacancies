require "rails_helper"

RSpec.describe "support_users/publisher_ats_api_clients/index" do
  let(:organisation) { create(:school) }
  let(:vacancy_one) { create(:external_vacancy, organisations: [organisation], created_at: 2.days.ago) }
  let(:vacancy_two) { create(:external_vacancy, organisations: [organisation], created_at: 1.day.ago) }
  let(:api_client) { create(:publisher_ats_api_client, vacancies: [vacancy_one, vacancy_two], created_at: 3.days.ago) }
  let(:first_vacancy_dates) { { api_client.id => vacancy_one.created_at } }
  let(:vacancy_counts) { { api_client.id => 2 } }
  let(:unique_organisation_counts) { { api_client.id => 1 } }

  before do
    assign :api_clients, [api_client]
    assign :first_vacancy_dates, first_vacancy_dates
    assign :vacancy_counts, vacancy_counts
    assign :unique_organisation_counts, unique_organisation_counts

    render
  end

  context "when the client has vacancies" do
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

  context "when the client has no vacancies" do
    let(:api_client) { create(:publisher_ats_api_client) }
    let(:first_vacancy_dates) { {} }
    let(:vacancy_counts) { {} }
    let(:unique_organisation_counts) { {} }

    it "shows a blank first vacancy date and zero counts" do
      expect(rendered.html.css("td").map(&:text).first(4)).to eq(["Big MAT ATS", "", "0", "0"])
    end
  end
end
