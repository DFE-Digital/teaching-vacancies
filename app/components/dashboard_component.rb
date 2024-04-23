class DashboardComponent < ApplicationComponent
  include DatesHelper
  include VacanciesHelper

  def initialize(organisation:, sort:, selected_type:, publisher_preference:, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)
    @organisation = organisation
    @sort = sort
    @publisher_preference = publisher_preference
    @vacancy_types = %w[published expired pending draft awaiting_feedback]
    @selected_type = @vacancy_types.include?(selected_type) ? selected_type : "published"

    set_organisation_options if @organisation.school_group?
    set_vacancies
  end

  def grid_column_class
    organisation.school_group? ? "govuk-grid-column-two-thirds-at-desktop" : "govuk-grid-column-three-quarters"
  end

  def no_jobs_text
    t("jobs.manage.#{selected_type}.no_jobs.#{publisher_preference.organisations.any? ? 'with' : 'no'}_filters")
  end

  def view_applicants(vacancy)
    return unless vacancy.enable_job_applications?
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

  def set_vacancies
    @vacancies =
      if publisher_preference.organisations.any?
        Vacancy.in_organisation_ids(publisher_preference.organisations.map(&:id))
      elsif organisation.local_authority?
        Vacancy.in_organisation_ids(publisher_preference.schools.map(&:id))
      else
        organisation.all_vacancies
      end

    @vacancies = @vacancies.includes(:job_applications) if include_job_applications?
    @vacancies = @vacancies.send(selected_scope)
                           .order(sort.by => sort.order)
                           .reject { |vacancy| vacancy.job_title.blank? }
  end

  def include_job_applications?
    organisation.group_type != "local_authority" && @selected_type.in?(%w[published expired])
  end

  def selected_scope
    @selected_type == "published" ? "live" : selected_type
  end

  def set_organisation_options
    schools = organisation.local_authority? ? publisher_preference.schools : organisation.schools
    @organisation_options = schools.not_closed.order(:name).map do |school|
      count = school.vacancies.send(selected_scope).count
      Option.new(id: school.id, name: school.name, label: "#{school.name} (#{count})")
    end

    return if organisation.local_authority?

    count = organisation.vacancies.send(selected_scope).count
    @organisation_options.unshift(
      Option.new(id: organisation.id, name: "Head office", label: "Head office (#{count})"),
    )
  end

  def default_classes
    %w[dashboard-component]
  end
end
