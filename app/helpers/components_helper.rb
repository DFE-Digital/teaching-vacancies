module ComponentsHelper
  {
    banner_button: "BannerButtonComponent",
    card: "CardComponent",
    dashboard: "DashboardComponent",
    empty_section: "EmptySectionComponent",
    filters: "FiltersComponent",
    job_application_notes: "PublisherNotesOnJobApplicationComponent",
    job_application_review: "JobApplicationReviewComponent",
    landing_page_link_group: "LandingPageLinkGroupComponent",
    map: "MapComponent",
    navigation_list: "NavigationListComponent",
    editor: "EditorComponent",
    searchable_collection: "SearchableCollectionComponent",
    supportal_table: "SupportalTableComponent",
    tabs: "TabsComponent",
    vacancy_form_page_heading: "VacancyFormPageHeadingComponent",
  }.each do |name, klass|
    define_method(name) do |*args, **kwargs, &block|
      capture do
        render(klass.constantize.new(*args, **kwargs)) do |com|
          # no code ever fails to provide a block
          # :nocov:
          block.presence&.call(com)
          # :nocov:
        end
      end
    end
  end
end

ActiveSupport.on_load(:action_view) { include ComponentsHelper }
