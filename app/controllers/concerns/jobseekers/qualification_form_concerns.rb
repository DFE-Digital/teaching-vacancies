module Jobseekers::QualificationFormConcerns
  extend ActiveSupport::Concern

  def qualification_form_param_key(category)
    ActiveModel::Naming.param_key(category_form_class(category))
  end

  def category_form_class(category)
    name = case category
           when "gcse", "a_level", "as_level"
             "Secondary::CommonForm"
           when "undergraduate", "postgraduate"
             "DegreeForm"
           when "other"
             "OtherForm"
           end
    "Jobseekers::Qualifications::#{name}".constantize
  end
end
