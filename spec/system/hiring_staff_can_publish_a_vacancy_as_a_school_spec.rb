require 'rails_helper'

RSpec.describe 'Creating a vacancy' do
  let(:school) { create(:school) }
  let(:session_id) { SecureRandom.uuid }

  before(:each) { stub_hiring_staff_auth(urn: school.urn, session_id: session_id) }

  scenario 'Visiting the school page' do
    school = create(:school, name: 'Salisbury School')
    stub_hiring_staff_auth(urn: school.urn)

    visit organisation_path

    expect(page).to have_content('Salisbury School')
    expect(page).to have_content(/#{school.address}/)
    expect(page).to have_content(/#{school.town}/)

    click_link 'Create a job listing'

    expect(page).to have_content(I18n.t('jobs.current_step', step: 1, total: 7))
  end

  context 'creating a new vacancy' do
    let(:suitable_for_nqt) { 'no' }
    let(:vacancy) do
      VacancyPresenter.new(build(:vacancy, :complete,
                                 job_roles: %i[teacher sen_specialist],
                                 suitable_for_nqt: suitable_for_nqt,
                                 working_patterns: %w[full_time part_time],
                                 publish_on: Time.zone.today))
    end

    scenario 'redirects to step 1, job specification' do
      visit new_organisation_job_path

      expect(page.current_path).to eq(job_specification_organisation_job_path)
      expect(page).to have_content(I18n.t('jobs.create_a_job_title_no_org'))
      expect(page).to have_content(I18n.t('jobs.current_step', step: 1, total: 7))
    end

    describe '#job_specification' do
      scenario 'is invalid unless all mandatory fields are submitted' do
        visit new_organisation_job_path

        click_on I18n.t('buttons.continue')

        mandatory_fields = %w[job_title working_patterns]

        within('.govuk-error-summary') do
          expect(page).to have_content('There is a problem')
        end

        mandatory_fields.each do |field|
          within_row_for(element: field == 'job_title' ? 'label' : 'legend', text: I18n.t("jobs.#{field}")) do
            expect(page).to have_content(I18n.t("activerecord.errors.models.vacancy.attributes.#{field}.blank"))
          end
        end
      end

      scenario 'redirects to step 2, pay package, when submitted successfully' do
        visit new_organisation_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        expect(page).to have_content(I18n.t('jobs.current_step', step: 2, total: 7))
        within('h2.govuk-heading-l') do
          expect(page).to have_content(I18n.t('jobs.pay_package'))
        end
      end

      context 'when job is selected as suitable for NQTs' do
        let(:suitable_for_nqt) { 'yes' }

        scenario 'Suitable for NQTs is appended to the job roles' do
          visit new_organisation_job_path

          fill_in_job_specification_form_fields(vacancy)
          click_on I18n.t('buttons.continue')

          expect(Vacancy.last.job_roles).to include('nqt_suitable')
        end
      end

      scenario 'vacancy state is create' do
        visit new_organisation_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        expect(Vacancy.last.state).to eql('create')
      end

      scenario 'tracks the vacancy creation' do
        visit new_organisation_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        activity = Vacancy.last.activities.last
        expect(activity.session_id).to eq(session_id)
        expect(activity.key).to eq('vacancy.create')
        expect(activity.parameters.symbolize_keys).to include(job_title: [nil, vacancy.job_title])
      end
    end

    describe '#pay_package' do
      scenario 'is invalid unless all mandatory fields are submitted' do
        visit new_organisation_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        click_on I18n.t('buttons.continue')

        within('.govuk-error-summary') do
          expect(page).to have_content('There is a problem')
        end

        within_row_for(text: I18n.t('jobs.salary')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.salary.blank'))
        end
      end

      scenario 'redirects to step 3, important dates, when submitted successfuly' do
        visit new_organisation_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        fill_in_pay_package_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        expect(page).to have_content(I18n.t('jobs.current_step', step: 3, total: 7))
        within('h2.govuk-heading-l') do
          expect(page).to have_content(I18n.t('jobs.important_dates'))
        end
      end
    end

    describe '#important_dates' do
      scenario 'is invalid unless all mandatory fields are submitted' do
        visit new_organisation_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        fill_in_pay_package_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        click_on I18n.t('buttons.continue')

        within('.govuk-error-summary') do
          expect(page).to have_content('There is a problem')
        end

        within_row_for(element: 'legend',
                       text: strip_tags(I18n.t('helpers.fieldset.important_dates_form.publish_on_html'))) do
          expect(page).to have_content(
            I18n.t('activemodel.errors.models.important_dates_form.attributes.publish_on.blank'),
          )
        end

        within_row_for(element: 'legend',
                       text: strip_tags(I18n.t('helpers.fieldset.important_dates_form.expires_on_html'))) do
          expect(page).to have_content(
            I18n.t('activemodel.errors.models.important_dates_form.attributes.expires_on.blank'),
          )
        end

        within_row_for(element: 'legend',
                       text: strip_tags(I18n.t('helpers.fieldset.important_dates_form.expiry_time_html'))) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.expiry_time.blank'))
        end
      end

      scenario 'redirects to step 4, supporting documents, when submitted successfuly' do
        visit new_organisation_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        fill_in_pay_package_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        fill_in_important_dates_fields(vacancy)
        click_on I18n.t('buttons.continue')

        expect(page).to have_content(I18n.t('jobs.current_step', step: 4, total: 7))
        within('h2.govuk-heading-l') do
          expect(page).to have_content(I18n.t('jobs.supporting_documents'))
        end
      end
    end

    describe '#supporting_documents' do
      scenario 'is invalid unless all mandatory fields are submitted' do
        visit new_organisation_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        fill_in_pay_package_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        fill_in_important_dates_fields(vacancy)
        click_on I18n.t('buttons.continue')

        click_on I18n.t('buttons.continue') # submit empty form

        expect(page)
          .to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.supporting_documents.inclusion'))
      end

      scenario 'redirects to step 4, application details, when choosing no' do
        visit new_organisation_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        fill_in_pay_package_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        fill_in_important_dates_fields(vacancy)
        click_on I18n.t('buttons.continue')

        select_no_for_supporting_documents
        click_on I18n.t('buttons.continue')

        expect(page).to have_content(I18n.t('jobs.current_step', step: 5, total: 7))
        within('h2.govuk-heading-l') do
          expect(page).to have_content(I18n.t('jobs.application_details'))
        end
      end

      scenario 'redirects to step 3, upload_documents, when choosing yes' do
        visit new_organisation_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        fill_in_pay_package_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        fill_in_important_dates_fields(vacancy)
        click_on I18n.t('buttons.continue')

        choose 'Yes'
        click_on I18n.t('buttons.continue')

        expect(page).to have_content(I18n.t('jobs.current_step', step: 4, total: 7))
        within('h2.govuk-heading-l') do
          expect(page).to have_content(I18n.t('jobs.supporting_documents'))
        end
        expect(page).to have_content(I18n.t('jobs.upload_file'))
      end
    end

    describe '#documents' do
      let(:documents_vacancy) { create(:vacancy) }

      before { documents_vacancy.organisation_vacancies.create(organisation: school) }

      scenario 'hiring staff can select a file for upload' do
        visit organisation_job_documents_path(documents_vacancy.id)
        page.attach_file('documents-form-documents-field', Rails.root.join('spec/fixtures/files/blank_job_spec.pdf'))
        expect(page.find('#documents-form-documents-field').value).to_not be nil
      end

      context 'when uploading files' do
        let(:document_upload) { double('document_upload') }
        let(:filename) { 'blank_job_spec.pdf' }

        before do
          allow(DocumentUpload).to receive(:new).and_return(document_upload)
          allow(document_upload).to receive(:upload)
          allow(document_upload).to receive_message_chain(:uploaded, :web_content_link).and_return('test_url')
          allow(document_upload).to receive_message_chain(:uploaded, :id).and_return('test_id')
          allow(document_upload).to receive(:safe_download).and_return(true)
          allow(document_upload).to receive(:google_error).and_return(false)
        end

        scenario 'displays uploaded file in a table' do
          visit organisation_job_documents_path(documents_vacancy.id)

          upload_document(
            'new_documents_form',
            'documents-form-documents-field',
            "spec/fixtures/files/#{filename}",
          )

          expect(page).to have_content(filename)
        end

        scenario 'displays error message when invalid file type is uploaded' do
          visit organisation_job_documents_path(documents_vacancy.id)

          allow_any_instance_of(HiringStaff::Vacancies::DocumentsController)
            .to receive_message_chain(:valid_content_type?).and_return(false)

          upload_document(
            'new_documents_form',
            'documents-form-documents-field',
            "spec/fixtures/files/#{filename}",
          )

          expect(page).to have_content(I18n.t('jobs.file_type_error_message', filename: filename))
        end

        scenario 'displays error message when large file is uploaded' do
          stub_const("#{HiringStaff::Vacancies::DocumentsController}::FILE_SIZE_LIMIT", 1.kilobyte)
          visit organisation_job_documents_path(documents_vacancy.id)

          upload_document(
            'new_documents_form',
            'documents-form-documents-field',
            "spec/fixtures/files/#{filename}",
          )

          expect(page).to have_content(
            I18n.t('jobs.file_size_error_message', filename: filename, size_limit: '1 KB'),
          )
        end

        scenario 'displays error message when virus file is uploaded' do
          visit organisation_job_documents_path(documents_vacancy.id)

          allow(document_upload).to receive(:safe_download).and_return(false)

          upload_document(
            'new_documents_form',
            'documents-form-documents-field',
            "spec/fixtures/files/#{filename}",
          )

          expect(page).to have_content(I18n.t('jobs.file_virus_error_message', filename: filename))
        end

        scenario 'displays error message when file not uploaded' do
          visit organisation_job_documents_path(documents_vacancy.id)

          allow(document_upload).to receive(:google_error).and_return(true)

          upload_document(
            'new_documents_form',
            'documents-form-documents-field',
            "spec/fixtures/files/#{filename}",
          )

          expect(page).to have_content(I18n.t('jobs.file_google_error_message', filename: filename))
        end
      end

      context 'when deleting uploaded files', js: true do
        let(:document_delete) { double('document_delete') }

        before do
          allow(DocumentDelete).to receive(:new).and_return(document_delete)

          create :document, vacancy: documents_vacancy, name: 'delete_me.pdf'
          create :document, vacancy: documents_vacancy, name: 'do_not_delete_me.pdf'

          visit organisation_job_documents_path(documents_vacancy.id)

          find('[data-file-name="delete_me.pdf"]').click
        end

        scenario 'deletes them' do
          allow(document_delete).to receive(:delete).and_return(true)

          click_on 'Yes, remove file'

          within '#js-xhr-flashes' do
            expect(page).to have_content 'delete_me.pdf was removed'
          end
        end

        scenario 'shows errors' do
          allow(document_delete).to receive(:delete).and_return(false)

          click_on 'Yes, remove file'

          within '#js-gem-c-modal-dialogue__error' do
            expect(page).to have_content 'An error occurred while removing the file.'
          end
        end
      end
    end

    describe '#application_details' do
      scenario 'is invalid unless all mandatory fields are submitted' do
        visit new_organisation_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        fill_in_pay_package_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        fill_in_important_dates_fields(vacancy)
        click_on I18n.t('buttons.continue')

        select_no_for_supporting_documents
        click_on I18n.t('buttons.continue')

        click_on I18n.t('buttons.continue')

        within('.govuk-error-summary') do
          expect(page).to have_content('There is a problem')
        end

        within_row_for(text: strip_tags(I18n.t('helpers.fieldset.application_details_form.contact_email_html'))) do
          expect(page).to have_content(
            I18n.t('activemodel.errors.models.application_details_form.attributes.contact_email.blank'),
          )
        end
      end

      scenario 'redirects to the job summary page when submitted successfully' do
        visit new_organisation_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        fill_in_pay_package_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        fill_in_important_dates_fields(vacancy)
        click_on I18n.t('buttons.continue')

        select_no_for_supporting_documents
        click_on I18n.t('buttons.continue')

        fill_in_application_details_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        expect(page).to have_content(I18n.t('jobs.current_step', step: 6, total: 7))
        within('h2.govuk-heading-l') do
          expect(page).to have_content(I18n.t('jobs.job_summary'))
        end
      end
    end

    describe '#job_summary' do
      scenario 'is invalid unless all mandatory fields are submitted' do
        visit new_organisation_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        fill_in_pay_package_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        fill_in_important_dates_fields(vacancy)
        click_on I18n.t('buttons.continue')

        select_no_for_supporting_documents
        click_on I18n.t('buttons.continue')

        fill_in_application_details_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        click_on I18n.t('buttons.continue')

        within('.govuk-error-summary') do
          expect(page).to have_content('There is a problem')
        end

        within_row_for(text: I18n.t('jobs.job_summary')) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.job_summary.blank'))
        end

        within_row_for(text: I18n.t('jobs.about_school', school: school.name)) do
          expect(page).to have_content(school.description)
        end
      end

      scenario 'redirects to the vacancy review page when submitted successfully' do
        visit new_organisation_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        fill_in_pay_package_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        fill_in_important_dates_fields(vacancy)
        click_on I18n.t('buttons.continue')

        select_no_for_supporting_documents
        click_on I18n.t('buttons.continue')

        fill_in_application_details_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        fill_in_job_summary_form_fields(vacancy)
        click_on I18n.t('buttons.continue')

        expect(page).to have_content(I18n.t('jobs.current_step', step: 7, total: 7))
        within('h2.govuk-heading-l') do
          expect(page).to have_content(I18n.t('jobs.review_heading'))
        end
        verify_all_vacancy_details(vacancy)
      end
    end

    describe '#review' do
      context 'redirects the user back to the last incomplete step' do
        scenario 'redirects to step 2, pay package, when that step has not been completed' do
          visit new_organisation_job_path

          fill_in_job_specification_form_fields(vacancy)
          click_on I18n.t('buttons.continue')

          v = Vacancy.find_by(job_title: vacancy.job_title)
          visit organisation_job_path(id: v.id)

          expect(page).to have_content(I18n.t('jobs.current_step', step: 2, total: 7))
          within('h2.govuk-heading-l') do
            expect(page).to have_content(I18n.t('jobs.pay_package'))
          end
        end

        scenario 'redirects to step 5, application details, when that step has not been completed' do
          visit new_organisation_job_path

          fill_in_job_specification_form_fields(vacancy)
          click_on I18n.t('buttons.continue')

          fill_in_pay_package_form_fields(vacancy)
          click_on I18n.t('buttons.continue')

          fill_in_important_dates_fields(vacancy)
          click_on I18n.t('buttons.continue')

          select_no_for_supporting_documents
          click_on I18n.t('buttons.continue')

          v = Vacancy.find_by(job_title: vacancy.job_title)
          visit organisation_job_path(id: v.id)

          expect(page).to have_content(I18n.t('jobs.current_step', step: 5, total: 7))
          within('h2.govuk-heading-l') do
            expect(page).to have_content(I18n.t('jobs.application_details'))
          end
        end

        scenario 'redirects to step 6, job summary, when that step has not been completed' do
          visit new_organisation_job_path

          fill_in_job_specification_form_fields(vacancy)
          click_on I18n.t('buttons.continue')

          fill_in_pay_package_form_fields(vacancy)
          click_on I18n.t('buttons.continue')

          fill_in_important_dates_fields(vacancy)
          click_on I18n.t('buttons.continue')

          select_no_for_supporting_documents
          click_on I18n.t('buttons.continue')

          fill_in_application_details_form_fields(vacancy)
          click_on I18n.t('buttons.continue')

          v = Vacancy.find_by(job_title: vacancy.job_title)
          visit organisation_job_path(id: v.id)

          expect(page).to have_content(I18n.t('jobs.current_step', step: 6, total: 7))
          within('h2.govuk-heading-l') do
            expect(page).to have_content(I18n.t('jobs.job_summary'))
          end
        end

        scenario 'vacancy state is review when all steps completed' do
          visit new_organisation_job_path

          fill_in_job_specification_form_fields(vacancy)
          click_on I18n.t('buttons.continue')

          fill_in_pay_package_form_fields(vacancy)
          click_on I18n.t('buttons.continue')

          fill_in_important_dates_fields(vacancy)
          click_on I18n.t('buttons.continue')

          select_no_for_supporting_documents
          click_on I18n.t('buttons.continue')

          fill_in_application_details_form_fields(vacancy)
          click_on I18n.t('buttons.continue')

          fill_in_job_summary_form_fields(vacancy)
          click_on I18n.t('buttons.continue')

          expect(Vacancy.last.state).to eql('review')
          expect(page).to have_content(I18n.t('jobs.current_step', step: 7, total: 7))
          within('h2.govuk-heading-l') do
            expect(page).to have_content(I18n.t('jobs.review_heading'))
          end
        end

        scenario 'vacancy state is review' do
          visit new_organisation_job_path

          fill_in_job_specification_form_fields(vacancy)
          click_on I18n.t('buttons.continue')

          fill_in_pay_package_form_fields(vacancy)
          click_on I18n.t('buttons.continue')

          fill_in_important_dates_fields(vacancy)
          click_on I18n.t('buttons.continue')

          select_no_for_supporting_documents
          click_on I18n.t('buttons.continue')

          fill_in_application_details_form_fields(vacancy)
          click_on I18n.t('buttons.continue')

          fill_in_job_summary_form_fields(vacancy)
          click_on I18n.t('buttons.continue')

          expect(Vacancy.last.state).to eql('review')
          expect(page).to have_content(I18n.t('jobs.current_step', step: 7, total: 7))
          within('h2.govuk-heading-l') do
            expect(page).to have_content(I18n.t('jobs.review_heading'))
          end

          click_header_link(I18n.t('jobs.application_details'))
          expect(page).to have_content(I18n.t('jobs.current_step', step: 5, total: 7))
          within('h2.govuk-heading-l') do
            expect(page).to have_content(I18n.t('jobs.application_details'))
          end
          expect(Vacancy.last.state).to eql('review')

          click_on I18n.t('buttons.update_job')
          expect(Vacancy.last.state).to eql('review')

          click_header_link(I18n.t('jobs.job_details'))
          expect(page).to have_content(I18n.t('jobs.current_step', step: 1, total: 7))
          within('h2.govuk-heading-l') do
            expect(page).to have_content(I18n.t('jobs.job_details'))
          end
          expect(Vacancy.last.state).to eql('review')
        end
      end

      scenario 'is not available for published vacancies' do
        vacancy = create(:vacancy, :published)
        vacancy.organisation_vacancies.create(organisation: school)

        visit organisation_job_review_path(vacancy.id)

        expect(page).to have_current_path(organisation_job_path(vacancy.id))
      end

      scenario 'lists all the vacancy details correctly' do
        vacancy = create(:vacancy, :complete, :draft)
        vacancy.organisation_vacancies.create(organisation: school)

        vacancy = VacancyPresenter.new(vacancy)
        visit organisation_job_review_path(vacancy.id)

        expect(page).to have_content(I18n.t('jobs.review_heading'))

        verify_all_vacancy_details(vacancy)
      end

      context 'when the listing is full-time' do
        scenario 'lists all the full-time vacancy details correctly' do
          vacancy = create(:vacancy, :complete, :draft, working_patterns: %w[full_time])
          vacancy.organisation_vacancies.create(organisation: school)

          vacancy = VacancyPresenter.new(vacancy)

          visit organisation_job_review_path(vacancy.id)

          expect(page).to have_content(I18n.t('jobs.review_heading'))

          verify_all_vacancy_details(vacancy)
        end
      end

      context 'when the listing is part-time' do
        scenario 'lists all the part-time vacancy details correctly' do
          vacancy = create(:vacancy, :complete, :draft, working_patterns: %w[part_time])
          vacancy.organisation_vacancies.create(organisation: school)

          vacancy = VacancyPresenter.new(vacancy)

          visit organisation_job_review_path(vacancy.id)

          expect(page).to have_content(I18n.t('jobs.review_heading'))

          verify_all_vacancy_details(vacancy)
        end
      end

      context 'when the listing is both full- and part-time' do
        scenario 'lists all the working pattern vacancy details correctly' do
          vacancy = create(:vacancy, :complete, :draft, working_patterns: %w[full_time part_time])
          vacancy.organisation_vacancies.create(organisation: school)

          vacancy = VacancyPresenter.new(vacancy)

          visit organisation_job_review_path(vacancy.id)

          expect(page).to have_content(I18n.t('jobs.review_heading'))

          verify_all_vacancy_details(vacancy)
        end
      end

      context 'edit job_specification_details' do
        scenario 'updates the vacancy details' do
          vacancy = create(:vacancy, :draft, :complete)
          vacancy.organisation_vacancies.create(organisation: school)
          visit organisation_job_review_path(vacancy.id)
          click_header_link(I18n.t('jobs.job_details'))

          expect(page).to have_content(I18n.t('jobs.current_step', step: 1, total: 7))

          fill_in 'job_specification_form[job_title]', with: 'An edited job title'
          click_on I18n.t('buttons.update_job')

          expect(page).to have_content(I18n.t('jobs.review_heading'))
          expect(page).to have_content('An edited job title')
        end

        scenario 'tracks any changes to  the vacancy details' do
          vacancy = create(:vacancy, :draft, :complete)
          vacancy.organisation_vacancies.create(organisation: school)
          current_title = vacancy.job_title
          current_slug = vacancy.slug
          visit organisation_job_review_path(vacancy.id)
          click_header_link(I18n.t('jobs.job_details'))

          expect(page).to have_content(I18n.t('jobs.current_step', step: 1, total: 7))

          fill_in 'job_specification_form[job_title]', with: 'High school teacher'
          click_on I18n.t('buttons.update_job')

          activity = vacancy.activities.last
          expect(activity.session_id).to eq(session_id)
          expect(activity.parameters.symbolize_keys).to include(job_title: [current_title, 'High school teacher'])
          expect(activity.parameters.symbolize_keys).to include(slug: [current_slug, 'high-school-teacher'])
        end

        scenario 'fails validation until values are set correctly' do
          vacancy = create(:vacancy, :draft, :complete)
          vacancy.organisation_vacancies.create(organisation: school)
          visit organisation_job_review_path(vacancy.id)
          click_header_link(I18n.t('jobs.job_details'))

          fill_in 'job_specification_form[job_title]', with: ''
          click_on I18n.t('buttons.update_job')

          expect(page).to have_content('Enter a job title')

          fill_in 'job_specification_form[job_title]', with: 'A new job title'
          click_on I18n.t('buttons.update_job')

          expect(page).to have_content(I18n.t('jobs.review_heading'))
          expect(page).to have_content('A new job title')
        end
      end

      context 'editing the supporting_documents' do
        scenario 'updates the vacancy details' do
          visit new_organisation_job_path

          fill_in_job_specification_form_fields(vacancy)
          click_on I18n.t('buttons.continue')

          fill_in_pay_package_form_fields(vacancy)
          click_on I18n.t('buttons.continue')

          fill_in_important_dates_fields(vacancy)
          click_on I18n.t('buttons.continue')

          select_no_for_supporting_documents
          click_on I18n.t('buttons.continue')

          fill_in_application_details_form_fields(vacancy)
          click_on I18n.t('buttons.continue')

          fill_in_job_summary_form_fields(vacancy)
          click_on I18n.t('buttons.continue')

          expect(page).to have_content(I18n.t('jobs.review_heading'))

          click_header_link(I18n.t('jobs.supporting_documents'))

          expect(page).to have_content(I18n.t('jobs.current_step', step: 4, total: 7))
          expect(page).to have_content(I18n.t('jobs.upload_file'))

          click_on I18n.t('buttons.update_job')

          expect(page).to have_content(I18n.t('jobs.review_heading'))
        end
      end

      context 'editing the application_details' do
        scenario 'fails validation until values are set correctly' do
          vacancy = create(:vacancy, :draft, :complete)
          vacancy.organisation_vacancies.create(organisation: school)
          visit organisation_job_review_path(vacancy.id)
          click_header_link(I18n.t('jobs.application_details'))

          expect(page).to have_content(I18n.t('jobs.current_step', step: 5, total: 7))

          fill_in 'application_details_form[contact_email]', with: 'not a valid email'
          click_on I18n.t('buttons.update_job')

          expect(page).to have_content('Enter an email address in the correct format, like name@example.com')

          fill_in 'application_details_form[contact_email]', with: 'a@valid.email'
          click_on I18n.t('buttons.update_job')

          expect(page).to have_content(I18n.t('jobs.review_heading'))
          expect(page).to have_content('a@valid.email')
        end

        scenario 'fails validation correctly when an invalid link is entered' do
          vacancy = create(:vacancy, :draft, :complete)
          vacancy.organisation_vacancies.create(organisation: school)
          visit organisation_job_review_path(vacancy.id)
          click_header_link(I18n.t('jobs.application_details'))

          expect(page).to have_content(I18n.t('jobs.current_step', step: 5, total: 7))

          fill_in 'application_details_form[application_link]', with: 'www invalid.domain.com'
          click_on I18n.t('buttons.update_job')

          expect(page).to have_content(I18n.t('application_details_errors.application_link.url'))

          fill_in 'application_details_form[application_link]', with: 'www.valid-domain.com'
          click_on I18n.t('buttons.update_job')

          expect(page).to have_content(I18n.t('jobs.review_heading'))
          expect(page).to have_content('www.valid-domain.com')
        end

        scenario 'updates the vacancy details' do
          vacancy = create(:vacancy, :draft, :complete)
          vacancy.organisation_vacancies.create(organisation: school)
          visit organisation_job_review_path(vacancy.id)
          click_header_link(I18n.t('jobs.application_details'))

          expect(page).to have_content(I18n.t('jobs.current_step', step: 5, total: 7))

          fill_in 'application_details_form[contact_email]', with: 'an@email.com'
          click_on I18n.t('buttons.update_job')

          expect(page).to have_content(I18n.t('jobs.review_heading'))
          expect(page).to have_content('an@email.com')
        end

        scenario 'tracks any changes' do
          vacancy = create(:vacancy, :draft, :complete)
          vacancy.organisation_vacancies.create(organisation: school)
          contact_email = vacancy.contact_email
          visit organisation_job_review_path(vacancy.id)
          click_header_link(I18n.t('jobs.application_details'))

          fill_in 'application_details_form[contact_email]', with: 'an@email.com'
          click_on I18n.t('buttons.update_job')

          activity = vacancy.activities.last
          expect(activity.session_id).to eq(session_id)
          expect(activity.parameters.symbolize_keys).to include(contact_email: [contact_email, 'an@email.com'])
        end
      end

      scenario 'redirects to the school vacancy page when published' do
        vacancy = create(:vacancy, :draft)
        vacancy.organisation_vacancies.create(organisation: school)
        visit organisation_job_review_path(vacancy.id)
        click_on I18n.t('jobs.submit_listing.button')

        expect(page).to have_content(I18n.t('jobs.confirmation_page.view_posted_job'))
      end
    end

    describe '#publish' do
      scenario 'adds the current user as a contact for feedback on the published vacancy' do
        current_user = User.find_by(oid: session_id)
        vacancy = create(:vacancy, :draft)
        vacancy.organisation_vacancies.create(organisation: school)

        visit organisation_job_review_path(vacancy.id)
        click_on I18n.t('jobs.submit_listing.button')

        expect(vacancy.reload.publisher_user_id).to eq(current_user.id)
      end

      scenario 'view the published listing as a job seeker' do
        vacancy = create(:vacancy, :draft)
        vacancy.organisation_vacancies.create(organisation: school)

        visit organisation_job_review_path(vacancy.id)

        click_on I18n.t('jobs.submit_listing.button')
        save_page

        click_on I18n.t('jobs.confirmation_page.view_posted_job')

        verify_vacancy_show_page_details(VacancyPresenter.new(vacancy))
      end

      context 'when the listing is full-time' do
        scenario 'view the full-time published listing as a job seeker' do
          vacancy = create(:vacancy, :draft, working_patterns: %w[full_time])
          vacancy.organisation_vacancies.create(organisation: school)

          visit organisation_job_review_path(vacancy.id)

          click_on I18n.t('jobs.submit_listing.button')
          save_page

          click_on I18n.t('jobs.confirmation_page.view_posted_job')

          verify_vacancy_show_page_details(VacancyPresenter.new(vacancy))
        end
      end

      context 'when the listing is part-time' do
        scenario 'view the part-time published listing as a job seeker' do
          vacancy = create(:vacancy, :draft, working_patterns: %w[part_time])
          vacancy.organisation_vacancies.create(organisation: school)

          visit organisation_job_review_path(vacancy.id)

          click_on I18n.t('jobs.submit_listing.button')
          save_page

          click_on I18n.t('jobs.confirmation_page.view_posted_job')

          verify_vacancy_show_page_details(VacancyPresenter.new(vacancy))
        end
      end

      context 'when the listing is both full- and part-time' do
        scenario 'view the full- and part-time published listing as a job seeker' do
          vacancy = create(:vacancy, :draft, working_patterns: %w[full_time part_time])
          vacancy.organisation_vacancies.create(organisation: school)

          visit organisation_job_review_path(vacancy.id)

          click_on I18n.t('jobs.submit_listing.button')
          save_page

          click_on I18n.t('jobs.confirmation_page.view_posted_job')

          verify_vacancy_show_page_details(VacancyPresenter.new(vacancy))
        end
      end

      scenario 'cannot be published unless the details are valid' do
        yesterday_date = Time.zone.yesterday
        vacancy = create(:vacancy, :draft, publish_on: Time.zone.tomorrow)
        vacancy.organisation_vacancies.create(organisation: school)
        vacancy.assign_attributes expires_on: yesterday_date
        vacancy.save(validate: false)

        visit organisation_job_review_path(vacancy.id)

        expect(page).to have_content(I18n.t('jobs.current_step', step: 3, total: 7))
        within('h2.govuk-heading-l') do
          expect(page).to have_content(I18n.t('jobs.important_dates'))
        end

        expect(find_field('important_dates_form[expires_on(3i)]').value).to eql(yesterday_date.day.to_s)
        expect(find_field('important_dates_form[expires_on(2i)]').value).to eql(yesterday_date.month.to_s)
        expect(find_field('important_dates_form[expires_on(1i)]').value).to eql(yesterday_date.year.to_s)

        click_on I18n.t('buttons.continue')

        within('.govuk-error-summary') do
          expect(page).to have_content('There is a problem')
        end

        within_row_for(element: 'legend',
                       text: strip_tags(I18n.t('helpers.fieldset.important_dates_form.expires_on_html'))) do
          expect(page).to have_content(
            I18n.t('activemodel.errors.models.important_dates_form.attributes.expires_on.before_today'),
          )
        end

        expiry_date = Time.zone.today + 1.week

        fill_in 'important_dates_form[expires_on(3i)]', with: expiry_date.day
        fill_in 'important_dates_form[expires_on(2i)]', with: expiry_date.month
        fill_in 'important_dates_form[expires_on(1i)]', with: expiry_date.year
        click_on I18n.t('buttons.continue')

        click_on I18n.t('jobs.submit_listing.button')
        expect(page).to have_content(I18n.t('jobs.confirmation_page.submitted'))
      end

      scenario 'can be published at a later date' do
        vacancy = create(:vacancy, :draft, publish_on: Time.zone.tomorrow)
        vacancy.organisation_vacancies.create(organisation: school)

        visit organisation_job_review_path(vacancy.id)
        click_on 'Confirm and submit job'

        expect(page).to have_content("Your job listing will be posted on #{format_date(vacancy.publish_on)}.")
        visit organisation_job_path(vacancy.id)
        expect(page).to have_content('Date listed')
        expect(page).to have_content(format_date(vacancy.publish_on).to_s)
      end

      scenario 'displays the expiration date and time on the confirmation page' do
        vacancy = create(:vacancy, :draft, expiry_time: Time.zone.now + 5.days)
        vacancy.organisation_vacancies.create(organisation: school)
        visit organisation_job_review_path(vacancy.id)
        click_on I18n.t('jobs.submit_listing.button')

        expect(page).to have_content(
          'The listing will appear on the service until ' \
          "#{format_date(vacancy.expires_on)} at #{format_time(vacancy.expiry_time)}, " \
          'after which it will no longer be visible to jobseekers.',
        )
      end

      scenario 'tracks publishing information' do
        vacancy = create(:vacancy, :draft, publish_on: Time.zone.tomorrow)
        vacancy.organisation_vacancies.create(organisation: school)

        visit organisation_job_review_path(vacancy.id)
        click_on 'Confirm and submit job'

        activity = vacancy.activities.last
        expect(activity.session_id).to eq(session_id)
        expect(activity.key).to eq('vacancy.publish')
      end

      scenario 'a published vacancy cannot be republished' do
        vacancy = create(:vacancy, :draft, publish_on: Time.zone.tomorrow)
        vacancy.organisation_vacancies.create(organisation: school)

        visit organisation_job_review_path(vacancy.id)
        click_on 'Confirm and submit job'
        expect(page).to have_content('The job listing has been completed')

        visit organisation_job_publish_path(vacancy.id)

        expect(page).to have_content(I18n.t('messages.jobs.already_published'))
      end

      scenario 'a published vacancy cannot be edited' do
        vacancy = create(:vacancy, :published)
        vacancy.organisation_vacancies.create(organisation: school)

        visit organisation_job_review_path(vacancy.id)
        expect(page.current_path).to eq(organisation_job_path(vacancy.id))
        expect(page).to have_content(I18n.t('messages.jobs.already_published'))
      end

      context 'adds a job to update the Google index in the queue' do
        scenario 'if the vacancy is published immediately' do
          vacancy = create(:vacancy, :draft, publish_on: Time.zone.today)
          vacancy.organisation_vacancies.create(organisation: school)

          expect_any_instance_of(HiringStaff::Vacancies::ApplicationController)
            .to receive(:update_google_index).with(vacancy)

          visit organisation_job_review_path(vacancy.id)
          click_on I18n.t('jobs.submit_listing.button')
        end
      end

      context 'updates the published vacancy audit table' do
        scenario 'when the vacancy is published' do
          vacancy = create(:vacancy, :draft, publish_on: Time.zone.today)
          vacancy.organisation_vacancies.create(organisation: school)

          expect(AuditPublishedVacancyJob).to receive(:perform_later).with(vacancy.id)

          visit organisation_job_review_path(vacancy.id)
          click_on I18n.t('jobs.submit_listing.button')
        end
      end
    end
  end
end
