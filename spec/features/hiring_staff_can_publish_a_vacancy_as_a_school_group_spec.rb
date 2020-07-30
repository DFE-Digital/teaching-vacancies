require 'rails_helper'

RSpec.feature 'Creating a vacancy' do
  let(:school_group) { create(:school_group) }
  let(:school) { create(:school, name: 'Special school group school') }
  let(:session_id) { SecureRandom.uuid }

  before do
    allow(SchoolGroupJobsFeature).to receive(:enabled?).and_return(true)
    SchoolGroupMembership.find_or_create_by(school_id: school.id, school_group_id: school_group.id)
    stub_hiring_staff_auth(uid: school_group.uid, session_id: session_id)
  end

  context 'when job is located at school group central office' do
    let(:vacancy) { build(:vacancy, :with_school_group, :complete) }

    describe '#job_location' do
      scenario 'redirects to job details when submitted successfully but vacancy is not created' do
        visit new_organisation_job_path

        expect(page).to have_content(I18n.t('jobs.current_step', step: 1, total: 8))
        within('h2.govuk-heading-l') do
          expect(page).to have_content(I18n.t('jobs.job_location'))
        end

        fill_in_job_location_form_field(vacancy)
        click_on I18n.t('buttons.continue')

        expect(page).to have_content(I18n.t('jobs.current_step', step: 2, total: 8))
        within('h2.govuk-heading-l') do
          expect(page).to have_content(I18n.t('jobs.job_details'))
        end

        expect(Vacancy.count).to eql(0)
      end
    end

    describe '#job_details' do
      scenario 'vacancy is created' do
        visit new_organisation_job_path

        fill_in_job_location_form_field(vacancy)
        click_on I18n.t('buttons.continue')

        fill_in_job_specification_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        expect(Vacancy.last.state).to eql('create')
        expect(Vacancy.last.readable_job_location).to eql(
          I18n.t('hiring_staff.organisations.school_groups.readable_job_location')
        )
        activity = Vacancy.last.activities.last
        expect(activity.session_id).to eql(session_id)
        expect(activity.key).to eql('vacancy.create')
        expect(activity.parameters.symbolize_keys).to include(job_title: [nil, vacancy.job_title])
      end
    end
  end

  context 'when job is located at a single school in the school group' do
    let(:vacancy) do
      build(:vacancy, :with_school_group_at_school, :complete, school_group: school_group, school: school)
    end

    describe '#job_location' do
      scenario 'redirects to job details when submitted successfully but vacancy is not created' do
        visit new_organisation_job_path

        expect(page).to have_content(I18n.t('jobs.current_step', step: 1, total: 8))
        within('h2.govuk-heading-l') do
          expect(page).to have_content(I18n.t('jobs.job_location'))
        end

        fill_in_job_location_form_field(vacancy)
        click_on I18n.t('buttons.continue')

        expect(page).to have_content(I18n.t('jobs.current_step', step: 1, total: 8))
        within('h2.govuk-heading-l') do
          expect(page).to have_content(I18n.t('jobs.job_location'))
        end

        expect(Vacancy.count).to eql(0)

        fill_in_school_form_field(school)
        click_on I18n.t('buttons.continue')

        expect(page).to have_content(I18n.t('jobs.current_step', step: 2, total: 8))
        within('h2.govuk-heading-l') do
          expect(page).to have_content(I18n.t('jobs.job_details'))
        end

        expect(Vacancy.count).to eql(0)
      end
    end

    describe '#job_details' do
      scenario 'vacancy is created' do
        visit new_organisation_job_path

        fill_in_job_location_form_field(vacancy)
        click_on I18n.t('buttons.continue')

        fill_in_school_form_field(school)
        click_on I18n.t('buttons.continue')

        fill_in_job_specification_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        expect(Vacancy.last.state).to eql('create')
        expect(Vacancy.last.readable_job_location).to eql(school.name)
        activity = Vacancy.last.activities.last
        expect(activity.session_id).to eql(session_id)
        expect(activity.key).to eql('vacancy.create')
        expect(activity.parameters.symbolize_keys).to include(job_title: [nil, vacancy.job_title])
      end
    end
  end
end
