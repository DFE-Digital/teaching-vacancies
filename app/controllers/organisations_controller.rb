class OrganisationsController < ApplicationController
  before_action :strip_empty_filter_checkboxes, only: %i[index]

  before_action :set_organisation, only: %i[show]

  def show
    # rubocop false positive - the suggested code doesn't work (replace reduce(&:+) with sum) as this is a pair of arrays
    # rubocop:disable Performance/Sum
    # bring trust jobs to the front of the list
    @vacancies = @organisation.all_vacancies.live.partition { |v| v.organisation.trust? }.reduce(&:+)
    # rubocop:enable Performance/Sum
  end

  def index
    @school_search = Search::SchoolSearch.new(search_form.to_h, scope: search_scope)
    @pagy, @schools = pagy(@school_search.organisations)
  end

  private

  def search_form
    @search_form ||= SchoolSearchForm.new(params)
  end

  def search_scope
    Organisation.visible_to_jobseekers.order(:name)
  end

  def set_organisation
    @organisation = Organisation.friendly.find(params[:id] || params[:organisation_id])
  end

  def strip_empty_filter_checkboxes
    strip_empty_checkboxes(%i[education_phase key_stage special_school job_availability organisation_types school_types]) unless params[:skip_strip_checkboxes]
  end
end
