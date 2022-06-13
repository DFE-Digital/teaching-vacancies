# This is an abstract class.  See VacancyReviewComponent::Section or
# JobApplicationReviewComponent::Section for specific implementations.
class ReviewComponent::Section < ApplicationComponent
  include FormsHelper
  include StatusTagHelper

  renders_one :heading, ReviewComponent::Section::Heading
  renders_many :field_div_sets, ->(f = nil, form: nil) { render_divs_for_fields(f || form) }

  delegate :row, to: :@list

  def initialize(record, name:, id: nil, forms: [], **kwargs)
    super(**kwargs)

    forms << "#{name.to_s.camelize}Form" if forms.empty?

    @forms = forms.map { |f| constantize_form(f) }
    @id = id || name
    @name = name
    @record = record
  end

  private

  def before_render
    field_div_sets(@forms.map { |f| { form: f } })

    heading(title: heading_text, link_to: [error_link_text, error_path], allow_edit: allow_edit?) do
      review_section_tag(@record, @forms.map(&:target_name), @forms)
    end

    @list = build_list
  end

  def content
    # Calling `super` here has side-effects which
    # affect the contents of `@list.rows`.
    super_content = super

    if @list.rows.any?
      render(@list)
    else
      super_content
    end
  end

  attr_reader :id

  def default_attributes
    { class: %w[review-component__section] }
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

  def error_link_text
    raise "Not implemented"
  end

  def allow_edit?
    true
  end
end
