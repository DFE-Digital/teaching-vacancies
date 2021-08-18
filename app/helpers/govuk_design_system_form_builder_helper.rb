module GovukDesignSystemFormBuilderHelper
  def collection_options_with_hints(form, field)
    # https://govuk-form-builder.netlify.app/form-elements/radios/#radio-buttons-collection-with-descriptions

    form_name = form.class.to_s.underscore.tr("/", "_")

    I18n.t("helpers.label.#{form_name}.#{field}_options").map do |key, value|
      hint = I18n.t("helpers.hints.#{form_name}.#{field}_options.#{key}", default: nil)

      OpenStruct.new(id: key, name: value, hint: hint)
    end
  end
end
