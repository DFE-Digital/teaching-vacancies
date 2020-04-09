module VacancyHelpers
  def fill_in_job_specification_form_fields(vacancy)
    fill_in 'job_specification_form[job_title]', with: vacancy.job_title
    select vacancy.subject.name, from: 'job_specification_form[subject_id]' if vacancy.subject
    select vacancy.first_supporting_subject,
      from: 'job_specification_form[first_supporting_subject_id]' if vacancy.first_supporting_subject
    select vacancy.second_supporting_subject,
      from: 'job_specification_form[second_supporting_subject_id]' if vacancy.second_supporting_subject
    fill_in 'job_specification_form[starts_on_dd]', with: vacancy.starts_on.day if vacancy.starts_on
    fill_in 'job_specification_form[starts_on_mm]', with: vacancy.starts_on.strftime('%m') if vacancy.starts_on
    fill_in 'job_specification_form[starts_on_yyyy]', with: vacancy.starts_on.year if vacancy.starts_on
    fill_in 'job_specification_form[ends_on_dd]', with: vacancy.ends_on.day if vacancy.ends_on
    fill_in 'job_specification_form[ends_on_mm]', with: vacancy.ends_on.strftime('%m') if vacancy.ends_on
    fill_in 'job_specification_form[ends_on_yyyy]', with: vacancy.ends_on.year if vacancy.ends_on

    vacancy.model_working_patterns.each do |working_pattern|
      check Vacancy.human_attribute_name("working_patterns.#{working_pattern}"),
            name: 'job_specification_form[working_patterns][]',
            visible: false
    end

    vacancy.job_roles&.each do |job_role|
      check job_role,
            name: 'job_specification_form[job_roles][]',
            visible: false
    end
  end

  def fill_in_pay_package_form_fields(vacancy)
    fill_in 'pay_package_form[salary]', with: vacancy.salary
    fill_in 'pay_package_form[benefits]', with: vacancy.benefits
  end

  def fill_in_supporting_documents_form_fields
    find('label[for="supporting-documents-form-supporting-documents-yes-field"]').click
  end

  def select_no_for_supporting_documents
    find('label[for="supporting-documents-form-supporting-documents-no-field"]').click
  end

  def upload_document(form_id, input_name, filepath)
    page.attach_file(input_name, Rails.root.join(filepath))
    # Submit form on file upload without requiring Javascript driver
    form = page.find("##{form_id}")
    Capybara::RackTest::Form.new(page.driver, form.native).submit(form)
  end

  def fill_in_application_details_form_fields(vacancy)
    fill_in 'application_details_form[contact_email]', with: vacancy.contact_email
    fill_in 'application_details_form[application_link]', with: vacancy.application_link

    fill_in 'application_details_form[expires_on_dd]', with: vacancy.expires_on.day
    fill_in 'application_details_form[expires_on_mm]', with: vacancy.expires_on.strftime('%m')
    fill_in 'application_details_form[expires_on_yyyy]', with: vacancy.expires_on.year

    fill_in 'application_details_form[expiry_time_hh]', with: vacancy.expiry_time.strftime('%-l')
    fill_in 'application_details_form[expiry_time_mm]', with: vacancy.expiry_time.strftime('%-M')
    select vacancy.expiry_time.strftime('%P'), from: 'application_details_form[expiry_time_meridiem]'

    fill_in 'application_details_form[publish_on_dd]', with: vacancy.publish_on.day
    fill_in 'application_details_form[publish_on_mm]', with: vacancy.publish_on.strftime('%m')
    fill_in 'application_details_form[publish_on_yyyy]', with: vacancy.publish_on.year
  end

  def fill_in_job_summary_form_fields(vacancy)
    fill_in 'job_summary_form[job_summary]', with: vacancy.job_summary
    fill_in 'job_summary_form[about_school]', with: vacancy.about_school
  end

  def fill_in_copy_vacancy_form_fields(vacancy)
    fill_in 'copy_vacancy_form[job_title]', with: vacancy.job_title

    fill_in 'copy_vacancy_form[starts_on_dd]', with: vacancy.starts_on.day
    fill_in 'copy_vacancy_form[starts_on_mm]', with: vacancy.starts_on.strftime('%m')
    fill_in 'copy_vacancy_form[starts_on_yyyy]', with: vacancy.starts_on.year

    fill_in 'copy_vacancy_form[ends_on_dd]', with: vacancy.ends_on.day
    fill_in 'copy_vacancy_form[ends_on_mm]', with: vacancy.ends_on.strftime('%m')
    fill_in 'copy_vacancy_form[ends_on_yyyy]', with: vacancy.ends_on.year

    fill_in 'copy_vacancy_form[expires_on_dd]', with: vacancy.expires_on&.day
    fill_in 'copy_vacancy_form[expires_on_mm]', with: vacancy.expires_on&.strftime('%m')
    fill_in 'copy_vacancy_form[expires_on_yyyy]', with: vacancy.expires_on&.year

    fill_in 'copy_vacancy_form[expiry_time_hh]', with: vacancy.expiry_time.strftime('%-l')
    fill_in 'copy_vacancy_form[expiry_time_mm]', with: vacancy.expiry_time.strftime('%-M')
    select vacancy.expiry_time.strftime('%P'), from: 'copy_vacancy_form[expiry_time_meridiem]'

    fill_in 'copy_vacancy_form[publish_on_dd]', with: vacancy.publish_on&.day
    fill_in 'copy_vacancy_form[publish_on_mm]', with: vacancy.publish_on&.strftime('%m')
    fill_in 'copy_vacancy_form[publish_on_yyyy]', with: vacancy.publish_on&.year
  end

  def verify_all_vacancy_details(vacancy)
    expect(page).to have_content(vacancy.job_title)
    expect(page).to have_content(vacancy.show_job_roles)
    expect(page).to have_content(vacancy.subject.name)
    expect(page).to have_content(vacancy.other_subjects)
    expect(page).to have_content(vacancy.working_patterns)
    expect(page).to have_content(vacancy.starts_on.to_s.strip) if vacancy.starts_on?
    expect(page).to have_content(vacancy.ends_on.to_s.strip) if vacancy.ends_on?

    expect(page).to have_content(vacancy.salary)
    expect(page.html).to include(vacancy.benefits)

    expect(page).to have_content(I18n.t('jobs.supporting_documents'))

    expect(page).to have_content(vacancy.contact_email)
    expect(page).to have_content(vacancy.application_link)
    expect(page).to have_content(vacancy.expires_on.to_s.strip)
    expect(page).to have_content(vacancy.publish_on.to_s.strip)

    expect(page.html).to include(vacancy.job_summary)
    expect(page.html).to include(vacancy.about_school)
  end

  def verify_vacancy_show_page_details(vacancy)
    expect(page).to have_content(vacancy.job_title)
    expect(page).to have_content(vacancy.show_job_roles)
    expect(page.html).to include(vacancy.job_summary)
    expect(page).to have_content(vacancy.subject.name)
    expect(page).to have_content(vacancy.other_subjects)
    expect(page).to have_content(vacancy.working_patterns)
    expect(page).to have_content(vacancy.starts_on.to_s.strip) if vacancy.starts_on?
    expect(page).to have_content(vacancy.ends_on.to_s.strip) if vacancy.ends_on?

    expect(page).to have_content(vacancy.salary)
    expect(page.html).to include(vacancy.benefits)

    if vacancy.documents.any?
      expect(page).to have_content(I18n.t('jobs.supporting_documents'))
    end

    if vacancy.documents.none? && vacancy.any_candidate_specification?
      expect(page.html).to include(vacancy.education)
      expect(page.html).to include(vacancy.qualifications)
      expect(page.html).to include(vacancy.experience)
    end

    expect(page).to have_link(I18n.t('jobs.apply'), href: new_job_interest_path(vacancy.id))
    expect(page).to have_content(vacancy.expires_on.to_s.strip)
    expect(page).to have_content(vacancy.publish_on.to_s.strip)
  end

  def expect_schema_property_to_match_value(key, value)
    expect(page).to have_selector("meta[itemprop='#{key}'][content='#{value}']")
  end

  def skip_vacancy_publish_on_validation
    allow_any_instance_of(Vacancy).to receive(:publish_on_must_not_be_in_the_past).and_return(true)
  end

  def vacancy_json_ld(vacancy)
    json = {
      '@context': 'http://schema.org',
      '@type': 'JobPosting',
      'title': vacancy.job_title,
      'salary': vacancy.salary,
      'jobBenefits': vacancy.benefits,
      'datePosted': vacancy.publish_on.to_time.iso8601,
      'description': vacancy.job_summary,
      'educationRequirements': vacancy.education,
      'qualifications': vacancy.qualifications,
      'experienceRequirements': vacancy.experience,
      'employmentType': vacancy.working_patterns_for_job_schema,
      'industry': 'Education',
      'jobLocation': {
        '@type': 'Place',
        'address': {
          '@type': 'PostalAddress',
          'addressLocality': vacancy.school.town,
          'addressRegion': vacancy.school.region.name,
          'streetAddress': vacancy.school.address,
          'postalCode': vacancy.school.postcode,
        },
      },
      'url': job_url(vacancy),
      'hiringOrganization': {
        '@type': 'School',
        'name': vacancy.school.name,
        'identifier': vacancy.school.urn,
      },
      'validThrough': vacancy.expires_on.end_of_day.to_time.iso8601,
    }

    json
  end

  def verify_vacancy_list_page_details(vacancy)
    expect(page.find('.vacancy')).not_to have_content(vacancy.publish_on)
    expect(page.find('.vacancy')).not_to have_content(vacancy.starts_on) if vacancy.starts_on?
    expect(page.find('.vacancy')).to have_content(vacancy.school.school_type.label.singularize)

    verify_shared_vacancy_list_page_details(vacancy)
  end

  private

  def verify_shared_vacancy_list_page_details(vacancy)
    expect(page.find('.vacancy')).to have_content(vacancy.job_title)
    expect(page.find('.vacancy')).to have_content(vacancy.location)
    expect(page.find('.vacancy')).to have_content(vacancy.salary)
    expect(page.find('.vacancy')).to have_content(vacancy.working_patterns)
    expect(page.find('.vacancy')).to have_content(vacancy.expires_on)
    unless vacancy.expiry_time.nil?
      expect(page.find('.vacancy')).to have_content(vacancy.expiry_time.strftime('%-l:%M %P'))
    end
  end
end
