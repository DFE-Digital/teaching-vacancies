class Jobseekers::StartPageFiltersComponent < ViewComponent::Base
  include VacanciesHelper

  def initialize(form:)
    @form = form
  end

  def start_page_filters_hash
    { removeButtons: false,
      totalCount: job_role_options.size,
      has_submit_button: false,
      items: [
        { options: job_role_options,
          title: 'Job roles',
          search: false,
          attribute: :job_roles,
          value_method: :last,
          text_method: :first,
          small: true }
        ]
      }
  end
end
