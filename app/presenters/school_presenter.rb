class SchoolPresenter < BasePresenter
  def school_type_with_religious_character
    model.has_religious_character? ?
      model.school_type.label + ', ' + model.gias_data['religious_character'] :
      model.school_type.label
  end

  def location
    [model.name, model.town, model.county].reject(&:blank?).join(', ')
  end

  def school_size
    if model.gias_data.present?
      return model.gias_data['NumberOfPupils'] + ' pupils enrolled' if model.gias_data['NumberOfPupils'].present?
      return 'Up to ' + model.gias_data['SchoolCapacity'] + 'pupils' if model.gias_data['SchoolCapacity'].present?
    end
    'No data available'
  end

  def ofsted_report
    if model.gias_data.present?
      "https://www.ofsted.gov.uk/oxedu_providers/full/(urn)/#{model.gias_data['URN']}"
    end
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
