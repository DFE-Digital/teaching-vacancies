require 'rails_helper'

RSpec.describe HiringStaff::Vacancies::JobSpecificationController, type: :controller do
  let(:vacancy) { double('vacancy') }
  let(:vacancy_id) { double('test_vacancy_id') }
  let(:school_id) { double('test_school_id') }
  let(:job_specification_form) { class_double(JobSpecificationForm) }

  before do
    allow(job_specification_form).to receive(:new)

    allow(controller).to receive(:session).and_return(double('session').as_null_object)
    allow(controller).to receive_message_chain(:session, :key?).with(:urn).and_return(true)
    allow(controller).to receive_message_chain(:current_user, :accepted_terms_and_conditions?).and_return(true)

    allow(vacancy).to receive_message_chain(:id).and_return(vacancy_id)
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
          .to eql(school_job_job_specification_path(vacancy_id))
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
          .to eql(job_specification_school_job_path(school_id: school_id))
      end
    end
  end

  describe '#convert_subject_ids_to_subjects_array' do
    let(:subject) { create(:subject, name: SUBJECT_OPTIONS.sample.first) }
    let(:first_supporting_subject) { create(:subject, name: GetSubjectName::SUBJECT_SYNONYMS.keys.sample) }
    let(:second_supporting_subject) { create(:subject, name: 'An invalid subject') }

    let(:params) do
      {
        job_specification_form: {
          subject_id: subject.id,
          first_supporting_subject_id: first_supporting_subject.id,
          second_supporting_subject_id: second_supporting_subject.id
        }
      }
    end

    it 'converts valid subject ids to a string array of subject names' do
      post :create, params: params
      expect(controller.params[:job_specification_form][:subjects]).to eql(
        [subject.name, GetSubjectName::SUBJECT_SYNONYMS[first_supporting_subject.name]]
      )
    end

    context 'duplicate subject synonyms' do
      let(:subject) { create(:subject, name: 'English Literature') }
      let(:first_supporting_subject) { create(:subject, name: 'English Language') }

      it 'converts valid subject ids to a string array of unique subject names' do
        post :create, params: params
        expect(controller.params[:job_specification_form][:subjects]).to eql(
          ['English']
        )
      end
    end
  end

  describe '#create' do
    context 'job role is suitable for NQT' do
      let(:params) do
        {
          job_specification_form: {
            job_roles: [I18n.t('jobs.job_role_options.nqt_suitable')]
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
            job_roles: [I18n.t('jobs.job_role_options.teacher')]
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
