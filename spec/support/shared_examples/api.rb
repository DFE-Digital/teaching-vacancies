RSpec.shared_examples "X-Robots-Tag" do
  describe "X-Robots-Tag" do
    it "robots are asked to index but not to follow" do
      expect(response.headers["X-Robots-Tag"]).to eq("noarchive")
    end
  end
end

RSpec.shared_examples "charset is UTF-8" do
  it "charset is set to UTF-8" do
    expect(response.charset.to_s.downcase).to eq("utf-8")
  end
end

RSpec.shared_examples "Content-Type JSON" do
  describe "Content-Type" do
    it_behaves_like "charset is UTF-8"

    it "type is set to application/json" do
      expect(response.content_type).to include("application/json")
    end
  end
end
