require "rails_helper"

RSpec.describe Vacancy do
  describe "organisation associations" do
    let(:school_group) { create(:trust, :with_geopoint, schools: [school_one, school_two]) }
    let(:school_one) { create(:school, name: "First school", phase: "primary") }
    let(:school_two) { create(:school, name: "Second school", phase: "primary") }
    let(:vacancy) { create(:vacancy, :ect_suitable, job_roles: %w[teacher], organisations: [school_group], phases: %w[primary], key_stages: %w[ks1]) }

    describe "#refresh_geolocation" do
      context "when associated with a school group (trust)" do
        it "uses the school group's geopoint" do
          expect(vacancy.geolocation).to eq(school_group.geopoint)
        end
      end

      context "when changing from school group to a single school" do
        before do
          vacancy.organisations = [school_one]
        end

        it "updates the geolocation to the school's geopoint" do
          expect(vacancy.geolocation).to eq(school_one.geopoint)
        end
      end

      context "when changing from school group to multiple schools" do
        before do
          vacancy.organisations = [school_one, school_two]
        end

        it "creates a multi-point geolocation" do
          expect(vacancy.geolocation).to be_a(RGeo::Geographic::SphericalMultiPointImpl)
          points = [school_one.geopoint, school_two.geopoint]
          expect(vacancy.geolocation.count).to eq(2)
          # We need to test that each point in the multipoint is one of our school geopoints
          vacancy.geolocation.each do |point|
            expect(points).to include(point)
          end
        end
      end

      context "when changing back to the school group" do
        before do
          vacancy.organisations = [school_one, school_two]
          vacancy.organisations = [school_group]
        end

        it "updates the geolocation back to the school group's geopoint" do
          expect(vacancy.geolocation).to eq(school_group.geopoint)
        end
      end
    end

    describe "#organisation" do
      context "when associated with a school group" do
        it "returns the school group" do
          expect(vacancy.organisation).to eq(school_group)
        end
      end

      context "when associated with a single school" do
        before do
          vacancy.organisations = [school_one]
        end

        it "returns the school" do
          expect(vacancy.organisation).to eq(school_one)
        end
      end

      context "when associated with multiple schools" do
        before do
          vacancy.organisations = [school_one, school_two]
        end

        it "returns the first school" do
          expect(vacancy.organisation).to eq(school_group)
        end
      end
    end

    describe "#central_office?" do
      context "when associated with just a school group" do
        it "returns true" do
          expect(vacancy.central_office?).to be true
        end
      end

      context "when associated with a school" do
        before do
          vacancy.organisations = [school_one]
        end

        it "returns false" do
          expect(vacancy.central_office?).to be false
        end
      end

      context "when associated with multiple organisations" do
        before do
          vacancy.organisations = [school_one, school_two]
        end

        it "returns false" do
          expect(vacancy.central_office?).to be false
        end
      end
    end

    describe "phases and key stages" do
      it "maintains compatibility between phases and key stages" do
        # Start with primary phase and ks1
        expect(vacancy.phases).to contain_exactly("primary")
        expect(vacancy.key_stages).to contain_exactly("ks1")

        # Key stages should match the allowed ones for the phase
        expect(vacancy.key_stages_for_phases).to contain_exactly(:early_years, :ks1, :ks2)
      end

      it "provides the correct key stages options based on phases" do
        # Primary phase should offer early_years, ks1, ks2
        vacancy.phases = %w[primary]
        expect(vacancy.key_stages_for_phases).to contain_exactly(:early_years, :ks1, :ks2)

        # Secondary phase should offer ks3, ks4, ks5
        vacancy.phases = %w[secondary]
        expect(vacancy.key_stages_for_phases).to contain_exactly(:ks3, :ks4, :ks5)

        # Multiple phases should offer a union of key stages
        vacancy.phases = %w[primary secondary]
        expect(vacancy.key_stages_for_phases).to contain_exactly(:early_years, :ks1, :ks2, :ks3, :ks4, :ks5)
      end
    end
  end
end
