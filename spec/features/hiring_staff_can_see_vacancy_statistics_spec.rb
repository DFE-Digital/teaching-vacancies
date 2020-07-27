require 'rails_helper'

RSpec.feature 'Hiring staff can NOT see vacancy statistics' do
  let(:school) { create(:school) }
  let(:total_pageviews) { nil }
  let(:total_get_more_info_clicks) { nil }

  before { stub_hiring_staff_auth(urn: school.urn) }

  context 'when vacancy is published' do
    let(:status) { 'published' }

    let!(:vacancy) do
      create(:vacancy,
             school: school,
             status: status,
             total_pageviews: total_pageviews,
             total_get_more_info_clicks: total_get_more_info_clicks)
    end

    before do
      visit organisation_path(school)
    end

    # The removed tests for page view displays can be found in the git history.

    scenario 'page views are not shown' do
      expect(page).not_to have_content('Total views')
    end
  end

  context 'when vacancy is expired' do
    let!(:vacancy) do
      expired_vacancy = build(:vacancy,
                              :expired,
                              school: school,
                              total_pageviews: total_pageviews,
                              total_get_more_info_clicks: total_get_more_info_clicks)
      expired_vacancy.save(validate: false)
      expired_vacancy
    end

    before do
      visit jobs_with_type_organisation_path(:expired)
    end


    # The removed tests for page view displays can be found in the git history.

    scenario 'page views are not shown' do
      expect(page).not_to have_content('Total views')
    end
  end
end
