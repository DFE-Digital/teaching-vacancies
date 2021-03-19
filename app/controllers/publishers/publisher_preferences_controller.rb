class Publishers::PublisherPreferencesController < Publishers::BaseController
  def update
    strip_empty_checkboxes(%i[organisation_ids], :publisher_preference)

    publisher_preference = PublisherPreference.find_by(publisher: current_publisher, organisation: current_organisation)

    publisher_preference.organisation_publisher_preferences.delete_all

    params[:publisher_preference][:organisation_ids].each do |organisation_id|
      publisher_preference.organisation_publisher_preferences.create(organisation_id: organisation_id)
    end

    redirect_to jobs_with_type_organisation_path(params[:publisher_preference][:jobs_type])
  end
end
