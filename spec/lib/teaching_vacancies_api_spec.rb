require 'rails_helper'

RSpec.describe TeachingVacancies::API do
  describe '#vacancies' do
    let(:teaching_vacancies_api) { TeachingVacancies::API.new }
    let(:endpoint) { 'https://teaching-vacancies.service.gov.uk/api/v1/jobs.json' }
    let(:job_postings) do
      [
        { '@context' => 'http://schema.org', '@type' => 'JobPosting', 'title' => 'Teacher of Maths' },
        { '@context' => 'http://schema.org', '@type' => 'JobPosting', 'title' => 'Second in Science' },
      ]
    end
    let(:api_response) { double(body: "{\"data\": #{job_postings.to_json}}") }

    before do
      allow(HTTParty).to receive(:get).with(endpoint).and_return(api_response)
    end

    it 'returns the job postings from the API' do
      expect(teaching_vacancies_api.jobs).to eql(job_postings)
    end

    context 'when a limit is given' do
      it 'limits the amount of job postings returned' do
        expect(teaching_vacancies_api.jobs(limit: 1)).to eql([job_postings.first])
      end
    end
  end
end
