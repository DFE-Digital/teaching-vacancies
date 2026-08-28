require "rails_helper"

RSpec.describe "Creating a vacancy as an FE college" do
  let(:college) { create(:college) }
  let(:publisher) { create(:publisher, organisations: [college]) }
  let(:created_vacancy) { Vacancy.order(:created_at).last }

  before do
    login_publisher(publisher: publisher, organisation: college)
    visit organisation_jobs_with_type_path
    click_on I18n.t("buttons.create_job")
    click_on I18n.t("buttons.create_job")
  end

  after { logout }

  def fill_in_job_details_through_important_dates(vacancy)
    expect(publisher_job_title_page).to be_displayed
    publisher_job_title_page.fill_in_and_submit_form(vacancy.job_title)

    # Confirm job address is shown for FE colleges only
    expect(publisher_confirm_job_address_page).to be_displayed
    publisher_confirm_job_address_page.fill_in_and_submit_form(
      line1: "10 Campus Road",
      town: "Brighton",
      postcode: "BN1 1AA",
    )

    # Job role page shows Teacher for teaching roles, and the full support role list (school-style plus FE-specific), but not other teaching roles
    expect(publisher_job_role_page).to be_displayed
    expect(page).to have_content(I18n.t("helpers.label.publishers_job_listing_job_role_form.teaching_job_role_options.teacher"))
    expect(page).to have_content(I18n.t("helpers.label.publishers_job_listing_job_role_form.support_job_role_options.leadership_and_management"))
    expect(page).to have_content(I18n.t("helpers.label.publishers_job_listing_job_role_form.support_job_role_options.teaching_assistant"))
    expect(page).to have_no_content(I18n.t("helpers.label.publishers_job_listing_job_role_form.teaching_job_role_options.headteacher"))
    publisher_job_role_page.fill_in_and_submit_form(vacancy.job_roles.first)

    # education_phases and key stages are skipped for FE colleges
    expect(publisher_education_phase_page).not_to be_displayed
    expect(publisher_key_stage_page).not_to be_displayed

    expect(publisher_subjects_page).to be_displayed
    publisher_subjects_page.fill_in_and_submit_form(vacancy.subjects)

    expect(publisher_contract_information_page).to be_displayed
    publisher_contract_information_page.fill_in_and_submit_form(vacancy)

    expect(publisher_start_date_page).to be_displayed
    publisher_start_date_page.fill_in_and_submit_form(vacancy.starts_on)

    expect(publisher_pay_package_page).to be_displayed
    publisher_pay_package_page.fill_in_and_submit_form(vacancy)

    expect(publisher_about_the_role_page).to be_displayed
    click_on I18n.t("buttons.save_and_continue")

    expect(publisher_about_the_role_page).to be_displayed
    expect(publisher_about_the_role_page.errors.map(&:text)).to eq([
      I18n.t("about_the_role_errors.fe_role_qts_required.inclusion"),
      I18n.t("about_the_role_errors.ect_status.inclusion"),
      I18n.t("about_the_role_errors.skills_and_experience.blank"),
      I18n.t("about_the_role_errors.school_offer.blank", organisation: "college"),
      I18n.t("about_the_role_errors.further_details_provided.inclusion"),
      I18n.t("about_the_role_errors.flexi_working_details_provided.inclusion"),
    ])
    publisher_about_the_role_page.fill_in_and_submit_form(vacancy)

    expect(publisher_school_visits_page).to be_displayed
    publisher_school_visits_page.fill_in_and_submit_form(vacancy.school_visits)

    expect(publisher_visa_sponsorship_page).to be_displayed
    publisher_visa_sponsorship_page.fill_in_and_submit_form(vacancy.visa_sponsorship_available)

    expect(publisher_important_dates_page).to be_displayed
    publisher_important_dates_page.fill_in_and_submit_form(publish_on: vacancy.publish_on, expires_at: vacancy.expires_at)
  end

  context "when applying via website" do
    let(:vacancy) do
      build(:vacancy,
            :ect_suitable,
            :secondary,
            :apply_via_website,
            publish_on: Date.current,
            organisations: [college])
    end

    it "shows the confirm job address step after job title, restricts job roles, and shows the address on the review page" do
      fill_in_job_details_through_important_dates(vacancy)

      # applying_for_the_job is skipped; how_to_receive_applications is shown instead
      expect(publisher_applying_for_the_job_page).not_to be_displayed
      expect(publisher_how_to_receive_applications_page).to be_displayed
      publisher_how_to_receive_applications_page.fill_in_and_submit_form(vacancy.receive_applications)

      expect(publisher_application_link_page).to be_displayed
      publisher_application_link_page.fill_in_and_submit_form(vacancy.application_link)

      expect(publisher_include_additional_documents_page).to be_displayed
      publisher_include_additional_documents_page.fill_in_and_submit_form(vacancy.include_additional_documents)

      expect(publisher_contact_details_page).to be_displayed
      publisher_contact_details_page.fill_in_and_submit_form(vacancy.contact_email, vacancy.contact_number)

      expect(publisher_confirm_contact_details_page).to be_displayed
      publisher_confirm_contact_details_page.fill_in_and_submit_form

      # Review page — campus address row shows the custom address entered above
      expect(page).to have_current_path(organisation_job_review_path(created_vacancy.id), ignore_query: true)
      expect(page).to have_css("#job_location")
      expect(page).to have_content("10 Campus Road, Brighton, BN1 1AA")

      # FE college should have a Change link on the Locations row linking to confirm_job_address
      within("#job_location") do
        expect(page).to have_link(I18n.t("buttons.change"), href: /confirm_job_address/)
      end

      within("#receive_applications") do
        expect(page).to have_content(I18n.t("helpers.label.publishers_job_listing_how_to_receive_applications_form.receive_applications_options.website"))
      end

      within("#application_link") do
        expect(page).to have_content(vacancy.application_link)
      end
    end
  end

  context "when uploading an application form" do
    let(:vacancy) do
      build(:vacancy,
            :ect_suitable,
            :secondary,
            publish_on: Date.current,
            organisations: [college])
    end

    it "routes through application_form and anonymise_applications steps" do
      fill_in_job_details_through_important_dates(vacancy)

      # applying_for_the_job is skipped; how_to_receive_applications is shown instead
      expect(publisher_applying_for_the_job_page).not_to be_displayed
      expect(publisher_how_to_receive_applications_page).to be_displayed
      publisher_how_to_receive_applications_page.fill_in_and_submit_form("uploaded_form")

      expect(publisher_application_form_page).to be_displayed
      page.attach_file("publishers_job_listing_application_form_form[application_form]", Rails.root.join("spec/fixtures/files/blank_job_spec.pdf"))
      click_on I18n.t("buttons.save_and_continue")

      expect(publisher_anonymise_applications_page).to be_displayed
      publisher_anonymise_applications_page.anonymous_option.click
      click_on I18n.t("buttons.save_and_continue")

      expect(publisher_include_additional_documents_page).to be_displayed
      publisher_include_additional_documents_page.fill_in_and_submit_form(vacancy.include_additional_documents)

      expect(publisher_contact_details_page).to be_displayed
      publisher_contact_details_page.fill_in_and_submit_form(vacancy.contact_email, vacancy.contact_number)

      expect(publisher_confirm_contact_details_page).to be_displayed
      publisher_confirm_contact_details_page.fill_in_and_submit_form

      expect(page).to have_current_path(organisation_job_review_path(created_vacancy.id), ignore_query: true)

      within("#receive_applications") do
        expect(page).to have_content(I18n.t("helpers.label.publishers_job_listing_how_to_receive_applications_form.receive_applications_options.uploaded_form"))
      end

      within("#uploaded_form") do
        expect(page).to have_content("blank_job_spec.pdf")
      end

      within("#anonymise_applications") do
        expect(page).to have_content("Yes")
      end
    end
  end
end
