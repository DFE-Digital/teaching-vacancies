require 'rails_helper'

RSpec.describe HiringStaff::Vacancies::ApplicationController, type: :controller do
  describe '#update_google_index' do
    let!(:vacancy) { create(:vacancy) }

    context 'when in production' do
      before(:each) do
        allow(Rails).to receive(:env)
          .and_return(ActiveSupport::StringInquirer.new('production'))
      end

      it 'does perform the task' do
        expect(UpdateGoogleIndexQueueJob).to receive(:perform_later)
        controller.update_google_index(vacancy)
      end
    end

    context 'when NOT in production' do
      before(:each) do
        allow(Rails).to receive(:env)
          .and_return(ActiveSupport::StringInquirer.new('staging'))
      end

      it 'does NOT perform the task' do
        expect(UpdateGoogleIndexQueueJob).not_to receive(:perform_later)
        controller.update_google_index(vacancy)
      end
    end
  end

  describe '#remove_google_index' do
    let!(:vacancy) { create(:vacancy) }

    context 'when in production' do
      before(:each) do
        allow(Rails).to receive(:env)
          .and_return(ActiveSupport::StringInquirer.new('production'))
      end

      it 'does perform the task' do
        expect(RemoveGoogleIndexQueueJob).to receive(:perform_later)
        controller.remove_google_index(vacancy)
      end
    end

    context 'when NOT in production' do
      before(:each) do
        allow(Rails).to receive(:env)
          .and_return(ActiveSupport::StringInquirer.new('staging'))
      end

      it 'does NOT perform the task' do
        expect(RemoveGoogleIndexQueueJob).not_to receive(:perform_later)
        controller.remove_google_index(vacancy)
      end
    end
  end
end
