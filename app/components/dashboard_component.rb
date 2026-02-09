class DashboardComponent < ApplicationComponent
  include DatesHelper
  include VacanciesHelper

  # rubocop:disable Metrics/ParameterLists
  def initialize(organisation:, sort:, selected_type:, publisher_preference:, vacancies:, count:, vacancy_types:, filter_form:, selected_organisation_ids: [])
    # rubocop:enable Metrics/ParameterLists
    super(classes: [], html_attributes: {})
    @organisation = organisation
    @sort = sort
    @publisher_preference = publisher_preference
    # only used by dashboard_component.html.slim
    @vacancy_types = vacancy_types
    @selected_type = selected_type
    @selected_organisation_ids = selected_organisation_ids
    @filter_form = filter_form

    @vacancies = vacancies
    set_organisation_options if @organisation.school_group?
    @count = count
  end

  def grid_column_class
    organisation.school_group? ? "govuk-grid-column-two-thirds-at-desktop" : "govuk-grid-column-three-quarters"
  end

  def no_jobs_text
    t("jobs.manage.#{selected_type}.no_jobs.#{@selected_organisation_ids.any? ? 'with' : 'no'}_filters")
  end

  def view_applicants(vacancy, job_applications_count)
    govuk_link_to(tag.span(t("jobs.manage.view_applicants", count: job_applications_count)) \
                    + tag.span(" for #{vacancy.job_title}", class: "govuk-visually-hidden"),
                  organisation_job_job_applications_path(vacancy.id),
                  class: "govuk-link--no-visited-state")
  end

  private

  attr_reader :publisher_preference, :organisation, :selected_type, :sort, :vacancies, :selected_organisation_ids

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
