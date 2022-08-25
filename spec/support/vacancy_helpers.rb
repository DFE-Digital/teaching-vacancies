module VacancyHelpers
  def change_job_locations(vacancy, organisations)
    vacancy.organisations = organisations
    click_header_link(I18n.t("publishers.vacancies.steps.job_location"))
    fill_in_job_location_form_field(vacancy)
  end

  def fill_in_job_location_form_field(vacancy)
    vacancy.organisations.each do |organisation|
      check(organisation.school? ? organisation.name : I18n.t("organisations.job_location_heading.central_office"))
    end
  end

  def fill_in_job_role_form_fields(vacancy)
    choose I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.#{vacancy.job_role}")
  end

  def fill_in_ect_status_form_fields(vacancy)
    choose I18n.t("helpers.label.publishers_job_listing_job_role_details_form.ect_status_options.#{vacancy.ect_status}")
  end

  def fill_in_education_phases_form_fields(vacancy)
    check I18n.t("helpers.label.publishers_job_listing_education_phases_form.phases_options.#{vacancy.phases.first}")
  end

  def fill_in_job_role_details_form_fields(vacancy)
    choose I18n.t("helpers.label.publishers_job_listing_job_role_details_form.ect_status_options.#{vacancy.ect_status}")
  end

  def fill_in_job_details_form_fields(vacancy, include_key_stages: true)
    fill_in "publishers_job_listing_job_details_form[job_title]", with: vacancy.job_title

    vacancy.subjects&.each do |subject|
      check subject,
            name: "publishers_job_listing_job_details_form[subjects][]",
            visible: false
    end

    choose I18n.t("helpers.label.publishers_job_listing_job_details_form.contract_type_options.#{vacancy.contract_type}")
    if include_key_stages
      vacancy.key_stages.each do |key_stage|
        check I18n.t("helpers.label.publishers_job_listing_job_details_form.key_stages_options.#{key_stage}")
      end
    end
    fill_in "publishers_job_listing_job_details_form[fixed_term_contract_duration]", with: vacancy.fixed_term_contract_duration
    fill_in "publishers_job_listing_job_details_form[parental_leave_cover_contract_duration]", with: vacancy.parental_leave_cover_contract_duration
  end

  def fill_in_working_patterns_form_fields(vacancy)
    vacancy.working_patterns.each do |working_pattern|
      check Vacancy.human_attribute_name(working_pattern.to_s), name: "publishers_job_listing_working_patterns_form[working_patterns][]"
    end

    fill_in "publishers_job_listing_working_patterns_form[full_time_details]", with: vacancy.full_time_details if vacancy.working_patterns.include?("full_time")
    fill_in "publishers_job_listing_working_patterns_form[part_time_details]", with: vacancy.part_time_details if vacancy.working_patterns.include?("part_time")
  end

  def fill_in_pay_package_form_fields(vacancy)
    fill_in "publishers_job_listing_pay_package_form[salary]", with: vacancy.salary
    fill_in "publishers_job_listing_pay_package_form[actual_salary]", with: vacancy.actual_salary unless vacancy.working_patterns == ["full_time"]
    fill_in "publishers_job_listing_pay_package_form[benefits]", with: vacancy.benefits
  end

  def fill_in_important_dates_fields(vacancy)
    choose I18n.t("helpers.label.publishers_job_listing_important_dates_form.publish_on_day_options.another_day")

    fill_in "publishers_job_listing_important_dates_form[publish_on(3i)]", with: vacancy.publish_on.day
    fill_in "publishers_job_listing_important_dates_form[publish_on(2i)]", with: vacancy.publish_on.month
    fill_in "publishers_job_listing_important_dates_form[publish_on(1i)]", with: vacancy.publish_on.year

    fill_in "publishers_job_listing_important_dates_form[expires_at(3i)]", with: vacancy.expires_at.day
    fill_in "publishers_job_listing_important_dates_form[expires_at(2i)]", with: vacancy.expires_at.month
    fill_in "publishers_job_listing_important_dates_form[expires_at(1i)]", with: vacancy.expires_at.year

    choose "9am", name: "publishers_job_listing_important_dates_form[expiry_time]"

    fill_in "publishers_job_listing_important_dates_form[starts_on(3i)]", with: vacancy.starts_on.day
    fill_in "publishers_job_listing_important_dates_form[starts_on(2i)]", with: vacancy.starts_on.month
    fill_in "publishers_job_listing_important_dates_form[starts_on(1i)]", with: vacancy.starts_on.year
  end

  def upload_document(form_id, input_name, filepath)
    page.attach_file(input_name, Rails.root.join(filepath))
    # Submit form on file upload without requiring Javascript driver
    form = page.find("##{form_id}")
    Capybara::RackTest::Form.new(page.driver, form.native).submit(form)
  end

  def fill_in_applying_for_the_job_form_fields(vacancy, local_authority_vacancy: false)
    return unless !local_authority_vacancy && vacancy.enable_job_applications?

    choose strip_tags(I18n.t("helpers.label.publishers_job_listing_applying_for_the_job_form.enable_job_applications_options.true"))
  end

  def fill_in_applying_for_the_job_details_form_fields(vacancy, local_authority_vacancy: false)
    if !local_authority_vacancy && vacancy.enable_job_applications?
      fill_in "publishers_job_listing_applying_for_the_job_details_form[personal_statement_guidance]", with: vacancy.personal_statement_guidance
    else
      fill_in "publishers_job_listing_applying_for_the_job_details_form[how_to_apply]", with: vacancy.how_to_apply
      fill_in "publishers_job_listing_applying_for_the_job_details_form[application_link]", with: vacancy.application_link
    end

    fill_in "publishers_job_listing_applying_for_the_job_details_form[contact_email]", with: vacancy.contact_email
    fill_in "publishers_job_listing_applying_for_the_job_details_form[contact_number]", with: vacancy.contact_number
    fill_in "publishers_job_listing_applying_for_the_job_details_form[school_visits]", with: vacancy.school_visits
  end

  def fill_in_job_summary_form_fields(vacancy)
    fill_in "publishers_job_listing_job_summary_form[job_advert]", with: vacancy.job_advert
    fill_in "publishers_job_listing_job_summary_form[about_school]", with: vacancy.about_school
  end

  def fill_in_copy_vacancy_form_fields(vacancy)
    choose I18n.t("helpers.label.publishers_job_listing_copy_vacancy_form.publish_on_day_options.another_day")

    fill_in "publishers_job_listing_copy_vacancy_form[job_title]", with: vacancy.job_title

    fill_in "publishers_job_listing_copy_vacancy_form[expires_at(3i)]", with: vacancy.expires_at&.day
    fill_in "publishers_job_listing_copy_vacancy_form[expires_at(2i)]", with: vacancy.expires_at&.strftime("%m")
    fill_in "publishers_job_listing_copy_vacancy_form[expires_at(1i)]", with: vacancy.expires_at&.year

    choose "9am", name: "publishers_job_listing_copy_vacancy_form[expiry_time]"

    fill_in "publishers_job_listing_copy_vacancy_form[publish_on(3i)]", with: vacancy.publish_on&.day
    fill_in "publishers_job_listing_copy_vacancy_form[publish_on(2i)]", with: vacancy.publish_on&.strftime("%m")
    fill_in "publishers_job_listing_copy_vacancy_form[publish_on(1i)]", with: vacancy.publish_on&.year

    choose I18n.t("helpers.legend.publishers_job_listing_important_dates_form.start_date_specific")

    fill_in "publishers_job_listing_copy_vacancy_form[starts_on(3i)]", with: vacancy.starts_on.day if vacancy.starts_on
    fill_in "publishers_job_listing_copy_vacancy_form[starts_on(2i)]", with: vacancy.starts_on.strftime("%m") if vacancy.starts_on
    fill_in "publishers_job_listing_copy_vacancy_form[starts_on(1i)]", with: vacancy.starts_on.year if vacancy.starts_on
  end

  def verify_all_vacancy_details(vacancy)
    vacancy.reload
    vacancy = VacancyPresenter.new(vacancy) unless vacancy.is_a?(VacancyPresenter)

    unless vacancy.organisation.school?
      if vacancy.organisations.many?
        expect(page).to have_content(I18n.t("organisations.job_location_heading.at_multiple_locations", organisation_type: organisation_type_basic(vacancy.organisation)))
      else
        expect(page).to have_content(I18n.t("organisations.job_location_heading.central_office"))
      end
      expect(page).to have_content(vacancy.organisations.first.name)
      expect(page).to have_content(full_address(vacancy.organisations.first))
    end

    expect(page).to have_content(vacancy.readable_job_role)
    expect(page).to have_content(strip_tags(vacancy.readable_ect_status)) if vacancy.ect_status.present?

    expect(page).to have_content(vacancy.phase&.humanize) if vacancy.phase.present?
    expect(page).to have_content(vacancy.contract_type_with_duration)
    expect(page).to have_content(vacancy.job_title)
    expect(page).to have_content(vacancy.readable_key_stages) if vacancy.key_stages.present?
    expect(page).to have_content(vacancy.readable_subjects)

    vacancy.working_patterns.each do |working_pattern|
      expect(page).to have_content(working_pattern.humanize)
    end

    expect(page).to have_content(vacancy.full_time_details) if vacancy.working_patterns.include?("full_time")
    expect(page).to have_content(vacancy.part_time_details) if vacancy.working_patterns.include?("part_time")

    expect(page).to have_content(vacancy.salary)
    expect(page.html).to include(vacancy.benefits)

    expect(page).to have_content(vacancy.publish_on.to_formatted_s.strip)
    expect(page).to have_content(vacancy.expires_at.to_date.to_formatted_s.strip)
    if vacancy.starts_on?
      expect(page).to have_content(vacancy.starts_on.to_formatted_s.strip)
    elsif vacancy.starts_asap?
      expect(page).to have_content(I18n.t("jobs.starts_asap"))
    end

    expect(page).to have_content(I18n.t("publishers.vacancies.steps.documents"))

    expect(page).to have_content(vacancy.contact_email)
    expect(page).to have_content(vacancy.contact_number)
    expect(page.html).to include(vacancy.school_visits)

    if vacancy.enable_job_applications?
      expect(page).to have_content(vacancy.personal_statement_guidance)
    else
      expect(page.html).to include(vacancy.how_to_apply)
      expect(page).to have_content(vacancy.application_link)
    end

    expect(page.html).to include(vacancy.job_advert)
    expect(page.html).to include(vacancy.about_school)
  end

  def verify_vacancy_show_page_details(vacancy)
    vacancy = VacancyPresenter.new(vacancy)
    expect(page).to have_content(vacancy.job_title)
    expect(page).to have_content(vacancy.readable_job_role)
    vacancy.subjects.each { |subject| expect(page).to have_content subject }

    expect(page).to have_content(vacancy.readable_working_patterns)

    expect(page).to have_content(vacancy.salary)
    expect(page.html).to include(vacancy.benefits)

    expect(page).to have_content(vacancy.publish_on.to_formatted_s.strip)
    expect(page).to have_content(vacancy.expires_at.to_date.to_formatted_s.strip)
    if vacancy.starts_on?
      expect(page).to have_content(vacancy.starts_on.to_formatted_s.strip)
    elsif vacancy.starts_asap?
      expect(page).to have_content(I18n.t("jobs.starts_asap"))
    end

    expect(page.html).to include(vacancy.school_visits)
    expect(page.html).to include(vacancy.how_to_apply) unless vacancy.enable_job_applications?

    expect(page.html).to include(vacancy.job_advert)
    expect(page.html).to include(vacancy.about_school)

    expect(page).to have_content(I18n.t("publishers.vacancies.steps.documents")) if vacancy.supporting_documents.any?

    if vacancy.enable_job_applications?
      expect(page).to have_link(I18n.t("jobseekers.job_applications.apply"), href: new_jobseekers_job_job_application_path(vacancy.id))
    else
      expect(page).to have_link(I18n.t("jobs.apply"), href: new_job_interest_path(vacancy.id))
    end
  end

  def expect_schema_property_to_match_value(key, value)
    expect(page).to have_selector("meta[itemprop='#{key}'][content='#{value}']")
  end

  def vacancy_json_ld(vacancy)
    {
      "@context": "http://schema.org",
      "@type": "JobPosting",
      title: vacancy.job_title,
      jobBenefits: vacancy.benefits,
      datePosted: vacancy.publish_on.to_time.iso8601,
      description: vacancy.job_advert,
      occupationalCategory: vacancy.job_role,
      directApply: vacancy.enable_job_applications,
      employmentType: vacancy.working_patterns_for_job_schema,
      industry: "Education",
      jobLocation: {
        "@type": "Place",
        address: {
          "@type": "PostalAddress",
          addressLocality: vacancy.organisation.town,
          addressRegion: vacancy.organisation.region,
          streetAddress: vacancy.organisation.address,
          postalCode: vacancy.organisation.postcode,
          addressCountry: "GB",
        },
      },
      url: job_url(vacancy),
      hiringOrganization: {
        "@type": "Organization",
        name: vacancy.organisation_name,
        identifier: vacancy.organisation.urn,
        description: vacancy.about_school,
      },
      validThrough: vacancy.expires_at.to_time.iso8601,
    }
  end

  def create_published_vacancy(*args, **kwargs)
    build(:vacancy, :past_publish, *args, **kwargs).tap do |vacancy|
      yield vacancy if block_given?
      vacancy.save(validate: false) # Validation prevents publishing on a past date
    end
  end
end
