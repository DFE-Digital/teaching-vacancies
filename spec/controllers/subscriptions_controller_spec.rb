require "rails_helper"

RSpec.describe SubscriptionsController, type: :controller do
  describe "#new" do
    subject { get :new, params: { search_criteria: { keyword: "english" } } }

    it "returns 200" do
      subject
      expect(response.code).to eq("200")
    end
  end

  describe "#create" do
    let(:params) do
      {
        subscription_form: {
          email: "foo@email.com",
          frequency: "daily",
          keyword: "english",
        },
      }
    end
    let(:subject) { post :create, params: params }
    let(:subscription) { Subscription.last }

    it "returns 200" do
      subject
      expect(response.code).to eq("200")
    end

    it "queues a job to audit the subscription" do
      expect { subject }.to have_enqueued_job(AuditSubscriptionCreationJob)
    end

    it "creates a subscription" do
      expect { subject }.to change { Subscription.count }.by(1)
      expect(subscription.email).to eq("foo@email.com")
      expect(subscription.search_criteria[:keyword]).to eq "english"
    end

    context "with unsafe params" do
      let(:params) do
        {
          subscription_form: {
            email: "<script>foo@email.com</script>",
            frequency: "daily",
            search_criteria: "<body onload=alert('test1')>Text</body>",
          },
        }
      end

      it "does not create a subscription" do
        expect { subject }.to change { Subscription.count }.by(0)
      end
    end
  end

  describe "#edit" do
    let(:subscription) { create(:subscription, email: "bob@dylan.com", frequency: :daily) }

    subject { get :edit, params: { id: subscription.token } }

    it "returns 200" do
      subject
      expect(response.code).to eq("200")
    end
  end

  describe "#update" do
    let(:subscription) { create(:subscription, email: "bob@dylan.com", frequency: :daily) }

    let(:params) do
      {
        email: "jimi@hendrix.com",
        frequency: "weekly",
        keyword: "english",
      }
    end
    let!(:subject) { put :update, params: { id: subscription.token, subscription_form: params } }

    it "returns 200" do
      expect(response.code).to eq("200")
    end

    it "updates a subscription" do
      expect(subscription.reload.email).to eq("jimi@hendrix.com")
      expect(subscription.search_criteria[:keyword]).to eq "english"
    end

    context "with unsafe params" do
      let(:params) do
        {
          email: "<script>foo@email.com</script>",
          frequency: "daily",
          search_criteria: "<body onload=alert('test1')>Text</body>",
        }
      end

      it "does not update a subscription" do
        expect(subscription.reload.email).to eq("bob@dylan.com")
      end
    end
  end
end
