require 'rails_helper'
RSpec.describe VacancyPresenter do
  describe '#salary_range' do
    let(:vacancy) { VacancyPresenter.new(create(:vacancy, minimum_salary: 30000, maximum_salary: 40000)) }

    it 'return the formatted minimum to maximum salary' do
      expect(vacancy.salary_range).to eq('£30,000 to £40,000 per year')
    end

    it 'returns the formatted minumum to maximum salary with the specified delimiter' do
      expect(vacancy.salary_range('to')).to eq('£30,000 to £40,000 per year')
    end

    context 'when no maximum salary is set' do
      let(:vacancy) { VacancyPresenter.new(create(:vacancy, minimum_salary: 30000, maximum_salary: nil)) }

      it 'should just return the minimum salary' do
        expect(vacancy.salary_range).to eq('£30,000')
      end
    end

    context 'when the vacancy is part time' do
      let(:vacancy) do
        VacancyPresenter.new(
          create(:vacancy,
                 working_patterns: ['part_time'],
                 minimum_salary: 30000, maximum_salary: 40000)
        )
      end

      it 'should state the salary is full time equivalent' do
        expect(vacancy.salary_range).to eq('£30,000 to £40,000 per year (full-time equivalent)')
      end
    end
  end

  describe '#expired?' do
    context 'when expiry time not given' do
      it 'returns true when the vacancy has expired' do
        vacancy = VacancyPresenter.new(build(:vacancy, :with_no_expiry_time, expires_on: 4.days.ago))
        expect(vacancy).to be_expired
      end

      it 'returns false when the vacancy expires today' do
        vacancy = VacancyPresenter.new(build(:vacancy, :with_no_expiry_time, expires_on: Time.zone.today))
        expect(vacancy).not_to be_expired
      end

      it 'returns false when the vacancy has yet to expire' do
        vacancy = VacancyPresenter.new(build(:vacancy, :with_no_expiry_time, expires_on: 6.days.from_now))
        expect(vacancy).not_to be_expired
      end
    end

    context 'when expiry time given' do
      it 'returns true when the vacancy has expired by now' do
        vacancy = VacancyPresenter.new(build(:vacancy, expiry_time: Time.zone.now - 1.hour))

        expect(vacancy).to be_expired
      end

      it 'returns false when the vacancy expires later today' do
        vacancy = VacancyPresenter.new(build(:vacancy, expiry_time: Time.zone.now + 1.hour))

        expect(vacancy).not_to be_expired
      end
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

  describe '#working_patterns' do
    it 'returns nil if working_patterns is unset' do
      vacancy = VacancyPresenter.new(create(:vacancy,
                                            :without_working_patterns,
                                            school: create(:school, name: 'Smith High School')))

      expect(vacancy.working_patterns).to be_nil
    end

    it 'returns a working patterns string if working_patterns is set' do
      vacancy = VacancyPresenter.new(create(:vacancy,
                                            school: create(:school, name: 'Smith High School'),
                                            working_patterns: ['full_time', 'part_time']))

      expect(vacancy.working_patterns).to eq(I18n.t('jobs.working_patterns_info_many',
                                                    patterns: 'full-time, part-time'))
    end
  end

  describe '#working_patterns_for_job_schema' do
    it 'returns nil if working_patterns is unset' do
      vacancy = VacancyPresenter.new(create(:vacancy,
                                            :without_working_patterns,
                                            school: create(:school, name: 'Smith High School')))

      expect(vacancy.working_patterns_for_job_schema).to be_nil
    end

    it 'returns a working patterns string if working_patterns is set' do
      vacancy = VacancyPresenter.new(create(:vacancy,
                                            school: create(:school, name: 'Smith High School'),
                                            working_patterns: ['full_time', 'part_time']))

      expect(vacancy.working_patterns_for_job_schema).to eq('FULL_TIME, PART_TIME')
    end
  end

  describe '#share_url' do
    it 'returns the absolute public url for the job post' do
      vacancy = VacancyPresenter.new(create(:vacancy, job_title: 'PE Teacher'))
      expected_url = URI('localhost:3000/jobs/pe-teacher')
      expect(vacancy.share_url).to match(expected_url.to_s)
    end

    context 'when campaign parameters are passed' do
      it 'builds the campaign URL' do
        vacancy = VacancyPresenter.new(create(:vacancy, job_title: 'PE Teacher'))
        expected_campaign_url = URI('https://localhost:3000/jobs/pe-teacher?utm_medium=dance&utm_source=subscription')
        expect(vacancy.share_url(source: 'subscription', medium: 'dance')).to match(expected_campaign_url.to_s)
      end
    end
  end

  describe '#to_row' do
    let(:vacancy) { VacancyPresenter.new(create(:vacancy)) }
    before do
      allow(vacancy).to receive(:id).and_return('123a-456b-789c')
      allow(vacancy).to receive(:slug).and_return('my-new-vacancy')
    end

    it 'creates a CSV row representation of the vacancy' do
      expect(vacancy.to_row).to be_a(Hash)
      expect(vacancy.to_row[:id]).to eq('123a-456b-789c')
      expect(vacancy.to_row[:slug]).to eq('my-new-vacancy')
      expect(vacancy.to_row[:status]).to eq('published')
    end
  end
end
