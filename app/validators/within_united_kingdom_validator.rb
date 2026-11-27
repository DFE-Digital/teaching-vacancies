class WithinUnitedKingdomValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    # The regions, counties and cities we hold a polygon for are searched by area, without a lookup. Ordnance Survey
    # has no place called "Essex", so geocoding one would go to Google.
    return if LocationPolygon.contain?(value.strip)

    unless Geocoding.new(value.strip).uk_coordinates?
      record.errors.add(attribute, I18n.t("activemodel.errors.models.jobseekers/job_preferences_form/location_form.attributes.location.blank"))
    end
  end
end
