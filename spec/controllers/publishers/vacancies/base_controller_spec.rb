require "rails_helper"

RSpec.describe Publishers::Vacancies::BaseController do
  describe "#update_google_index" do
    let!(:vacancy) { create(:vacancy) }

    before do
      allow(UpdateGoogleIndexQueueJob).to receive(:perform_later)
    end

    context "when DisableExpensiveJobs is not enabled" do
      before { allow(DisableExpensiveJobs).to receive(:enabled?).and_return(false) }

      it "does perform the task" do
        controller.send(:update_google_index, vacancy)
        expect(UpdateGoogleIndexQueueJob).to have_received(:perform_later)
      end
    end

    context "when DisableExpensiveJobs is enabled" do
      before { allow(DisableExpensiveJobs).to receive(:enabled?).and_return(true) }

      it "does NOT perform the task" do
        controller.send(:update_google_index, vacancy)
        expect(UpdateGoogleIndexQueueJob).not_to have_received(:perform_later)
      end
    end
  end

  describe "#remove_google_index" do
    let!(:vacancy) { create(:vacancy) }

    before do
      allow(RemoveGoogleIndexQueueJob).to receive(:perform_later)
    end

    context "when DisableExpensiveJobs is not enabled" do
      before { allow(DisableExpensiveJobs).to receive(:enabled?).and_return(false) }

      it "does perform the task" do
        controller.send(:remove_google_index, vacancy)
        expect(RemoveGoogleIndexQueueJob).to have_received(:perform_later)
      end
    end

    context "when DisableExpensiveJobs is enabled" do
      before { allow(DisableExpensiveJobs).to receive(:enabled?).and_return(true) }

      it "does NOT perform the task" do
        controller.send(:remove_google_index, vacancy)
        expect(RemoveGoogleIndexQueueJob).not_to have_received(:perform_later)
      end
    end
  end
end
