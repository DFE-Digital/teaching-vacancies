class OrganisationsController < ApplicationController
  before_action :strip_empty_filter_checkboxes, only: %i[index]

  def show
    organisation
  end

  def index
    @school_search = Search::SchoolSearch.new(search_form.to_h, scope: search_scope)
    @pagy, @schools = pagy(@school_search.organisations)
  end

  private

  helper_method def search_form
    @search_form ||= SchoolSearchForm.new(params)
  end

  def search_scope
    Organisation.visible_to_jobseekers.order(:name)
  end

  def organisation
    @organisation ||= Organisation.friendly.find(params[:id] || params[:organisation_id])
  end

  def strip_empty_filter_checkboxes
    strip_empty_checkboxes(%i[education_phase key_stage special_school job_availability organisation_types school_types]) unless params[:skip_strip_checkboxes]
  end
end
