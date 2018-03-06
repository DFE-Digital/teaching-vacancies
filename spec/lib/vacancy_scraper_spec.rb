require 'rails_helper'
require 'open-uri'
require 'vacancy_scraper'

RSpec.describe VacancyScraper::NorthEastSchools do

  let(:psychology_teacher_url) { 'https://www.jobsinschoolsnortheast.com/job/teacher-of-psychology-2/' }

  before do
    ['Mathematics', 'Psychology'].each {|s| Subject.create(name: s) }
  end

  context 'Scraping NorthEastSchool vacancies' do
    context 'Psychology teacher sample' do
      let(:scraper) { VacancyScraper::NorthEastSchools.new(psychology_teacher_url) }

      before do
        psychology_teacher = File.read(Rails.root.join('spec', 'fixtures', 'teacher-of-psychology.html'))
        stub_request(:get, psychology_teacher_url).to_return(body: psychology_teacher, status: 200)
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
        expect(scraper.working_pattern).to eq("full time")
      end

      it '#salary' do
        expect(scraper.salary).to eq("MPS £22,917 –UPS £38,633")
      end

      it '#max_salary' do
        expect(scraper.max_salary).to eq("38,633")
      end

      it '#min_salary' do
        expect(scraper.min_salary).to eq("22,917")
      end
    end

    context 'Math teacher sample' do
      let(:math_teacher_url) { 'https://www.jobsinschoolsnortheast.com/job/assistant-curriculum-leader-mathematics-2/' }
      let(:scraper) { VacancyScraper::NorthEastSchools.new(math_teacher_url) }
      before do
        math_teacher = File.read(Rails.root.join('spec', 'fixtures', 'math-teacher.html'))
        stub_request(:get, math_teacher_url).to_return(body: math_teacher, status: 200)
      end

      it '#job_title' do
        expect(scraper.job_title).to eq('Assistant Curriculum Leader: Mathematics')
      end

      it '#subject' do
        expect(scraper.subject).to eq('Mathematics')
      end

      it '#school_name' do
        expect(scraper.school_name).to eq('George Stephenson High School')
      end

      it '#contract' do
        expect(scraper.contract).to eq('Permanent')
      end

      it '#working_pattern' do
        expect(scraper.working_pattern).to eq("")
      end

      it '#work_hours' do
        expect(scraper.work_hours).to eq("32.5")
      end

      it '#salary' do
        expect(scraper.salary).to eq("TMPS/UPS")
      end

      it '#max_salary' do
        expect(scraper.max_salary).to eq(nil)
      end

      it '#min_salary' do
        expect(scraper.min_salary).to eq(nil)
      end
    end

    context 'Main scale teacher' do
      let(:main_scale_teacher_url) { 'https://www.jobsinschoolsnortheast.com/job/permanent-main-scale-teacher/' }
      let(:scraper) { VacancyScraper::NorthEastSchools.new(main_scale_teacher_url) }

      before do
        teacher = File.read(Rails.root.join('spec', 'fixtures', 'primary-teacher.html'))
        stub_request(:get, main_scale_teacher_url).to_return(body: teacher, status: 200)
      end

      it '#job_title' do
        expect(scraper.job_title).to eq('Permanent Main Scale Teacher')
      end

      it '#subject' do
        expect(scraper.subject).to eq(nil)
      end

      it '#school_name' do
        expect(scraper.school_name).to eq('St Cuthberts')
      end

      it '#contract' do
        expect(scraper.contract).to eq('Permanent')
      end

      it '#working_pattern' do
        expect(scraper.working_pattern).to eq("full time")
      end

      it '#salary' do
        expect(scraper.salary).to eq("Range: £23,375 to £34,500 plus £4,530 TLR2B")
      end

      it '#max_salary' do
        expect(scraper.max_salary).to eq("34,500")
      end

      it '#min_salary' do
        expect(scraper.min_salary).to eq("23,375")
      end
    end
  end
end
