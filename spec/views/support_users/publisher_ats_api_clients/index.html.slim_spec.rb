require "rails_helper"

RSpec.describe "support_users/publisher_ats_api_clients/index" do
  let(:api_client) { build_stubbed(:publisher_ats_api_client, vacancies: build_stubbed_list(:vacancy, 2)) }

  before do
    assign :api_clients, [api_client]

    render
  end

  it "shows some data" do
    expect(rendered.html.css("td").map(&:text))
      .to eq(
        ["Big MAT ATS",
         api_client.created_at.to_fs,
         "0",
         "2",
         api_client.created_at.to_fs,
         " 6 November 2024 2:31pm"],
      )
  end
end
