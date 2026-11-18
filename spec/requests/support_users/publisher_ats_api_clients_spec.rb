require "rails_helper"

RSpec.describe "Listing ATS API clients" do
  before { sign_in(create(:support_user), scope: :support_user) }

  context "when there are API clients" do
    let!(:api_client) { create(:publisher_ats_api_client) }
    let!(:other_client) { create(:publisher_ats_api_client, name: "Other ATS") }
    let!(:empty_client) { create(:publisher_ats_api_client, name: "Empty ATS") }
    let(:school) { create(:school) }
    let(:other_school) { create(:school) }
    let!(:first_vacancy) do
      create(:external_vacancy, publisher_ats_api_client: api_client, organisations: [school, other_school], created_at: 3.days.ago)
    end
    let!(:other_client_vacancy) do
      create(:external_vacancy, publisher_ats_api_client: other_client, organisations: [school], created_at: 1.day.ago)
    end

    before do
      create(:external_vacancy, publisher_ats_api_client: api_client, organisations: [school], created_at: 2.days.ago)
    end

    it "shows each client's first vacancy, vacancy count and distinct school count, including clients without vacancies" do
      get support_users_publisher_ats_api_clients_path

      expect(response).to have_http_status(:success)
      rows = Nokogiri::HTML(response.body).css("tbody tr").map do |row|
        row.css("td").first(4).map { |cell| cell.text.strip }
      end
      expect(rows).to contain_exactly(
        [api_client.name, first_vacancy.created_at.to_fs.strip, "2", "2"],
        [other_client.name, other_client_vacancy.created_at.to_fs.strip, "1", "1"],
        [empty_client.name, "", "0", "0"],
      )
    end
  end

  context "when there are no API clients" do
    it "shows the list without any client rows" do
      get support_users_publisher_ats_api_clients_path

      expect(response).to have_http_status(:success)
      expect(Nokogiri::HTML(response.body).css("tbody tr")).to be_empty
    end
  end
end
