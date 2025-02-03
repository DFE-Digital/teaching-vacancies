module QualificationsHelper
  QUALIFICATIONS_ORDER = %w[
    postgraduate
    undergraduate
    a_level
    as_level
    gcse
    other
  ].freeze

  def qualifications_sort_and_group(qualifications)
    qualifications.sort_by { |q| QUALIFICATIONS_ORDER.index(q[:category]) }.group_by { |q| q[:category] }
  end

  def qualifications_group_category_other?(qualifications)
    qualifications.all? { |qualification| qualification.category == "other" }
  end

  def display_secondary_qualification(res)
    if res.awarding_body.blank?
      "#{res.subject} – #{res.grade}"
    else
      "#{res.subject} – #{res.grade} (#{res.awarding_body})"
    end
  end
end
