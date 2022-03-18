class EditorComponent < ApplicationComponent
  def initialize(form_input:, value:, field_name:, hint: nil, label: {}, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes.merge({ data: { controller: "editor" } }))

    @field_name = field_name
    @label = label
    @hint = hint
    @value = value
    @form_input = form_input
  end

  private

  def default_classes
    %w[editor-component]
  end
end
