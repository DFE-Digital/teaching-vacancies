module VacancyHelpers
  def change_job_locations(_vacancy, organisations)
    click_review_page_change_link(section: "job_details", row: "job_location")
    fill_in_job_location_form_fields(organisations)
  end

  def fill_in_job_location_form_fields(organisations)
    within ".govuk-checkboxes" do
      all("label").each do |label|
        uncheck(label.text)
      end
    end
    organisations.each do |organisation|
      check(organisation.school? ? organisation.name : I18n.t("organisations.job_location_heading.central_office"))
    end
  end

  def fill_in_job_role_form_fields(job_role)
    checkbox_label = I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.#{job_role}")
    find("label", text: checkbox_label, visible: true).click
  end

  def fill_in_education_phases_form_fields(vacancy)
    check I18n.t("helpers.label.publishers_job_listing_education_phases_form.phases_options.#{vacancy.phases.first}")
  end

  def fill_in_job_title_form_fields(job_title)
    fill_in "publishers_job_listing_job_title_form[job_title]", with: job_title
  end

  def fill_in_key_stages_form_fields(key_stages)
    key_stages.each do |key_stage|
      check I18n.t("helpers.label.publishers_job_listing_key_stages_form.key_stages_options.#{key_stage}")
    end
  end

  def fill_in_subjects_form_fields(subjects)
    subjects&.each do |subject|
      check subject,
            name: "publishers_job_listing_subjects_form[subjects][]",
            visible: false
    end
  end

  def fill_in_pay_package_form_fields(vacancy)
    if vacancy.contract_type == "casual"
      check I18n.t("helpers.label.publishers_job_listing_pay_package_form.salary_types_options.hourly_rate")
      fill_in "publishers_job_listing_pay_package_form[salary]", with: vacancy.hourly_rate
    else
      check I18n.t("helpers.label.publishers_job_listing_pay_package_form.salary_types_options.full_time")
      fill_in "publishers_job_listing_pay_package_form[salary]", with: vacancy.salary

      if vacancy.working_patterns.include? "part_time"
        check I18n.t("helpers.label.publishers_job_listing_pay_package_form.salary_types_options.part_time")
        fill_in "publishers_job_listing_pay_package_form[actual_salary]", with: vacancy.actual_salary
      end

      check I18n.t("helpers.label.publishers_job_listing_pay_package_form.salary_types_options.pay_scale")
      fill_in "publishers_job_listing_pay_package_form[pay_scale]", with: vacancy.pay_scale
    end

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

  def fill_in_start_date_form_fields(starts_on = 35.days.from_now)
    choose I18n.t("helpers.legend.publishers_job_listing_start_date_form.start_date_specific")

    fill_in "publishers_job_listing_start_date_form[starts_on(3i)]", with: starts_on.day
    fill_in "publishers_job_listing_start_date_form[starts_on(2i)]", with: starts_on.month
    fill_in "publishers_job_listing_start_date_form[starts_on(1i)]", with: starts_on.year
  end

  def fill_in_applying_for_the_job_form_fields(vacancy, local_authority_vacancy: false)
    return unless !local_authority_vacancy && vacancy.enable_job_applications?

    find('label[for="publishers-job-listing-applying-for-the-job-form-application-form-type-no-religion-field"]').click
  end

  def fill_in_applying_for_the_job_disable_job_applications
    choose strip_tags(I18n.t("helpers.label.publishers_job_listing_applying_for_the_job_form.application_form_type_options.other"))
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

  def fill_in_visa_sponsorship_form_fields(vacancy)
    choose I18n.t("helpers.label.publishers_job_listing_visa_sponsorship_form.visa_sponsorship_available_options.#{vacancy.visa_sponsorship_available}")
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

    within ".flexi_working_details_provided" do
      choose I18n.t("helpers.label.publishers_job_listing_about_the_role_form.flexi_working_details_provided_options.#{vacancy.flexi_working_details_provided}")
    end
    fill_in "publishers_job_listing_about_the_role_form[flexi_working]", with: vacancy.flexi_working

    within ".further-details-provided-radios" do
      choose I18n.t("helpers.label.publishers_job_listing_about_the_role_form.further_details_provided_options.#{vacancy.further_details_provided}")
      fill_in "publishers_job_listing_about_the_role_form[further_details]", with: vacancy.further_details
    end
  end

  def fill_in_include_additional_documents_form_fields(include_additional_documents)
    choose I18n.t("helpers.label.publishers_job_listing_include_additional_documents_form.include_additional_documents_options.#{include_additional_documents}")
  end

  def verify_vacancy_show_page_details(vacancy)
    vacancy = VacancyPresenter.new(vacancy)
    expect(page).to have_content(vacancy.job_title)
    readable_job_roles = vacancy.job_roles.map { |role| I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.#{role}") }
    readable_job_roles.each do |role|
      expect(page).to have_content(role)
    end
    sponsorship_text = vacancy.visa_sponsorship_available ? "Skilled Worker visas can be sponsored" : "Visas cannot be sponsored"
    expect(page).to have_content(sponsorship_text)
    vacancy.subjects.each { |subject| expect(page).to have_content subject }

    expect(page).to have_content(vacancy.readable_working_patterns)
    expect(page).to have_content(vacancy.contract_type_with_duration)

    expect(page).to have_content(vacancy.salary)
    expect(page.html).to include(vacancy.benefits_details) if vacancy.benefits?

    expect(page).to have_content(vacancy.publish_on.to_formatted_s.strip)
    expect(page).to have_content(vacancy.expires_at.to_date.to_formatted_s.strip)
    if vacancy.start_date_type == "specific_date"
      expect(page).to have_content(vacancy.starts_on.to_formatted_s.strip)
    elsif vacancy.start_date_type == "asap"
      expect(page).to have_content("As soon as possible")
    end

    expect(page.html).to include(vacancy.skills_and_experience)
    expect(page.html).to include(vacancy.school_offer)

    if vacancy.organisation&.safeguarding_information.present?
      expect(page.html).to include(vacancy.organisation.safeguarding_information)
    elsif vacancy.safeguarding_information_provided
      expect(page.html).to include(vacancy.safeguarding_information)
    end

    expect(page.html).to include(vacancy.further_details)

    expect(page).to have_content(I18n.t("publishers.vacancies.steps.documents")) if vacancy.supporting_documents.any?

    if vacancy.enable_job_applications?
      sponsorship_inset_text = vacancy.visa_sponsorship_available ? "Skilled Worker visas can be sponsored." : "Visas cannot be sponsored"
      expect(page).to have_content sponsorship_inset_text
      expect(page).to have_link(I18n.t("jobseekers.job_applications.apply.apply"), href: new_jobseekers_job_job_application_path(vacancy.id))
    else
      expect(page).to have_content(I18n.t("jobs.apply_via_website"))
      expect(page).to have_link(I18n.t("jobs.apply"), href: vacancy.application_link)
    end
  end

  def create_published_vacancy(*, **)
    build(:vacancy, :past_publish, *, **).tap do |vacancy|
      yield vacancy if block_given?
      vacancy.save(validate: false) # Validation prevents publishing on a past date
    end
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

  def expect_correct_pay_package_options(vacancy)
    if vacancy.contract_type == "casual"
      expect(page).not_to have_content("Full-time equivalent salary")
      expect(page).not_to have_content("Actual salary")
      expect(page).not_to have_content("Pay scale")
      expect(page).to have_content("Hourly rate of pay")
    else
      expect(page).to have_content("Full-time equivalent salary")
      expect(page).to have_content("Pay scale")
      expect(page).to have_content("Hourly rate of pay")
      if vacancy.working_patterns.include? "part_time"
        expect(page).to have_content("Actual salary")
      else
        expect(page).not_to have_content("Actual salary")
      end
    end
  end

  def fill_in_forms_until_applying_for(vacancy)
    click_on I18n.t("buttons.create_job")
    expect(page).to have_content(I18n.t("jobs.create_job_caption", step: 1, total: 4))
    expect(page).to have_current_path(organisation_job_build_path(created_vacancy.id, :job_title), ignore_query: true)

    fill_in_job_title_form_fields(vacancy.job_title)
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_current_path(organisation_job_build_path(created_vacancy.id, :job_role), ignore_query: true)

    fill_in_job_role_form_fields(vacancy.job_roles.first)
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_current_path(organisation_job_build_path(created_vacancy.id, :key_stages), ignore_query: true)

    fill_in_key_stages_form_fields(vacancy.key_stages_for_phases)
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_current_path(organisation_job_build_path(created_vacancy.id, :subjects), ignore_query: true)

    fill_in_subjects_form_fields(vacancy.subjects)
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_current_path(organisation_job_build_path(created_vacancy.id, :contract_information), ignore_query: true)

    publisher_contract_information_page.fill_in_and_submit_form(vacancy)
    click_on I18n.t("buttons.save_and_continue")

    expect(page).to have_current_path(organisation_job_build_path(created_vacancy.id, :start_date), ignore_query: true)
    fill_in_start_date_form_fields(vacancy.starts_on)
    click_on I18n.t("buttons.save_and_continue")

    expect(page).to have_current_path(organisation_job_build_path(created_vacancy.id, :pay_package), ignore_query: true)
    fill_in_pay_package_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")

    expect(page).to have_current_path(organisation_job_build_path(created_vacancy.id, :about_the_role), ignore_query: true)
    fill_in_about_the_role_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")

    expect(page).to have_current_path(organisation_job_build_path(created_vacancy.id, :include_additional_documents), ignore_query: true)
    fill_in_include_additional_documents_form_fields(vacancy.include_additional_documents)
    click_on I18n.t("buttons.save_and_continue")

    expect(page).to have_current_path(organisation_job_build_path(created_vacancy.id, :school_visits), ignore_query: true)
    fill_in_school_visits_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")

    expect(page).to have_current_path(organisation_job_build_path(created_vacancy.id, :visa_sponsorship), ignore_query: true)
    fill_in_visa_sponsorship_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")

    expect(page).to have_current_path(organisation_job_build_path(created_vacancy.id, :important_dates), ignore_query: true)
    fill_in_important_dates_form_fields(vacancy)
    click_on I18n.t("buttons.save_and_continue")

    expect(page).to have_current_path(organisation_job_build_path(created_vacancy.id, :applying_for_the_job), ignore_query: true)
  end
end
