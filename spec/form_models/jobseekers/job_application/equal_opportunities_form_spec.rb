require "rails_helper"

RSpec.describe Jobseekers::JobApplication::EqualOpportunitiesForm, type: :model do
  it { is_expected.to validate_inclusion_of(:disability).in_array(%w[no prefer_not_to_say yes]) }
  it { is_expected.to validate_inclusion_of(:gender).in_array(%w[man other prefer_not_to_say woman]) }
  it { is_expected.to validate_inclusion_of(:orientation).in_array(%w[bisexual gay_or_lesbian heterosexual other prefer_not_to_say]) }
  it { is_expected.to validate_inclusion_of(:ethnicity).in_array(%w[asian black mixed other prefer_not_to_say white]) }
  it { is_expected.to validate_inclusion_of(:religion).in_array(%w[buddhist christian hindu jewish muslim none other prefer_not_to_say sikh]) }

  context "when gender is other" do
    before { allow(subject).to receive(:gender).and_return("other") }

    it { is_expected.to validate_presence_of(:gender_description) }
  end

  context "when orientation is other" do
    before { allow(subject).to receive(:orientation).and_return("other") }

    it { is_expected.to validate_presence_of(:orientation_description) }
  end

  context "when ethnicity is other" do
    before { allow(subject).to receive(:ethnicity).and_return("other") }

    it { is_expected.to validate_presence_of(:ethnicity_description) }
  end

  context "when religion is other" do
    before { allow(subject).to receive(:religion).and_return("other") }

    it { is_expected.to validate_presence_of(:religion_description) }
  end
end
