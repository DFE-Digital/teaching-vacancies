module OrganisationsHelper
  include AddressHelper

  OFSTED_REPORT_ENDPOINT = "https://reports.ofsted.gov.uk/oxedu_providers/full/(urn)/".freeze
  APPLICATION_PACK_FILENAME = "teaching-vacancies-application-form-guide-sept-21.pdf".freeze

  def age_range(school)
    return t("schools.not_given") unless school.minimum_age? && school.maximum_age?

    "#{school.minimum_age} to #{school.maximum_age}"
  end

  def edit_vacancy_section_number(section, organisation)
    sections = {
      job_location: 1,
      job_details: 2,
      pay_package: 3,
      important_dates: 4,
      documents: 5,
      applying_for_the_job: 6,
      job_summary: 7,
    }
    section_number = organisation.school_group? ? sections[section] : sections[section] - 1
    "#{section_number}."
  end

  def full_address(organisation)
    address_join([organisation.address, organisation.town, organisation.county, organisation.postcode])
  end

  def change_description(organisation)
    safe_join([t("buttons.change"), tag.span(t("publishers.organisations.aria_change_description", organisation_type: organisation_type_basic(organisation)), class: "govuk-visually-hidden")])
  end

  def change_website_url(organisation)
    safe_join([t("buttons.change"), tag.span(t("publishers.organisations.aria_change_website", organisation_type: organisation_type_basic(organisation)), class: "govuk-visually-hidden")])
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
      organisation.school_type.singularize,
      organisation.religious_character,
      "ages #{organisation.minimum_age} to #{organisation.maximum_age}",
    ]

    school_type_details.reject(&:blank?).reject { |str| str == I18n.t("schools.not_given") }.join(", ")
  end

  def organisation_types(organisations)
    organisations.group_by { |org| [org.school_type, org.religious_character] }.map do |type, orgs_by_type|
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

  def school_phase(school)
    school.readable_phases&.map(&:capitalize)&.reject(&:blank?)&.join(", ")
  end

  def school_size(school)
    if school.gias_data.present?
      return number_of_pupils(school) if school.gias_data["NumberOfPupils"].present?
      return school_capacity(school) if school.gias_data["SchoolCapacity"].present?
    end
    I18n.t("schools.no_information")
  end

  def organisation_url(school)
    if school.website?
      school.website
    elsif school.url?
      school.url
    else
      false
    end
  end

  def application_pack_asset_size
    (File.size("public/#{APPLICATION_PACK_FILENAME}") / 1.0.megabyte).round(2)
  end

  def application_pack_asset_path
    ActionController::Base.helpers.asset_path(APPLICATION_PACK_FILENAME)
  end

  def show_application_reminder?(vacancy, publisher, session_show)
    !vacancy.nil? &&
      session_show &&
      !publisher.viewed_application_feature_reminder_page_at &&
      publisher.viewed_new_features_page_at &&
      vacancy.updated_at > publisher.viewed_new_features_page_at &&
      !vacancy.enable_job_applications
  end

  private

  def number_of_pupils(school)
    I18n.t("schools.size.enrolled", pupils: pupils, number: school.gias_data["NumberOfPupils"])
  end

  def school_capacity(school)
    I18n.t("schools.size.up_to", capacity: school.gias_data["SchoolCapacity"], pupils: pupils)
  end

  def pupils
    I18n.t("schools.size.pupils").pluralize
  end
end
