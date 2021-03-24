require "rails_helper"

RSpec.describe VacanciesHelper do
  describe "#new_attributes" do
    let(:vacancy) { double("vacancy").as_null_object }

    it "includes contact_number for legacy listings" do
      allow(vacancy).to receive(:contact_number).and_return(nil)
      expect(helper.new_attributes(vacancy)[:contact_number]).to eq(I18n.t("jobs.contact_number"))
    end
  end

  describe "#review_heading" do
    let(:vacancy) { double("vacancy").as_null_object }

    it "returns copy review heading if vacancy state is copy" do
      allow(vacancy).to receive(:published?).and_return(false)
      allow(vacancy).to receive(:state).and_return("copy")

      expect(review_heading(vacancy)).to eq(I18n.t("jobs.copy_review_heading"))
    end

    it "returns review heading" do
      allow(vacancy).to receive(:published?).and_return(false)
      allow(vacancy).to receive(:state).and_return("not_copy_review")

      expect(review_heading(vacancy)).to eq(I18n.t("jobs.review_heading"))
    end
  end

  describe "#hidden_state_field_value" do
    let(:vacancy) { double("vacancy").as_null_object }

    before do
      allow(vacancy).to receive(:published?).and_return(nil)
      allow(vacancy).to receive(:state).and_return(nil)
    end

    it "returns copy if copy true" do
      expect(hidden_state_field_value(vacancy, copy: true)).to eq("copy")
    end

    it "returns edit_published if published vacancy" do
      allow(vacancy).to receive(:published?).and_return(true)
      expect(hidden_state_field_value(vacancy)).to eq("edit_published")
    end

    it "returns current state if vacancy state is copy/review/edit" do
      allow(vacancy).to receive(:published?).and_return(false)

      allow(vacancy).to receive(:state).and_return("copy")
      expect(hidden_state_field_value(vacancy)).to eq("copy")

      allow(vacancy).to receive(:state).and_return("review")
      expect(hidden_state_field_value(vacancy)).to eq("review")

      allow(vacancy).to receive(:state).and_return("edit")
      expect(hidden_state_field_value(vacancy)).to eq("edit")
    end

    it "returns create" do
      expect(hidden_state_field_value(vacancy)).to eq("create")
    end
  end

  describe "#back_to_manage_jobs_link" do
    let(:vacancy) { double("vacancy").as_null_object }

    before do
      allow(vacancy).to receive(:listed?).and_return(false)
      allow(vacancy).to receive(:published?).and_return(false)
      allow(vacancy).to receive_message_chain(:expires_at, :future?).and_return(false)
    end

    it "returns draft jobs link for draft jobs" do
      expect(back_to_manage_jobs_link(vacancy)).to eq(jobs_with_type_organisation_path("draft"))
    end

    it "returns pending jobs link for scheduled jobs" do
      allow(vacancy).to receive(:published?).and_return(true)
      allow(vacancy).to receive_message_chain(:expires_at, :future?).and_return(true)
      expect(back_to_manage_jobs_link(vacancy)).to eq(jobs_with_type_organisation_path("pending"))
    end

    it "returns published jobs link for published jobs" do
      allow(vacancy).to receive(:listed?).and_return(true)
      expect(back_to_manage_jobs_link(vacancy)).to eq(jobs_with_type_organisation_path("published"))
    end

    it "returns expired jobs link for expired jobs" do
      allow(vacancy).to receive(:published?).and_return(true)
      allow(vacancy).to receive_message_chain(:expires_at, :past?).and_return(true)
      expect(back_to_manage_jobs_link(vacancy)).to eq(jobs_with_type_organisation_path("expired"))
    end
  end
end
