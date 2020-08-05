class HiringStaff::VacanciesComponent < ViewComponent::Base
  delegate :awaiting_feedback_tab, to: :helpers

  def initialize(organisation:, sort:, selected_type:, filters:, filters_form:)
    @organisation = organisation
    @sort = sort
    @filters = filters
    @filters_form = filters_form

    @selected_type = selected_type&.to_sym || :published
    @vacancy_types = %i[published pending draft expired awaiting_feedback]

    @vacancies = send(@selected_type)
    @school_options = set_school_options if organisation.is_a?(SchoolGroup)

    @vacancies = set_filters(@vacancies, @filters) if organisation.is_a?(SchoolGroup)
    @vacancies = @vacancies.map { |v| OrganisationVacancyPresenter.new(v) }
  end

  def render?
    @organisation.vacancies.active.any?
  end

  def selected_class(vacancy_type)
    'govuk-tabs__list-item--selected' if @selected_type == vacancy_type
  end

  def grid_column_class
    @organisation.is_a?(SchoolGroup) ? 'govuk-grid-column-three-quarters' : 'govuk-grid-column-full'
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

  def draft
    @organisation.vacancies.draft.order(@sort.column => @sort.order)
  end

  def pending
    @organisation.vacancies.pending.order(@sort.column => @sort.order)
  end

  def expired
    @organisation.vacancies.expired.order(@sort.column => @sort.order)
  end

  def published
    @organisation.vacancies.live.order(@sort.column => @sort.order)
  end

  def awaiting_feedback
    @organisation.vacancies.awaiting_feedback.order(@sort.column => @sort.order)
  end

  def set_filters(vacancies, filters)
    school_group_in_school_ids = filters[:managed_school_ids]&.include?('school_group')

    return vacancies if filters.none? || filters[:managed_organisations] == 'all'

    return vacancies.in_central_office if
      filters[:managed_school_ids] == ['school_group']

    return vacancies.in_school_ids(filters[:managed_school_ids]) if
      filters[:managed_school_ids]&.any? && !school_group_in_school_ids

    vacancies
      .in_school_ids(filters[:managed_school_ids]&.reject { |school_id| school_id == 'school_group' })
      .or(vacancies.in_central_office)
  end

  def set_school_options
    @school_options = @organisation.schools.order(:name).map do |school|
      OpenStruct.new({ id: school.id, name: "#{school.name} (#{@vacancies.in_school_ids(school.id).count})" })
    end
    @school_options.unshift(
      OpenStruct.new({ id: 'school_group', name: "Trust head office (#{@vacancies.in_central_office.count})" })
    )
  end
end
