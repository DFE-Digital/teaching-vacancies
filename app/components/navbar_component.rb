class NavbarComponent < GovukComponent::Base
  delegate :active_link_class, to: :helpers
  delegate :organisation_type_basic, to: :helpers

  attr_accessor :publisher_signed_in, :jobseeker_signed_in, :current_organisation, :current_publisher

  def initialize(publisher_signed_in:, jobseeker_signed_in:, current_organisation:, current_publisher:, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @publisher_signed_in = publisher_signed_in
    @jobseeker_signed_in = jobseeker_signed_in
    @current_organisation = current_organisation
    @current_publisher = current_publisher
  end

  private

  def default_classes
    %w[navbar-component]
  end
end
