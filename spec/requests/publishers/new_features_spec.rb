require "rails_helper"

RSpec.shared_examples "does not redirect the publisher to the new features page" do
  it "does not redirect the publisher to the new features page" do
    expect(get(organisation_path)).to render_template(:show)
  end
end

RSpec.describe "New features page" do
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher, dismissed_new_features_page_at: nil) }

  before do
    allow_any_instance_of(Publishers::AuthenticationConcerns).to receive(:current_organisation).and_return(organisation)
    sign_in(publisher, scope: :publisher)
  end

  describe "GET organisations#show" do
    context "when the publisher is logged in as a local authority" do
      let(:organisation) { create(:local_authority) }

      before { allow(PublisherPreference).to receive(:find_by).and_return(instance_double(PublisherPreference)) }

      it_behaves_like "does not redirect the publisher to the new features page"
    end

    context "when the publisher has previously dismissed the new features page" do
      let(:publisher) { create(:publisher, dismissed_new_features_page_at: 2.days.ago) }

      it_behaves_like "does not redirect the publisher to the new features page"
    end

    context "when the publisher has previously published a vacancy that allows applications" do
      let!(:vacancy) { create(:vacancy, publisher: publisher, organisations: [organisation], enable_job_applications: true) }

      it_behaves_like "does not redirect the publisher to the new features page"
    end

    context "when the publisher is not signed in as a local authority and has not done either of the above" do
      it "redirects them to the new features page" do
        get organisation_path

        expect(response).to redirect_to(new_features_path)
      end
    end
  end
end
