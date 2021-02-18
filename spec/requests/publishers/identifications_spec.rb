require "rails_helper"

RSpec.describe "Publishers::Identifications", type: :request do
  describe "POST #create" do
    before { allow(AuthenticationFallback).to receive(:enabled?).and_return(false) }

    it "redirects to DfE Sign in" do
      post identifications_path
      expect(response).to redirect_to(new_dfe_path)
    end
  end
end
