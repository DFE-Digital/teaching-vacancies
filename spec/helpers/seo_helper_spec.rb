require "rails_helper"

RSpec.describe SeoHelper do
  describe "#seo_friendly_url" do
    let(:link1) { "https://localhost:3000/teaching-jobs-in-st.%20helens" }
    let(:link2) { "https://localhost:3000/teaching-jobs-in-education_support" }

    it "returns an SEO friendly url" do
      expect(seo_friendly_url(link1)).to eq("https://localhost:3000/teaching-jobs-in-st-helens")
      expect(seo_friendly_url(link2)).to eq("https://localhost:3000/teaching-jobs-in-education-support")
    end
  end
end
