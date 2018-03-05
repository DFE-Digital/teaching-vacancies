require 'rails_helper'
require 'open-uri'
require 'vacancy_scraper'

RSpec.describe VacancyScraper::NorthEastSchools do

  let(:psychology_teacher_url) { 'https://www.jobsinschoolsnortheast.com/job/teacher-of-psychology-2/' }

  context 'Scraping a vacancy from NorthEastSchools' do
    context 'parses the vacancy details' do

      let(:scraper) { VacancyScraper::NorthEastSchools.new(psychology_teacher_url) }

      before do
        sample_vacancy = File.read(Rails.root.join('spec', 'fixtures', 'teacher-of-psychology.html'))
        stub_request(:get, psychology_teacher_url).to_return(body: sample_vacancy, status: 200)
      end

      it '#job_title' do
        expect(scraper.job_title).to eq('Teacher of Psychology')
      end

      it '#subject' do
        expect(scraper.subject).to eq('Psychology')
      end

      it '#school_name' do
        expect(scraper.school_name).to eq('Kings Priory School')
      end

      it '#contract' do
        expect(scraper.contract).to eq('Permanent')
      end

      it '#working_pattern' do
        expect(scraper.working_pattern).to eq(:full_time)
      end

      it '#salary' do
        expect(scraper.salary).to eq("MPS £22,917 –UPS £38,633")
      end
    end
  end
end
