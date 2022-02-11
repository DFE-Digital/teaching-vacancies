require "rails_helper"

RSpec.describe "Publisher notifications" do
  let(:publisher) { create(:publisher, accepted_terms_at: 1.day.ago) }
  let(:organisation) { build(:school) }
  let(:vacancy) { create(:vacancy, organisations: [organisation]) }
  let(:job_application) { create(:job_application, vacancy: vacancy) }
  let!(:notification) { create(:notification, :job_application_received, recipient: publisher, params: { vacancy: vacancy, job_application: job_application }) }

  before do
    allow_any_instance_of(Publishers::BaseController).to receive(:current_organisation).and_return(organisation)
    sign_in(publisher, scope: :publisher)
  end

  describe "GET #index" do
    it "renders the index page" do
      expect(get(publishers_notifications_path)).to render_template(:index)
    end

    it "marks notifications as read" do
      freeze_time do
        expect { get publishers_notifications_path }.to change { notification.reload.read_at }.from(nil).to(Time.current)
      end
    end
  end
end
