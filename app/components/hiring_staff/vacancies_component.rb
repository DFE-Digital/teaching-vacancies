class HiringStaff::VacanciesComponent < ViewComponent::Base
  delegate :awaiting_feedback_tab, to: :helpers

  def initialize(organisation:, sort:, selected_type:, filters:)
    @organisation = organisation
    @sort = sort
    @filters = filters
    @selected_type = selected_type&.to_sym || :published
    @vacancy_types = %i[published pending draft expired awaiting_feedback]

    @vacancies = send(@selected_type)
    @vacancies = set_filters(@vacancies, @filters) if organisation.is_a?(SchoolGroup)
    @vacancies = @vacancies.map { |v| OrganisationVacancyPresenter.new(v) }
  end

  def render?
    @organisation.vacancies.active.any?
  end

  def selected_class(vacancy_type)
    'govuk-tabs__list-item--selected' if @selected_type == vacancy_type
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
    return vacancies if filters.none? || filters[:managed_organisations] == 'all'

    in_school_urns = filters[:managed_school_urns]&.any? ? vacancies.in_school_urns(filters[:managed_school_urns]) : []
    in_central_office = filters[:managed_organisations] == 'school_group' ? vacancies.in_central_office : []

    in_school_urns + in_central_office
  end
end
