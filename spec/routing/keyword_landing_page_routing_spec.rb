require "rails_helper"

RSpec.describe "keyword landing page routing" do
  it "routes keyword/location URLs to the vacancies controller" do
    expect(get("/teaching-assistant-jobs/birmingham")).to route_to(
      controller: "vacancies",
      action: "index",
      keyword_landing_page_name: "teaching-assistant",
      location_landing_page_name: "birmingham",
    )
  end
end
