require "rails_helper"

RSpec.shared_examples "no keyword in the criteria" do
  it "does not set keyword" do
    expect(subject.criteria[:keyword]).to be_nil
  end
end

RSpec.shared_examples "radius is set" do
  it "sets the radius to 25" do
    expect(subject.criteria[:radius]).to eq("25")
  end
end

RSpec.describe Search::CriteriaInventor do
  subject { described_class.new(vacancy, working_patterns_variant) }

  let(:postcode) { "ab12 3cd" }
  let(:readable_phases) { %w[secondary primary] }
  let(:school) { create(:school, postcode: postcode, readable_phases: readable_phases) }
  let(:working_patterns) { %w[full_time part_time] }
  let(:subjects) { %w[English Maths] }
  let(:job_title) { "A wonderful job" }
  let(:job_roles) { %w[teacher send_responsible] }
  let(:location_trait) { :at_one_school }
  let(:organisation_vacancies_attributes) { [{ organisation: school }] }
  let(:postcode_from_mean_geolocation) { "OX14 JE1" }
  let(:vacancy) do
    create(:vacancy, location_trait, organisation_vacancies_attributes: organisation_vacancies_attributes,
                                     postcode_from_mean_geolocation: postcode_from_mean_geolocation,
                                     working_patterns: working_patterns,
                                     subjects: subjects,
                                     job_title: job_title,
                                     job_roles: job_roles)
  end
  let(:working_patterns_variant) { :default }

  describe "#criteria" do
    context "location" do
      let(:trust) { create(:trust) }

      context "when vacancy is associated to a single school" do
        it "sets the location to the school's postcode" do
          expect(subject.criteria[:location]).to eq(postcode)
        end

        it_behaves_like "radius is set"
      end

      context "when the vacancy is associated to multiple schools in a school group" do
        let(:school1) { create(:school) }
        let(:school2) { create(:school) }
        let(:organisation_vacancies_attributes) { [{ organisation: trust }, { organisation: school1 }, { organisation: school2 }] }
        let(:location_trait) { :at_multiple_schools }

        before do
          SchoolGroupMembership.create(school: school1, school_group: trust)
          SchoolGroupMembership.create(school: school2, school_group: trust)
          vacancy.reload
        end

        it "uses the vacancy's postcode_from_mean_geolocation attribute" do
          expect(subject.criteria[:location]).to eq(postcode_from_mean_geolocation)
        end

        it_behaves_like "radius is set"

        context "and the vacancy does not already have a postcode_from_mean_geolocation attribute" do
          let(:postcode_from_mean_geolocation) { nil }

          it "calls the Geocoding class to calculate the postcode from the mean location and sets the vacancy attribute" do
            expect(subject.criteria[:location]).to eq(Geocoder::DEFAULT_LOCATION)
            expect(vacancy.postcode_from_mean_geolocation).to eq(Geocoder::DEFAULT_LOCATION)
          end
        end
      end

      context "when the vacancy is at the central office of a trust" do
        let(:location_trait) { :central_office }
        let(:organisation_vacancies_attributes) { [{ organisation: trust }] }

        it "sets the location to the trust's postcode" do
          expect(subject.criteria[:location]).to eq(trust.postcode)
        end

        it_behaves_like "radius is set"
      end
    end

    describe "working_patterns" do
      context "when working_patterns_variant is set to default" do
        let(:working_patterns_variant) { :default }

        it "sets the working patterns to the same as the vacancy" do
          expect(subject.criteria[:working_patterns]).to eq(working_patterns)
        end
      end

      context "when working_patterns_variant is set to absent" do
        let(:working_patterns_variant) { :absent }

        it "does not set working_patterns" do
          expect(subject.criteria[:working_patterns]).to eq(nil)
        end
      end
    end

    it "sets the phases to the same as the vacancy" do
      vacancy.reload
      expect(subject.criteria[:phases]).to eq(readable_phases)
    end

    it "sets the job roles to the same as the vacancy" do
      expect(subject.criteria[:job_roles]).to eq(job_roles)
    end

    describe "#keyword" do
      context "when the job listing has more than one subject" do
        it_behaves_like "no keyword in the criteria"
      end

      context "when the job listing has one subject" do
        let(:subjects) { %w[Science] }

        it "uses the subject as the keyword" do
          expect(subject.criteria[:keyword]).to eq("Science")
        end
      end

      context "when the job listing has no subject" do
        let(:subjects) { [] }

        context "when the job title contains more than one subject" do
          let(:job_title) { "Teacher of Chemistry and Music" }

          it_behaves_like "no keyword in the criteria"
        end

        context "when the job title contains one subject" do
          let(:job_title) { "Teacher of Geography" }

          it "uses the subject as the keyword" do
            expect(subject.criteria[:keyword]).to eq("Geography")
          end
        end

        context "when the job title does not contain a subject" do
          context "when the job listing has at least one job role" do
            it_behaves_like "no keyword in the criteria"
          end

          context "when the job listing does not have at lease one job role" do
            let(:job_roles) { [] }

            context "when the job title contains pre-defined key words separated by spaces" do
              let(:job_title) { "Teacher of non-SEN-se, Principal-ity, getting a-Head, and of being a Teaching Assistant" }

              it "uses the pre-defined key words as the keyword" do
                expect(subject.criteria[:keyword]).to eq("Teacher Teaching Assistant")
              end
            end

            context "when the job title does not contain a pre-defined key word" do
              let(:job_title) { "Chief Joy Officer" }

              it_behaves_like "no keyword in the criteria"
            end
          end
        end
      end
    end

    describe "#get_subjects_from_vacancy" do
      context "when the job listing has one subject" do
        let(:subjects) { %w[Science] }

        it "does not set the subjects" do
          expect(subject.criteria[:subjects]).to be_nil
        end
      end

      context "when the job listing has more than one subject" do
        it "sets the subjects" do
          expect(subject.criteria[:subjects]).to eq(subjects)
        end
      end

      context "when the job listing has no subject" do
        let(:subjects) { [] }

        context "when the job title contains more than one subject" do
          let(:job_title) { "Teacher of Science/Physics, Business studies and Maths" }

          it "sets the subjects" do
            expect(subject.criteria[:subjects]).to match_array(["Science", "Physics", "Business studies", "Mathematics"])
          end
        end

        context "when the job title does not contain more than one subject" do
          let(:job_title) { "Teacher of Magic" }

          it "does not set the subjects" do
            expect(subject.criteria[:subjects]).to be_nil
          end
        end
      end
    end
  end
end
