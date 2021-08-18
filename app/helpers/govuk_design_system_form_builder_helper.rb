module GovukDesignSystemFormBuilderHelper
  def collection_options_with_hints(form, field)
    # https://govuk-form-builder.netlify.app/form-elements/radios/#radio-buttons-collection-with-descriptions
    I18n.t("helpers.label.#{underscore_form_name(form)}.#{field}_options").map do |key, value|
      hint = I18n.t("helpers.hints.#{underscore_form_name(form)}.#{field}_options.#{key}", default: nil)

      OpenStruct.new(id: key, name: value, hint: hint)
    end
  end

  def underscore_form_name(form)
    form.class.to_s.underscore.tr("/", "_")
  end
end
