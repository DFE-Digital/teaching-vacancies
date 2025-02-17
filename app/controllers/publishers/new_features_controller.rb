class Publishers::NewFeaturesController < Publishers::BaseController
  skip_before_action :check_terms_and_conditions

  # TODO: update when a new feature is introduced
  NEW_FEATURES_PAGE_UPDATED_AT = DateTime.new(2022, 3, 17).freeze # This constant lives here so that we remember to update it.

  def reminder
    session[:visited_application_feature_reminder_page] = true
  end
end
