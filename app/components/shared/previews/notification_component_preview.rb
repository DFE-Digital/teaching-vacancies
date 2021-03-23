class Shared::Previews::NotificationComponentPreview < ViewComponent::Preview
  layout "design_system"

  def self.component_name
    component_class.to_s.underscore.humanize.split("/").second.split.first
  end

  def self.component_class
    Shared::NotificationComponent
  end

  def self.form
    Shared::Previews::NotificationComponentPreview::OptionsForm
  end

  def self.interactive_options
    %w[background dismiss icon]
  end

  def preview; end
end
