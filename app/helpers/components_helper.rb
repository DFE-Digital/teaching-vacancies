module ComponentsHelper
  {
    banner_button: "BannerButtonComponent",
    card: "CardComponent",
    dashboard: "DashboardComponent",
    editor: "EditorComponent",
    empty_section: "EmptySectionComponent",
    filters: "FiltersComponent",
    job_application_review: "JobApplicationReviewComponent",
    landing_page_link_group: "LandingPageLinkGroupComponent",
    map: "MapComponent",
    navigation_list: "NavigationListComponent",
    publisher_notes_on_job_application: "PublisherNotesOnJobApplicationComponent",
    searchable_collection: "SearchableCollectionComponent",
    supportal_table: "SupportalTableComponent",
    tabs: "TabsComponent",
    vacancy_form_page_heading: "VacancyFormPageHeadingComponent",
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
