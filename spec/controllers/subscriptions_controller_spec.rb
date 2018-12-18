require 'rails_helper'

RSpec.describe SubscriptionsController, type: :controller do
  describe '#create' do
    it 'persists only sanitised params' do
      params = {
        subscription: {
          email: '<script>foo@email.com</script>',
          search_criteria: "<body onload=alert('test1')>Text</script>",
          frequency: "<img src='http://url.to.file.which/not.exist' onerror=alert(document.cookie);>"
        }
      }

      post :create, params: params

      subscription = Subscription.last
      expect(subscription.email).to eql('foo@email.com')
      expect(subscription.search_criteria).to eql('Text')
      expect(subscription.frequency).to eql('daily')
    end
  end
end
