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
    jobs_at_central_office = @vacancies.select { |v| v.job_location == 'central_office' }

    options = [[
      "#{I18n.t('hiring_staff.organisations.school_groups.readable_job_location')} (#{jobs_at_central_office.count})",
      'school_group'
    ]]

    @organisation.schools.sort_by { |school| school.name }.each do |school|
      jobs_at_school = @vacancies.select { |v| v.readable_job_location == school.name }
      options.push(["#{school.name} (#{jobs_at_school.count})", school.urn])
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
