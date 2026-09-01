class CommuteTimesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def create
    vacancy = PublishedVacancy.kept.listed.friendly.find(params[:job_id])
    duration = DrivingTime.new(postcode: params[:postcode], destination: vacancy.geolocation).duration_in_minutes

    render partial: "vacancies/search/commute_time_result", locals: { duration: duration }
  rescue DrivingTime::InvalidPostcodeError
    render json: { error: t("jobs.commute_time_invalid_postcode") }, status: :unprocessable_content
  rescue DrivingTime::RouteNotFoundError
    render json: { error: t("jobs.commute_time_route_not_found") }, status: :unprocessable_content
  rescue DrivingTime::RequestError => e
    Rails.logger.error("Driving time request failed: #{e.message}")
    render json: { error: t("jobs.commute_time_error") }, status: :bad_gateway
  end
end
