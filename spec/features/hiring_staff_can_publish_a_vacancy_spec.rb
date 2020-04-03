require 'rails_helper'

RSpec.feature 'Creating a vacancy' do
  let(:school) { create(:school) }
  let(:session_id) { SecureRandom.uuid }

  before(:each) do
    stub_hiring_staff_auth(urn: school.urn, session_id: session_id)
  end

  scenario 'Visiting the school page' do
    school = create(:school, name: 'Salisbury School')
    stub_hiring_staff_auth(urn: school.urn)

    visit school_path

    expect(page).to have_content('Salisbury School')
    expect(page).to have_content(/#{school.address}/)
    expect(page).to have_content(/#{school.town}/)

    click_link 'Create a job listing'

    expect(page).to have_content(I18n.t('jobs.current_step', step: 1, total: 5))
  end

  context 'creating a new vacancy' do
    let!(:subjects) { create_list(:subject, 3) }
    let(:vacancy) do
      VacancyPresenter.new(build(:vacancy, :complete,
                                 job_roles: [
                                   I18n.t('jobs.job_role_options.teacher'),
                                   I18n.t('jobs.job_role_options.sen_specialist')
                                  ],
                                 school: school,
                                 subject: subjects[0],
                                 first_supporting_subject: subjects[1],
                                 second_supporting_subject: subjects[2],
                                 working_patterns: ['full_time', 'part_time'],
                                 publish_on: Time.zone.today))
    end

    scenario 'redirects to step 1, job specification' do
      visit new_school_job_path

      expect(page.current_path).to eq(job_specification_school_job_path)
      expect(page).to have_content(I18n.t('jobs.create_a_job', school: school.name))
      expect(page).to have_content(I18n.t('jobs.current_step', step: 1, total: 5))
    end

    context '#job_specification' do
      scenario 'is invalid unless all mandatory fields are submitted' do
        visit new_school_job_path

        click_on I18n.t('buttons.save_and_continue')

        mandatory_fields = %w[job_title job_roles job_description working_patterns]

        within('.govuk-error-summary') do
          expect(page).to have_content(I18n.t('errors.title', count: mandatory_fields.size))
        end

        mandatory_fields.each do |field|
          within_row_for(text: I18n.t("jobs.#{field}")) do
            expect(page).to have_content((I18n.t("activerecord.errors.models.vacancy.attributes.#{field}.blank")))
          end
        end
      end

      scenario 'redirects to step 2, pay package, when submitted successfully' do
        visit new_school_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on I18n.t('buttons.save_and_continue')

        expect(page).to have_content(I18n.t('jobs.current_step', step: 2, total: 5))
        expect(page).to have_content(I18n.t('jobs.pay_package'))
      end

      scenario 'tracks the vacancy creation' do
        visit new_school_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on I18n.t('buttons.save_and_continue')

        activity = Vacancy.last.activities.last
        expect(activity.session_id).to eq(session_id)
        expect(activity.key).to eq('vacancy.create')
        expect(activity.parameters.symbolize_keys).to include(job_title: [nil, vacancy.job_title])
      end
    end

    context '#pay_package' do
      scenario 'is invalid unless all mandatory fields are submitted' do
        visit new_school_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on I18n.t('buttons.save_and_continue')

        click_on I18n.t('buttons.save_and_continue')

        within('.govuk-error-summary') do
          expect(page).to have_content(I18n.t('errors.title', count: 1))
        end

        within_row_for(text: I18n.t('jobs.salary')) do
          expect(page).to have_content((I18n.t('activerecord.errors.models.vacancy.attributes.salary.blank')))
        end
      end

      context 'with feature upload documents enabled' do
        scenario 'redirects to step 3, supporting documents, when submitted successfuly' do
          visit new_school_job_path

          fill_in_job_specification_form_fields(vacancy)
          click_on I18n.t('buttons.save_and_continue')

          fill_in_pay_package_form_fields(vacancy)
          click_on I18n.t('buttons.save_and_continue')

          expect(page).to have_content(I18n.t('jobs.current_step', step: 3, total: 5))
          expect(page.current_path).to eq(supporting_documents_school_job_path)
        end
      end
    end

    context '#supporting_documents' do
      scenario 'is invalid unless all mandatory fields are submitted' do
        visit new_school_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on I18n.t('buttons.save_and_continue')

        fill_in_pay_package_form_fields(vacancy)
        click_on I18n.t('buttons.save_and_continue')

        click_on I18n.t('buttons.save_and_continue') # submit empty form

        expect(page)
          .to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.supporting_documents.inclusion'))
      end

      scenario 'redirects to step 4, application details, when choosing no' do
        visit new_school_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on I18n.t('buttons.save_and_continue')

        fill_in_pay_package_form_fields(vacancy)
        click_on I18n.t('buttons.save_and_continue')

        select_no_for_supporting_documents
        click_on I18n.t('buttons.save_and_continue')

        expect(page).to have_content(I18n.t('jobs.current_step', step: 4, total: 5))
        expect(page.current_path).to eq(application_details_school_job_path)
      end

      scenario 'redirects to step 3, upload_documents, when choosing yes' do
        visit new_school_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on I18n.t('buttons.save_and_continue')

        fill_in_pay_package_form_fields(vacancy)
        click_on I18n.t('buttons.save_and_continue')

        choose 'Yes'
        click_on I18n.t('buttons.save_and_continue')

        expect(page).to have_content(I18n.t('jobs.upload_file'))
      end
    end

    context '#documents' do
      let(:documents_vacancy) do
        create(:vacancy, school: school)
      end

      scenario 'hiring staff can select a file for upload' do
        visit school_job_documents_path(documents_vacancy.id)
        page.attach_file('documents-form-documents-field', Rails.root.join('spec/fixtures/files/blank_job_spec.pdf'))
        expect(page.find('#documents-form-documents-field').value).to_not be nil
      end

      context 'when uploading files' do
        let(:document_upload) { double('document_upload') }

        before do
          allow(DocumentUpload).to receive(:new).and_return(document_upload)
          allow(document_upload).to receive(:upload)
          allow(document_upload).to receive_message_chain(:uploaded, :web_content_link).and_return('test_url')
          allow(document_upload).to receive_message_chain(:uploaded, :id).and_return('test_id')
          allow(document_upload).to receive(:safe_download).and_return(true)
          allow(document_upload).to receive(:google_error).and_return(false)
        end

        scenario 'displays uploaded file in a table' do
          visit school_job_documents_path(documents_vacancy.id)

          upload_document(
            'new_documents_form',
            'documents-form-documents-field',
            'spec/fixtures/files/blank_job_spec.pdf'
          )

          expect(page).to have_content('blank_job_spec.pdf')
        end

        scenario 'displays error message when large file is uploaded' do
          stub_const("#{HiringStaff::Vacancies::DocumentsController}::FILE_SIZE_LIMIT", 1.kilobyte)
          visit school_job_documents_path(documents_vacancy.id)

          upload_document(
            'new_documents_form',
            'documents-form-documents-field',
            'spec/fixtures/files/blank_job_spec.pdf'
          )

          expect(page).to have_content('blank_job_spec.pdf must be smaller than')
        end

        scenario 'displays error message when virus file is uploaded' do
          visit school_job_documents_path(documents_vacancy.id)

          allow(document_upload).to receive(:safe_download).and_return(false)

          upload_document(
            'new_documents_form',
            'documents-form-documents-field',
            'spec/fixtures/files/blank_job_spec.pdf'
          )

          expect(page).to have_content('blank_job_spec.pdf contains a virus')
        end

        scenario 'displays error message when file not uploaded' do
          visit school_job_documents_path(documents_vacancy.id)

          allow(document_upload).to receive(:google_error).and_return(true)

          upload_document(
            'new_documents_form',
            'documents-form-documents-field',
            'spec/fixtures/files/blank_job_spec.pdf'
          )

          expect(page).to have_content('blank_job_spec.pdf could not be uploaded - try again')
        end
      end

      context 'when deleting uploaded files', js: true do
        let(:document_delete) { double('document_delete') }

        before do
          allow(DocumentDelete).to receive(:new).and_return(document_delete)

          create :document, vacancy: documents_vacancy, name: 'delete_me.pdf'
          create :document, vacancy: documents_vacancy, name: 'do_not_delete_me.pdf'

          visit school_job_documents_path(documents_vacancy.id)

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

    context '#application_details' do
      scenario 'is invalid unless all mandatory fields are submitted' do
        visit new_school_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on I18n.t('buttons.save_and_continue')

        fill_in_pay_package_form_fields(vacancy)
        click_on I18n.t('buttons.save_and_continue')

        select_no_for_supporting_documents
        click_on I18n.t('buttons.save_and_continue')

        click_on I18n.t('buttons.save_and_continue')

        within('.govuk-error-summary') do
          expect(page).to have_content(I18n.t('errors.title', count: 5))
        end

        within_row_for(text: I18n.t('jobs.contact_email')) do
          expect(page).to have_content(
            I18n.t('activemodel.errors.models.application_details_form.attributes.contact_email.blank'))
        end

        within_row_for(element: 'legend', text: I18n.t('jobs.deadline_date')) do
          expect(page).to have_content(
            I18n.t('activemodel.errors.models.application_details_form.attributes.expires_on.blank'))
        end

        within_row_for(element: 'legend', text: strip_tags(I18n.t('jobs.deadline_time_html'))) do
          expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.expiry_time.blank'))
        end

        within_row_for(element: 'legend', text: I18n.t('jobs.publication_date')) do
          expect(page).to have_content(
            I18n.t('activemodel.errors.models.application_details_form.attributes.publish_on.blank'))
        end
      end

      context 'when the upload feature flag is OFF' do
        scenario 'redirects to the vacancy review page when submitted successfully' do
          visit new_school_job_path

          fill_in_job_specification_form_fields(vacancy)
          click_on I18n.t('buttons.save_and_continue')

          fill_in_pay_package_form_fields(vacancy)
          click_on I18n.t('buttons.save_and_continue')

          select_no_for_supporting_documents
          click_on I18n.t('buttons.save_and_continue')

          fill_in_application_details_form_fields(vacancy)
          click_on I18n.t('buttons.save_and_continue')

          expect(page).to have_content(I18n.t('jobs.review'))
          verify_all_vacancy_details(vacancy)
        end
      end
    end

    context '#review' do
      context 'redirects the user back to the last incomplete step' do
        scenario 'redirects to step 2, pay package, when that step has not been completed' do
          visit new_school_job_path

          fill_in_job_specification_form_fields(vacancy)
          click_on I18n.t('buttons.save_and_continue')

          v = Vacancy.find_by(job_title: vacancy.job_title)
          visit school_job_path(id: v.id)

          expect(page).to have_content(I18n.t('jobs.current_step', step: 2, total: 5))
        end

        scenario 'redirects to step 4, application details, when that step has not been completed' do
          visit new_school_job_path

          fill_in_job_specification_form_fields(vacancy)
          click_on I18n.t('buttons.save_and_continue')

          fill_in_pay_package_form_fields(vacancy)
          click_on I18n.t('buttons.save_and_continue')

          select_no_for_supporting_documents
          click_on I18n.t('buttons.save_and_continue')

          v = Vacancy.find_by(job_title: vacancy.job_title)
          visit school_job_path(id: v.id)

          expect(page).to have_content(I18n.t('jobs.current_step', step: 4, total: 5))
        end

        scenario 'redirects to appropriate step when clicked on change on review page' do
          visit new_school_job_path

          fill_in_job_specification_form_fields(vacancy)
          click_on I18n.t('buttons.save_and_continue')

          fill_in_pay_package_form_fields(vacancy)
          click_on I18n.t('buttons.save_and_continue')

          select_no_for_supporting_documents
          click_on I18n.t('buttons.save_and_continue')

          fill_in_application_details_form_fields(vacancy)
          click_on I18n.t('buttons.save_and_continue')

          click_header_link(I18n.t('jobs.application_details'))
          expect(page).to have_content(I18n.t('jobs.current_step', step: 4, total: 5))

          click_on I18n.t('buttons.save_and_continue')

          click_header_link(I18n.t('jobs.job_details'))
          expect(page).to have_content(I18n.t('jobs.current_step', step: 1, total: 5))
        end
      end

      scenario 'is not available for published vacancies' do
        vacancy = create(:vacancy, :published, school_id: school.id)

        visit school_job_review_path(vacancy.id)

        expect(page).to have_current_path(school_job_path(vacancy.id))
      end

      scenario 'lists all the vacancy details correctly' do
        vacancy = VacancyPresenter.new(create(:vacancy, :complete, :draft, school_id: school.id))
        visit school_job_review_path(vacancy.id)

        expect(page).to have_content(I18n.t('jobs.review_heading'))

        verify_all_vacancy_details(vacancy)
      end

      scenario 'enables the user to resolve cross-form errors' do
        vacancy = build(:vacancy, :draft, :complete, slug: 'vacancy-slug', school_id: school.id,
                                                     starts_on: Time.zone.today,
                                                     expiry_time: Time.zone.now + 5.days)
        vacancy.save(validate: false)

        visit school_job_review_path(vacancy.id)
        expect(page)
          .to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.starts_on.before_expires_on'))

        click_header_link(I18n.t('jobs.job_details'))
        expect(page)
          .to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.starts_on.before_expires_on'))
      end

      context 'when the listing is full-time' do
        scenario 'lists all the full-time vacancy details correctly' do
          vacancy = VacancyPresenter.new(
            create(:vacancy,
                   :complete,
                   :draft,
                   school_id: school.id,
                   working_patterns: ['full_time'])
          )
          visit school_job_review_path(vacancy.id)

          expect(page).to have_content(I18n.t('jobs.review_heading'))

          verify_all_vacancy_details(vacancy)
        end
      end

      context 'when the listing is part-time' do
        scenario 'lists all the part-time vacancy details correctly' do
          vacancy = VacancyPresenter.new(
            create(:vacancy,
                   :complete,
                   :draft,
                   school_id: school.id,
                   working_patterns: ['part_time'])
          )
          visit school_job_review_path(vacancy.id)

          expect(page).to have_content(I18n.t('jobs.review_heading'))

          verify_all_vacancy_details(vacancy)
        end
      end

      context 'when the listing is both full- and part-time' do
        scenario 'lists all the working pattern vacancy details correctly' do
          vacancy = VacancyPresenter.new(
            create(:vacancy,
                   :complete,
                   :draft,
                   school_id: school.id,
                   working_patterns: ['full_time', 'part_time'])
          )
          visit school_job_review_path(vacancy.id)

          expect(page).to have_content(I18n.t('jobs.review_heading'))

          verify_all_vacancy_details(vacancy)
        end
      end

      context 'edit job_specification_details' do
        scenario 'updates the vacancy details' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_job_review_path(vacancy.id)
          click_header_link(I18n.t('jobs.job_details'))

          expect(page).to have_content(I18n.t('jobs.current_step', step: 1, total: 5))

          fill_in 'job_specification_form[job_title]', with: 'An edited job title'
          click_on I18n.t('buttons.save_and_continue')

          expect(page).to have_content(I18n.t('jobs.review_heading'))
          expect(page).to have_content('An edited job title')
        end

        scenario 'tracks any changes to  the vacancy details' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          current_title = vacancy.job_title
          current_slug = vacancy.slug
          visit school_job_review_path(vacancy.id)
          click_header_link(I18n.t('jobs.job_details'))

          expect(page).to have_content(I18n.t('jobs.current_step', step: 1, total: 5))

          fill_in 'job_specification_form[job_title]', with: 'High school teacher'
          click_on I18n.t('buttons.save_and_continue')

          activity = vacancy.activities.last
          expect(activity.session_id).to eq(session_id)
          expect(activity.parameters.symbolize_keys).to include(job_title: [current_title, 'High school teacher'])
          expect(activity.parameters.symbolize_keys).to include(slug: [current_slug, 'high-school-teacher'])
        end

        scenario 'fails validation until values are set correctly' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_job_review_path(vacancy.id)
          click_header_link(I18n.t('jobs.job_details'))

          fill_in 'job_specification_form[job_title]', with: ''
          click_on I18n.t('buttons.save_and_continue')

          expect(page).to have_content('Enter a job title')

          fill_in 'job_specification_form[job_title]', with: 'A new job title'
          click_on I18n.t('buttons.save_and_continue')

          expect(page).to have_content(I18n.t('jobs.review_heading'))
          expect(page).to have_content('A new job title')
        end
      end

      context 'editing the supporting_documents' do
        scenario 'updates the vacancy details' do
          visit new_school_job_path

          fill_in_job_specification_form_fields(vacancy)
          click_on I18n.t('buttons.save_and_continue')

          fill_in_pay_package_form_fields(vacancy)
          click_on I18n.t('buttons.save_and_continue')

          select_no_for_supporting_documents
          click_on I18n.t('buttons.save_and_continue')

          fill_in_application_details_form_fields(vacancy)
          click_on I18n.t('buttons.save_and_continue')

          expect(page).to have_content(I18n.t('jobs.review_heading'))

          click_header_link(I18n.t('jobs.supporting_documents'))

          expect(page).to have_content(I18n.t('jobs.current_step', step: 3, total: 5))
          expect(page).to have_content(I18n.t('jobs.upload_file'))

          click_on I18n.t('buttons.save_and_continue')

          expect(page).to have_content(I18n.t('jobs.review_heading'))
        end
      end

      context 'editing the application_details' do
        scenario 'fails validation until values are set correctly' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_job_review_path(vacancy.id)
          click_header_link(I18n.t('jobs.application_details'))

          expect(page).to have_content(I18n.t('jobs.current_step', step: 4, total: 5))

          fill_in 'application_details_form[contact_email]', with: 'not a valid email'
          click_on I18n.t('buttons.save_and_continue')

          expect(page).to have_content('Enter an email address in the correct format, like name@example.com')

          fill_in 'application_details_form[contact_email]', with: 'a@valid.email'
          click_on I18n.t('buttons.save_and_continue')

          expect(page).to have_content(I18n.t('jobs.review_heading'))
          expect(page).to have_content('a@valid.email')
        end

        scenario 'fails validation correctly when an invalid link is entered' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_job_review_path(vacancy.id)
          click_header_link(I18n.t('jobs.application_details'))

          expect(page).to have_content(I18n.t('jobs.current_step', step: 4, total: 5))

          fill_in 'application_details_form[application_link]', with: 'www invalid.domain.com'
          click_on I18n.t('buttons.save_and_continue')

          expect(page).to have_content('Enter an application link in the correct format, like http://www.school.ac.uk')

          fill_in 'application_details_form[application_link]', with: 'www.valid-domain.com'
          click_on I18n.t('buttons.save_and_continue')

          expect(page).to have_content(I18n.t('jobs.review_heading'))
          expect(page).to have_content('www.valid-domain.com')
        end

        scenario 'updates the vacancy details' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          visit school_job_review_path(vacancy.id)
          click_header_link(I18n.t('jobs.application_details'))

          expect(page).to have_content(I18n.t('jobs.current_step', step: 4, total: 5))

          fill_in 'application_details_form[contact_email]', with: 'an@email.com'
          click_on I18n.t('buttons.save_and_continue')

          expect(page).to have_content(I18n.t('jobs.review_heading'))
          expect(page).to have_content('an@email.com')
        end

        scenario 'tracks any changes' do
          vacancy = create(:vacancy, :draft, :complete, school_id: school.id)
          contact_email = vacancy.contact_email
          visit school_job_review_path(vacancy.id)
          click_header_link(I18n.t('jobs.application_details'))

          fill_in 'application_details_form[contact_email]', with: 'an@email.com'
          click_on I18n.t('buttons.save_and_continue')

          activity = vacancy.activities.last
          expect(activity.session_id).to eq(session_id)
          expect(activity.parameters.symbolize_keys).to include(contact_email: [contact_email, 'an@email.com'])
        end
      end

      scenario 'redirects to the school vacancy page when published' do
        vacancy = create(:vacancy, :draft, school_id: school.id)
        visit school_job_review_path(vacancy.id)
        click_on I18n.t('jobs.submit_listing.button')

        expect(page).to have_content('Preview your job listing')
      end
    end

    context '#publish' do
      scenario 'adds the current user as a contact for feedback on the published vacancy' do
        current_user = User.find_by(oid: session_id)
        vacancy = create(:vacancy, :draft, school: school)

        visit school_job_review_path(vacancy.id)
        click_on I18n.t('jobs.submit_listing.button')

        expect(vacancy.reload.publisher_user_id).to eq(current_user.id)
      end

      scenario 'view the published listing as a job seeker' do
        vacancy = create(:vacancy, :draft, school_id: school.id)

        visit school_job_review_path(vacancy.id)

        click_on I18n.t('jobs.submit_listing.button')
        save_page

        click_on I18n.t('jobs.confirmation_page.preview_posted_job')

        verify_vacancy_show_page_details(VacancyPresenter.new(vacancy))
      end

      context 'when the listing is full-time' do
        scenario 'view the full-time published listing as a job seeker' do
          vacancy = create(:vacancy, :draft, school_id: school.id, working_patterns: ['full_time'])

          visit school_job_review_path(vacancy.id)

          click_on I18n.t('jobs.submit_listing.button')
          save_page

          click_on I18n.t('jobs.confirmation_page.preview_posted_job')

          verify_vacancy_show_page_details(VacancyPresenter.new(vacancy))
        end
      end

      context 'when the listing is part-time' do
        scenario 'view the part-time published listing as a job seeker' do
          vacancy = create(:vacancy, :draft, school_id: school.id, working_patterns: ['part_time'])

          visit school_job_review_path(vacancy.id)

          click_on I18n.t('jobs.submit_listing.button')
          save_page

          click_on I18n.t('jobs.confirmation_page.preview_posted_job')

          verify_vacancy_show_page_details(VacancyPresenter.new(vacancy))
        end
      end

      context 'when the listing is both full- and part-time' do
        scenario 'view the full- and part-time published listing as a job seeker' do
          vacancy = create(:vacancy, :draft, school_id: school.id, working_patterns: ['full_time', 'part_time'])

          visit school_job_review_path(vacancy.id)

          click_on I18n.t('jobs.submit_listing.button')
          save_page

          click_on I18n.t('jobs.confirmation_page.preview_posted_job')

          verify_vacancy_show_page_details(VacancyPresenter.new(vacancy))
        end
      end

      scenario 'cannot be published unless the details are valid' do
        vacancy = create(:vacancy, :draft, school_id: school.id, publish_on: Time.zone.tomorrow)
        vacancy.assign_attributes expires_on: Time.zone.yesterday
        vacancy.save(validate: false)

        visit school_job_review_path(vacancy.id)
        click_on 'Confirm and submit job'

        expect(page).to have_content(I18n.t('errors.jobs.unable_to_publish'))
        expect(page).to have_content(
          I18n.t('activerecord.errors.models.vacancy.attributes.expires_on.before_publish_date')
        )
      end

      scenario 'can be published at a later date' do
        vacancy = create(:vacancy, :draft, school_id: school.id, publish_on: Time.zone.tomorrow)

        visit school_job_review_path(vacancy.id)
        click_on 'Confirm and submit job'

        expect(page).to have_content("Your job listing will be posted on #{format_date(vacancy.publish_on)}.")
        visit school_job_path(vacancy.id)
        expect(page).to have_content('Date listed')
        expect(page).to have_content("#{format_date(vacancy.publish_on)}")
      end

      scenario 'displays the expiration date and time on the confirmation page' do
        vacancy = create(:vacancy, :draft, school_id: school.id, expiry_time: Time.zone.now + 5.days)
        visit school_job_review_path(vacancy.id)
        click_on I18n.t('jobs.submit_listing.button')

        expect(page).to have_content(
          'The listing will appear on the service until ' \
          "#{format_date(vacancy.expires_on)} at #{format_time(vacancy.expiry_time)}, " \
          'after which it will no longer be visible to jobseekers.'
        )
      end

      scenario 'tracks publishing information' do
        vacancy = create(:vacancy, :draft, school_id: school.id, publish_on: Time.zone.tomorrow)

        visit school_job_review_path(vacancy.id)
        click_on 'Confirm and submit job'

        activity = vacancy.activities.last
        expect(activity.session_id).to eq(session_id)
        expect(activity.key).to eq('vacancy.publish')
      end

      scenario 'a published vacancy cannot be republished' do
        vacancy = create(:vacancy, :draft, school_id: school.id, publish_on: Time.zone.tomorrow)

        visit school_job_review_path(vacancy.id)
        click_on 'Confirm and submit job'
        expect(page).to have_content('The job listing has been completed')

        visit school_job_publish_path(vacancy.id)

        expect(page).to have_content('This job has already been published')
      end

      scenario 'a published vacancy cannot be edited' do
        visit new_school_job_path

        fill_in_job_specification_form_fields(vacancy)
        click_on I18n.t('buttons.save_and_continue')
        fill_in_pay_package_form_fields(vacancy)
        click_on I18n.t('buttons.save_and_continue')
        select_no_for_supporting_documents
        click_on I18n.t('buttons.save_and_continue')
        fill_in_application_details_form_fields(vacancy)
        click_on I18n.t('buttons.save_and_continue')
        click_link('vacancy-review-submit')
        expect(page).to have_content('Preview your job listing')

        visit application_details_school_job_path
        expect(page.current_path).to eq(job_specification_school_job_path)
      end

      context 'adds a job to update the Google index in the queue' do
        scenario 'if the vacancy is published immediately' do
          vacancy = create(:vacancy, :draft, school_id: school.id, publish_on: Time.zone.today)

          expect_any_instance_of(HiringStaff::Vacancies::ApplicationController)
            .to receive(:update_google_index).with(vacancy)

          visit school_job_review_path(vacancy.id)
          click_on I18n.t('jobs.submit_listing.button')
        end
      end

      context 'updates the published vacancy spreadsheet via Sidekiq' do
        scenario 'when the vacancy is published' do
          vacancy = create(:vacancy, :draft, school_id: school.id, publish_on: Time.zone.today)

          expect(AuditPublishedVacancyJob).to receive(:perform_later).with(vacancy.id)

          visit school_job_review_path(vacancy.id)
          click_on I18n.t('jobs.submit_listing.button')
        end
      end
    end
  end
end
