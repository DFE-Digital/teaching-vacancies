require "rails_helper"

RSpec.describe Jobseekers::Qualifications::OtherForm, type: :model do
  subject { described_class.new(params) }
  let(:params) { {} }

  it { is_expected.to validate_presence_of(:category) }
  it { is_expected.to validate_presence_of(:finished_studying) }
  it { is_expected.to validate_presence_of(:institution) }
  it { is_expected.to validate_presence_of(:name) }

  context "when finished studying is false" do
    let(:params) { { "finished_studying" => "false" } }

    it { is_expected.to validate_presence_of(:finished_studying_details) }
  end

  context "when finished studying is true" do
    let(:params) { { "finished_studying" => "true" } }

    it { is_expected.to validate_numericality_of(:year).is_less_than_or_equal_to(Time.current.year) }
  end
end
