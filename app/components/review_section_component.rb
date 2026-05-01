# This is an abstract class.
# See JobApplicationReviewComponent::Section for specific implementation.
class ReviewSectionComponent < ApplicationComponent
  include StatusTagHelper

  renders_many :field_div_sets, ->(form: nil) { render_divs_for_fields(form) }

  def initialize(name:, forms: [], **)
    super(**)

    forms << "#{name.to_s.camelize}Form" if forms.empty?

    @forms = forms.map { |f| constantize_form(f) }
    @name = name
    # @rows = []
  end

  private

  def before_render
    with_field_div_sets(@forms.map { |f| { form: f } })
  end

  def default_classes
    %w[review-component__section]
  end

  def render_divs_for_fields(form_model)
    fields = form_model.fields.map { |field| field.is_a?(Hash) ? field.keys.first : field }
    safe_join(fields.map { |field| tag.div(id: field) })
  end
end
