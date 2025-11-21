# frozen_string_literal: true

module PageObjects
  module Pages
    module Application
      def app_pages
        @app_pages ||= {}
      end

      {
        publisher_application: "Publisher::JobApplicationPage",
        publisher_ats_ask_references_email: "Publisher::Ats::AskReferencesEmailPage",
        publisher_ats_collect_references: "Publisher::Ats::CollectReferencesPage",
        publisher_applications_awaiting_feedback: "Publisher::JobApplicationsAwaitingFeedbackPage",
        publisher_vacancy: "Publisher::VacancyPage",
        publisher_ats_applications: "Publisher::Ats::JobApplicationsPage",
        publisher_ats_interviewing: "Publisher::Ats::InterviewingApplicationsPage",
        publisher_ats_pre_interview_checks: "Publisher::Ats::PreInterviewChecksPage",
        publisher_ats_reference_request: "Publisher::Ats::ReferenceRequestPage",
        publisher_ats_interview_datetime: "Publisher::Ats::InterviewDatetimePage",
        publisher_ats_tag: "Publisher::Ats::TagPage",
        publisher_ats_job_decline_date: "Publisher::Ats::JobDeclineDatePage",
        publisher_ats_job_offer_date: "Publisher::Ats::JobOfferDateTagPage",
        publisher_ats_job_feedback_date: "Publisher::Ats::FeedbackTagPage",
        publisher_include_additional_documents: "Publisher::IncludeAdditionalDocumentsPage",
        publisher_job_title: "Publisher::JobTitlePage",
        publisher_pay_package: "Publisher::PayPackagePage",
        publisher_application_form: "Publisher::ApplicationFormPage",
        publisher_important_dates: "Publisher::ImportantDatesPage",
        publisher_contact_details: "Publisher::ContactDetailsPage",
        publisher_anonymise_applications: "Publisher::AnonymiseApplicationsPage",
        publisher_confirm_contact_details: "Publisher::ConfirmContactDetailsPage",
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
        jobseeker_application_start: "Jobseeker::JobApplicationStartPage",
        publisher_ats_self_disclosure: "Publisher::Ats::SelfDisclosurePage",
        jobseeker_self_disclosure_personal_details: "Jobseeker::JobApplications::SelfDisclosure::PersonalDetailPage",
        jobseeker_self_disclosure_barred_list: "Jobseeker::JobApplications::SelfDisclosure::BarredListPage",
        jobseeker_self_disclosure_conduct: "Jobseeker::JobApplications::SelfDisclosure::ConductPage",
        jobseeker_self_disclosure_confirmation: "Jobseeker::JobApplications::SelfDisclosure::ConfirmationPage",
        jobseeker_self_disclosure_completed: "Jobseeker::JobApplications::SelfDisclosure::CompletedPage",
        referee_can_give_reference: "Publisher::Ats::Referee::CanGiveReferencePage",
        referee_employment_reference: "Publisher::Ats::Referee::EmploymentReferencePage",
        referee_reference_information: "Publisher::Ats::Referee::ReferenceInformationPage",
        referee_how_would_you_rate1: "Publisher::Ats::Referee::HowWouldYouRatePage1",
        referee_how_would_you_rate2: "Publisher::Ats::Referee::HowWouldYouRatePage2",
        referee_how_would_you_rate3: "Publisher::Ats::Referee::HowWouldYouRatePage3",
        referee_referee_details: "Publisher::Ats::Referee::RefereeDetailsPage",
      }.each do |page_name, page_class|
        full_page_class = "PageObjects::Pages::#{page_class}"

        define_method "#{page_name}_page" do
          app_pages[page_name] ||= full_page_class.constantize.__send__ :new
        end
      end
    end
  end
end
