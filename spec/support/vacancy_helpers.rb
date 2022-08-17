module VacancyHelpers
  def change_job_locations(vacancy, organisations)
    vacancy.organisations = organisations
    click_review_page_change_link(section: "job_details", row: "job_location")
    fill_in_job_location_form_fields(vacancy)
  end

  def fill_in_job_location_form_fields(vacancy)
    vacancy.organisations.each do |organisation|
      check(organisation.school? ? organisation.name : I18n.t("organisations.job_location_heading.central_office"))
    end
  end

  def fill_in_job_role_form_fields(vacancy)
    choose I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.#{vacancy.job_role}")
  end

  def fill_in_education_phases_form_fields(vacancy)
    check I18n.t("helpers.label.publishers_job_listing_education_phases_form.phases_options.#{vacancy.phases.first}")
  end

  def fill_in_job_title_form_fields(vacancy)
    fill_in "publishers_job_listing_job_title_form[job_title]", with: vacancy.job_title
  end

  def fill_in_key_stages_form_fields(vacancy)
    vacancy.key_stages_for_phases.each do |key_stage|
      check I18n.t("helpers.label.publishers_job_listing_key_stages_form.key_stages_options.#{key_stage}")
    end
  end

  def fill_in_subjects_form_fields(vacancy)
    vacancy.subjects&.each do |subject|
      check subject,
            name: "publishers_job_listing_subjects_form[subjects][]",
            visible: false
    end
  end

  def fill_in_contract_type_form_fields(vacancy)
    choose I18n.t("helpers.label.publishers_job_listing_contract_type_form.contract_type_options.#{vacancy.contract_type}")
  end

  def fill_in_working_patterns_form_fields(vacancy)
    vacancy.working_patterns.each do |working_pattern|
      check Vacancy.human_attribute_name(working_pattern.to_s), name: "publishers_job_listing_working_patterns_form[working_patterns][]"
    end

    fill_in "publishers_job_listing_working_patterns_form[full_time_details]", with: vacancy.full_time_details if vacancy.working_patterns.include?("full_time")
    fill_in "publishers_job_listing_working_patterns_form[part_time_details]", with: vacancy.part_time_details if vacancy.working_patterns.include?("part_time")
  end

  def fill_in_pay_package_form_fields(vacancy)
    check I18n.t("helpers.label.publishers_job_listing_pay_package_form.salary_types_options.full_time")
    fill_in "publishers_job_listing_pay_package_form[salary]", with: vacancy.salary

    if vacancy.working_patterns.include? "part_time"
      check I18n.t("helpers.label.publishers_job_listing_pay_package_form.salary_types_options.part_time")
      fill_in "publishers_job_listing_pay_package_form[actual_salary]", with: vacancy.actual_salary
    end

    check I18n.t("helpers.label.publishers_job_listing_pay_package_form.salary_types_options.pay_scale")
    fill_in "publishers_job_listing_pay_package_form[pay_scale]", with: vacancy.pay_scale

    choose I18n.t("helpers.label.publishers_job_listing_pay_package_form.benefits_options.true")
    fill_in "publishers_job_listing_pay_package_form[benefits_details]", with: vacancy.benefits_details
  end

  def fill_in_important_dates_form_fields(vacancy)
    choose I18n.t("helpers.label.publishers_job_listing_important_dates_form.publish_on_day_options.another_day")

    fill_in "publishers_job_listing_important_dates_form[publish_on(3i)]", with: vacancy.publish_on.day
    fill_in "publishers_job_listing_important_dates_form[publish_on(2i)]", with: vacancy.publish_on.month
    fill_in "publishers_job_listing_important_dates_form[publish_on(1i)]", with: vacancy.publish_on.year

    fill_in "publishers_job_listing_important_dates_form[expires_at(3i)]", with: vacancy.expires_at.day
    fill_in "publishers_job_listing_important_dates_form[expires_at(2i)]", with: vacancy.expires_at.month
    fill_in "publishers_job_listing_important_dates_form[expires_at(1i)]", with: vacancy.expires_at.year

    choose "9am", name: "publishers_job_listing_important_dates_form[expiry_time]"
  end

  def fill_in_start_date_form_fields(vacancy)
    choose I18n.t("helpers.legend.publishers_job_listing_start_date_form.start_date_specific")

    fill_in "publishers_job_listing_start_date_form[starts_on(3i)]", with: vacancy.starts_on.day
    fill_in "publishers_job_listing_start_date_form[starts_on(2i)]", with: vacancy.starts_on.month
    fill_in "publishers_job_listing_start_date_form[starts_on(1i)]", with: vacancy.starts_on.year
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

  def fill_in_how_to_receive_applications_form_fields(vacancy)
    choose I18n.t("helpers.label.publishers_job_listing_how_to_receive_applications_form.receive_applications_options.#{vacancy.receive_applications}")
  end

  def fill_in_application_link_form_fields(vacancy)
    fill_in "publishers_job_listing_application_link_form[application_link]", with: vacancy.application_link
  end

  def fill_in_school_visits_form_fields(vacancy)
    choose I18n.t("helpers.label.publishers_job_listing_school_visits_form.school_visits_options.#{vacancy.school_visits}")
  end

  def fill_in_contact_details_form_fields(vacancy)
    choose I18n.t("helpers.label.publishers_job_listing_contact_details_form.contact_email_options.other")
    fill_in "publishers_job_listing_contact_details_form[other_contact_email]", with: vacancy.contact_email

    choose I18n.t("helpers.label.publishers_job_listing_contact_details_form.contact_number_provided_options.#{vacancy.contact_number_provided}")
    fill_in "publishers_job_listing_contact_details_form[contact_number]", with: vacancy.contact_number
  end

  def fill_in_about_the_role_form_fields(vacancy)
    within ".ect-status-radios" do
      choose I18n.t("helpers.label.publishers_job_listing_about_the_role_form.ect_status_options.#{vacancy.ect_status}")
    end

    fill_in "publishers_job_listing_about_the_role_form[skills_and_experience]", with: vacancy.skills_and_experience
    fill_in "publishers_job_listing_about_the_role_form[school_offer]", with: vacancy.school_offer

    within ".safeguarding-information-provided-radios" do
      choose I18n.t("helpers.label.publishers_job_listing_about_the_role_form.safeguarding_information_provided_options.#{vacancy.safeguarding_information_provided}")
      fill_in "publishers_job_listing_about_the_role_form[safeguarding_information]", with: vacancy.safeguarding_information
    end

    within ".further-details-provided-radios" do
      choose I18n.t("helpers.label.publishers_job_listing_about_the_role_form.further_details_provided_options.#{vacancy.further_details_provided}")
      fill_in "publishers_job_listing_about_the_role_form[further_details]", with: vacancy.further_details
    end
  end

  def fill_in_include_additional_documents_form_fields(vacancy)
    choose I18n.t("helpers.label.publishers_job_listing_include_additional_documents_form.include_additional_documents_options.#{vacancy.include_additional_documents}")
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

    verify_job_locations(vacancy)

    expect(page).to have_content(vacancy.readable_job_role)
    expect(page).to have_content(vacancy.phase&.humanize) if vacancy.phase.present?
    expect(page).to have_content(vacancy.job_title)
    expect(page).to have_content(vacancy.readable_key_stages) if vacancy.key_stages.present?
    expect(page).to have_content(vacancy.readable_subjects) if vacancy.subjects.any?
    expect(page).to have_content(vacancy.contract_type_with_duration)

    vacancy.working_patterns.each do |working_pattern|
      expect(page).to have_content(working_pattern.humanize)
    end

    expect(page).to have_content(vacancy.full_time_details) if vacancy.working_patterns.include?("full_time")
    expect(page).to have_content(vacancy.part_time_details) if vacancy.working_patterns.include?("part_time")

    expect(page).to have_content(vacancy.salary) if vacancy.salary_types.include?("full_time")
    expect(page).to have_content(vacancy.actual_salary) if vacancy.salary_types.include?("part_time")
    expect(page).to have_content(vacancy.pay_scale) if vacancy.salary_types.include?("pay_scale")

    expect(page.html).to include(vacancy.benefits_details) if vacancy.benefits?

    expect(page).to have_content(vacancy.publish_on.to_formatted_s.strip)
    expect(page).to have_content(vacancy.expires_at.to_date.to_formatted_s.strip)
    if vacancy.start_date_type == "specific_date"
      expect(page).to have_content(vacancy.starts_on.to_formatted_s.strip)
    end

    if vacancy.enable_job_applications?
      expect(page).to have_content(vacancy.personal_statement_guidance)
    else
      expect(page.html).to include(vacancy.receive_applications.humanize)
      expect(page).to have_content(vacancy.application_link) if vacancy.receive_applications == "website"
      expect(page).to have_content(vacancy.application_email) if vacancy.receive_applications == "email"
    end

    expect(page).to have_content(I18n.t("jobs.school_visits"))
    expect(page).to have_content(vacancy.contact_email)
    expect(page).to have_content(vacancy.contact_number)

    expect(page).to have_content(strip_tags(vacancy.readable_ect_status)) if vacancy.ect_status.present?
    expect(page).to have_content(vacancy.skills_and_experience)
    expect(page).to have_content(vacancy.school_offer)
    expect(page).to have_content(vacancy.safeguarding_information) if vacancy.safeguarding_information_provided
    expect(page).to have_content(vacancy.further_details) if vacancy.further_details_provided
    expect(page).to have_content(I18n.t("jobs.include_additional_documents"))

    return unless vacancy.include_additional_documents?

    expect(page).to have_content(I18n.t("jobs.additional_documents"))
  end

  def verify_vacancy_show_page_details(vacancy)
    vacancy = VacancyPresenter.new(vacancy)
    expect(page).to have_content(vacancy.job_title)
    expect(page).to have_content(vacancy.readable_job_role)
    vacancy.subjects.each { |subject| expect(page).to have_content subject }

    expect(page).to have_content(vacancy.readable_working_patterns)
    expect(page).to have_content(vacancy.contract_type_with_duration)

    expect(page).to have_content(vacancy.salary)
    expect(page.html).to include(vacancy.benefits_details) if vacancy.benefits?

    expect(page).to have_content(vacancy.publish_on.to_formatted_s.strip)
    expect(page).to have_content(vacancy.expires_at.to_date.to_formatted_s.strip)
    if vacancy.starts_on?
      expect(page).to have_content(vacancy.starts_on.to_formatted_s.strip)
    end

    expect(page.html).to include(vacancy.skills_and_experience)
    expect(page.html).to include(vacancy.school_offer)
    expect(page.html).to include(vacancy.safeguarding_information)
    expect(page.html).to include(vacancy.further_details)

    expect(page).to have_content(I18n.t("publishers.vacancies.steps.documents")) if vacancy.supporting_documents.any?

    if vacancy.enable_job_applications?
      expect(page).to have_link(I18n.t("jobseekers.job_applications.apply"), href: new_jobseekers_job_job_application_path(vacancy.id))
    else
      expect(page).to have_content(I18n.t("jobs.apply_via_website"))
      expect(page).to have_link(I18n.t("jobs.apply"), href: vacancy.application_link)
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
      jobBenefits: vacancy.benefits_details,
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

  def has_published_vacancy_review_heading?(vacancy)
    expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.status_tag.published"))
    expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.inset_text.published", publish_date: format_date(vacancy.publish_on), expiry_time: format_time_to_datetime_at(vacancy.expires_at)))
    expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.view"))
    expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.copy"))
    expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.close_early"))
    expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.extend_closing_date"))
  end

  def has_complete_draft_vacancy_review_heading?(vacancy)
    expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.status_tag.draft"))
    if vacancy.publish_on.future?
      expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.inset_text.scheduled_complete_draft"))
      expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.scheduled_complete_draft"))
    else
      expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.inset_text.complete_draft"))
      expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.publish"))
    end
    expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.preview"))
    expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.copy"))
    expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.delete"))
  end

  def has_incomplete_draft_vacancy_review_heading?(vacancy)
    expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.status_tag.draft"))
    expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.inset_text.incomplete_draft", publish_date: format_date(vacancy.publish_on), expiry_time: format_time_to_datetime_at(vacancy.expires_at)))
    expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.complete"))
    expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.copy"))
    expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.delete"))
  end

  def has_scheduled_vacancy_review_heading?(vacancy)
    expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.status_tag.scheduled"))
    expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.inset_text.scheduled", publish_date: format_date(vacancy.publish_on), expiry_time: format_time_to_datetime_at(vacancy.expires_at)))
    expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.preview"))
    expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.copy"))
    expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.delete"))
    expect(page).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.convert_to_draft"))
  end

  def verify_job_locations(vacancy)
    vacancy.organisations.each do |organisation|
      if organisation.school?
        expect(page).to have_content("#{organisation.name}, #{full_address(organisation)}")
      else
        expect(page).to have_content("#{I18n.t('organisations.job_location_heading.central_office')}, #{full_address(organisation)}")
      end
    end
  end
end
