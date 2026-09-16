# frozen_string_literal: true

module ReadableVacancyHelper
  def vacancy_readable_visa_sponsorship_availability(model)
    ["visa sponsorship"] if model.visa_sponsorship_available
  end

  def school_group_names
    organisations.map { |organisation|
      if organisation.is_a?(SchoolGroup)
        organisation.name
      else
        organisation.school_groups.map(&:name).compact_blank
      end
    }.flatten.uniq
  end

  def school_group_types
    organisations.map { |organisation|
      if organisation.is_a?(SchoolGroup)
        organisation.group_type
      else
        organisation.school_groups.map(&:group_type).compact_blank
      end
    }.flatten.uniq
  end

  def religious_character
    organisations.filter_map { |organisation| organisation.religious_character if organisation.is_a?(School) }
  end
end
