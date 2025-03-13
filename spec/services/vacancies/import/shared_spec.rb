require "rails_helper"

class Vacancies::Import::Shared::Test
  extend Vacancies::Import::Shared
end

RSpec.describe "Vacancies::Import::Shared" do
  describe "#map_middle_school_phase" do
    subject(:klass) { Vacancies::Import::Shared::Test }

    context "when school is middle-deemed-primary" do
      let(:phase) { "middle_deemed_primary" }

      it "maps to primary" do
        expect(klass.map_middle_school_phase(phase)).to eq(%w[primary])
      end
    end

    context "when school is middle-deemed-secondayr" do
      let(:phase) { "middle_deemed_secondary" }

      it "maps to secondary" do
        expect(klass.map_middle_school_phase(phase)).to eq(%w[secondary])
      end
    end

    context "when school is not mapped as middle" do
      let(:phase) { "not_applicable" }

      it "maps to primary secondary" do
        expect(klass.map_middle_school_phase(phase)).to eq(%w[primary secondary])
      end
    end
  end
end
