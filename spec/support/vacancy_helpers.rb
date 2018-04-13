module VacancyHelpers
  def fill_in_job_specification_form_fields(vacancy)
    fill_in 'job_specification_form[job_title]', with: vacancy.job_title
    fill_in 'job_specification_form[job_description]', with: vacancy.job_description
    select vacancy.working_pattern, from: 'job_specification_form[working_pattern]'
    select vacancy.pay_scale, from: 'job_specification_form[pay_scale_id]'
    select vacancy.subject.name, from: 'job_specification_form[subject_id]'
    select vacancy.leadership.title, from: 'job_specification_form[leadership_id]'
    fill_in 'job_specification_form[minimum_salary]', with: vacancy.minimum_salary
    fill_in 'job_specification_form[maximum_salary]', with: vacancy.maximum_salary
    fill_in 'job_specification_form[starts_on_dd]', with: vacancy.starts_on.day
    fill_in 'job_specification_form[starts_on_mm]', with: vacancy.starts_on.strftime('%m')
    fill_in 'job_specification_form[starts_on_yyyy]', with: vacancy.starts_on.year
    fill_in 'job_specification_form[ends_on_dd]', with: vacancy.ends_on.day
    fill_in 'job_specification_form[ends_on_mm]', with: vacancy.ends_on.strftime('%m')
    fill_in 'job_specification_form[ends_on_yyyy]', with: vacancy.ends_on.year
  end

  def fill_in_candidate_specification_form_fields(vacancy)
    fill_in 'candidate_specification_form[education]', with: vacancy.education
    fill_in 'candidate_specification_form[qualifications]', with: vacancy.qualifications
    fill_in 'candidate_specification_form[experience]', with: vacancy.experience
  end

  def fill_in_application_details_form_fields(vacancy)
    fill_in 'application_details_form[contact_email]', with: vacancy.contact_email
    fill_in 'application_details_form[application_link]', with: vacancy.application_link
    fill_in 'application_details_form[expires_on_dd]', with: vacancy.expires_on.day
    fill_in 'application_details_form[expires_on_mm]', with: vacancy.expires_on.strftime('%m')
    fill_in 'application_details_form[expires_on_yyyy]', with: vacancy.expires_on.year
    fill_in 'application_details_form[publish_on_dd]', with: vacancy.publish_on.day
    fill_in 'application_details_form[publish_on_mm]', with: vacancy.publish_on.strftime('%m')
    fill_in 'application_details_form[publish_on_yyyy]', with: vacancy.publish_on.year
  end

  def verify_all_vacancy_details(vacancy)
    expect(page).to have_content(vacancy.job_title)
    expect(page).to have_content(vacancy.job_description)
    expect(page).to have_content(vacancy.subject.name)
    expect(page).to have_content(vacancy.salary_range)
    expect(page).to have_content(vacancy.working_pattern)
    expect(page).to have_content(vacancy.benefits)
    expect(page).to have_content(vacancy.pay_scale)
    expect(page).to have_content(vacancy.weekly_hours)
    expect(page).to have_content(vacancy.starts_on)
    expect(page).to have_content(vacancy.ends_on)

    expect(page).to have_content(vacancy.education)
    expect(page).to have_content(vacancy.qualifications)
    expect(page).to have_content(vacancy.experience)
    expect(page).to have_content(vacancy.leadership.title)

    expect(page).to have_content(vacancy.contact_email)
    expect(page).to have_content(vacancy.application_link)
    expect(page).to have_content(vacancy.expires_on)
    expect(page).to have_content(vacancy.publish_on)
  end

  def expect_schema_property_to_match_value(key, value)
    expect(page).to have_selector("meta[itemprop='#{key}'][content='#{value}']")
  end

  def skip_vacancy_publish_on_validation
    allow_any_instance_of(Vacancy).to receive(:validity_of_publish_on).and_return(true)
  end

  def vacancy_json_ld(vacancy)
    {
      '@context': 'http://schema.org',
      '@type': 'JobPosting',
      'title': vacancy.job_title,
      'jobBenefits': vacancy.benefits,
      'datePosted': vacancy.publish_on.to_time.iso8601,
      'description': vacancy.job_description,
      'educationRequirements': vacancy.education,
      'qualifications': vacancy.qualifications,
      'experienceRequirements': vacancy.experience,
      'employmentType': vacancy.working_pattern_for_job_schema,
      'industry': 'Education',
      'jobLocation': {
        '@type': 'Place',
        'address': {
          '@type': 'PostalAddress',
          'addressLocality': vacancy.school.town,
          'addressRegion': vacancy.school.county,
          'streetAddress': vacancy.school.address,
          'postalCode': vacancy.school.postcode,
        },
      },
      'url': vacancy_url(vacancy),
      'baseSalary': {
        '@type': 'MonetaryAmount',
        'currency': 'GBP',
        value: {
          '@type': 'QuantitativeValue',
          'minValue': vacancy.minimum_salary,
          'maxValue': vacancy.maximum_salary,
          'unitText': 'YEAR'
        },
      },
      'hiringOrganization': {
        '@type': 'School',
        'name': vacancy.school.name,
        'identifier': vacancy.school.urn,
      },
      'validThrough': vacancy.expires_on.to_time.iso8601,
      'workHours': vacancy.weekly_hours,
    }
  end
end
