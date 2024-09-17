require "rails_helper"

RSpec.describe Jobseekers::AccountTransfer do
  let!(:current_jobseeker) { create(:jobseeker) }
  let!(:account_to_transfer) { create(:jobseeker, email: "old_account@example.com") }

  let!(:profile) { create(:jobseeker_profile, jobseeker: account_to_transfer) }
  let!(:feedbacks) { create_list(:feedback, 3, jobseeker: account_to_transfer) }
  let!(:job_applications) { create_list(:job_application, 3, jobseeker: account_to_transfer) }
  let!(:saved_jobs) { create_list(:saved_job, 3, jobseeker: account_to_transfer) }
  let!(:subscriptions) { create_list(:subscription, 2, email: account_to_transfer.email) }

  subject { described_class.new(current_jobseeker, account_to_transfer.email) }

  describe "#call" do
    context "when account to transfer exists" do
      it "transfers the profile to the current jobseeker" do
        subject.call
        expect(current_jobseeker.reload.jobseeker_profile).to eq(profile)
        expect(profile.reload.jobseeker_id).to eq(current_jobseeker.id)
      end

      it "transfers feedbacks to the current jobseeker" do
        subject.call
        feedbacks.each do |feedback|
          expect(feedback.reload.jobseeker_id).to eq(current_jobseeker.id)
        end
      end

      it "transfers job applications to the current jobseeker" do
        subject.call
        job_applications.each do |job_application|
          expect(job_application.reload.jobseeker_id).to eq(current_jobseeker.id)
        end
      end

      it "transfers saved jobs to the current jobseeker" do
        subject.call
        saved_jobs.each do |saved_job|
          expect(saved_job.reload.jobseeker_id).to eq(current_jobseeker.id)
        end
      end

      it "updates subscriptions to the current jobseeker email" do
        subject.call
        subscriptions.each do |subscription|
          expect(subscription.reload.email).to eq(current_jobseeker.email)
        end
      end

      it "deletes the account to transfer after successful transfer" do
        expect { subject.call }.to change { Jobseeker.exists?(account_to_transfer.id) }.from(true).to(false)
      end
    end

    context "when account to transfer does not exist" do
      it "raises an error and does nothing" do
        service = described_class.new(current_jobseeker, "non_existent@example.com")
        expect { service.call }.to raise_error(Jobseekers::AccountTransfer::AccountNotFoundError)
        expect(Jobseeker.exists?(account_to_transfer.id)).to eq true
      end
    end

    context "when there is no profile to transfer" do
      before do
        account_to_transfer.jobseeker_profile.destroy!
      end

      it "does not transfer any profile but completes other transfers" do
        subject.call
        expect(current_jobseeker.reload.jobseeker_profile).to be_nil
        feedbacks.each do |feedback|
          expect(feedback.reload.jobseeker_id).to eq(current_jobseeker.id)
        end
      end

      it "deletes the account to transfer after successful transfer of other data" do
        expect { subject.call }.to change { Jobseeker.exists?(account_to_transfer.id) }.from(true).to(false)
      end
    end

    context "when an error occurs during the transfer" do
      before do
        allow_any_instance_of(JobseekerProfile).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)
      end

      it "rolls back all changes" do
        expect { subject.call }.to raise_error(ActiveRecord::RecordInvalid)
        feedbacks.each do |feedback|
          expect(feedback.reload.jobseeker_id).to eq(account_to_transfer.id)
        end
        expect(profile.reload.jobseeker_id).to eq(account_to_transfer.id)
      end

      it "does not delete account to transfer" do
        expect { subject.call }.to raise_error(ActiveRecord::RecordInvalid)
        expect(Jobseeker.exists?(account_to_transfer.id)).to eq true
      end
    end
  end
end
