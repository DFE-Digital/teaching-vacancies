class HiringStaff::VacanciesComponent < ViewComponent::Base
  delegate :awaiting_feedback_tab, to: :helpers

  def initialize(organisation:, sort:, selected_type:, filters:, filters_form:)
    @organisation = organisation
    @sort = sort
    @filters = filters
    @filters_form = filters_form

    @selected_type = selected_type&.to_sym || :published
    @vacancy_types = %i[published pending draft expired awaiting_feedback]

    set_organisation_options if @organisation.is_a?(SchoolGroup)
    set_vacancies
  end

  def render?
    @organisation.all_vacancies.active.any?
  end

  def selected_class(vacancy_type)
    'govuk-tabs__list-item--selected' if @selected_type == vacancy_type
  end

  def grid_column_class
    @organisation.is_a?(SchoolGroup) ? 'govuk-grid-column-two-thirds' : 'govuk-grid-column-full'
  end

  def filters_applied_text
    I18n.t('jobs.dashboard_filters.heading', count: @filters[:managed_school_ids]&.count)
  end

  def vacancy_type_tab_link(vacancy_type)
    if vacancy_type == :awaiting_feedback
      link_to jobs_with_type_organisation_path(vacancy_type), class: 'govuk-tabs__tab' do
        awaiting_feedback_tab(@organisation.vacancies.awaiting_feedback.count)
      end
    else
      link_to t("jobs.#{vacancy_type}_jobs"), jobs_with_type_organisation_path(vacancy_type), class: 'govuk-tabs__tab'
    end
  end

private

  def set_vacancies
    @vacancies =
      if @filters[:managed_school_ids]&.any?
        Vacancy.in_organisation_ids(@filters[:managed_school_ids])
      else
        @organisation.all_vacancies
      end
    @vacancies = @vacancies.send(selected_scope)
    @vacancies = @vacancies.order(@sort.column => @sort.order)
    @vacancies = @vacancies.map { |v| OrganisationVacancyPresenter.new(v) }
  end

  def selected_scope
    @selected_type == :published ? :live : @selected_type
  end

  def set_organisation_options
    @organisation_options = @organisation.schools.order(:name).map do |school|
      count = Vacancy.in_organisation_ids(school.id).send(selected_scope).count
      OpenStruct.new({ id: school.id, name: school.name, label: "#{school.name} (#{count})" })
    end
    count = Vacancy.in_organisation_ids(@organisation.id).send(selected_scope).count
    unless @organisation.group_type == 'local_authority'
      @organisation_options.unshift(
        OpenStruct.new({ id: @organisation.id, name: 'Trust head office', label: "Trust head office (#{count})" }),
      )
    end
  end
end
