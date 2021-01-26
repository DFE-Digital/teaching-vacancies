require "rails_helper"

RSpec.describe SubscriptionFinder do
  describe ".new" do
    it "is initialised with a hash of params" do
      service = described_class.new(email: "foo", search_criteria: "bar", frequency: "daily")
      expect(service).to be_an_instance_of(described_class)
    end
  end

  describe "#exists?" do
    let(:params) { { email: "foo@email.com", search_criteria: "bar", frequency: "daily" } }
    context "when there are no existing subscriptions" do
      it "returns false" do
        service = described_class.new(params)
        expect(service.exists?).to eq(false)
      end
    end

    context "when an existing subscription exists with email, search_criteria and frequency" do
      before(:each) do
        create(
          :daily_subscription,
          email: "foo@email.com",
          search_criteria: "bar",
          frequency: "daily",
        )
      end

      it "returns true" do
        service = described_class.new(params)
        expect(service.exists?).to eq(true)
      end
    end

    context "when malicious arguments are passed in" do
      it "does not pass them to `where`" do
        harmful_params = {
          email: "<script>foo@email.com</script>",
          search_criteria: "<body onload=alert('test1')>Text</body>",
          frequency: "<img src='http://url.to.file.which/not.exist' onerror=alert(document.cookie);>",
        }
        empty_active_record_relation = Subscription.none

        expect(Subscription).to receive(:where)
          .with(
            email: "",
            search_criteria: "Text",
            frequency: "",
          )
          .and_return(empty_active_record_relation)

        described_class.new(harmful_params).exists?
      end
    end
  end
end
