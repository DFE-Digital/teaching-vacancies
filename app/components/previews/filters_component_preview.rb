class FiltersComponentPreview < ViewComponent::Preview
  layout "design_system"

  def self.component_name
    component_class.to_s.underscore.humanize.split.first.downcase
  end

  def self.component_class
    FiltersComponent
  end

  def self.form
    FiltersComponentPreview::OptionsForm
  end

  def self.interactive_options
    %w[remove_buttons close_all search small scroll]
  end

  def preview; end
end
