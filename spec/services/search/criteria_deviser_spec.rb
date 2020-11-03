require "rails_helper"

RSpec.describe Search::CriteriaDeviser do
  subject { described_class.new(vacancy) }

  let(:postcode) { "ab12 3cd" }
  let(:readable_phases) { %w[secondary primary] }
  let(:school) do
    create(:school,
           postcode: postcode,
           readable_phases: readable_phases)
  end
  let(:working_patterns) { %w[full_time part_time] }
  let(:subjects) { %w[English Maths] }
  let(:job_title) { "A wonderful job" }
  let(:job_roles) { %w[teacher sen_specialist leadership] }
  let(:vacancy) do
    create(:vacancy, :at_one_school,
           working_patterns: working_patterns,
           subjects: subjects,
           job_title: job_title,
           job_roles: job_roles)
  end

  before do
    vacancy.organisation_vacancies.create(organisation: school)
    vacancy.reload
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

    it "sets the working pattern to the same as the vacancy" do
      expect(subject.criteria[:working_patterns]).to eq(working_patterns)
    end

    it "sets the phases to the same as the school" do
      expect(subject.criteria[:phases]).to eq(readable_phases)
    end

    context "when the vacancy is nqt suitable" do
      let(:job_roles) { %w[nqt_suitable] }

      it "includes NQT suitable in the job roles" do
        expect(subject.criteria[:job_roles]).to eq(%w[nqt_suitable])
      end
    end

    context "when the job listing has no subject but does have job roles" do
      let(:subjects) { [] }

      it "sets the job roles" do
        expect(subject.criteria[:job_roles]).to eq(%w[teacher sen_specialist leadership])
      end

      it "does not set the keyword" do
        expect(subject.criteria[:keyword]).to be_nil
      end
    end

    describe "#keyword" do
      context "when the job listing has a subject" do
        it "uses the subjects as the keyword" do
          expect(subject.criteria[:keyword]).to eq("English Maths")
        end
      end

      context "when the job listing has no subject or job roles" do
        let(:subjects) { [] }
        let(:job_roles) { [] }

        context "when the job title contains a subject" do
          let(:job_title) { "Teacher of Geography" }

          it "uses the subject as the keyword" do
            expect(subject.criteria[:keyword]).to eq("Geography")
          end
        end

        context "when the job title does not contain a subject" do
          context "when the job title contains pre-defined key words separated by spaces" do
            let(:job_title) { "Teacher of non-SEN-se, Principal-ity, getting a-Head, and of being a Teaching Assistant" }

            it "uses the pre-defined key words as the keyword" do
              expect(subject.criteria[:keyword]).to eq("Teacher Teaching Assistant")
            end
          end

          context "when the job title does not contain a pre-defined key word" do
            let(:job_title) { "Chief Joy Officer" }

            it "has no keyword in the criteria" do
              expect(subject.criteria[:keyword]).to be_nil
            end
          end
        end
      end
    end
  end
end
