module FormsHelper
  def render_divs_for_fields(form_model)
    safe_join(form_model.fields.map { |field| tag.div(id: field) })
  end
end
