require 'rails_helper'
require 'open-uri'
require 'vacancy_scraper'

RSpec.describe VacancyScraper::NorthEastSchools do
  context 'Scraping NorthEastSchool vacancies' do
    before(:each) do
      create(:pay_scale, code: 'MPS1', salary: 22917)
      create(:pay_scale, code: 'UPS3', salary: 38633)
      create(:pay_scale, code: 'LPS5', salary: 44544)
      create(:pay_scale, code: 'LPS12', salary: 51639)
      create(:pay_scale, code: 'LPS16', salary: 59857)
      create(:pay_scale, code: 'LPS29', salary: 159857)
      create(:pay_scale, code: 'LPS35', salary: 189857)
    end

    context 'Retrieving the listed vacancy urls' do
      let(:list_manager) { VacancyScraper::NorthEastSchools::ListManager.new }

      before do
        vacancies = File.read(Rails.root.join('spec', 'fixtures', 'vacancies-1.html'))
        stub_request(:get, VacancyScraper::NorthEastSchools::ListManager::SEARCH_PATH)
          .to_return(body: vacancies, status: 200)
      end

      it 'search_results' do
        expect(list_manager.search_results.count).to eq(5)
        expect(list_manager.search_results.first).to eq('https://www.jobsinschoolsnortheast.com/job/teacher-year-5-3/')
        expect(list_manager.search_results.last).to eq('https://www.jobsinschoolsnortheast.com/job/teachers-mathematics-2-posts-ups-mps/')
      end

      it 'next_page' do
        expect(list_manager.next_page).to eq('https://www.jobsinschoolsnortheast.com/search-results/2/?schooltype=82+96+87+84+80+74+81+73+85+76+72+75+91+83&jobrole=11&subject=&area=')
      end

      it 'processes all pages' do
        list_manager = double(VacancyScraper::NorthEastSchools::ListManager, search_results: [], next_page: nil)

        expect(VacancyScraper::NorthEastSchools::ListManager).to receive(:new).and_return(list_manager)

        VacancyScraper::NorthEastSchools::Processor.execute!
      end
    end

    context 'Vacancy examples' do
      context 'when the school name is similar to others by 1 word' do
        let(:scraper) { VacancyScraper::NorthEastSchools::Scraper.new(health_and_social_teacher_url) }
        let(:health_and_social_teacher_url) do
          'https://www.jobsinschoolsnortheast.com/job/teacher-health-social-care-5/'
        end

        before do
          health_and_social_teacher = File.read(Rails.root.join('spec', 'fixtures', 'health-and-social.html'))
          stub_request(:get, health_and_social_teacher_url).to_return(body: health_and_social_teacher, status: 200)
        end

        it 'returns the correct school' do
          create(:school, name: 'Durham Sixth Form Centre')
          create(:school, name: 'Eltham Sixth Form Centre')
          create(:school, name: 'Fulham Sixth Form Centre')
          create(:school, name: 'Witham Sixth Form Centre')

          expect(scraper.school.name).to eq('Durham Sixth Form Centre')
        end
      end

      context 'Psychology teacher sample' do
        let(:scraper) { VacancyScraper::NorthEastSchools::Scraper.new(psychology_teacher_url) }
        let(:psychology_teacher_url) { 'https://www.jobsinschoolsnortheast.com/job/teacher-of-psychology-2/' }

        before do
          psychology_teacher = File.read(Rails.root.join('spec', 'fixtures', 'teacher-of-psychology.html'))
          stub_request(:get, psychology_teacher_url).to_return(body: psychology_teacher, status: 200)
        end

        it '#job_title' do
          expect(scraper.job_title).to eq('Teacher of Psychology')
        end

        it '#job_description' do
          expect(scraper.job_description).to_not include(
            'please click <a href="https://kingspriory.careers.eteach.com/o/teacher-of-psychology">here \
            </a> to be redirected'
          )

          expect(scraper.job_description).to include('please click here to be redirected')
        end

        it '#url' do
          expect(scraper.url).to eq('http://www.kingsprioryschool.co.uk')
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
          expect(scraper.salary).to eq('MPS £22,917 –UPS £38,633')
        end

        it '#pay_scale' do
          expect(scraper.pay_scale).to eq('MPS1')
        end

        it '#max_salary' do
          expect(scraper.max_salary).to eq('38633')
        end

        it '#min_salary' do
          expect(scraper.min_salary).to eq('22917')
        end

        it '#starts_on' do
          expect(scraper.starts_on).to eq(Date.new(2018, 9, 1))
        end

        it '#ends_on' do
          expect(scraper.ends_on).to eq(Date.new(2018, 3, 22))
        end

        it 'saved as it passes validation' do
          expect(Vacancy).to receive_message_chain(:where, :exists?).and_return(false)
          expect(School).to receive(:where).and_return([create(:school)])

          # ensure publish_on is not past the fixture's end date (22 3 2018)
          expect(Time.zone).to receive(:today).and_return(Date.new(2018, 3, 20))

          scraper.map!
          expect(Vacancy.count).to eq(1)
        end
      end

      context 'Math teacher sample' do
        let(:vacancy_url) { 'https://www.jobsinschoolsnortheast.com/job/assistant-curriculum-leader-mathematics-2/' }
        let(:scraper) { VacancyScraper::NorthEastSchools::Scraper.new(vacancy_url) }
        before do
          stub_const('VacancyScraper::NorthEastSchools::Scraper::SUBJECTS_REGEX',
                     'English|Economics|General Science|Math')
          math_teacher = File.read(Rails.root.join('spec', 'fixtures', 'math-teacher.html'))
          stub_request(:get, vacancy_url).to_return(body: math_teacher, status: 200)
        end

        it '#job_title' do
          expect(scraper.job_title).to eq('Assistant Curriculum Leader: Mathematics')
        end

        it '#job_description' do
          expect(scraper.job_description).to include(
            '<p><strong>ASSISTANT CURRICULUM LEADER: MATHEMATICS </strong></p>'
          )
        end

        it '#subject' do
          expect(scraper.subject).to eq('Math')
        end

        it '#school_name' do
          expect(scraper.school_name).to eq('George Stephenson High School')
        end

        it '#contract' do
          expect(scraper.contract).to eq('Permanent')
        end

        it '#working_pattern' do
          expect(scraper.working_pattern).to eq(:full_time)
        end

        it '#work_hours' do
          expect(scraper.work_hours).to eq('32.5')
        end

        it '#salary' do
          expect(scraper.salary).to eq('TMPS/UPS')
        end

        it '#pay_scale' do
          expect(scraper.pay_scale).to eq('MPS1')
        end

        it '#max_salary' do
          expect(scraper.max_salary).to eq(38633)
        end

        it '#min_salary' do
          expect(scraper.min_salary).to eq(22917)
        end

        it '#ends_on' do
          expect(scraper.ends_on).to eq(Date.new(2018, 3, 15))
        end
      end

      context 'Main scale teacher' do
        let(:main_scale_teacher_url) { 'https://www.jobsinschoolsnortheast.com/job/permanent-main-scale-teacher/' }
        let(:scraper) { VacancyScraper::NorthEastSchools::Scraper.new(main_scale_teacher_url) }

        before do
          teacher = File.read(Rails.root.join('spec', 'fixtures', 'primary-teacher.html'))
          stub_request(:get, main_scale_teacher_url).to_return(body: teacher, status: 200)
        end

        it '#job_title' do
          expect(scraper.job_title).to eq('Permanent Main Scale Teacher')
        end

        it '#job_description' do
          expect(scraper.job_description).to include(
            '<p><strong>Permanent Main Scale Teacher plus TLR2B (KS2 and maths)</strong></p>'
          )
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
          expect(scraper.working_pattern).to eq(:full_time)
        end

        it '#salary' do
          expect(scraper.salary).to eq('Range: £23,375 to £34,500 plus £4,530 TLR2B')
        end

        it '#pay_scale' do
          expect(scraper.pay_scale).to eq(nil)
        end

        it '#starts_on' do
          expect(scraper.starts_on).to eq(Date.new(2018, 9, 1))
        end

        it '#max_salary' do
          expect(scraper.max_salary).to eq('34500')
        end

        it '#min_salary' do
          expect(scraper.min_salary).to eq('23375')
        end

        it '#ends_on' do
          expect(scraper.ends_on).to eq(Date.new(2018, 3, 19))
        end
      end

      context 'English teacher' do
        let(:url) { 'https://www.jobsinschoolsnortheast.com/job/teacher-of-english-45/' }
        let(:scraper) { VacancyScraper::NorthEastSchools::Scraper.new(url) }

        before do
          stub_const('VacancyScraper::NorthEastSchools::Scraper::SUBJECTS_REGEX',
                     'English|Economics|General Science|History')

          teacher = File.read(Rails.root.join('spec', 'fixtures', 'english-teacher.html'))
          stub_request(:get, url).to_return(body: teacher, status: 200)
        end

        it '#job_title' do
          expect(scraper.job_title).to eq('Teacher of English')
        end

        it '#job_description' do
          expect(scraper.job_description).to include(
            '<p>NQT /Main/Upper Pay Ranges: £22,917 – £38,633 per annum</p>'
          )

          expect(scraper.job_description).to_not include(
            '<p> <p>'
          )
        end

        it '#subject' do
          expect(scraper.subject).to eq('English')
        end

        it '#school_name' do
          expect(scraper.school_name).to eq('Astley Community High School')
        end

        it '#contract' do
          expect(scraper.contract).to eq('Permanent')
        end

        it '#working_pattern' do
          expect(scraper.working_pattern).to eq(:full_time)
        end

        it '#salary' do
          expect(scraper.salary).to eq('NQT /Main/Upper Pay Ranges: £22,917 - £38,633 per annum')
        end

        it '#pay_scale' do
          expect(scraper.pay_scale).to eq('MPS1')
        end

        it '#max_salary' do
          expect(scraper.max_salary).to eq('38633')
        end

        it '#min_salary' do
          expect(scraper.min_salary).to eq('22917')
        end

        it '#ends_on' do
          expect(scraper.ends_on).to eq(Date.new(2018, 3, 20))
        end
      end

      context 'Leadership Role' do
        let(:url) { 'https://www.jobsinschoolsnortheast.com/job/head-physics-specialist-lead-practitioner/' }
        let(:scraper) { VacancyScraper::NorthEastSchools::Scraper.new(url) }

        before do
          teacher = File.read(Rails.root.join('spec', 'fixtures', 'head-physics-specialist.html'))
          stub_request(:get, url).to_return(body: teacher, status: 200)
        end

        it '#job_title' do
          expect(scraper.job_title).to eq('Head of Physics (Specialist Lead Practitioner)')
        end

        it '#subject' do
          expect(scraper.subject).to eq('Physics')
        end

        it '#school_name' do
          expect(scraper.school_name).to eq('The English Martyrs School and Sixth Form College')
        end

        it '#contract' do
          expect(scraper.contract).to eq('Permanent')
        end

        it '#working_pattern' do
          expect(scraper.working_pattern).to eq(:full_time)
        end

        it '#salary' do
          expect(scraper.salary).to eq('Lead Practitioner Scale 5 points to be negotiated')
        end

        it '#pay_scale' do
          expect(scraper.pay_scale).to eq('LPS5')
        end

        it '#max_salary' do
          expect(scraper.max_salary).to eq(nil)
        end

        it '#min_salary' do
          expect(scraper.min_salary).to eq(44544)
        end

        it '#ends_on' do
          expect(scraper.ends_on).to eq(Date.new(2018, 3, 9))
        end

        it '#body' do
          expect(scraper.body.to_html).to include('Salary on Lead Practitioner Scale 5 points to be negotiated')
        end

        it '#application' do
          expect(scraper.application_form).to eq('https://www.jobsinschoolsnortheast.com/wp-content/uploads/2018/02/Teacher-Application-Form-2017.doc')
        end

        it '#supporting_documents' do
          expect(scraper.supporting_documents[0]).to eq('https://www.jobsinschoolsnortheast.com/wp-content/uploads/2018/02/Teacher-Application-Form-2017.doc')
          expect(scraper.supporting_documents[1]).to eq('https://www.jobsinschoolsnortheast.com/wp-content/uploads/2018/02/Lead-Practitioner-Physics-JD.doc')
          expect(scraper.supporting_documents[2]).to eq('https://www.jobsinschoolsnortheast.com/wp-content/uploads/2018/02/Lead-Practioner-Physics-PS.docx')
        end
      end

      context 'Curriculum Geography  Role' do
        let(:url) { 'https://www.jobsinschoolsnortheast.com/job/curriculum-leader-geography/' }
        let(:scraper) { VacancyScraper::NorthEastSchools::Scraper.new(url) }

        before do
          teacher = File.read(Rails.root.join('spec', 'fixtures', 'geography-leader.html'))
          stub_request(:get, url).to_return(body: teacher, status: 200)
        end

        it '#salary' do
          expect(scraper.salary).to eq('M1 - U3 plus TLR2c')
        end

        it '#pay_scale' do
          expect(scraper.pay_scale).to eq('MPS1')
        end

        it '#max_salary' do
          expect(scraper.max_salary).to eq(38633)
        end

        it '#min_salary' do
          expect(scraper.min_salary).to eq(22917)
        end
      end

      context 'Assistant head teacher' do
        let(:url) { 'https://www.jobsinschoolsnortheast.com/job/assistant-headteacher-9/' }
        let(:scraper) { VacancyScraper::NorthEastSchools::Scraper.new(url) }

        before do
          teacher = File.read(Rails.root.join('spec', 'fixtures', 'assistant-headteacher.html'))
          stub_request(:get, url).to_return(body: teacher, status: 200)
        end

        it '#salary' do
          expect(scraper.salary).to eq('Leadership Scale L12-16')
        end

        it '#pay_scale' do
          expect(scraper.pay_scale).to eq('LPS12')
        end

        it '#max_salary' do
          expect(scraper.max_salary).to eq(59857)
        end

        it '#min_salary' do
          expect(scraper.min_salary).to eq(51639)
        end
      end

      context 'Headteacher' do
        let(:url) { 'https://www.jobsinschoolsnortheast.com/job/prudhoe-community-high-school-headteacher/' }
        let(:scraper) { VacancyScraper::NorthEastSchools::Scraper.new(url) }

        before do
          teacher = File.read(Rails.root.join('spec', 'fixtures', 'headteacher.html'))
          stub_request(:get, url).to_return(body: teacher, status: 200)
        end

        it '#salary' do
          expect(scraper.salary).to eq('L29 - L35')
        end

        it '#pay_scale' do
          expect(scraper.pay_scale).to eq('LPS29')
        end

        it '#max_salary' do
          expect(scraper.max_salary).to eq(189857)
        end

        it '#min_salary' do
          expect(scraper.min_salary).to eq(159857)
        end
      end
      context 'MPR/UPR payscale checks' do
        let(:vacancy_url) { 'https://www.jobsinschoolsnortheast.com/job/teacher-of-mathematics-24/' }
        let(:scraper) { VacancyScraper::NorthEastSchools::Scraper.new(vacancy_url) }
        before do
          math_teacher = File.read(Rails.root.join('spec', 'fixtures', 'math-teacher-2.html'))
          stub_request(:get, vacancy_url).to_return(body: math_teacher, status: 200)
        end

        it '#salary' do
          expect(scraper.salary).to eq('MPR / UPR')
        end

        it '#pay_scale' do
          expect(scraper.pay_scale).to eq('MPS1')
        end

        it '#max_salary' do
          expect(scraper.max_salary).to eq(38633)
        end

        it '#min_salary' do
          expect(scraper.min_salary).to eq(22917)
        end
      end

      context 'Main Payscale teacher' do
        let(:vacancy_url) { 'https://www.jobsinschoolsnortheast.com/job/english-ks4-co-ordinator/' }
        let(:scraper) { VacancyScraper::NorthEastSchools::Scraper.new(vacancy_url) }
        before do
          math_teacher = File.read(Rails.root.join('spec', 'fixtures', 'mainscale-teacher.html'))
          stub_request(:get, vacancy_url).to_return(body: math_teacher, status: 200)
        end

        it '#salary' do
          expect(scraper.salary).to eq('Main / Upper Payscale plus £1,938 - £3,921 (dependent on experience)')
        end

        it '#pay_scale' do
          expect(scraper.pay_scale).to eq('MPS1')
        end

        it '#max_salary' do
          expect(scraper.max_salary).to eq(38633)
        end

        it '#min_salary' do
          expect(scraper.min_salary).to eq(22917)
        end
      end

      context 'KS2 Classroom Teacher' do
        let(:vacancy_url) { 'https://www.jobsinschoolsnortheast.com/job/ks2-classroom-teacher/' }
        let(:scraper) { VacancyScraper::NorthEastSchools::Scraper.new(vacancy_url) }
        before do
          math_teacher = File.read(Rails.root.join('spec', 'fixtures', 'ks2-classroom-teacher.html'))
          stub_request(:get, vacancy_url).to_return(body: math_teacher, status: 200)
        end

        it '#salary' do
          expect(scraper.salary).to eq('Main Scale')
        end

        it '#pay_scale' do
          expect(scraper.pay_scale).to eq('MPS1')
        end

        it '#min_salary' do
          expect(scraper.min_salary).to eq(22917)
        end

        it '#ends_on' do
          expect(scraper.ends_on).to eq(nil)
        end

        it '#application_link' do
          expect(scraper.application_link).to eq("#{vacancy_url}#application")
        end

        it 'not saved because it fails validation' do
          expect(Vacancy).to receive_message_chain(:where, :exists?).and_return(false)
          expect(School).to receive(:where).and_return([create(:school)])

          scraper.map!
          expect(Vacancy.count).to eq(0)
        end
      end
    end
  end
end
