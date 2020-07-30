class HiringStaff::VacanciesComponent < ViewComponent::Base
  delegate :awaiting_feedback_tab, to: :helpers

  def initialize(organisation:, sort:, selected_type:)
    @organisation = organisation
    @sort = sort
    @selected_type = selected_type&.to_sym || :published
    @vacancy_types = %i[published pending draft expired awaiting_feedback]

    @vacancies = send(@selected_type).map { |v| OrganisationVacancyPresenter.new(v) }
    @job_location_options = job_location_options if organisation.is_a?(SchoolGroup)
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

  def job_location_options
    locations = Set.new
    locations.add(I18n.t('hiring_staff.organisations.school_groups.readable_job_location'))
    @organisation.schools.sort_by { |school| school.name }.each do |school|
      locations.add(school.name)
    end

    options = []
    locations.each do |loc|
      jobs_at_location = @vacancies.select { |v| v.readable_job_location == loc }
      options.push("#{loc} (#{jobs_at_location.count})")
    end
    options
  end

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
end
