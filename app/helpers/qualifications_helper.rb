module QualificationsHelper
  QUALIFICATIONS_ORDER = %w[
    postgraduate
    undergraduate
    a_level
    as_level
    gcse
    other_secondary
    other
  ].freeze

  def qualifications_sort_and_group(qualifications)
    qualifications.sort_by { |q| QUALIFICATIONS_ORDER.index(q[:category]) }.group_by { |q| q[:category] }
  end
end
