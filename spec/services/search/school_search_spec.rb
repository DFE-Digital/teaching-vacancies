require "rails_helper"

RSpec.describe Search::SchoolSearch do
  subject { described_class.new(form_hash, scope: scope) }

  let(:form_hash) do
    {
      name: name,
      location: ([location, radius] if location.present?),
    }.compact
  end

  let(:name) { nil }
  let(:location) { nil }
  let(:radius) { 10 }

  let(:scope) { School.all }

  context "when no filters (except for radius) are given" do
    it "returns unmodified scope" do
      expect(subject.organisations.to_sql).to eq(scope.to_sql)
    end
  end

  context "when location and radius are given" do
    let(:location) { "Sevenoaks" }

    it "returns scope modified by location search" do
      expect(subject.organisations.to_sql).to eq(scope.search_by_location(location, radius).to_sql)
    end
  end

  context "when only name is given" do
    let(:radius) { nil }
    let(:name) { "Bexleyheath Academy" }

    it "returns scope modified by name search" do
      expect(subject.organisations.to_sql).to eq(scope.search_by_name(name).to_sql)
    end
  end
end
