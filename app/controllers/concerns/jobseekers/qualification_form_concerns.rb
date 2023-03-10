module Jobseekers::QualificationFormConcerns
  extend ActiveSupport::Concern

  def qualification_form_param_key(category)
    ActiveModel::Naming.param_key(category_form_class(category))
  end

  def category_form_class(category)
    name = if %w[select_category submit_category].include?(action_name)
             "CategoryForm"
           elsif %w[confirm_destroy].include?(action_name)
             "DeleteForm"
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
    "Jobseekers::Qualifications::#{name}".constantize
  end
end
