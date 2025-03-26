require "rails_helper"

RSpec.describe Publishers::Vacancies::BaseController do
  describe "#update_google_index" do
    let!(:vacancy) { create(:vacancy) }

    context "when DisableExpensiveJobs is not enabled" do
      it "does perform the task" do
        expect(UpdateGoogleIndexQueueJob).to receive(:perform_later)
        controller.send(:update_google_index, vacancy)
      end
    end

    context "when DisableExpensiveJobs is enabled", :disable_expensive_jobs do
      it "does NOT perform the task" do
        expect(UpdateGoogleIndexQueueJob).not_to receive(:perform_later)
        controller.send(:update_google_index, vacancy)
      end
    end
  end
end
