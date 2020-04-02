require 'rails_helper'

RSpec.describe HiringStaff::Vacancies::JobSpecificationController, type: :controller do
  describe '#create' do
    before do
      allow(controller).to receive(:session).and_return(double('session').as_null_object)
      allow(controller).to receive_message_chain(:session, :key?).with(:urn).and_return(true)
      allow(controller).to receive_message_chain(:current_user, :accepted_terms_and_conditions?).and_return(true)
    end

    context 'job role is suitable for NQT' do
      let(:params) do
        {
          job_specification_form: {
            job_roles: I18n.t('jobs.job_role_options.nqt_suitable')
          }
        }
      end

      it 'persists the job role in the NQT field' do
        post :create, params: params
        expect(controller.params[:job_specification_form][:newly_qualified_teacher]).to eql(true)
      end
    end

    context 'job role is NOT suitable for NQT' do
      let(:params) do
        {
          job_specification_form: {
            job_roles: I18n.t('jobs.job_role_options.teacher')
          }
        }
      end

      it 'persists the job role in the NQT field' do
        post :create, params: params
        expect(controller.params[:job_specification_form][:newly_qualified_teacher]).to eql(false)
      end
    end
  end
end
