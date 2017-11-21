module VacancyHelpers
  def fill_in_job_spec_fields(vacancy)
    fill_in 'vacancy[job_title]', with: vacancy.job_title
    fill_in 'vacancy[headline]', with: vacancy.headline
    fill_in 'vacancy[job_description]', with: vacancy.job_description
    select vacancy.working_pattern.humanize, from: 'vacancy[working_pattern]'
    fill_in 'vacancy[minimum_salary]', with: vacancy.minimum_salary
    fill_in 'vacancy[maximum_salary]', with: vacancy.maximum_salary
    click_button 'Save and continue'
  end

  def fill_in_candidate_specification_fields(vacancy)
    fill_in 'vacancy[essential_requirements]', with: vacancy.essential_requirements
  end

  # rubocop:disable Metrics/AbcSize
  def fill_in_application_details_fields(vacancy)
    fill_in 'vacancy[expires_on_dd]', with: Faker::Business.credit_card_expiry_date.day
    fill_in 'vacancy[expires_on_mm]', with: Faker::Business.credit_card_expiry_date.strftime('%m')
    fill_in 'vacancy[expires_on_yyyy]', with: Faker::Business.credit_card_expiry_date.year
    fill_in 'vacancy[publish_on_dd]', with: Time.zone.today.day
    fill_in 'vacancy[publish_on_mm]', with: Time.zone.today.strftime('%m')
    fill_in 'vacancy[publish_on_yyyy]', with: Time.zone.today.year
    fill_in 'vacancy[contact_email]', with: vacancy.contact_email
  end
  # rubocop:enable Metrics/AbcSize

  def expect_schema_property_to_match_value(key, value)
    expect(page).to have_selector("meta[itemprop='#{key}'][content='#{value}']")
  end

  def skip_vacancy_publish_on_validation
    allow_any_instance_of(Vacancy).to receive(:validity_of_publish_on).and_return(true)
  end

  # rubocop:disable Metrics/AbcSize
  def vacancy_json_ld(vacancy)
    {
      '@context': 'http://schema.org',
      '@type': 'JobPosting',
      'jobBenefits': vacancy.benefits,
      'datePosted': vacancy.publish_on.to_s(:db),
      'description': vacancy.headline,
      'educationRequirements': vacancy.education,
      'qualifications': vacancy.qualifications,
      'employmentType': vacancy.working_pattern&.titleize,
      'experienceRequirements': vacancy.essential_requirements,
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
      'responsibilities': vacancy.job_description,
      'title': vacancy.job_title,
      'url': vacancy_url(vacancy),
      'baseSalary': {
        '@type': 'MonetaryAmount',
        'minValue': vacancy.minimum_salary,
        'maxValue': vacancy.maximum_salary,
        'currency': 'GBP',
      },
      'hiringOrganization': {
        '@type': 'Organization',
        'name': vacancy.school.name,
      },
      'validThrough': vacancy.expires_on.to_s(:db),
      'workHours': vacancy.weekly_hours,
    }
    # rubocop:enable Metrics/AbcSize
  end
end
