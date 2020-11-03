require "rails_helper"

RSpec.describe "staging authentication", type: :request do
  context "when in development" do
    it_behaves_like "no basic auth"
  end

  context "when in test" do
    it_behaves_like "no basic auth"
  end

  context "when in staging" do
    before(:each) { stub_global_auth(return_value: true) }
    # it_behaves_like 'basic auth'
    it_behaves_like "no basic auth"
  end

  context "when in production" do
    before(:each) { stub_global_auth(return_value: false) }
    it_behaves_like "no basic auth"
  end
end
