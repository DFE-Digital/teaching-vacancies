require "rails_helper"

RSpec.describe "non-existent pages" do
  it "returns a 404 for html" do
    get "/foo"
    expect(response).to have_http_status(404)
    expect(response.header["Content-Type"]).to include "text/html"
    expect(response.body).to include("Page not found")
  end

  it "returns a 404 for js" do
    get "/foo.js"
    expect(response).to have_http_status(404)
    expect(response.body).to be_empty
  end

  it "returns a 404 for json" do
    get "/foo.json"
    expect(response).to have_http_status(404)
    expect(response.header["Content-Type"]).to include "application/json"
    expect(JSON.parse(response.body)).to eq("error" => "Resource not found")
  end

  it "returns a 404 for xml" do
    get "/foo.xml"
    expect(response).to have_http_status(404)
    expect(response.header["Content-Type"]).to include "application/xml"
    expect(response.body).to be_empty
  end

  it "returns a 404 for unknown formats" do
    get "/foo.unknown"
    expect(response).to have_http_status(404)
    expect(response.body).to be_empty
  end
end