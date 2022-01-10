class BannerComponent < GovukComponent::Base
  def initialize(classes: [], html_attributes: {})
    super(classes:, html_attributes:)
  end

  private

  def default_classes
    %w[banner-component]
  end
end
