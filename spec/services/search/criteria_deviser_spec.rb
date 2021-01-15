require "rails_helper"

RSpec.shared_examples "no keyword in the criteria" do
  it "does not set keyword" do
    expect(subject.criteria[:keyword]).to be_nil
  end
end

RSpec.describe Search::CriteriaDeviser do
  subject { described_class.new(vacancy) }

  let(:postcode) { "ab12 3cd" }
  let(:readable_phases) { %w[secondary primary] }
  let(:school) { create(:school, postcode: postcode, readable_phases: readable_phases) }
  let(:working_patterns) { %w[full_time part_time] }
  let(:subjects) { %w[English Maths] }
  let(:job_title) { "A wonderful job" }
  let(:job_roles) { %w[teacher sen_specialist leadership] }
  let(:vacancy) do
    create(:vacancy, :at_one_school, organisation_vacancies_attributes: [{ organisation: school }],
                                     working_patterns: working_patterns,
                                     subjects: subjects,
                                     job_title: job_title,
                                     job_roles: job_roles)
  end

  describe "#devise_search_criteria" do
    context "when the parent organisation has no postcode" do
      let(:postcode) { nil }

      it "does not set the location" do
        expect(subject.criteria[:location]).to be_nil
      end

      it "does not set the radius" do
        expect(subject.criteria[:radius]).to be_nil
      end
    end

    context "when the parent organisation has a postcode" do
      it "sets the location to the postcode" do
        expect(subject.criteria[:location]).to eq(postcode)
      end

      it "sets the radius to 10" do
        expect(subject.criteria[:radius]).to eq("10")
      end
    end

    it "sets the working patterns to the same as the vacancy" do
      expect(subject.criteria[:working_patterns]).to eq(working_patterns)
    end

    it "sets the phases to the same as the school" do
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
