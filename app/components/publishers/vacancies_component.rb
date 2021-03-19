class Publishers::VacanciesComponent < ViewComponent::Base
  def initialize(organisation:, sort:, selected_type:, publisher_preference:, sort_form:, email:)
    @organisation = organisation
    @sort = sort
    @publisher_preference = publisher_preference
    @sort_form = sort_form
    @email = email
    @vacancy_types = %w[published expired pending draft awaiting_feedback]
    @selected_type = @vacancy_types.include?(selected_type) ? selected_type : "published"

    set_organisation_options if @organisation.is_a?(SchoolGroup)
    set_vacancies
  end

  def render?
    organisation.all_vacancies.active.any?
  end

  def selected?(vacancy_type)
    selected_type == vacancy_type
  end

  def vacancy_sort_options
    Publishers::VacancySort.new(organisation, selected_type)
  end

  def vacancy_links
    @vacancy_types.map { |vacancy_type| vacancy_type_tab_link(vacancy_type, selected?(vacancy_type)) }
  end

  def grid_column_class
    organisation.is_a?(SchoolGroup) ? "govuk-grid-column-two-thirds" : "govuk-grid-column-full"
  end

  def vacancy_type_tab_link(vacancy_type, selected)
    link_to t(".#{vacancy_type}.tab_heading"), jobs_with_type_organisation_path(vacancy_type), class: "moj-primary-navigation__link", "aria-current": ("page" if selected)
  end

  def no_jobs_text
    I18n.t("jobs.manage.#{selected_type}.no_jobs.#{publisher_preference.organisations.any? ? 'with' : 'no'}_filters")
  end

  private

  attr_reader :publisher_preference, :organisation, :selected_type, :sort, :vacancies

  def set_vacancies
    @vacancies =
      if publisher_preference.organisations.any?
        Vacancy.in_organisation_ids(publisher_preference.organisations.map(&:id))
      else
        organisation.all_vacancies
      end
    @vacancies = vacancies.send(selected_scope)
                          .order(sort.column => sort.order)
                          .reject { |vacancy| vacancy.job_title.blank? }
                          .map { |v| OrganisationVacancyPresenter.new(v) }
  end

  def selected_scope
    @selected_type == "published" ? "live" : selected_type
  end

  def set_organisation_options
    @organisation_options = organisation.schools.not_closed.order(:name).map do |school|
      count = Vacancy.in_organisation_ids(school.id).send(selected_scope).count
      OpenStruct.new({ id: school.id, name: school.name, label: "#{school.name} (#{count})" })
    end

    return if organisation.group_type == "local_authority"

    count = Vacancy.in_organisation_ids(organisation.id).send(selected_scope).count
    @organisation_options.unshift(
      OpenStruct.new({ id: organisation.id, name: "Trust head office", label: "Trust head office (#{count})" }),
    )
  end
end
