class Base < ViewComponent::Preview
  layout "application"

  def self.component_name
    component_class.to_s.underscore.humanize.split.first.downcase
  end

  def self.form
    Form
  end

  def preview; end
end
