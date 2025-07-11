# frozen_string_literal: true

module PageObjects
  module Pages
    module Application
      def app_pages
        @app_pages ||= {}
      end

      {
        publisher_application: "Publisher::JobApplicationPage",
        publisher_applications_awaiting_feedback: "Publisher::JobApplicationsAwaitingFeedbackPage",
        publisher_vacancy: "Publisher::VacancyPage",
        publisher_ats_applications: "Publisher::Ats::JobApplicationsPage",
        publisher_ats_interviewing: "Publisher::Ats::InterviewingApplicationsPage",
        publisher_include_additional_documents: "Publisher::IncludeAdditionalDocumentsPage",
        publisher_job_title: "Publisher::JobTitlePage",
        publisher_pay_package: "Publisher::PayPackagePage",
        publisher_application_form: "Publisher::ApplicationFormPage",
        publisher_important_dates: "Publisher::ImportantDatesPage",
        publisher_contact_details: "Publisher::ContactDetailsPage",
        publisher_about_the_role: "Publisher::AboutTheRolePage",
        publisher_add_document: "Publisher::AddDocumentPage",
        publisher_vacancy_documents: "Publisher::VacancyDocumentsPage",
        publisher_job_location: "Publisher::JobLocationPage",
        publisher_job_role: "Publisher::JobRolePage",
        publisher_education_phase: "Publisher::EducationPhasePage",
        publisher_key_stage: "Publisher::KeyStagePage",
        publisher_subjects: "Publisher::SubjectsPage",
        publisher_contract_information: "Publisher::ContractInformationPage",
        publisher_start_date: "Publisher::StartDatePage",
        publisher_school_visits: "Publisher::SchoolVisitsPage",
        publisher_visa_sponsorship: "Publisher::VisaSponsorshipPage",
        publisher_applying_for_the_job: "Publisher::ApplyingForTheJobPage",
        publisher_how_to_receive_applications: "Publisher::HowToReceiveApplicationsPage",
        publisher_application_link: "Publisher::ApplicationLinkPage",
        jobseeker_applications: "Jobseeker::JobApplicationsPage",
        jobseeker_application: "Jobseeker::JobApplicationPage",
        jobseeker_application_apply: "Jobseeker::JobApplicationApplyPage",
      }.each do |page_name, page_class|
        full_page_class = "PageObjects::Pages::#{page_class}"

        define_method "#{page_name}_page" do
          app_pages[page_name] ||= full_page_class.constantize.__send__ :new
        end
      end
    end
  end
end
