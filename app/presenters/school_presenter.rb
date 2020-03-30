require 'active_support/inflector'

class SchoolPresenter < BasePresenter
  OFSTED_REPORT_ENDPOINT = 'https://reports.ofsted.gov.uk/oxedu_providers/full/(urn)/'

  def school_type_with_religious_character
    school_type = model.school_type.label.singularize
    model.has_religious_character? ? school_type + ', ' + model.gias_data['ReligiousCharacter (name)'] : school_type
  end

  def location
    [model.name, model.town, model.county].reject(&:blank?).join(', ')
  end

  def school_size
    if model.gias_data.present?
      return number_of_pupils if model.gias_data['NumberOfPupils'].present?
      return school_capacity if model.gias_data['SchoolCapacity'].present?
    end
    I18n.t('schools.no_information')
  end

  def ofsted_report
    if model.gias_data.present? && model.gias_data['URN'].present?
      OFSTED_REPORT_ENDPOINT + model.gias_data['URN'].to_s
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

  private

  def number_of_pupils
    I18n.t('schools.size.enrolled', pupils: pupils, number: model.gias_data['NumberOfPupils'])
  end

  def school_capacity
    I18n.t('schools.size.up_to', capacity: model.gias_data['SchoolCapacity'], pupils: pupils)
  end

  def pupils
    I18n.t('schools.size.pupils').pluralize
  end
end
