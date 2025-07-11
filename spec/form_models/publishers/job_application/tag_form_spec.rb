require "rails_helper"

module Publishers
  module JobApplication
    RSpec.describe TagForm, type: :model do
      subject(:tag_form) { described_class.new(job_applications:, status:, origin:, vacancy:) }

      let(:vacancy) { create(:vacancy) }
      let(:job_applications) { create_list(:job_application, 2, vacancy:, status: job_application_status) }
      let(:status) { "shortlisted" }
      let(:origin) { "shortlisted" }
      let(:job_application_status) { "submitted" }

      before { vacancy.job_applications = job_applications }

      it { is_expected.to validate_length_of(:job_applications) }

      describe ".job_application_ids" do
        subject { described_class.new(job_applications:, status:, origin:, vacancy:).job_application_ids }

        let(:job_application) { create(:job_application) }

        context "with a selection" do
          let(:job_applications) { ::JobApplication.where(id: job_application.id) }

          it { is_expected.to eq([job_application.id]) }
        end

        context "with no selection" do
          let(:job_applications) { ::JobApplication.where(id: "no-id") }

          it { is_expected.to eq([]) }
        end
      end

      describe "validation" do
        context "when context is update_tag" do
          it "when status missing invalid" do
            tag_form.status = nil
            tag_form.valid?(:update_tag)
            expect(tag_form.errors[:status]).to be_present
          end

          it "when status present valid" do
            tag_form.valid?(:update_tag)
            expect(tag_form.errors[:status]).to be_empty
          end
        end
      end

      describe ".attributes" do
        subject(:candidates) do
          described_class.new(job_applications:, status:, origin:, vacancy:, offered_at:, declined_at:).attributes
        end

        let(:offered_at) { 1.day.ago }
        let(:declined_at) { 1.day.ago }

        context "when status offered" do
          let(:status) { "offered" }

          it { is_expected.to eq({ "status" => status, "offered_at" => offered_at }) }
        end

        context "when status declined" do
          let(:status) { "declined" }

          it { is_expected.to eq({ "status" => status, "declined_at" => declined_at }) }
        end

        context "when status any other" do
          let(:status) { "submitted" }

          it { is_expected.to eq({ "status" => status }) }
        end
      end

      describe ".candidates" do
        subject(:candidates) do
          described_class.new(job_applications:, status:, origin:, vacancy:).candidates
        end

        context "when job application status is submitted" do
          let(:job_application_status) { "submitted" }

          it "returns candidates in tab group" do
            expect(candidates["submitted"]).to match_array(job_applications)
            %w[unsuccessful shortlisted interviewing offered declined].each do |tab_name|
              expect(candidates[tab_name]).to be_empty
            end
          end
        end

        context "when job application status is unsuccessful" do
          let(:job_application_status) { "unsuccessful" }

          it "returns candidates in tab group" do
            expect(candidates["unsuccessful"]).to match_array(job_applications)
            %w[submitted shortlisted interviewing offered declined].each do |tab_name|
              expect(candidates[tab_name]).to be_empty
            end
          end
        end

        context "when job application status is shortlisted" do
          let(:job_application_status) { "shortlisted" }

          it "returns candidates in tab group" do
            expect(candidates["shortlisted"]).to match_array(job_applications)
            %w[submitted unsuccessful interviewing offered declined].each do |tab_name|
              expect(candidates[tab_name]).to be_empty
            end
          end
        end

        context "when job application status is interviewing" do
          let(:job_application_status) { "interviewing" }

          it "returns candidates in tab group" do
            expect(candidates["interviewing"]).to match_array(job_applications)
            %w[submitted unsuccessful shortlisted offered declined].each do |tab_name|
              expect(candidates[tab_name]).to be_empty
            end
          end
        end

        context "when job application status is offered" do
          let(:job_application_status) { "offered" }

          it "returns candidates in tab group" do
            expect(candidates["offered"]).to match_array(job_applications)
            %w[submitted unsuccessful shortlisted interviewing declined].each do |tab_name|
              expect(candidates[tab_name]).to be_empty
            end
          end
        end

        context "when job application status is declined" do
          let(:job_application_status) { "declined" }

          it "returns candidates in tab group" do
            expect(candidates["declined"]).to match_array(job_applications)
            %w[submitted unsuccessful shortlisted interviewing offered].each do |tab_name|
              expect(candidates[tab_name]).to be_empty
            end
          end
        end
      end

      describe ".tabs" do
        subject { described_class.new(job_applications:, status:, origin:, vacancy:).tabs }

        context "when job applications are shortlisted" do
          let(:job_application_status) { "shortlisted" }

          it { is_expected.to match_array([["submitted", 0], ["unsuccessful", 0], ["shortlisted", 2], ["interviewing", 0], ["offered", 0]]) } # rubocop:disable  RSpec/MatchArray
        end

        context "when job applications are declined" do
          let(:job_application_status) { "declined" }

          before do
            create(:job_application, vacancy:, status: "offered")
          end

          it { is_expected.to match_array([["submitted", 0], ["unsuccessful", 0], ["shortlisted", 0], ["interviewing", 0], ["offered", 3]]) } # rubocop:disable  RSpec/MatchArray
        end
      end

      describe ".available_statuses" do
        subject { described_class.new(job_applications:, status:, origin:).available_statuses }

        context "when origin is shortlisted" do
          let(:origin) { "shortlisted" }

          it { is_expected.to eq(%i[unsuccessful interviewing offered]) }
        end

        context "when origin is interviewing" do
          let(:origin) { "interviewing" }

          it { is_expected.to eq(%i[unsuccessful offered]) }
        end

        context "when origin is any other" do
          let(:origin) { "reviewed" }

          it { is_expected.to eq(%i[reviewed unsuccessful shortlisted interviewing offered]) }
        end
      end
    end
  end
end
