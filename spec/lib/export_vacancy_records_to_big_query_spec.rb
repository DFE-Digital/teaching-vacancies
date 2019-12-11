require 'rails_helper'
require 'export_vacancy_records_to_big_query'

RSpec.describe ExportVacancyRecordsToBigQuery do
  describe '#run!' do
    before do
      ENV['BIG_QUERY_DATASET'] = 'test_dataset'
      expect(bigquery_stub).to receive(:dataset).with('test_dataset').and_return(dataset_stub)
    end

    subject { ExportVacancyRecordsToBigQuery.new(bigquery: bigquery_stub) }

    let(:bigquery_stub) { instance_double('Google::Cloud::Bigquery::Project') }
    let(:dataset_stub) { instance_double('Google::Cloud::Bigquery::Dataset') }

    context 'with one vacancy' do
      let(:vacancy) { create(:vacancy).reload }

      let(:expected_table_data) do
        [
          {
          id: vacancy.id,
          slug: vacancy.slug,
          job_title: vacancy.job_title,
          minimum_salary: vacancy.minimum_salary,
          maximum_salary: vacancy.maximum_salary,
          starts_on: vacancy.starts_on,
          ends_on: vacancy.ends_on,
          subjects: subjects,
          min_pay_scale: vacancy.min_pay_scale.label,
          max_pay_scale: vacancy.max_pay_scale.label,
          leadership: vacancy.leadership&.title,
          education: vacancy.education,
          qualifications: vacancy.qualifications,
          experience: vacancy.experience,
          status: vacancy.status,
          expiry_time: format_date(vacancy.expiry_time), # TODO: Combine 2 fields
          publish_on: format_date(vacancy.publish_on),
          school: {
            urn: vacancy.school.urn,
            county: vacancy.school.county,
          },
          created_at: vacancy.created_at,
          updated_at: vacancy.updated_at,
          application_link: vacancy.application_link,
          newly_qualified_teacher: vacancy.newly_qualified_teacher,
          total_pageviews: vacancy.total_pageviews,
          total_get_more_info_clicks: vacancy.total_get_more_info_clicks,
          working_patterns: vacancy.working_patterns,
          listed_elsewhere: vacancy.listed_elsewhere,
          hired_status: vacancy.hired_status,
          pro_rata_salary: vacancy.pro_rata_salary,
          publisher_user_id: vacancy.publisher_user&.oid,
        }
      ]
      end

      context 'with only one subject' do
        let(:subjects) { [vacancy.subject.name] }

        it 'inserts into big query with one subject' do
          expect(dataset_stub).to receive(:insert).with('vacancies', expected_table_data, autocreate: true)

          subject.run!
        end
      end

      context 'with multiple subjects' do
        let(:vacancy) { create(:vacancy, :first_supporting_subject, :second_supporting_subject).reload }
        let(:subjects) do
          [vacancy.subject.name, vacancy.first_supporting_subject.name, vacancy.second_supporting_subject.name]
        end

        it 'inserts into big query with multiple subjects' do
          expect(dataset_stub).to receive(:insert).with('vacancies', expected_table_data, autocreate: true)

          subject.run!
        end
      end
    end

    context 'when the number of vacancies is greater than the batch size' do
      before { create_list(:vacancy, 3) }

      it 'inserts into big query twice' do
        expect(dataset_stub).to receive(:insert).twice

        subject.run!(batch_size: 2)
      end
    end

    def format_date(date)
      date.strftime('%FT%T%:z')
    end
  end
end
