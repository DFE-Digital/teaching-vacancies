require 'rails_helper'
RSpec.describe VacancyPresenter do
  describe '#salary_range' do
    it 'return the formatted minimum to maximum salary' do
      vacancy = VacancyPresenter.new(create(:vacancy, minimum_salary: 30000, maximum_salary: 40000))
      expect(vacancy.salary_range).to eq('£30,000 to £40,000 per year')
    end

    it 'returns the formatted minumum to maximum salary with the specified delimiter' do
      vacancy = VacancyPresenter.new(create(:vacancy, minimum_salary: 30000, maximum_salary: 40000))
      expect(vacancy.salary_range('to')).to eq('£30,000 to £40,000 per year')
    end

    context 'when no maximum salary is set' do
      it 'should just return the minimum salary' do
        vacancy = VacancyPresenter.new(create(:vacancy, minimum_salary: 20000, maximum_salary: nil))
        expect(vacancy.salary_range).to eq('£20,000')
      end
    end

    context 'when the vacancy is part time' do
      it 'should state the salary is pro rata' do
        vacancy = VacancyPresenter.new(
          create(:vacancy, minimum_salary: 30000, maximum_salary: 40000, working_pattern: :part_time)
        )
        expect(vacancy.salary_range).to eq('£30,000 to £40,000 per year pro rata')
      end
    end
  end

  describe '#expired?' do
    it 'returns true when the vacancy has expired' do
      vacancy = VacancyPresenter.new(build(:vacancy, expires_on: 4.days.ago))
      expect(vacancy).to be_expired
    end

    it 'returns false when the vacancy expires today' do
      vacancy = VacancyPresenter.new(build(:vacancy, expires_on: Time.zone.today))
      expect(vacancy).not_to be_expired
    end

    it 'returns false when the vacancy has yet to expire' do
      vacancy = VacancyPresenter.new(build(:vacancy, expires_on: 6.days.from_now))
      expect(vacancy).not_to be_expired
    end
  end

  describe '#location' do
    it 'returns the school location' do
      vacancy = VacancyPresenter.new(build(:vacancy))
      school = SchoolPresenter.new(vacancy.school)
      expect(vacancy).to receive(:school).and_return(school)
      expect(school).to receive(:location)

      vacancy.location
    end
  end

  describe '#main_subject' do
    it 'returns the subject name' do
      vacancy = VacancyPresenter.new(build(:vacancy))
      expect(vacancy.main_subject).to eq(vacancy.subject.name)
    end
  end

  describe '#pay_scale_range' do
    it 'returns an empty string when no pay_scale is set' do
      vacancy = VacancyPresenter.new(build(:vacancy, min_pay_scale: nil, max_pay_scale: nil))
      expect(vacancy.pay_scale_range).to eq('')
    end

    it 'returns the minimum payscale when no max_pay_scale is set' do
      vacancy = VacancyPresenter.new(build(:vacancy, max_pay_scale: nil))
      expect(vacancy.pay_scale_range).to eq("from #{vacancy.min_pay_scale.label}")
    end

    it 'returns the maximum payscale when no min_pay_scale is set' do
      vacancy = VacancyPresenter.new(build(:vacancy, min_pay_scale: nil))
      expect(vacancy.pay_scale_range).to eq("up to #{vacancy.max_pay_scale.label}")
    end

    it 'returns the  payscale range when min_pay_scale and max_pay_scale are set' do
      vacancy = VacancyPresenter.new(build(:vacancy))
      expect(vacancy.pay_scale_range).to eq("#{vacancy.min_pay_scale.label} to #{vacancy.max_pay_scale.label}")
    end
  end

  describe '#publish_today?' do
    it 'verifies that the publish_on is set to today' do
      vacancy = VacancyPresenter.new(build(:vacancy, publish_on: Time.zone.today))

      expect(vacancy.publish_today?).to eq(true)
    end
  end

  describe '#job_description' do
    it 'sanitizes and transforms the job_description into HTML' do
      vacancy = build(:vacancy, job_description: '<script> call();</script>Sanitized content')
      presenter = VacancyPresenter.new(vacancy)

      expect(presenter.job_description).to eq('<p> call();Sanitized content</p>')
    end
  end

  describe '#flexible_working' do
    it 'shows nothing if flexible working is not available' do
      school = create(:school)
      vacancy = VacancyPresenter.new(build(:vacancy, school: school, flexible_working: false))
      expect(vacancy.flexible_working).to eq('No')
    end

    it 'shows a link to email the school if flexible working is available' do
      school = create(:school, name: 'Smith High School')
      vacancy = VacancyPresenter.new(build(:vacancy, school: school, flexible_working: true))
      expect(vacancy.flexible_working).to include('Smith High School')
    end
  end

  describe '#share_url' do
    it 'returns the absolute public url for the job post' do
      vacancy = VacancyPresenter.new(create(:vacancy, job_title: 'PE Teacher'))
      expected_url = URI('localhost:3000/jobs/pe-teacher')
      expect(vacancy.share_url).to match(expected_url.to_s)
    end
  end

  describe '#to_row' do
    let(:vacancy) { VacancyPresenter.new(create(:vacancy)) }
    before do
      allow(vacancy).to receive(:id).and_return('123a-456b-789c')
      allow(vacancy).to receive(:slug).and_return('my-new-vacancy')
    end

    it 'creates a CSV row representation of the vacancy' do
      expect(vacancy.to_row).to be_an(Array)
      expect(vacancy.to_row).to include('123a-456b-789c', 'my-new-vacancy', 'published')
    end
  end
end
