require 'rails_helper'

RSpec.describe HiringStaff::JobCreationHelper do
  describe '#total_steps' do
    around do |example|
      Rails.application.routes.draw do
        get :step_one, params: { to: 'job#step_one', defaults: { create_step: 1 } }
        get :step_two, params: { to: 'job#step_two', defaults: { create_step: 2 } }
      end

      example.run

      Rails.application.routes_reloader.reload!
    end

    it 'counts the number of routes with { defaults: { create_step: /\d+/ }} and returns the total' do
      expect(helper.total_steps).to eql(2)
    end
  end

  describe '#current_step' do
    let(:params) do
      double('params')
    end

    it 'returns the value of the `create_step` param' do
      allow(params).to receive(:[]).with(:create_step).and_return(1)
      allow(helper).to receive(:params).and_return(params)
      expect(helper.current_step).to eql(1)
    end
  end
end
