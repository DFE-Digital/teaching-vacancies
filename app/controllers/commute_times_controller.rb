class CommuteTimesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def show
    set_commute_time
  rescue CommuteTime::InvalidPostcodeError
    render_error(t("jobs.commute_time_invalid_postcode"))
  rescue CommuteTime::InvalidTravelModeError
    render_error(t("jobs.commute_time_invalid_travel_mode"))
  rescue CommuteTime::RouteNotFoundError
    render_error(t("jobs.commute_time_route_not_found"))
  rescue CommuteTime::RequestError => e
    Rails.logger.error("Commute time request failed for #{@travel_mode}: #{e.message}")
    render_error(t("jobs.commute_time_error"))
  end

  private

  def set_commute_time
    @vacancy = PublishedVacancy.kept.listed.friendly.find(params[:job_id])
    @search_location = params[:search_location].to_s.strip.upcase
    @travel_mode = params[:travel_mode].to_s
    return if @travel_mode.blank?

    @duration = commute_time.duration_in_minutes
  end

  def commute_time
    CommuteTime.new(
      postcode: @search_location,
      destination: @vacancy.geolocation,
      travel_mode: @travel_mode,
    )
  end

  def render_error(message)
    @error = message
    render :show
  end
end
