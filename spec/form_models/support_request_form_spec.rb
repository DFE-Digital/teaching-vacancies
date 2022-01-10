require "rails_helper"

RSpec.describe SupportRequestForm, type: :model do
  subject(:form) { described_class.new(params) }

  let(:is_for_whole_site) { "yes" }
  let(:page) { nil }

  let(:params) do
    {
      email_address: "test@example.com",
      is_for_whole_site:,
      issue: "Help!",
      name: "A User",
      page:,
    }
  end

  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to validate_presence_of(:email_address) }
  it { is_expected.to allow_value("email@example.com").for(:email_address) }
  it { is_expected.to_not allow_value("invalid@email@com").for(:email_address) }

  it { is_expected.to validate_inclusion_of(:is_for_whole_site).in_array(%w[yes no]) }

  it { is_expected.to validate_presence_of(:issue) }
  it { is_expected.to validate_length_of(:issue).is_at_most(1200) }

  describe "#page" do
    context "when the request is for the whole site" do
      let(:is_for_whole_site) { "yes" }

      it { is_expected.not_to validate_presence_of(:page) }

      it "defaults the page to 'Teaching Vacancies'" do
        expect(form.page).to eq("Teaching Vacancies")
      end
    end

    context "when the request is for a specific page" do
      let(:is_for_whole_site) { "no" }
      let(:page) { "That one page" }

      it { is_expected.to validate_presence_of(:page) }

      it "returns the given page" do
        expect(form.page).to eq(page)
      end
    end
  end
end
