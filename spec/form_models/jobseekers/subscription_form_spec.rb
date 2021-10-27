require "rails_helper"

RSpec.shared_examples "a form that correctly calls Search::RadiusBuilder" do
  it "sets the radius and location attributes" do
    expect(Search::RadiusBuilder).to receive(:new).with(location, radius).and_return(radius_builder)
    expect(subject.radius).to eq(expected_radius)
    expect(subject.location).to eq(location)
  end
end

RSpec.shared_examples "a form with the correct attributes" do
  it "sets the keyword, job_roles, phases, and working_patterns attributes" do
    expect(subject.keyword).to eq(keyword)
    expect(subject.job_roles).to eq(job_roles)
    expect(subject.phases).to eq(phases)
    expect(subject.working_patterns).to eq(working_patterns)
  end
end

RSpec.describe Jobseekers::SubscriptionForm, type: :model do
  subject { described_class.new(params) }

  describe "#initialize" do
    let(:radius_builder) { instance_double(Search::RadiusBuilder) }
    let(:expected_radius) { "1000" }
    let(:keyword) { "jobs" }
    let(:job_roles) { %w[teacher wizard] }
    let(:phases) { %w[primary ternary] }
    let(:working_patterns) { %w[twenty_four_seven] }

    before { allow(radius_builder).to receive(:radius).and_return(expected_radius) }

    context "when keyword, job_roles, phases, working_patterns are provided in the params" do
      let(:params) { { keyword: keyword, job_roles: job_roles, phases: phases, working_patterns: working_patterns } }

      it_behaves_like "a form with the correct attributes"
    end

    context "when keyword, job_roles, phases, working_patterns are provided in the search_criteria param" do
      let(:params) { { search_criteria: { keyword: keyword, job_roles: job_roles, phases: phases, working_patterns: working_patterns } } }

      it_behaves_like "a form with the correct attributes"
    end

    context "when a radius is provided in the params" do
      let(:radius) { "1" }

      context "when a location is provided in the params" do
        let(:location) { "North Nowhere" }
        let(:params) { { radius: radius, location: location } }

        it_behaves_like "a form that correctly calls Search::RadiusBuilder"
      end

      context "when a location is provided in the search_criteria param" do
        let(:location) { "North Nowhere" }
        let(:params) { { radius: radius, search_criteria: { location: location } } }

        it_behaves_like "a form that correctly calls Search::RadiusBuilder"
      end

      context "when a location is not provided" do
        let(:location) { nil }
        let(:params) { { radius: radius } }

        it_behaves_like "a form that correctly calls Search::RadiusBuilder"
      end
    end

    context "when a radius is provided in the search_criteria param" do
      let(:radius) { "1" }

      context "when a location is provided in the params" do
        let(:location) { "North Nowhere" }
        let(:params) { { search_criteria: { radius: radius }, location: location } }

        it_behaves_like "a form that correctly calls Search::RadiusBuilder"
      end

      context "when a location is provided in the search_criteria param" do
        let(:location) { "North Nowhere" }
        let(:params) { { search_criteria: { radius: radius, location: location } } }

        it_behaves_like "a form that correctly calls Search::RadiusBuilder"
      end

      context "when a location is not provided" do
        let(:location) { nil }
        let(:params) { { search_criteria: { radius: radius } } }

        it_behaves_like "a form that correctly calls Search::RadiusBuilder"
      end
    end

    context "when a radius is not provided" do
      let(:radius) { nil }

      context "when a location is provided in the params" do
        let(:location) { "North Nowhere" }
        let(:params) { { location: location } }

        it_behaves_like "a form that correctly calls Search::RadiusBuilder"
      end

      context "when a location is provided in the search_criteria param" do
        let(:location) { "North Nowhere" }
        let(:params) { { search_criteria: { location: location } } }

        it_behaves_like "a form that correctly calls Search::RadiusBuilder"
      end

      context "when a location is not provided" do
        let(:location) { nil }
        let(:params) { {} }

        it_behaves_like "a form that correctly calls Search::RadiusBuilder"
      end
    end
  end

  describe "#search_criteria_hash" do
    let(:params) { { keyword: keyword, job_roles: job_roles, radius: radius, location: location } }
    let(:keyword) { "physics" }
    let(:radius) { nil }
    let(:location) { nil }
    let(:job_roles) { [] }

    context "when a value is blank" do
      let(:keyword) { "" }
      let(:job_roles) { %w[teacher] }

      it "is deleted from the hash" do
        expect(subject.search_criteria_hash).to eq({ job_roles: job_roles })
      end
    end

    context "when a value is empty" do
      let(:job_roles) { [] }

      it "is deleted from the hash" do
        expect(subject.search_criteria_hash).to eq({ keyword: keyword })
      end
    end

    context "when radius is present" do
      let(:radius) { "10" }

      context "when location is not present" do
        it "omits radius value from the hash" do
          expect(subject.search_criteria_hash).to eq({ keyword: keyword })
        end
      end

      context "when location is present" do
        let(:location) { "North Nowhere" }

        it "includes radius value in the hash" do
          expect(subject.search_criteria_hash).to eq({ keyword: keyword, location: location, radius: "10" })
        end
      end
    end
  end

  describe "#validations" do
    let(:params) { {} }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:frequency) }
    it { is_expected.to allow_value("valid@example.com").for(:email) }
    it { is_expected.not_to allow_value("invalid_email").for(:email) }

    context "when job alert already exists" do
      let(:params) { { email: "test@example.net", frequency: "daily", keyword: "maths" } }

      before { allow(Subscription).to receive_message_chain(:where, :exists?).and_return(true) }

      it "validates uniqueness of job alert" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:base]).to include(I18n.t("subscriptions.errors.duplicate_alert"))
      end
    end

    context "when location and no other field are selected" do
      let(:params) { { location: "Anywhere but a polygon" } }

      it "validates location_and_one_other_criterion_selected" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:base]).to include(I18n.t("subscriptions.errors.no_location_and_other_criterion_selected"))
      end
    end

    context "when one other field selected but no location" do
      let(:params) { { keyword: "Maths" } }

      it "validates location_and_one_other_criterion_selected" do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:base]).to include(I18n.t("subscriptions.errors.no_location_and_other_criterion_selected"))
      end
    end
  end
end
