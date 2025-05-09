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
        publisher_include_additional_documents: "Publisher::IncludeAdditionalDocumentsPage",
        publisher_add_document: "Publisher::AddDocumentPage",
        publisher_vacancy_documents: "Publisher::VacancyDocumentsPage",
      }.each do |page_name, page_class|
        full_page_class = "PageObjects::Pages::#{page_class}"

        define_method "#{page_name}_page" do
          app_pages[page_name] ||= full_page_class.constantize.__send__ :new
        end
      end
    end
  end
end
