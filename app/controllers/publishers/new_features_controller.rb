class Publishers::NewFeaturesController < Publishers::BaseController
  skip_before_action :check_terms_and_conditions, only: %i[show update reminder]

  NEW_FEATURES_PAGE_UPDATED_AT = DateTime.new(2022, 3, 17).freeze # This constant lives here so that we remember to update it.

  def show
    @new_features_form = Publishers::NewFeaturesForm.new
    session[:visited_new_features_page] = true
  end

  def update
    @new_features_form = Publishers::NewFeaturesForm.new(new_features_params)

    current_publisher.update(dismissed_new_features_page_at: Time.current) if new_features_params[:dismiss].present?
    redirect_to organisation_path
  end

  def reminder
    session[:visited_application_feature_reminder_page] = true
  end

  private

  def new_features_params
    (params[:publishers_new_features_form] || params).permit(:dismiss)
  end
end
