require 'rails_helper'

RSpec.feature 'Hiring staff can see total page views' do
  let(:school) { create(:school) }

  before { stub_hiring_staff_auth(urn: school.urn) }

  context 'when vacancy is published' do
    let(:status) { 'published' }
    let!(:vacancy) { create(:vacancy, school: school, status: status, total_pageviews: total_pageviews) }

    before do
      visit school_path(school)
    end

    context 'page views are nil' do
      let(:total_pageviews) { nil }

      scenario 'page views show zero' do
        within("tr#school_vacancy_presenter_#{vacancy.id}") do
          expect(page.find('td[4]')).to have_content('0')
        end
      end
    end

    context 'page views are present' do
      let(:total_pageviews) { 100 }

      scenario 'page views show the page view count' do
        within("tr#school_vacancy_presenter_#{vacancy.id}") do
          expect(page.find('td[4]')).to have_content(total_pageviews)
        end
      end
    end
  end

  context 'when vacancy is expired' do
    let!(:vacancy) do
      expired_vacancy = build(:vacancy, :expired, school: school, total_pageviews: total_pageviews)
      expired_vacancy.save(validate: false)
      expired_vacancy
    end

    before do
      visit jobs_with_type_school_path(:expired)
    end

    context 'page views are nil' do
      let(:total_pageviews) { nil }

      scenario 'page views show zero' do
        within("tr#school_vacancy_presenter_#{vacancy.id}") do
          expect(page.find('td[4]')).to have_content('0')
        end
      end
    end

    context 'page views are present' do
      let(:total_pageviews) { 100 }

      scenario 'page views show the page view count' do
        within("tr#school_vacancy_presenter_#{vacancy.id}") do
          expect(page.find('td[4]')).to have_content(total_pageviews)
        end
      end
    end
  end
end