module FormsHelper
  def render_divs_for_fields(form_model)
    fields = form_model.fields.map { |field| field.is_a?(Hash) ? field.keys.first : field }
    safe_join(fields.map { |field| tag.div(id: field) })
  end
end
