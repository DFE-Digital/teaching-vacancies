class Shared::NotificationComponentPreview < ViewComponent::Preview
  layout "design_system"

  def self.form
    Shared::NotificationComponentPreview::OptionsForm
  end

  def self.variants
    %w[success warning notice empty]
  end

  def default
  end
end
