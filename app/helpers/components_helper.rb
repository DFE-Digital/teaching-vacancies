module ComponentsHelper
  {
    card: "CardComponent",
    dashboard: "DashboardComponent",
    empty_section: "EmptySectionComponent",
    filters: "FiltersComponent",
    job_application_review: "JobApplicationReviewComponent",
    map: "MapComponent",
    navigation_list: "NavigationListComponent",
    publishers_no_vacancies: "Publishers::NoVacanciesComponent",
    publishers_school_overview: "Publishers::SchoolOverviewComponent",
    publishers_vacancies: "Publishers::VacanciesComponent",
    publishers_vacancy_form_page_heading: "Publishers::VacancyFormPageHeadingComponent",
    review: "ReviewComponent",
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
