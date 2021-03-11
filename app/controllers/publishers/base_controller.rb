class Publishers::BaseController < ApplicationController
  TIMEOUT_PERIOD = 60.minutes

  before_action :authenticate_publisher!,
                :check_terms_and_conditions

  include ActionView::Helpers::DateHelper

  helper_method :current_publisher

  def check_terms_and_conditions
    redirect_to terms_and_conditions_path unless current_publisher.accepted_terms_and_conditions?
  end

  def current_publisher_preferences
    return unless current_organisation.is_a?(SchoolGroup)

    PublisherPreference.find_by(publisher_id: current_publisher.id, school_group_id: current_organisation.id)
  end

  def redirect_signed_in_publishers
    redirect_to organisation_path if current_organisation.present?
  end

  def timeout_period_as_string
    distance_of_time_in_words(TIMEOUT_PERIOD).gsub("about ", "")
  end

  def verify_school_group
    redirect_to organisation_path, danger: "You are not allowed" unless current_organisation.is_a?(SchoolGroup)
  end
end
