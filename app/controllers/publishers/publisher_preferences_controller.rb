class Publishers::PublisherPreferencesController < Publishers::BaseController
  before_action :strip_empty_publisher_preference_checkboxes, only: %i[create update]

  def new
    @publisher_preference = PublisherPreference.new
  end

  def create
    @publisher_preference = PublisherPreference.new(publisher: current_publisher, organisation: current_organisation)

    if params[:publisher_preference][:school_ids].any?
      @publisher_preference.save
      create_local_authority_publisher_schools
      redirect_to organisation_path
    else
      @publisher_preference.errors.add(:school_ids_fieldset, t(".form.missing_schools_error"))
      render :new
    end
  end

  def edit
    @publisher_preference = PublisherPreference.find_by(publisher: current_publisher, organisation: current_organisation)
  end

  def update
    @publisher_preference = PublisherPreference.find_by(publisher: current_publisher, organisation: current_organisation)

    if params[:publisher_preference][:school_ids]&.none?
      @publisher_preference.errors.add(:school_ids_fieldset, t(".form.missing_schools_error"))
      return render :edit
    elsif params[:publisher_preference][:school_ids]&.any?
      create_local_authority_publisher_schools
    elsif params[:publisher_preference][:organisation_ids]
      create_organisation_publisher_preferences
    end
    redirect_to jobs_with_type_organisation_path(params[:publisher_preference][:jobs_type])
  end

  private

  def create_local_authority_publisher_schools
    @publisher_preference.local_authority_publisher_schools.delete_all
    params[:publisher_preference][:school_ids].each do |school_id|
      @publisher_preference.local_authority_publisher_schools.create(school_id: school_id)
    end
  end

  def create_organisation_publisher_preferences
    @publisher_preference.organisation_publisher_preferences.delete_all
    params[:publisher_preference][:organisation_ids].each do |organisation_id|
      @publisher_preference.organisation_publisher_preferences.create(organisation_id: organisation_id)
    end
  end

  def strip_empty_publisher_preference_checkboxes
    strip_empty_checkboxes(%i[school_ids organisation_ids], :publisher_preference)
  end
end
