module QualificationFormConcerns
  extend ActiveSupport::Concern

  def qualification_form_param_key(category)
    form_class(category).to_s.underscore.tr("/", "_").to_sym
  end

  def form_class(category)
    name = if %w[select_category submit_category].include?(action_name)
             "CategoryForm"
           else
             case category
             when "gcse", "a_level", "as_level"
               "Secondary::CommonForm"
             when "other_secondary"
               "Secondary::OtherForm"
             when "undergraduate", "postgraduate"
               "DegreeForm"
             when "other"
               "OtherForm"
             end
           end
    "Jobseekers::JobApplication::Details::Qualifications::#{name}".constantize
  end
end
