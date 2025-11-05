class OrganisationsController < ApplicationController
  before_action :strip_empty_filter_checkboxes, only: %i[index]

  before_action :set_organisation, only: %i[show]

  def show
    # bring trust jobs to the front of the list
    @vacancies = @organisation.all_live_vacancies.partition { |v| v.organisation.trust? }.flatten
  end

  def index
    @school_search = Search::SchoolSearch.new(search_form.to_h)
    @pagy, @schools = pagy(@school_search.organisations.order(:name))
  end

  private

  def search_form
    @search_form ||= SchoolSearchForm.new(params)
  end

  def set_organisation
    @organisation = Organisation.friendly.find(params[:id] || params[:organisation_id])
  end

  def strip_empty_filter_checkboxes
    strip_empty_checkboxes(%i[education_phase key_stage special_school job_availability organisation_types school_types]) unless params[:skip_strip_checkboxes]
  end
end
