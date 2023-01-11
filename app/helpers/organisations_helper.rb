module OrganisationsHelper
  include AddressHelper

  OFSTED_REPORT_ENDPOINT = "https://reports.ofsted.gov.uk/oxedu_providers/full/(urn)/".freeze

  def age_range(school)
    return I18n.t("vacancies.listing.schools.not_given") unless school.minimum_age? && school.maximum_age?

    "#{school.minimum_age} to #{school.maximum_age}"
  end

  def full_address(organisation)
    address_join([organisation.address, organisation.town, organisation.county, organisation.postcode])
  end

  def location(organisation)
    address_join([organisation.name, organisation.town, organisation.county])
  end

  def ofsted_report(school)
    OFSTED_REPORT_ENDPOINT + school.urn
  end

  def organisation_type(organisation)
    return organisation.group_type if organisation.school_group?

    school_type_details = [
      organisation.school_type,
      organisation.religious_character,
      "ages #{organisation.minimum_age} to #{organisation.maximum_age}",
    ]

    school_type_details.reject(&:blank?).reject { |str| str == I18n.t("schools.not_given") }.join(", ")
  end

  def organisation_types(organisations)
    organisations.select(&:school?).group_by { |org| [org.school_type, org.religious_character] }.map do |type, orgs_by_type|
      type_for_display = [pluralize(orgs_by_type.count, type.first.downcase.singularize), type.last].reject(&:blank?)
                                                                                                    .join(", ")
      "#{type_for_display}, ages #{orgs_by_type.map(&:minimum_age).min} to #{orgs_by_type.map(&:maximum_age).max}"
    end
  end

  def organisation_type_basic(organisation)
    if organisation.school?
      "school"
    elsif organisation.local_authority?
      "local authority"
    else
      "trust"
    end
  end

  def school_or_trust_visits(organisation)
    if organisation.trust?
      "trust_visits_html"
    else
      "school_visits_html"
    end
  end

  def school_size(school)
    if school.gias_data.present?
      return number_of_pupils(school) if school.gias_data["NumberOfPupils"].present?
      return school_capacity(school) if school.gias_data["SchoolCapacity"].present?
    end
    I18n.t("vacancies.listing.schools.no_information")
  end

  def school_has_school_size_data?(school)
    school.gias_data["NumberOfPupils"].present? || school.gias_data["SchoolCapacity"].present?
  end

  def school_is_part_of_a_trust?(school)
    school.school_groups.any?(&:trust?)
  end

  def required_profile_info(value:, missing_prompt:)
    return value if value.present?

    missing_profile_information_notification(missing_prompt)
  end

  def required_profile_image(image:, missing_prompt:, alt_text:)
    return image_tag(image, alt: alt_text, class: "contained-image") if image.present?

    missing_profile_information_notification(missing_prompt)
  end

  private

  def number_of_pupils(school)
    return unless (number = school.gias_data["NumberOfPupils"])

    I18n.t("vacancies.listing.schools.size.enrolled", pupils: pupils, number: number)
  end

  def school_capacity(school)
    I18n.t("vacancies.listing.schools.size.up_to", capacity: school.gias_data["SchoolCapacity"])
  end

  def pupils
    I18n.t("schools.size.pupils").pluralize
  end

  def missing_profile_information_notification(prompt)
    content_tag(:div, class: %i[govuk-inset-text govuk-inset-text--dark-blue inset-text--narrow-border]) do
      [
        content_tag(:p, prompt, class: %i[govuk-inset-text--header]),
        content_tag(:p, t("publishers.organisations.organisation.not_provided")),
      ].join.html_safe
    end
  end
end
