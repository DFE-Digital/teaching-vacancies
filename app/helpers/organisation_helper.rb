module OrganisationHelper
  include AddressHelper

  OFSTED_REPORT_ENDPOINT = 'https://reports.ofsted.gov.uk/oxedu_providers/full/(urn)/'.freeze

  def location(organisation, job_location: nil)
    return "#{I18n.t('hiring_staff.organisations.readable_job_location.at_multiple_schools')}, #{organisation.name}" if
      job_location.presence == 'at_multiple_schools'

    address_join([organisation.name, organisation.town, organisation.county])
  end

  def full_address(organisation)
    address_join([organisation.address, organisation.town, organisation.county, organisation.postcode])
  end

  def organisation_type(organisation:, with_age_range: false)
    return organisation.group_type unless organisation.is_a?(School)

    school_type_details = [organisation.school_type.singularize, organisation.religious_character]
    school_type_details.push age_range(organisation) if with_age_range
    school_type_details.reject(&:blank?).reject { |str| str == I18n.t('schools.not_given') }.join(', ')
  end

  def organisation_types(organisations)
    organisations.map { |organisation| organisation_type(organisation: organisation, with_age_range: true) }
                 .uniq.join(', ')
  end

  def organisation_type_basic(organisation)
    if organisation.is_a?(School)
      'school'
    elsif organisation.group_type == 'local_authority'
      'local authority'
    else
      'trust'
    end
  end

  def school_phase(school)
    school.readable_phases&.map(&:capitalize)&.reject(&:blank?)&.join(', ')
  end

  def school_size(school)
    if school.gias_data.present?
      return number_of_pupils(school) if school.gias_data['NumberOfPupils'].present?
      return school_capacity(school) if school.gias_data['SchoolCapacity'].present?
    end
    I18n.t('schools.no_information')
  end

  def ofsted_report(school)
    OFSTED_REPORT_ENDPOINT + school.urn
  end

  def age_range(school)
    return I18n.t('schools.not_given') unless school.minimum_age? && school.maximum_age?

    "#{school.minimum_age} to #{school.maximum_age}"
  end

  def edit_vacancy_section_number(section, organisation)
    sections = {
      job_location: 1,
      job_details: 2,
      pay_package: 3,
      important_dates: 4,
      supporting_documents: 5,
      application_details: 6,
      job_summary: 7,
    }
    section_number = organisation.is_a?(SchoolGroup) ? sections[section] : sections[section] - 1
    "#{section_number}."
  end

private

  def number_of_pupils(school)
    I18n.t('schools.size.enrolled', pupils: pupils, number: school.gias_data['NumberOfPupils'])
  end

  def school_capacity(school)
    I18n.t('schools.size.up_to', capacity: school.gias_data['SchoolCapacity'], pupils: pupils)
  end

  def pupils
    I18n.t('schools.size.pupils').pluralize
  end
end
