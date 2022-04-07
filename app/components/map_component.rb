class MapComponent < GovukComponent::Base
  include LinksHelper
  include OrganisationsHelper

  def initialize(vacancies:, popup_variant:, zoom: 13, show_location_list: true, polygons: [], classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @vacancies = vacancies
    @zoom = zoom
    @popup_variant = popup_variant
    @show_location_list = show_location_list
    @polygons = polygons
  end

  def show_location_list_class
    @show_location_list ? "" : "govuk-!-display-none"
  end

  def show_marker_numbers
    @show_location_list
  end

  private

  def default_classes
    %w[map-component]
  end

  def show_map?
    @show_map ||= @vacancies[0].organisations.where.not(geopoint: nil).any?
  end
end
