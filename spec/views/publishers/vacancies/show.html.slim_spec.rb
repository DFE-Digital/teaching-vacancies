require "rails_helper"

RSpec.describe "publishers/vacancies/show" do
  let(:school) { build_stubbed(:school, phase: :secondary) }
  let(:vacancy_presenter) { VacancyPresenter.new(vacancy) }
  let(:blank_application_text) { t("buttons.download_blank_application") }

  before do
    assign :vacancy, vacancy_presenter
    assign :current_organisation, school
    assign :step_process, Publishers::Vacancies::VacancyStepProcess.new(:review, vacancy: vacancy, organisation: school)
    assign :next_invalid_step, next_invalid_step
    render
  end

  context "when published" do
    let(:vacancy) { build_stubbed(:vacancy, :secondary) }
    let(:next_invalid_step) { nil }

    it "has blank application download button" do
      expect(rendered).to have_link(blank_application_text, href: organisation_job_form_preview_path(vacancy.id, :blank))
    end

    it "doesn't have publish buttons" do
      expect(rendered).to have_no_content("Publish job listing")
    end

    it "shows all vacancy information" do
      vacancy.organisations.each do |organisation|
        expect(rendered).to have_content("#{organisation.name}, #{full_address(organisation)}")
      end

      expect(rendered).to have_content(vacancy_presenter.readable_job_roles)
      expect(rendered).to have_content(vacancy.job_title)
      expect(rendered).to have_content(vacancy_presenter.readable_key_stages)
      expect(rendered).to have_content(vacancy_presenter.readable_subjects)
      expect(rendered).to have_content(vacancy_presenter.contract_type_with_duration)

      vacancy.working_patterns.each do |working_pattern|
        expect(rendered).to have_content(/#{working_pattern.humanize}/i)
      end
      expect(rendered).to have_content(vacancy.working_patterns_details)

      expect(rendered).to have_content(vacancy.salary)
      expect(rendered).to have_content(vacancy.actual_salary)
      expect(rendered).to have_content(vacancy.pay_scale)

      expect(rendered).to have_content(strip_tags(vacancy.benefits_details))

      expect(rendered).to have_content(vacancy.publish_on.to_fs.strip)
      expect(rendered).to have_content(vacancy.expires_at.to_date.to_fs.strip)
      expect(rendered).to have_content(vacancy.starts_on.to_fs.strip)

      unless vacancy.enable_job_applications?
        expect(rendered).to include(I18n.t("helpers.label.publishers_job_listing_how_to_receive_applications_form.receive_applications_options.#{vacancy.receive_applications}"))
        expect(rendered).to have_content(vacancy.application_link) if vacancy.receive_applications == "website"
        expect(rendered).to have_content(vacancy.application_email) if vacancy.receive_applications == "email"
      end

      expect(rendered).to have_content(I18n.t("jobs.school_visits"))
      expect(rendered).to have_content(vacancy.contact_email)
      expect(rendered).to have_content(vacancy.contact_number)

      expect(rendered).to have_content(strip_tags(vacancy_presenter.readable_ect_status)) if vacancy.ect_status.present?
      expect(rendered).to have_content(vacancy.skills_and_experience)
      expect(rendered).to have_content(vacancy.school_offer)
      expect(rendered).to have_content(vacancy.flexi_working)

      expect(rendered).to have_content(vacancy.organisation.safeguarding_information)

      expect(rendered).to have_content(vacancy.further_details) if vacancy.further_details_provided
      expect(rendered).to have_content(I18n.t("jobs.include_additional_documents"))
    end

    it "shows heading information" do
      expect(rendered).to have_content(I18n.t("publishers.vacancies.show.heading_component.status_tag.published"))
      expect(rendered).to have_content(I18n.t("publishers.vacancies.show.heading_component.inset_text.published", publish_date: format_date(vacancy.publish_on), expiry_time: format_time_to_datetime_at(vacancy.expires_at)))
      expect(rendered).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.view"))
      expect(rendered).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.copy"))
      expect(rendered).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.close_early"))
      expect(rendered).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.extend_closing_date"))
    end
  end

  context "when published with documents" do
    # TODO: can't currently stub a vacancy with documents
    let(:vacancy) { create(:vacancy, :secondary, :with_supporting_documents) }
    let(:next_invalid_step) { nil }

    it "shows documents" do
      expect(rendered).to have_content(I18n.t("jobs.additional_documents"))
    end
  end

  context "when draft" do
    let(:job_details) { rendered.html.css("#job_details") }
    let(:about_the_role) { rendered.html.css("#about_the_role") }
    let(:important_dates) { rendered.html.css("#important_dates") }
    let(:application_process) { rendered.html.css("#application_process") }

    context "with a minimal vacancy" do
      let(:vacancy) { build_stubbed(:draft_vacancy, :without_contract_details, enable_job_applications: false) }
      let(:next_invalid_step) { :job_role }

      it "does not have a blank application download button" do
        expect(rendered).to have_no_link(blank_application_text)
      end

      it "show first section as in-progress, and the rest as not startable" do
        expect(job_details).to have_content "In progress"
        expect(about_the_role).to have_content "Cannot start yet"
        expect(important_dates).to have_content "Cannot start yet"
        expect(application_process).to have_content "Cannot start yet"
      end
    end

    context "with just a complete first section" do
      let(:vacancy) { build_stubbed(:draft_vacancy, :with_contract_details) }
      let(:next_invalid_step) { :working_patterns }

      it "show first section as complete" do
        expect(job_details).to have_content "Completed"
        expect(about_the_role).to have_content "Not started"
        expect(important_dates).to have_content "Cannot start yet"
        expect(application_process).to have_content "Cannot start yet"
      end
    end

    context "with a plain draft" do
      let(:vacancy) { build_stubbed(:draft_vacancy, :secondary, organisations: [school]) }
      let(:next_invalid_step) { nil }

      it "has publish buttons" do
        expect(rendered).to have_content("Publish job listing")
      end

      it "indicates that you're reviewing a draft" do
        expect(rendered).to have_content(I18n.t("publishers.vacancies.show.heading_component.status_tag.draft"))
        expect(rendered).to have_content(I18n.t("publishers.vacancies.show.heading_component.inset_text.complete_draft"))
        expect(rendered).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.publish"))
        expect(rendered).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.preview"))
        expect(rendered).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.copy"))
        expect(rendered).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.delete"))
      end
    end

    context "with a complete future published draft" do
      let(:vacancy) { build_stubbed(:draft_vacancy, :secondary, publish_on: Date.current + 6.months, organisations: [school]) }
      let(:next_invalid_step) { nil }

      it "displays schedule information" do
        expect(rendered).to have_content(I18n.t("publishers.vacancies.show.heading_component.inset_text.scheduled_complete_draft"))
        expect(rendered).to have_content(I18n.t("publishers.vacancies.show.heading_component.action.scheduled_complete_draft"))
      end
    end
  end
end
