require 'rails_helper'

RSpec.describe PublishVacancyForm do
  describe '#initialize' do
    it 'should set the stages for the form' do
      publish_form = PublishVacancyForm.new(stage1: 'foo', stage2: 'bar')
      expect(publish_form.stages).to eq(stage1: 'foo', stage2: 'bar')
    end
  end

  describe '#default_stage' do
    it 'should return the first stage as the default' do
      publish_form = PublishVacancyForm.new(stage1: 'foo', stage2: 'bar')
      expect(publish_form.default_stage).to eq(:stage1)
    end
  end

  describe '#step' do
    it 'should return the current step in the publishing process' do
      publish_form = PublishVacancyForm.new(stage1: 'foo', stage2: 'bar')
      expect(publish_form.step(:stage1)).to eq(1)

      publish_form = PublishVacancyForm.new(stage1: 'foo', stage2: 'bar')
      expect(publish_form.step(:stage2)).to eq(2)
    end

    it 'should return 1 if the current stage is unknown' do
      publish_form = PublishVacancyForm.new(stage1: 'foo', stage2: 'bar')
      expect(publish_form.step(:baz)).to eq(1)
    end
  end
end