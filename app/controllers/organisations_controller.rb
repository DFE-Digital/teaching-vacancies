class OrganisationsController < ApplicationController
  before_action :strip_empty_filter_checkboxes, only: %i[index]

  before_action :set_organisation, only: %i[show]
  before_action :set_search_form, only: %i[index]

  def show
    # bring trust jobs to the front of the list
    @vacancies = @organisation.all_live_vacancies.partition { |v| v.organisation.trust? }.flatten
  end

  def index
    @school_search = Search::SchoolSearch.new(@search_form.to_h, scope: Organisation.visible_to_jobseekers.where.not(detailed_school_type: School::FE_DETAILED_SCHOOL_TYPE))
    @pagy, @schools = pagy(@school_search.organisations.order(:name))
  end

  private

  def set_search_form
    @search_form = SchoolSearchForm.new(params)
  end

  def set_organisation
    @organisation = Organisation.friendly.find(params[:id] || params[:organisation_id])
  end

  # :nocov:
  def strip_empty_filter_checkboxes
    strip_empty_checkboxes(%i[education_phase key_stage job_availability organisation_types school_types]) unless params[:skip_strip_checkboxes]
  end
  # :nocov:
end
