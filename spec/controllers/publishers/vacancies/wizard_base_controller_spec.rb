require "rails_helper"

RSpec.describe Publishers::Vacancies::WizardBaseController do
  describe "#update_google_index" do
    let!(:vacancy) { create(:vacancy) }

    it "enqueues the task" do
      expect(UpdateGoogleIndexQueueJob).to receive(:perform_later)
      controller.send(:update_google_index, vacancy)
    end
  end
end
