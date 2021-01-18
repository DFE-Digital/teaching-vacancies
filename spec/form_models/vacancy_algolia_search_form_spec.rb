require "rails_helper"

RSpec.describe VacancyAlgoliaSearchForm, type: :model do
  let(:subject) { described_class.new(params) }

  describe "#strip_trailing_whitespaces_from_params" do
    context "when user input contains trailing whitespace" do
      let(:keyword) { " teacher " }
      let(:location) { "the big smoke " }
      let(:location_category) { " whitespace county" }
      let(:params) do
        { keyword: keyword, location: location, location_category: location_category }
      end

      it "strips the whitespace before saving the attribute" do
        expect(subject.keyword).to eq "teacher"
        expect(subject.location).to eq "the big smoke"
        expect(subject.location_category).to eq "whitespace county"
      end
    end
  end
end
