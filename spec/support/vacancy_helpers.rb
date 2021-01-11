module VacancyHelpers
  def fill_in_job_location_form_field(vacancy)
    hyphenated_location = vacancy.job_location.split("_").join("-")
    find("label[for=\"job-location-form-job-location-#{hyphenated_location}-field\"]").click
  end

  def change_job_location(vacancy, location)
    vacancy.job_location = location
    click_header_link(I18n.t("jobs.job_location"))
    fill_in_job_location_form_field(vacancy)
    click_on I18n.t("buttons.update_job")
  end

  def fill_in_school_form_field(school)
    find("label[for=\"schools-form-organisation-ids-#{school.id}-field\"]").click
  end

  def fill_in_job_details_form_fields(vacancy)
    fill_in "job_details_form[job_title]", with: vacancy.job_title

    working_patterns = vacancy.try(:model_working_patterns).presence || vacancy.working_patterns
    working_patterns.each do |working_pattern|
      check Vacancy.human_attribute_name("working_patterns.#{working_pattern}"),
            name: "job_details_form[working_patterns][]",
            visible: false
    end

    vacancy.job_roles&.each do |job_role|
      check I18n.t("helpers.label.job_details_form.job_roles_options.#{job_role}"),
            name: "job_details_form[job_roles][]",
            visible: false
    end

    find("label[for='job-details-form-suitable-for-nqt-#{vacancy.suitable_for_nqt}-field']").click

    vacancy.subjects&.each do |subject|
      check subject,
            name: "job_details_form[subjects][]",
            visible: false
    end
  end

  def fill_in_pay_package_form_fields(vacancy)
    fill_in "pay_package_form[salary]", with: vacancy.salary
    fill_in "pay_package_form[benefits]", with: vacancy.benefits
  end

  def fill_in_important_dates_fields(vacancy)
    fill_in "important_dates_form[publish_on(3i)]", with: vacancy.publish_on.day
    fill_in "important_dates_form[publish_on(2i)]", with: vacancy.publish_on.strftime("%m")
    fill_in "important_dates_form[publish_on(1i)]", with: vacancy.publish_on.year

    fill_in "important_dates_form[expires_on(3i)]", with: vacancy.expires_on.day
    fill_in "important_dates_form[expires_on(2i)]", with: vacancy.expires_on.strftime("%m")
    fill_in "important_dates_form[expires_on(1i)]", with: vacancy.expires_on.year

    fill_in "important_dates_form[expires_at_hh]", with: vacancy.expires_at.strftime("%-l")
    fill_in "important_dates_form[expires_at_mm]", with: vacancy.expires_at.strftime("%-M")
    select vacancy.expires_at.strftime("%P"), from: "important_dates_form[expires_at_meridiem]"

    fill_in "important_dates_form[starts_on(3i)]", with: vacancy.starts_on.day
    fill_in "important_dates_form[starts_on(2i)]", with: vacancy.starts_on.strftime("%m")
    fill_in "important_dates_form[starts_on(1i)]", with: vacancy.starts_on.year
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

  def fill_in_applying_for_the_job_form_fields(vacancy)
    fill_in "applying_for_the_job_form[contact_email]", with: vacancy.contact_email
    fill_in "applying_for_the_job_form[contact_number]", with: vacancy.contact_number
    fill_in "applying_for_the_job_form[school_visits]", with: vacancy.school_visits
    fill_in "applying_for_the_job_form[how_to_apply]", with: vacancy.how_to_apply
    fill_in "applying_for_the_job_form[application_link]", with: vacancy.application_link
  end

  def fill_in_job_summary_form_fields(vacancy)
    fill_in "job_summary_form[job_summary]", with: vacancy.job_summary
    fill_in "job_summary_form[about_school]", with: vacancy.about_school
  end

  def fill_in_copy_vacancy_form_fields(vacancy)
    fill_in "copy_vacancy_form[job_title]", with: vacancy.job_title

    fill_in "copy_vacancy_form[expires_on(3i)]", with: vacancy.expires_on&.day
    fill_in "copy_vacancy_form[expires_on(2i)]", with: vacancy.expires_on&.strftime("%m")
    fill_in "copy_vacancy_form[expires_on(1i)]", with: vacancy.expires_on&.year

    fill_in "copy_vacancy_form[expires_at_hh]", with: vacancy.expires_at.strftime("%-l")
    fill_in "copy_vacancy_form[expires_at_mm]", with: vacancy.expires_at.strftime("%-M")
    select vacancy.expires_at.strftime("%P"), from: "copy_vacancy_form[expires_at_meridiem]"

    fill_in "copy_vacancy_form[publish_on(3i)]", with: vacancy.publish_on&.day
    fill_in "copy_vacancy_form[publish_on(2i)]", with: vacancy.publish_on&.strftime("%m")
    fill_in "copy_vacancy_form[publish_on(1i)]", with: vacancy.publish_on&.year

    fill_in "copy_vacancy_form[starts_on(3i)]", with: vacancy.starts_on.day if vacancy.starts_on
    fill_in "copy_vacancy_form[starts_on(2i)]", with: vacancy.starts_on.strftime("%m") if vacancy.starts_on
    fill_in "copy_vacancy_form[starts_on(1i)]", with: vacancy.starts_on.year if vacancy.starts_on
  end

  def verify_all_vacancy_details(vacancy)
    expect(page).to have_content(vacancy.job_title)
    expect(page).to have_content(vacancy.show_job_roles)
    expect(page).to have_content(vacancy.show_subjects)
    expect(page).to have_content(vacancy.working_patterns)

    expect(page).to have_content(vacancy.salary)
    expect(page.html).to include(vacancy.benefits)

    expect(page).to have_content(vacancy.publish_on.to_s.strip)
    expect(page).to have_content(vacancy.expires_on.to_s.strip)
    expect(page).to have_content(vacancy.starts_on.to_s.strip) if vacancy.starts_on?

    expect(page).to have_content(I18n.t("jobs.supporting_documents"))

    expect(page).to have_content(vacancy.contact_email)
    expect(page).to have_content(vacancy.contact_number)
    expect(page.html).to include(vacancy.school_visits)
    expect(page.html).to include(vacancy.how_to_apply)
    expect(page).to have_content(vacancy.application_link)

    expect(page.html).to include(vacancy.job_summary)
    expect(page.html).to include(vacancy.about_school)
  end

  def verify_vacancy_show_page_details(vacancy)
    expect(page).to have_content(vacancy.job_title)
    expect(page).to have_content(vacancy.show_job_roles)
    expect(page).to have_content(vacancy.show_subjects)
    expect(page).to have_content(vacancy.working_patterns)

    expect(page).to have_content(vacancy.salary)
    expect(page.html).to include(vacancy.benefits)

    expect(page).to have_content(vacancy.publish_on.to_s.strip)
    expect(page).to have_content(vacancy.expires_on.to_s.strip)
    expect(page).to have_content(vacancy.starts_on.to_s.strip) if vacancy.starts_on?

    expect(page.html).to include(vacancy.school_visits)
    expect(page.html).to include(vacancy.how_to_apply)

    expect(page.html).to include(vacancy.job_summary)
    expect(page.html).to include(vacancy.about_school)

    if vacancy.documents.any?
      expect(page).to have_content(I18n.t("jobs.supporting_documents"))
    end

    if vacancy.documents.none? && vacancy.any_candidate_specification?
      expect(page.html).to include(vacancy.education)
      expect(page.html).to include(vacancy.qualifications)
      expect(page.html).to include(vacancy.experience)
    end

    expect(page).to have_link(I18n.t("jobs.apply"), href: new_job_interest_path(vacancy.id))
  end

  def expect_schema_property_to_match_value(key, value)
    expect(page).to have_selector("meta[itemprop='#{key}'][content='#{value}']")
  end

  def vacancy_json_ld(vacancy)
    {
      '@context': "http://schema.org",
      '@type': "JobPosting",
      'title': vacancy.job_title,
      'salary': vacancy.salary,
      'jobBenefits': vacancy.benefits,
      'datePosted': vacancy.publish_on.to_time.iso8601,
      'description': vacancy.job_summary,
      'occupationalCategory': vacancy.job_roles&.join(", "),
      'educationRequirements': vacancy.education,
      'qualifications': vacancy.qualifications,
      'experienceRequirements': vacancy.experience,
      'employmentType': vacancy.working_patterns_for_job_schema,
      'industry': "Education",
      'jobLocation': {
        '@type': "Place",
        'address': {
          '@type': "PostalAddress",
          'addressLocality': vacancy.parent_organisation.town,
          'addressRegion': vacancy.parent_organisation.region,
          'streetAddress': vacancy.parent_organisation.address,
          'postalCode': vacancy.parent_organisation.postcode,
        },
      },
      'url': job_url(vacancy),
      'hiringOrganization': {
        '@type': "School",
        'name': vacancy.parent_organisation.name,
        'identifier': vacancy.parent_organisation.urn,
        'description': vacancy.about_school,
      },
      'validThrough': vacancy.expires_on.end_of_day.to_time.iso8601,
    }
  end

  def verify_vacancy_list_page_details(vacancy)
    expect(page.find(".vacancy")).not_to have_content(vacancy.publish_on)
    expect(page.find(".vacancy")).not_to have_content(vacancy.starts_on) if vacancy.starts_on?
    expect(page.find(".vacancy")).to have_content(vacancy.parent_organisation.school_type.singularize)

    verify_shared_vacancy_list_page_details(vacancy)
  end

private

  def verify_shared_vacancy_list_page_details(vacancy)
    expect(page.find(".vacancy")).to have_content(vacancy.job_title)
    expect(page.find(".vacancy")).to have_content(vacancy.location)
    expect(page.find(".vacancy")).to have_content(vacancy.salary)
    expect(page.find(".vacancy")).to have_content(vacancy.working_patterns)
    expect(page.find(".vacancy")).to have_content(vacancy.expires_on)

    expect(page.find(".vacancy")).to have_content(vacancy.expires_at.strftime("%-l:%M %P")) unless vacancy.expires_at.nil?
  end
end
