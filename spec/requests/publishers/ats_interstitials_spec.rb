require "rails_helper"

RSpec.describe "Publishers::AtsInterstitials" do
  let(:publisher) { create(:publisher, acknowledged_ats_and_religious_form_interstitial: false) }
  let(:organisation) { create(:school) }

  before do
    sign_in(publisher, scope: :publisher)
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(Publishers::BaseController).to receive(:current_organisation).and_return(organisation)
    allow_any_instance_of(Publishers::BaseController).to receive(:current_publisher).and_return(publisher)
    # rubocop:enable RSpec/AnyInstance
  end

  describe "GET #show" do
    context "when the organisation is a SchoolGroup" do
      let(:organisation) { create(:school_group) }

      it "renders the show template successfully (hits :default branch)" do
        get publishers_ats_interstitial_path
        expect(response).to be_successful
      end
    end

    context "when the organisation is not a SchoolGroup" do
      let(:organisation) { create(:school) }

      before do
        allow(organisation).to receive(:ats_interstitial_variant).and_return(:custom_variant)
      end

      it "renders the show template successfully (hits 'else' branch)" do
        get publishers_ats_interstitial_path
        expect(response).to be_successful
      end
    end
  end

  describe "PATCH #update" do
    context "when the update is successful" do
      it "updates the publisher and redirects" do
        expect {
          patch publishers_ats_interstitial_path
        }.to change { publisher.reload.acknowledged_ats_and_religious_form_interstitial }.from(false).to(true)

        expect(response).to redirect_to(organisation_jobs_with_type_path)
      end
    end

    context "when the update fails" do
      before do
        allow(publisher).to receive(:update).and_return(false)
      end

      it "re-renders the show template" do
        patch publishers_ats_interstitial_path

        expect(response).to render_template(:show)
      end
    end

    context "when the update fails (SchoolGroup)" do
      let(:organisation) { create(:school_group) }

      before do
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(Publishers::BaseController).to receive(:current_organisation).and_return(organisation)
        allow_any_instance_of(Publisher).to receive(:update).and_return(false)
        # rubocop:enable RSpec/AnyInstance
      end

      it "renders show with :default variant" do
        patch publishers_ats_interstitial_path
        expect(assigns(:variant)).to eq("non_faith")
        expect(response).to render_template(:show)
      end
    end
  end
end
