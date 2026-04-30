# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publish" do
  include ActionDispatch::TestProcess::FixtureFile

  let(:publisher) { create(:publisher) }
  let(:organisation) { build(:school) }
  let(:vacancy) do
    create(:draft_vacancy, organisations: [organisation]).tap do |v|
      v.application_form.attach(
        io: Rails.root.join("spec/fixtures/files/blank_job_spec.pdf").open,
        filename: "application_form.pdf",
        content_type: "application/pdf",
      )
      v.application_form.blob.update!(metadata: { "malware_scan_result" => "clean" })
    end
  end
  let(:request) { post organisation_job_publish_path(vacancy.id) }

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(Publishers::BaseController).to receive(:current_organisation).and_return(organisation)
    # rubocop:enable RSpec/AnyInstance
    sign_in(publisher, scope: :publisher)
  end

  after { sign_out(publisher) }

  describe "POST #create" do
    context "when a blob is pending scan" do
      before { vacancy.application_form.blob.update_columns(metadata: {}) }

      it "redirects to the review page with a pending message" do
        expect(request).to redirect_to(organisation_job_review_path(vacancy.id))
        expect(flash[:alert]).to include(I18n.t("jobs.file_pending_scan_message", filename: vacancy.application_form.filename))
      end
    end

    context "when a blob is malicious" do
      before { vacancy.application_form.blob.update!(metadata: { "malware_scan_result" => "malicious" }) }

      it "redirects to the review page with an unsafe message" do
        expect(request).to redirect_to(organisation_job_review_path(vacancy.id))
        expect(flash[:alert]).to include(I18n.t("jobs.file_unsafe_error_message", filename: vacancy.application_form.filename))
      end
    end
  end
end
