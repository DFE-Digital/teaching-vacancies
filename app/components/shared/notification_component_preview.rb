class Shared::NotificationComponentPreview < ViewComponent::Preview
  layout "design_system"

  def self.component_name
    "notification"
  end

  def self.component_class
    Shared::NotificationComponent
  end

  def self.form
    Shared::NotificationComponentPreview::OptionsForm
  end

  def self.interactive_options
    %w[background dismiss icon]
  end

  def preview; end
end
