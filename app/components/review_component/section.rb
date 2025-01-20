# This is an abstract class.
# See JobApplicationReviewComponent::Section for specific implementation.
class ReviewComponent::Section < ApplicationComponent
  include FormsHelper
  include StatusTagHelper

  renders_many :field_div_sets, ->(f = nil, form: nil) { render_divs_for_fields(f || form) }

  class RowData
    attr_reader :key, :value

    def with_key(text:)
      @key = text
    end

    def with_value(text:)
      @value = text
    end
  end

  attr_reader :rows

  def initialize(record, name:, id: nil, forms: [], **)
    super(**)

    forms << "#{name.to_s.camelize}Form" if forms.empty?

    @forms = forms.map { |f| constantize_form(f) }
    @id = id || name
    @name = name
    @record = record
    @rows = []
  end

  def with_row
    row_data = RowData.new
    yield(row_data) if block_given?
    @rows << row_data
  end

  private

  def before_render
    with_field_div_sets(@forms.map { |f| { form: f } })
  end

  attr_reader :id

  def default_classes
    %w[review-component__section]
  end

  def heading_text
    raise "Not implemented"
  end

  def build_list
    raise "Not implemented"
  end

  def constantize_form(_form_class_name)
    raise "Not implemented"
  end

  def error_path
    raise "Not implemented"
  end

  def allow_edit?
    true
  end
end
