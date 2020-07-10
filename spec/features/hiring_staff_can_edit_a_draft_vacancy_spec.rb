require 'rails_helper'
RSpec.feature 'Hiring staff can edit a draft vacancy' do
  let(:school) { create(:school) }
  let!(:vacancy) do
    VacancyPresenter.new(build(:vacancy, :complete,
                               job_title: 'Draft vacancy',
                               school: school,
                               working_patterns: ['full_time', 'part_time']))
  end
  # To find the vacancy which is created by fill_in_job_specification_form_fields(vacancy)
  let(:draft_vacancy) { Vacancy.find_by(job_title: vacancy.job_title) }

  before do
    stub_hiring_staff_auth(urn: school.urn, session_id: SecureRandom.uuid)
  end

  context 'editing an incomplete draft vacancy' do
    context 'as a School-level user' do
      before do
        visit new_organisation_job_path
        fill_in_job_specification_form_fields(vacancy)
        click_on I18n.t('buttons.continue')
      end

      context 'redirects to' do
        scenario 'incomplete pay package step' do
          visit edit_organisation_job_path(id: draft_vacancy.id)

          expect(page).to have_content(I18n.t('jobs.current_step', step: 2, total: 7))
          within('h2.govuk-heading-l') do
            expect(page).to have_content(I18n.t('jobs.pay_package'))
          end
        end

        scenario 'incomplete important dates step' do
          visit edit_organisation_job_path(id: draft_vacancy.id)

          draft_vacancy.salary = 'Pay scale 1 to Pay scale 2'
          draft_vacancy.benefits = 'Gym, health insurance'

          fill_in_pay_package_form_fields(draft_vacancy)
          click_on I18n.t('buttons.continue')

          expect(page).to have_content(I18n.t('jobs.current_step', step: 3, total: 7))
          within('h2.govuk-heading-l') do
            expect(page).to have_content(I18n.t('jobs.important_dates'))
          end
        end

        scenario 'incomplete supporting documents step' do
          visit edit_organisation_job_path(id: draft_vacancy.id)

          draft_vacancy.salary = 'Pay scale 1 to Pay scale 2'
          draft_vacancy.benefits = 'Gym, health insurance'

          fill_in_pay_package_form_fields(draft_vacancy)
          click_on I18n.t('buttons.continue')

          draft_vacancy.starts_on = DateTime.now + 1.year
          draft_vacancy.expires_on = draft_vacancy.starts_on - 1.day
          draft_vacancy.expiry_time = Time.zone.now
          draft_vacancy.publish_on = DateTime.now + 1.day

          fill_in_important_dates_fields(draft_vacancy)
          click_on I18n.t('buttons.continue')

          expect(page).to have_content(I18n.t('jobs.current_step', step: 4, total: 7))
          within('h2.govuk-heading-l') do
            expect(page).to have_content(I18n.t('jobs.supporting_documents'))
          end
        end

        scenario 'documents step if YES selected for supporting documents' do
          visit edit_organisation_job_path(id: draft_vacancy.id)

          draft_vacancy.salary = 'Pay scale 1 to Pay scale 2'
          draft_vacancy.benefits = 'Gym, health insurance'

          fill_in_pay_package_form_fields(draft_vacancy)
          click_on I18n.t('buttons.continue')

          draft_vacancy.starts_on = DateTime.now + 1.year
          draft_vacancy.expires_on = draft_vacancy.starts_on - 1.day
          draft_vacancy.expiry_time = Time.zone.now
          draft_vacancy.publish_on = DateTime.now + 1.day

          fill_in_important_dates_fields(draft_vacancy)
          click_on I18n.t('buttons.continue')

          fill_in_supporting_documents_form_fields
          click_on I18n.t('buttons.continue')

          expect(page).to have_content(I18n.t('jobs.current_step', step: 4, total: 7))
          within('h2.govuk-heading-l') do
            expect(page).to have_content(I18n.t('jobs.supporting_documents'))
          end
        end

        scenario 'application details step if NO selected for supporting documents' do
          visit edit_organisation_job_path(id: draft_vacancy.id)

          draft_vacancy.salary = 'Pay scale 1 to Pay scale 2'
          draft_vacancy.benefits = 'Gym, health insurance'

          fill_in_pay_package_form_fields(draft_vacancy)
          click_on I18n.t('buttons.continue')

          draft_vacancy.starts_on = DateTime.now + 1.year
          draft_vacancy.expires_on = draft_vacancy.starts_on - 1.day
          draft_vacancy.expiry_time = Time.zone.now
          draft_vacancy.publish_on = DateTime.now + 1.day

          fill_in_important_dates_fields(draft_vacancy)
          click_on I18n.t('buttons.continue')

          select_no_for_supporting_documents
          click_on I18n.t('buttons.continue')

          expect(page).to have_content(I18n.t('jobs.current_step', step: 5, total: 7))
          within('h2.govuk-heading-l') do
            expect(page).to have_content(I18n.t('jobs.application_details'))
          end
        end

        scenario 'incomplete application details step' do
          visit edit_organisation_job_path(id: draft_vacancy.id)

          draft_vacancy.salary = 'Pay scale 1 to Pay scale 2'
          draft_vacancy.benefits = 'Gym, health insurance'

          fill_in_pay_package_form_fields(draft_vacancy)
          click_on I18n.t('buttons.continue')

          draft_vacancy.starts_on = DateTime.now + 1.year
          draft_vacancy.expires_on = draft_vacancy.starts_on - 1.day
          draft_vacancy.expiry_time = Time.zone.now
          draft_vacancy.publish_on = DateTime.now + 1.day

          fill_in_important_dates_fields(draft_vacancy)
          click_on I18n.t('buttons.continue')

          fill_in_supporting_documents_form_fields
          click_on I18n.t('buttons.continue')

          click_on I18n.t('buttons.continue')

          expect(page).to have_content(I18n.t('jobs.current_step', step: 5, total: 7))
          within('h2.govuk-heading-l') do
            expect(page).to have_content(I18n.t('jobs.application_details'))
          end
        end

        scenario 'incomplete job summary step' do
          visit edit_organisation_job_path(id: draft_vacancy.id)

          draft_vacancy.salary = 'Pay scale 1 to Pay scale 2'
          draft_vacancy.benefits = 'Gym, health insurance'

          fill_in_pay_package_form_fields(draft_vacancy)
          click_on I18n.t('buttons.continue')

          draft_vacancy.starts_on = DateTime.now + 1.year
          draft_vacancy.expires_on = draft_vacancy.starts_on - 1.day
          draft_vacancy.expiry_time = Time.zone.now
          draft_vacancy.publish_on = DateTime.now + 1.day

          fill_in_important_dates_fields(draft_vacancy)
          click_on I18n.t('buttons.continue')

          fill_in_supporting_documents_form_fields
          click_on I18n.t('buttons.continue')

          click_on I18n.t('buttons.continue')

          draft_vacancy.contact_email = 'test@email.com'
          draft_vacancy.application_link = 'https://example.com'

          fill_in_application_details_form_fields(draft_vacancy)
          click_on I18n.t('buttons.continue')

          expect(page).to have_content(I18n.t('jobs.current_step', step: 6, total: 7))
          within('h2.govuk-heading-l') do
            expect(page).to have_content(I18n.t('jobs.job_summary'))
          end
        end

        context 'after editing a different vacancy' do
          # We use the session to store vacancy attributes, make sure it doesn't leak between edits.
          before do
            visit edit_organisation_job_path(id: draft_vacancy.id)

            draft_vacancy.salary = 'Pay scale 1 to Pay scale 2'
            draft_vacancy.benefits = 'Gym, health insurance'

            fill_in_pay_package_form_fields(draft_vacancy)
            click_on I18n.t('buttons.continue')

            draft_vacancy.starts_on = DateTime.now + 1.year
            draft_vacancy.expires_on = draft_vacancy.starts_on - 1.day
            draft_vacancy.expiry_time = Time.zone.now
            draft_vacancy.publish_on = DateTime.now + 1.day

            fill_in_important_dates_fields(draft_vacancy)
            click_on I18n.t('buttons.continue')

            select_no_for_supporting_documents
            click_on I18n.t('buttons.continue')

            edit_a_published_vacancy
          end

          scenario 'then editing the draft redirects to incomplete step' do
            visit organisation_job_path(id: draft_vacancy.id)
            expect(page).to have_content(I18n.t('jobs.current_step', step: 5, total: 7))
          end

          def edit_a_published_vacancy
            published_vacancy = create(:vacancy, :published, school: school)
            visit edit_organisation_job_path(published_vacancy.id)
            click_header_link(I18n.t('jobs.application_details'))

            fill_in 'application_details_form[application_link]', with: 'https://example.com'
            click_on I18n.t('buttons.update_job')

            expect(page.body).to include(
              I18n.t('messages.jobs.listing_updated', job_title: published_vacancy.job_title)
            )
          end
        end
      end

      context 'as a SchoolGroup-level user' do
        let(:school_group) { create(:school_group) }
        let!(:vacancy) do
          VacancyPresenter.new(build(:vacancy, :complete,
                                    job_title: 'Draft vacancy 2',
                                    school_group: school_group,
                                    working_patterns: ['full_time', 'part_time']))
        end

        before do
          school_group.schools = [school]
          allow(SchoolGroupJobsFeature).to receive(:enabled?).and_return(true)
          stub_hiring_staff_auth(uid: school_group.uid, session_id: SecureRandom.uuid)
          visit new_organisation_job_path
          fill_in_job_location_form_field(vacancy)
          click_on I18n.t('buttons.continue')
          @vacancy_id = current_path.split('/')[-2] # /organisation/jobs/:job_id/school
        end

        scenario 'redirects to school step' do
          visit edit_organisation_job_path(id: @vacancy_id)

          expect(page).to have_content(I18n.t('jobs.current_step', step: 1, total: 8))
          within('h2.govuk-heading-l') do
            expect(page).to have_content(I18n.t('jobs.job_location'))
          end
        end

        scenario 'redirects to job specification step' do
          fill_in_school_form_field(school)
          click_on I18n.t('buttons.continue')

          visit edit_organisation_job_path(id: @vacancy_id)

          expect(page).to have_content(I18n.t('jobs.current_step', step: 2, total: 8))
          within('h2.govuk-heading-l') do
            expect(page).to have_content(I18n.t('jobs.job_details'))
          end
        end
      end
    end
  end

  context 'editing a complete draft vacancy' do
    let(:vacancy) { create(:vacancy, :draft, school: school) }

    scenario 'vacancy state is edit' do
      visit organisation_job_review_path(vacancy.id, edit_draft: true)

      expect(Vacancy.last.state).to eql('edit')
      within('h2.govuk-heading-l') do
        expect(page).to have_content(I18n.t('jobs.review_heading'))
      end
    end

    context '#cancel_and_return_later' do
      scenario 'can cancel and return from job details page' do
        visit organisation_job_review_path(vacancy.id)

        click_header_link(I18n.t('jobs.job_details'))
        expect(page).to have_content(I18n.t('buttons.cancel_and_return'))

        click_on I18n.t('buttons.cancel_and_return')
        expect(page.current_path).to eql(organisation_job_review_path(vacancy.id))
      end
    end
  end
end
