class FiltersComponentPreview < ViewComponent::Preview
  layout "application"

  def self.component_name
    component_class.to_s.underscore.humanize.split.first.downcase
  end

  def self.component_class
    FiltersComponent
  end

  def self.form
    FiltersComponentPreview::Form
  end

  def preview; end
end
