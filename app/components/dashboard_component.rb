class DashboardComponent < ApplicationComponent
  include DatesHelper
  include VacanciesHelper

  def initialize(organisation:, sort:, selected_type:, publisher_preference:, vacancies:, count:, vacancy_types:)
    super(classes: [], html_attributes: {})
    @organisation = organisation
    @sort = sort
    @publisher_preference = publisher_preference
    # only used by dashboard_component.html.slim
    @vacancy_types = vacancy_types
    @selected_type = selected_type

    @vacancies = vacancies
    set_organisation_options if @organisation.school_group?
    @count = count
  end

  def grid_column_class
    organisation.school_group? ? "govuk-grid-column-two-thirds-at-desktop" : "govuk-grid-column-three-quarters"
  end

  def no_jobs_text
    t("jobs.manage.#{selected_type}.no_jobs.#{publisher_preference.organisations.any? ? 'with' : 'no'}_filters")
  end

  def view_applicants(vacancy)
    return unless vacancy.allow_job_applications?
    return unless include_job_applications?

    applications = vacancy.job_applications.where(status: %w[submitted reviewed shortlisted unsuccessful])

    govuk_link_to(tag.span(t("jobs.manage.view_applicants", count: applications.count)) \
                  + tag.span(" for #{vacancy.job_title}", class: "govuk-visually-hidden"),
                  organisation_job_job_applications_path(vacancy.id),
                  class: "govuk-link--no-visited-state")
  end

  def vacancy_expired_over_a_year_ago?(vacancy)
    vacancy.expires_at < 1.year.ago
  end

  private

  attr_reader :publisher_preference, :organisation, :selected_type, :sort, :vacancies

  def include_job_applications?
    @selected_type.in?(%i[live expired])
  end

  def set_organisation_options
    schools = organisation.local_authority? ? publisher_preference.schools : organisation.schools
    @organisation_options = schools.not_closed.order(:name).map do |school|
      count = vacancies.in_organisation_ids([school.id]).count
      Option.new(id: school.id, name: school.name, label: "#{school.name} (#{count})")
    end

    return if organisation.local_authority?

    count = vacancies.in_organisation_ids([organisation.id]).count
    @organisation_options.unshift(
      Option.new(id: organisation.id, name: "Head office", label: "Head office (#{count})"),
    )
  end

  def default_classes
    %w[dashboard-component]
  end
end
