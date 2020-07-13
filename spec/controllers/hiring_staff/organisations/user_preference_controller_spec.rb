require 'rails_helper'

RSpec.describe HiringStaff::Organisations::UserPreferenceController, type: :controller do
  before do
    allow(controller).to receive_message_chain(:current_organisation, :is_a?).with(:SchoolGroup).and_return(true)
  end

  describe '#user_preferences_form_params' do
    let(:params) do
      { user_preference_form: {
          managed_school_urns: ['']
        },
        commit: commit
      }
    end

    before do
      allow(controller).to receive(:params).and_return(ActionController::Parameters.new(params))
    end

    context 'when commit is Skip this step' do
      let(:commit) { I18n.t('buttons.skip_this_step') }

      it 'sets managed_organisations to all in the params' do
        expect(controller.send(:user_preferences_form_params)[:managed_organisations]).to eql(['all'])
      end
    end

    context 'when managed_organisations is not present in the params' do
      let(:commit) { I18n.t('buttons.continue') }

      it 'sets managed_organisations to [] in the params' do
        expect(controller.send(:user_preferences_form_params)[:managed_organisations]).to eql([])
      end
    end
  end
end
