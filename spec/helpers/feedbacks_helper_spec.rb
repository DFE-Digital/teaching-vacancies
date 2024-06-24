require "rails_helper"

RSpec.describe FeedbacksHelper do
  describe "#header_feedback_link_text" do
    let(:feedback_url) { "jobseekers/account_feedback" }
    let(:jobseeker_signed_in?) { true }

    before do
      allow(helper).to receive(:jobseeker_signed_in?).and_return(jobseeker_signed_in?)
    end

    context "when jobseeker is signed in" do
      before do
        allow(helper).to receive(:feedback_url).and_return(feedback_url)
      end

      it "returns the correct feedback link for signed-in jobseeker" do
        expect(helper.header_feedback_link_text).to include(feedback_url)
      end
    end

    context "when jobseeker is not signed in" do
      let(:jobseeker_signed_in?) { false }

      it "returns the correct feedback link for not signed-in jobseeker" do
        expect(helper.header_feedback_link_text).to include(controller.new_feedback_path)
      end
    end
  end
end
