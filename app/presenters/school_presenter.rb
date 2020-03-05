class SchoolPresenter < BasePresenter
  def school_type_with_religious_character
    model.has_religious_character? ?
      model.school_type.label + ', ' + model.gias_data['religious_character'] :
      model.school_type.label
  end

  def location
    [model.name, model.town, model.county].reject(&:blank?).join(', ')
  end

  def full_address
    [model.address, model.town, model.county, model.postcode].compact.join(', ')
  end

  def age_range
    if model.minimum_age && model.maximum_age?
      "#{model.minimum_age} to #{model.maximum_age}"
    else
      I18n.t('schools.not_given')
    end
  end
end
