require "rails_helper"

RSpec.describe Publishers::JobListing::ApplyingForTheJobForm, type: :model do
  subject { described_class.new(params) }

  describe "#validations" do
    describe "#application_link" do
      context "when application_link is invalid" do
        let(:params) { { application_link: "invalid_link" } }

        it "is invalid" do
          expect(subject.valid?).to be false
        end

        it "raises correct error message" do
          subject.valid?
          expect(subject.errors.messages[:application_link].first).to eq(
            I18n.t("applying_for_the_job_errors.application_link.url"),
          )
        end
      end
    end

    describe "#contact_email" do
      context "when contact_email is blank" do
        let(:params) { {} }

        it "is invalid" do
          expect(subject.valid?).to be false
        end

        it "raises correct error message" do
          subject.valid?
          expect(subject.errors.messages[:contact_email].first).to eq(
            I18n.t("applying_for_the_job_errors.contact_email.blank"),
          )
        end
      end

      context "when contact_email is invalid" do
        let(:params) { { contact_email: "invalid-email" } }

        it "is invalid" do
          expect(subject.valid?).to be false
        end

        it "raises correct error message" do
          subject.valid?
          expect(subject.errors.messages[:contact_email].first).to eq(
            I18n.t("applying_for_the_job_errors.contact_email.invalid"),
          )
        end
      end
    end

    describe "#contact_number" do
      context "when contact_number is invalid" do
        let(:params) { { contact_number: "invalid-01234" } }

        it "is invalid" do
          expect(subject.valid?).to be false
        end

        it "raises correct error message" do
          subject.valid?
          expect(subject.errors.messages[:contact_number].first).to eq(
            I18n.t("applying_for_the_job_errors.contact_number.invalid"),
          )
        end
      end
    end
  end

  context "when all attributes are valid" do
    it "can correctly be converted to a vacancy" do
      application_details = described_class.new(state: "create",
                                                application_link: "http://an.application.link",
                                                contact_email: "some@email.com",
                                                contact_number: "01234 123456",
                                                how_to_apply: "How you can apply for the job",
                                                school_visits: "How you can visit the school")

      expect(application_details.valid?).to be true
      expect(application_details.vacancy.application_link).to eq("http://an.application.link")
      expect(application_details.vacancy.contact_email).to eq("some@email.com")
      expect(application_details.vacancy.contact_number).to eq("01234 123456")
      expect(application_details.vacancy.how_to_apply).to eq("How you can apply for the job")
      expect(application_details.vacancy.school_visits).to eq("How you can visit the school")
    end
  end
end
