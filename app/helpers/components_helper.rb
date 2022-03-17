module ComponentsHelper
  {
    card: "CardComponent",
    dashboard: "DashboardComponent",
    empty_section: "EmptySectionComponent",
    filters: "FiltersComponent",
    job_application_review: "JobApplicationReviewComponent",
    jobseekers_account_survey_link: "Jobseekers::AccountSurveyLinkComponent",
    jobseekers_search_results_heading: "Jobseekers::SearchResults::HeadingComponent",
    landing_page_link_group: "LandingPageLinkGroupComponent",
    map: "MapComponent",
    navigation_list: "NavigationListComponent",
    review: "ReviewComponent",
    searchable_collection: "SearchableCollectionComponent",
    tabs: "TabsComponent",
    vacancy_form_page_heading: "VacancyFormPageHeadingComponent",
    vacancy_review: "VacancyReviewComponent",
    vacancy_selector: "VacancySelectorComponent",
    validatable_summary_list: "ValidatableSummaryListComponent",
  }.each do |name, klass|
    define_method(name) do |*args, **kwargs, &block|
      capture do
        render(klass.constantize.new(*args, **kwargs)) do |com|
          block.call(com) if block.present?
        end
      end
    end
  end
end

ActiveSupport.on_load(:action_view) { include ComponentsHelper }
