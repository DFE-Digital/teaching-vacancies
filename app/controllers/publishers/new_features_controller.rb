class Publishers::NewFeaturesController < Publishers::BaseController
  skip_before_action :check_terms_and_conditions, only: %i[show update]

  def show
    @new_features_form = Publishers::NewFeaturesForm.new
  end

  def update
    @new_features_form = Publishers::NewFeaturesForm.new(new_features_params)

    current_publisher.update(dismissed_new_features_page_at: Time.current) if new_features_params[:dismiss].present?
    session[:visited_new_features_page] = true
    redirect_to organisation_path
  end

  private

  def new_features_params
    (params[:publishers_new_features_form] || params).permit(:dismiss)
  end
end
