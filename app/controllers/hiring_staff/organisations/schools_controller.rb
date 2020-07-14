class HiringStaff::Organisations::SchoolsController < HiringStaff::BaseController
  before_action :set_organisation, only: [:edit, :update]

  def index
  end

  def edit
  end

  def update
    if @organisation.update(description: description)
      redirect_to organisation_schools_path,
        success: I18n.t('messages.organisation.description_updated_html', organisation: @organisation.name)
    else
      render :edit
    end
  end

  private

  def set_organisation
    @organisation = params[:school_group] ? SchoolGroup.find(params[:id]) : School.find(params[:id])
  end

  def description
    return params[:school_group][:description] if params[:school_group]
    params[:school][:description] if params[:school]
  end
end
