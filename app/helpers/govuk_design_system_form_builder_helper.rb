module GovukDesignSystemFormBuilderHelper
  def options_with_bold_labels(form, field)
    # https://govuk-form-builder.netlify.app/form-elements/radios/#radio-buttons-collection-with-descriptions
    I18n.t("helpers.label.#{underscore_form_name(form)}.#{field}_options").map do |key, value|
      option = { id: key, name: value }
      hint = I18n.t("helpers.hints.#{underscore_form_name(form)}.#{field}_options.#{key}")
      option.merge({ description: hint }) unless hint.count("translation missing").positive?
      OpenStruct.new(option)
    end
  end

  def underscore_form_name(form)
    form.class.to_s.underscore.tr("/", "_")
  end
end
