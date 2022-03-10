class MapComponent < GovukComponent::Base
  include LinksHelper
  include OrganisationsHelper

  def initialize(vacancy:, zoom: 13, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @vacancy = vacancy
    @zoom = zoom
  end

  private

  def default_classes
    %w[map-component]
  end

  def show_map?
    @show_map ||= @vacancy.organisations.where.not(geopoint: nil).any?
  end
end
