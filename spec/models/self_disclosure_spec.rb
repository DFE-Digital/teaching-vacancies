require "rails_helper"

RSpec.describe SelfDisclosure do
  let(:self_disclosure_request) { create(:self_disclosure_request) }
  let(:job_application) { build(:job_application, self_disclosure_request:) }

  describe "#.find_or_create_by_and_prefill" do
    subject(:self_disclosure) { described_class.find_or_create_by_and_prefill!(job_application) }

    %i[previous_names city country postcode phone_number].each do |field|
      it { expect(self_disclosure[field]).to eq(job_application[field]) }
    end

    it { expect(self_disclosure.name).to eq(job_application.name) }
    it { expect(self_disclosure.address_line_1).to eq(job_application.street_address) }
  end

  describe ".prefill" do
    subject(:self_disclosure) { build(:self_disclosure, :pending) }

    before { self_disclosure.prefill(job_application) }

    %i[previous_names city country postcode phone_number].each do |field|
      it { expect(self_disclosure[field]).to eq(job_application[field]) }
    end

    it { expect(self_disclosure.name).to eq(job_application.name) }
    it { expect(self_disclosure.address_line_1).to eq(job_application.street_address) }
  end
end
