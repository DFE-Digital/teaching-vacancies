require "rails_helper"

RSpec.describe VacanciesHelper do
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

  describe "#vacancy_full_job_location" do
    subject { vacancy_full_job_location(vacancy) }

    context "when job_location is at_multiple_schools" do
      let(:trust) { build(:trust, name: "Magic Trust") }
      let(:vacancy) { build(:vacancy, :at_multiple_schools, organisation_vacancies_attributes: [{ organisation: trust }]) }

      it "returns the multiple schools location" do
        expect(subject).to eq("More than one school, Magic Trust")
      end
    end

    context "when job_location is not at_multiple_schools" do
      let(:school) { build(:school, name: "Magic School", town: "Cool Town", county: "Orange County", postcode: "SW1A") }
      let(:vacancy) { build(:vacancy, organisation_vacancies_attributes: [{ organisation: school }]) }

      it "returns the full location" do
        expect(subject).to eq("Magic School, Cool Town, Orange County, SW1A")
      end
    end
  end

  describe "#vacancy_review_section_tag" do
    subject { helper.vacancy_review_section_tag(vacancy, step) }

    let(:vacancy) { build_stubbed(:vacancy, completed_steps: %w[job_role job_details]) }

    context "when there is an error on an attribute in the step" do
      let(:form_class) { Publishers::JobListing::JobDetailsForm }
      let(:step) { %i[job_details] }

      before { allow(vacancy).to receive_message_chain(:errors, :messages).and_return({ job_title: "Enter a job title" }) }

      it "returns 'action required' tag" do
        expect(subject).to eq(helper.govuk_tag(text: t("shared.status_tags.action_required"), colour: "red"))
      end
    end

    context "when the step is completed" do
      let(:form_class) { Publishers::JobListing::JobDetailsForm }
      let(:step) { %i[job_details] }

      it "returns 'complete' tag" do
        expect(subject).to eq(helper.govuk_tag(text: I18n.t("shared.status_tags.complete")))
      end
    end

    context "when the step is not started" do
      let(:form_class) { Publishers::JobListing::WorkingPatternsForm }
      let(:step) { %i[working_patterns] }

      it "returns 'not started' tag" do
        expect(subject).to eq(helper.govuk_tag(text: I18n.t("shared.status_tags.not_started"), colour: "grey"))
      end
    end
  end
end
