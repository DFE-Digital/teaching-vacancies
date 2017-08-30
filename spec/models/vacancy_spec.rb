require 'rails_helper'

RSpec.describe Vacancy do
  describe 'validations' do
    it 'has to have a job title' do
      expect(Vacancy.new).to have(1).error_on(:job_title)
    end
    it 'has to have a headline' do
      expect(Vacancy.new).to have(1).error_on(:headline)
    end
    it 'has to have a slug' do
      expect(Vacancy.new).to have(1).error_on(:slug)
    end
    it 'has to have a job description' do
      expect(Vacancy.new).to have(1).error_on(:job_description)
    end
    it 'has to have a minimum salary' do
      expect(Vacancy.new).to have(1).error_on(:minimum_salary)
    end
    it 'has to have essential requirements' do
      expect(Vacancy.new).to have(1).error_on(:essential_requirements)
    end
    it 'has to have a working pattern' do
      expect(Vacancy.new).to have(1).error_on(:working_pattern)
    end
    it 'has to have publication date' do
      expect(Vacancy.new).to have(1).error_on(:publish_on)
    end
    it 'has to have an expiry date' do
      expect(Vacancy.new).to have(1).error_on(:expires_on)
    end
  end
end
