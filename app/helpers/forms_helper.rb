module FormsHelper
  def render_divs_for_fields(form_model)
    # Jobseekers::JobApplication::PersonalDetailsForm has a field { working_patterns: [] } so we need to use storable fields instead.
    fields = form_model == Jobseekers::JobApplication::PersonalDetailsForm ? form_model.storable_fields : form_model.fields
    safe_join(fields.map { |field| tag.div(id: field) })
  end
end
