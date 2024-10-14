# frozen_string_literal: true

require 'rspec'

RSpec.describe 'Please notify performance analyst if you change this test' do
  describe 'Apply Tag' do
    it 'has the correct text' do
      expect I18n.t("jobseekers.job_applications.apply").to eq("Apply for this job")
    end
  end
end
