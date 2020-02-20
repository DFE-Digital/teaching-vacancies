require 'rails_helper'

RSpec.describe 'Rendering job search result snippet', type: :view do
  let(:gias_data) { double(:gias_data) }
  let(:school_type) { double(:school_type, label: 'Community school') }
  let(:school) { instance_double(School, school_type: school_type) }
  # vacancy_presenter cannot be an instance_double because VacancyPresenter delegates
  # several methods used for the partial to Vacancy
  let(:vacancy_presenter) { double(:vacancy_presenter,
    expires_on: Time.zone.today.next_day,
    expiry_time: Time.zone.today.next_day,
    job_title: 'Pig Latin Teacher',
    location: 'Abingdon, Oxfordshire',
    salary_range: '£100-200 per year',
    working_patterns: 'Full time only',
    working_patterns?: true) }

  context 'when viewing vacancies belonging to a school with a religious character' do
    it 'displays the religious character' do
      allow(gias_data).to receive(:[]).with('religious_character').and_return('Pagan')
      allow(school).to receive(:gias_data).and_return(gias_data)
      allow(school).to receive(:has_religious_character?).and_return(true)
      allow(vacancy_presenter).to receive(:school).and_return(school)

      render partial: 'vacancies/vacancy.html.haml', locals: { vacancy: vacancy_presenter }

      expect(rendered).to have_content('Community school, Pagan')
    end
  end

  context 'when viewing vacancies belonging to a school without a religious character' do
    it 'does not display the religious character after the school type' do
      allow(gias_data).to receive(:[]).with('religious_character').and_return('None')
      allow(school).to receive(:gias_data).and_return(gias_data)
      allow(school).to receive(:has_religious_character?).and_return(false)
      allow(vacancy_presenter).to receive(:school).and_return(school)

      render partial: 'vacancies/vacancy.html.haml', locals: { vacancy: vacancy_presenter }

      expect(rendered).not_to have_content('Community school, None')
    end
  end
end