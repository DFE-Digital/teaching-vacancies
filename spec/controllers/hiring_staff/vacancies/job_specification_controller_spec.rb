require 'rails_helper'

RSpec.describe HiringStaff::Vacancies::JobSpecificationController, type: :controller do
  let(:session) { double('session') }
  let(:vacancy) { double('vacancy') }
  let(:vacancy_id) { double('test_vacancy_id') }
  let(:school_id) { double('test_school_id') }
  let(:job_specification_form) { class_double(JobSpecificationForm) }

  before do
    allow(job_specification_form).to receive(:new)

    allow(controller).to receive(:session).and_return(session)
    allow(session).to receive(:[]).with(:urn).and_return('urn')
    allow(session).to receive(:[]).with(:vacancy_attributes).and_return(nil)
    allow(session).to receive(:id).and_return(nil)
    allow(controller).to receive_message_chain(:current_user, :accepted_terms_and_conditions?).and_return(true)
    allow(controller).to receive_message_chain(:current_user, :last_activity_at).and_return(Time.zone.now)
    allow(controller).to receive_message_chain(:current_user, :update)

    allow(vacancy).to receive(:id).and_return(vacancy_id)
    allow(vacancy).to receive(:state).and_return('create')
    controller.instance_variable_set(:@vacancy, vacancy)
  end

  describe '#set_up_url' do
    before do
      allow(vacancy).to receive(:attributes).and_return(double('attributes').as_null_object)
    end

    context 'vacancy id is present' do
      it 'uses the update action' do
        get :show
        expect(controller.instance_variable_get(:@job_specification_url_method)).to eql('patch')
        expect(controller.instance_variable_get(:@job_specification_url))
          .to eql(organisation_job_job_specification_path(vacancy_id))
      end
    end

    context 'vacancy id is not present' do
      before do
        allow(controller).to receive_message_chain(:current_school, :id).and_return(school_id)
        controller.instance_variable_set(:@vacancy, nil)
      end

      it 'uses the create action' do
        get :show
        expect(controller.instance_variable_get(:@job_specification_url_method)).to eql('post')
        expect(controller.instance_variable_get(:@job_specification_url))
          .to eql(job_specification_organisation_job_path(school_id: school_id))
      end
    end
  end
end
