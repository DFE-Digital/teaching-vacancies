require 'rails_helper'

RSpec.describe CopyVacancy do
  describe '#call' do
    let(:document_copy) { double('document_copy') }

    before do
      allow(DocumentCopy).to receive(:new).and_return(document_copy)
      allow(document_copy).to receive(:copy).and_return(document_copy)
      allow(document_copy).to receive_message_chain(:copied, :web_content_link).and_return('test_url')
      allow(document_copy).to receive_message_chain(:copied, :id).and_return('test_id')
      allow(document_copy).to receive(:google_error).and_return(false)
    end

    it 'creates a new vacancy as draft' do
      vacancy = create(:vacancy, job_title: 'Maths teacher')

      result = described_class.new(vacancy).call

      expect(result).to be_kind_of(Vacancy)
      expect(Vacancy.count).to eq(2)
      expect(Vacancy.find(result.id).status).to eq('draft')
    end

    it 'does not change the original vacancy' do
      # Needed to compare a FactoryBot object fields for updated_at and created_at
      # and against the record it creates in Postgres.
      Timecop.freeze(Time.zone.local(2008, 9, 1, 12, 0, 0))

      vacancy = create(:vacancy, job_title: 'Maths teacher')

      described_class.new(vacancy).call

      expect(Vacancy.find(vacancy.id).attributes == vacancy.attributes)
        .to eq(true)

      Timecop.return
    end

    context '#documents' do
      it 'copies documents when copying a vacancy' do
        document = create(:document,
          name: 'Test.png',
          size: 1000,
          content_type: 'image/png',
          download_url: 'test/test.png',
          google_drive_id: 'testid'
        )
        vacancy = create(:vacancy, documents: [document])

        result = described_class.new(vacancy).call

        expect(result.documents.first.name).to eq(vacancy.documents.first.name)
      end

      it 'does not copy candidate specification fields' do
        vacancy = create(:vacancy)

        result = described_class.new(vacancy).call

        expect(result.experience).to eq(nil)
        expect(result.education).to eq(nil)
        expect(result.qualifications).to eq(nil)
      end
    end

    context '#subjects' do
      let(:subject) { create(:subject, name: Vacancy::SUBJECT_OPTIONS.sample.first) }
      let(:first_supporting_subject) { create(:subject, name: GetSubjectName::SUBJECT_SYNONYMS.keys.sample) }
      let(:second_supporting_subject) { create(:subject, name: 'An invalid subject') }
      let(:vacancy) { create(
        :vacancy, subjects: subjects, subject: subject,
        first_supporting_subject: first_supporting_subject, second_supporting_subject: second_supporting_subject
      ) }

      context 'subjects array is nil' do
        let(:subjects) { nil }

        it 'pushes valid subjects to the subjects array' do
          expect(described_class.new(vacancy).call.subjects).to include(
            subject.name, GetSubjectName::SUBJECT_SYNONYMS[first_supporting_subject.name]
          )
        end
      end

      context 'subjects array is empty' do
        let(:subjects) { [] }

        it 'pushes valid subjects to the subjects array' do
          expect(described_class.new(vacancy).call.subjects).to include(
            subject.name, GetSubjectName::SUBJECT_SYNONYMS[first_supporting_subject.name]
          )
        end
      end

      context 'subjects array contains subjects' do
        let(:subjects) { [Vacancy::SUBJECT_OPTIONS.sample.first] }

        it 'does not change the subjects array' do
          expect(described_class.new(vacancy).call.subjects).to eql(subjects)
        end
      end
    end

    context 'not all fields are copied' do
      let(:vacancy) do
        create(:vacancy,
               job_title: 'Maths teacher',
               slug: 'maths-teacher',
               weekly_pageviews: 4,
               total_pageviews: 4,
               weekly_pageviews_updated_at: Time.zone.today - 5.days,
               total_pageviews_updated_at: Time.zone.today - 5.days,
               total_get_more_info_clicks: 6,
               total_get_more_info_clicks_updated_at: Time.zone.today - 5.days)
      end
      let(:result) { described_class.new(vacancy).call }

      it 'should not copy the slug of a vacancy' do
        expect(Vacancy.find(result.id).slug).to_not eq('maths-teacher')
      end

      it 'should not copy the weekly page views of a vacancy' do
        expect(Vacancy.find(result.id).weekly_pageviews).to eq(0)
      end

      it 'should not copy the weekly page views update time of a vacancy' do
        Timecop.freeze(Time.zone.today - 5.days) do
          expect(Vacancy.find(result.id).weekly_pageviews_updated_at).to eq(Time.zone.now)
        end
      end

      it 'should not copy the weekly page views of a vacancy' do
        expect(Vacancy.find(result.id).total_pageviews).to eq(0)
      end

      it 'should not copy the weekly page views update time of a vacancy' do
        Timecop.freeze(Time.zone.today - 5.days) do
          expect(Vacancy.find(result.id).total_pageviews_updated_at).to eq(Time.zone.now)
        end
      end

      it 'should not copy the weekly page views of a vacancy' do
        expect(Vacancy.find(result.id).total_get_more_info_clicks).to eq(0)
      end

      it 'should not copy the weekly page views update time of a vacancy' do
        Timecop.freeze(Time.zone.today - 5.days) do
          expect(Vacancy.find(result.id).total_get_more_info_clicks_updated_at).to eq(Time.zone.now)
        end
      end
    end
  end
end
