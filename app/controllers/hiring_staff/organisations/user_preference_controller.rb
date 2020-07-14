class HiringStaff::Organisations::UserPreferenceController < HiringStaff::BaseController
  before_action :verify_school_group

  def show
    @user_preference_form = UserPreferenceForm.new(current_user, current_organisation)
  end

  def update
    @user_preference_form = UserPreferenceForm.new(current_user, current_organisation, user_preference_form_params)

    if @user_preference_form.valid?
      @user_preference_form.save
      redirect_to organisation_path
    else
      render :show
    end
  end

  private

  def update_managed_organisations
    if params[:commit] == I18n.t('buttons.skip_this_step')
      params[:user_preference_form][:managed_organisations] = ['all']
    elsif params[:user_preference_form][:managed_organisations].blank?
      params[:user_preference_form][:managed_organisations] = []
    end
  end

  def user_preference_form_params
    update_managed_organisations
    strip_empty_checkboxes(:user_preference_form, [:managed_organisations, :managed_school_urns])
    params.require(:user_preference_form).permit(managed_organisations: [], managed_school_urns: [])
  end

  def verify_school_group
    redirect_to organisation_path, danger: 'You are not allowed' unless current_organisation.is_a?(SchoolGroup)
  end
end
