require "rails_helper"

RSpec.describe Publishers::VacancySortingOptions do
  subject { described_class.new(organisation, vacancy_type) }

  context "for a School" do
    let(:organisation) { build_stubbed(:school) }

    context "by default" do
      let(:vacancy_type) { :any_old_type }

      it "returns the base set of options" do
        expect(subject.map(&:column)).to eq(%w[expires_on job_title])
      end
    end

    %i[pending draft].each do |status|
      context "for a `#{status}` status" do
        let(:vacancy_type) { status }

        it "returns the extended set of options" do
          expect(subject.map(&:column)).to eq(%w[expires_on job_title publish_on])
        end
      end
    end
  end

  context "for a SchoolGroup" do
    let(:organisation) { build_stubbed(:school_group) }

    context "by default" do
      let(:vacancy_type) { :any_old_type }

      it "returns the base set of options" do
        expect(subject.map(&:column)).to eq(%w[expires_on job_title readable_job_location])
      end
    end

    %i[pending draft].each do |status|
      context "for a `#{status}` status" do
        let(:vacancy_type) { status }

        it "returns the extended set of options" do
          expect(subject.map(&:column)).to eq(%w[expires_on job_title readable_job_location publish_on])
        end
      end
    end
  end
end
