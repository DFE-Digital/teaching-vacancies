class NotificationComponentPreview < ViewComponent::Preview
  layout "design_system"

  def self.component_name
    component_class.to_s.underscore.humanize.split.first.downcase
  end

  def self.component_class
    NotificationComponent
  end

  def self.form
    NotificationComponentPreview::OptionsForm
  end

  def self.interactive_options
    %w[background dismiss icon]
  end

  def preview; end
end
