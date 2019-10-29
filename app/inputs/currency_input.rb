class CurrencyInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    content_tag(:div, input_group(merged_input_options), class: 'currency-input')
  end

  private

  def input_group(merged_input_options)
    content_tag(:div, '£', class: 'currency-input__symbol', aria: { hidden: true }) +
      @builder.text_field(attribute_name, merged_input_options)
  end
end
