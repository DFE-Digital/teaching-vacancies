require 'rails_helper'
RSpec.describe JobSpecificationForm, type: :model do
  subject { JobSpecificationForm.new({}) }

  context 'validations' do
    it { should validate_presence_of(:job_title) }
    it { should validate_presence_of(:job_description) }
    it { should validate_presence_of(:minimum_salary) }
    it { should validate_presence_of(:working_pattern_ids) }

    describe '#maximum_salary' do
      let(:job_specification) do
        JobSpecificationForm.new(job_title: 'job title',
                                 job_description: 'description',
                                 minimum_salary: 20, maximum_salary: 10)
      end

      it 'the maximum salary should be higher than the minimum salary' do
        expect(job_specification.valid?).to be false
        expect(job_specification.errors.messages[:maximum_salary][0])
          .to eq('must be higher than the minimum salary')
      end
    end
  end

  describe '#starts_on' do
    it 'has no validation applied when blank' do
      job_specification_form = JobSpecificationForm.new(starts_on: nil)
      job_specification_form.valid?

      expect(job_specification_form).to have(:no).errors_on(:starts_on)
    end

    it 'must be in the future' do
      job_specification_form = JobSpecificationForm.new(starts_on: 1.day.ago)
      expect(job_specification_form.valid?).to be false

      expect(job_specification_form).to have(1).errors_on(:starts_on)
      expect(job_specification_form.errors.messages[:starts_on][0])
        .to eq('can\'t be in the past')
    end

    it 'must be before the ends_on date' do
      job_specification_form = JobSpecificationForm.new(starts_on: Time.zone.today + 10.days,
                                                        ends_on: Time.zone.today + 5.days)
      expect(job_specification_form.valid?).to be false

      expect(job_specification_form).to have(1).errors_on(:starts_on)
      expect(job_specification_form.errors.messages[:starts_on][0])
        .to eq('can\'t be after the end date')
    end

    it 'must be after the closing date' do
      job_specification_form = JobSpecificationForm.new(starts_on: Time.zone.today,
                                                        expires_on: Time.zone.tomorrow)
      expect(job_specification_form.valid?).to be false

      expect(job_specification_form).to have(1).errors_on(:starts_on)
      expect(job_specification_form.errors.messages[:starts_on][0])
        .to eq('must be after the closing date')
    end
  end

  describe '#ends_on' do
    it 'has no validation applied when blank' do
      job_specification_form = JobSpecificationForm.new(ends_on: nil)
      job_specification_form.valid?

      expect(job_specification_form).to have(:no).errors_on(:ends_on)
    end

    it 'must be in the future' do
      job_specification_form = JobSpecificationForm.new(ends_on: 1.day.ago)
      expect(job_specification_form.valid?).to be false

      expect(job_specification_form).to have(1).errors_on(:ends_on)
      expect(job_specification_form.errors.messages[:ends_on][0])
        .to eq('can\'t be in the past')
    end

    it 'must be after the closing date' do
      job_specification_form = JobSpecificationForm.new(ends_on: Time.zone.today,
                                                        expires_on: Time.zone.tomorrow)
      expect(job_specification_form.valid?).to be false

      expect(job_specification_form).to have(1).errors_on(:ends_on)
      expect(job_specification_form.errors.messages[:ends_on][0])
        .to eq('must be after the closing date')
    end
  end

  context 'when all attributes are valid' do
    let(:min_pay_scale) { create(:pay_scale) }
    let(:max_pay_scale) { create(:pay_scale) }
    let(:main_subject) { create(:subject) }
    let(:leadership) { create(:leadership) }
    let(:full_time) { create(:working_pattern, :full_time) }

    it 'a JobSpecificationForm can be converted to a vacancy' do
      job_specification_form = JobSpecificationForm.new(job_title: 'English Teacher',
                                                        job_description: 'description',
                                                        working_pattern_ids: [full_time.id],
                                                        minimum_salary: 20000, maximum_salary: 40000,
                                                        benefits: 'benefits', subject_id: main_subject.id,
                                                        min_pay_scale_id: min_pay_scale.id,
                                                        max_pay_scale_id: max_pay_scale.id,
                                                        leadership_id: leadership.id,
                                                        newly_qualified_teacher: true)

      expect(job_specification_form.valid?).to be true
      expect(job_specification_form.vacancy.job_title).to eq('English Teacher')
      expect(job_specification_form.vacancy.job_description).to eq('description')
      expect(job_specification_form.vacancy.working_pattern_ids).to eq([full_time.id])
      expect(job_specification_form.vacancy.minimum_salary).to eq('20000')
      expect(job_specification_form.vacancy.maximum_salary).to eq('40000')
      expect(job_specification_form.vacancy.benefits).to eq('benefits')
      expect(job_specification_form.vacancy.min_pay_scale.label).to eq(min_pay_scale.label)
      expect(job_specification_form.vacancy.max_pay_scale.label).to eq(max_pay_scale.label)
      expect(job_specification_form.vacancy.subject.name).to eq(main_subject.name)
      expect(job_specification_form.vacancy.leadership.title).to eq(leadership.title)
      expect(job_specification_form.vacancy.newly_qualified_teacher).to eq(true)
    end
  end
end
