require 'rails_helper'

RSpec.describe 'Hiring staff can filter vacancies in their dashboard' do
  let(:school_group) { create(:trust) }
  let(:school_1) { create(:school, name: 'Happy Rainbows School') }
  let(:school_2) { create(:school, name: 'Dreary Grey School') }
  let!(:school_group_vacancy) { create(:vacancy, :published, :at_central_office) }
  let!(:school_1_vacancy) { create(:vacancy, :published, :at_one_school) }
  let!(:school_1_draft_vacancy) { create(:vacancy, :draft, :at_one_school) }
  let!(:school_2_draft_vacancy) { create(:vacancy, :draft, :at_one_school) }

  before do
    school_group_vacancy.organisation_vacancies.create(organisation: school_group)
    school_1_vacancy.organisation_vacancies.create(organisation: school_1)
    school_1_draft_vacancy.organisation_vacancies.create(organisation: school_1)
    school_2_draft_vacancy.organisation_vacancies.create(organisation: school_2)

    SchoolGroupMembership.find_or_create_by(school_id: school_1.id, school_group_id: school_group.id)
    SchoolGroupMembership.find_or_create_by(school_id: school_2.id, school_group_id: school_group.id)

    stub_accepted_terms_and_conditions
    OmniAuth.config.test_mode = true

    stub_authentication_step(school_urn: nil, school_group_uid: school_group.uid)
    stub_authorisation_step
    stub_sign_in_with_multiple_organisations

    visit root_path
    sign_in_user

    UserPreference.find_or_create_by(
      user_id: User.last.id, school_group_id: school_group.id,
      managed_organisations: managed_organisations, managed_school_ids: managed_school_ids
    )
  end

  after do
    OmniAuth.config.mock_auth[:default] = nil
    OmniAuth.config.mock_auth[:dfe] = nil
    OmniAuth.config.test_mode = false
  end

  context 'when managed_organisations is all' do
    let(:managed_organisations) { 'all' }
    let(:managed_school_ids) { [] }

    context 'when viewing published jobs tab' do
      scenario 'it shows all published vacancies' do
        visit jobs_with_type_organisation_path(:published)

        expect(page).to_not have_css('.moj-filter__tag')
        expect(page).to have_content('Showing all jobs')

        expect(page).to have_content(school_group_vacancy.job_title)
        expect(page).to have_content(school_1_vacancy.job_title)
        expect(page).to_not have_content(school_1_draft_vacancy.job_title)
        expect(page).to_not have_content(school_2_draft_vacancy.job_title)
      end

      context 'when applying filters' do
        scenario 'it shows filtered published vacancies' do
          visit jobs_with_type_organisation_path(:published)

          check 'Happy Rainbows School (1)', name: 'managed_organisations_form[managed_school_ids][]', visible: false
          click_on I18n.t('buttons.apply_filters')

          expect(page).to have_css('.moj-filter__tag', count: 1)
          expect(page).to have_content('1 filter applied')

          expect(page).to_not have_content(school_group_vacancy.job_title)
          expect(page).to have_content(school_1_vacancy.job_title)
          expect(page).to_not have_content(school_1_draft_vacancy.job_title)
          expect(page).to_not have_content(school_2_draft_vacancy.job_title)
        end
      end
    end

    context 'when viewing draft jobs tab' do
      scenario 'it shows all draft vacancies' do
        visit jobs_with_type_organisation_path(:draft)

        expect(page).to_not have_css('.moj-filter__tag')
        expect(page).to have_content('Showing all jobs')

        expect(page).to_not have_content(school_group_vacancy.job_title)
        expect(page).to_not have_content(school_1_vacancy.job_title)
        expect(page).to have_content(school_1_draft_vacancy.job_title)
        expect(page).to have_content(school_2_draft_vacancy.job_title)
      end
    end
  end

  context 'when managed_school_ids contains school_group_id' do
    let(:managed_organisations) { '' }
    let(:managed_school_ids) { [school_group.id] }

    scenario 'it shows filtered published vacancies' do
      visit organisation_path

      expect(page).to have_css('.moj-filter__tag', count: 1)
      expect(page).to have_content('1 filter applied')

      expect(page).to have_content(school_group_vacancy.job_title)
      expect(page).to_not have_content(school_1_vacancy.job_title)
      expect(page).to_not have_content(school_1_draft_vacancy.job_title)
      expect(page).to_not have_content(school_2_draft_vacancy.job_title)
    end
  end

  context 'when managed_school_ids is not empty' do
    let(:managed_organisations) { '' }
    let(:managed_school_ids) { [school_1.id, school_2.id] }

    scenario 'it shows filtered published vacancies' do
      visit organisation_path

      expect(page).to have_css('.moj-filter__tag', count: 2)
      expect(page).to have_content('2 filters applied')

      expect(page).to_not have_content(school_group_vacancy.job_title)
      expect(page).to have_content(school_1_vacancy.job_title)
      expect(page).to_not have_content(school_1_draft_vacancy.job_title)
      expect(page).to_not have_content(school_2_draft_vacancy.job_title)
    end
  end
end
