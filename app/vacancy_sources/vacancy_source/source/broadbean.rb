class VacancySource::Source::Broadbean
  include VacancySource::Parser
  include VacancySource::Shared

  FEED_URL = ENV.fetch("VACANCY_SOURCE_BROADBEAN_FEED_URL").freeze
  SOURCE_NAME = "broadbean".freeze

  # Helper class for less verbose handling of items in the feed
  class FeedItem
    def initialize(xml_node)
      @xml_node = xml_node
    end

    def [](key)
      @xml_node.xpath(key)&.text&.presence
    end
  end

  include Enumerable

  def self.source_name
    SOURCE_NAME
  end

  def each
    items.each do |item|
      schools = find_schools(item)
      next if vacancy_listed_at_excluded_school_type?(schools)

      v = Vacancy.find_or_initialize_by(
        external_source: SOURCE_NAME,
        external_reference: item["reference"],
      )

      # An external vacancy is by definition always published
      v.status = :published
      # Consider publish_on date to be the first time we saw this vacancy come through
      # (i.e. today, unless it already has a publish on date set)
      v.publish_on ||= Date.today

      begin
        v.assign_attributes(attributes_for(item, schools))
      rescue ArgumentError => e
        v.errors.add(:base, e)
      end

      yield v
    end
  end

  def attributes_for(item, schools)
    {
      job_title: item["jobTitle"],
      job_advert: item["jobAdvert"],
      salary: item["salary"],
      expires_at: Time.zone.parse(item["expiresAt"]),
      external_advert_url: item["advertUrl"],

      # New structured fields
      job_roles: job_roles_for(item),
      ect_status: ect_status_for(item),
      subjects: item["subjects"].presence&.split(",") || [],
      working_patterns: item["workingPatterns"].presence&.split(","),
      contract_type: item["contractType"].presence,
      phases: phase_for(item),
      visa_sponsorship_available: visa_sponsorship_available_for(item),
    }.merge(organisation_fields(schools))
     .merge(start_date_fields(item))
  end

  def start_date_fields(item)
    return {} if item["startDate"].blank?

    parsed_date = StartDate.new(item["startDate"])
    if parsed_date.specific?
      { starts_on: parsed_date.date, start_date_type: parsed_date.type }
    else
      { other_start_date_details: parsed_date.date, start_date_type: parsed_date.type }
    end
  end

  def job_roles_for(item)
    roles = item["jobRole"]&.strip&.split(",")
    return [] if roles.blank?

    roles.flat_map do |role|
      # Translate legacy senior/middle leader into all the granular roles split from them
      if role == "senior_leader"
        Vacancy::SENIOR_LEADER_JOB_ROLES
      elsif role == "middle_leader"
        Vacancy::MIDDLE_LEADER_JOB_ROLES
      else
        Array.wrap(role.gsub("deputy_headteacher_principal", "deputy_headteacher")
                       .gsub("assistant_headteacher_principal", "assistant_headteacher")
                       .gsub("headteacher_principal", "headteacher")
                       .gsub(/head_of_year_or_phase|head_of_year/, "head_of_year_or_phase")
                       .gsub(/learning_support|other_support|science_technician/, "other_support")
                       .gsub(/\s+/, ""))
      end
    end
  end

  def ect_status_for(item)
    item["ectSuitable"] == "true" ? "ect_suitable" : "ect_unsuitable"
  end

  def phase_for(item)
    return if item["phase"].blank?

    item["phase"].strip
                 .gsub(/all_through|through_school/, "through")
                 .gsub(/16-19|16_19/, "sixth_form_or_college")
  end

  def visa_sponsorship_available_for(item)
    item["visaSponsorshipAvailable"] == "true"
  end

  def organisation_fields(schools)
    first_school = schools.first

    {
      organisations: schools,
      readable_job_location: first_school&.name,
      about_school: first_school&.description,
    }
  end

  def find_schools(item)
    multi_academy_trust = SchoolGroup.trusts.find_by(uid: item["trustUID"])
    school_urns = item["schoolUrns"]&.split(",")

    return [] if multi_academy_trust.blank? && school_urns.blank?
    return Organisation.where(urn: school_urns) if multi_academy_trust.blank?
    return Array(multi_academy_trust) if school_urns.blank?

    # When having both trust and schools, only return the schools that are in the trust if any. Otherwise, return the trust itself.
    multi_academy_trust.schools.where(urn: school_urns).order(:created_at).presence || Array(multi_academy_trust)
  end

  def items
    feed.xpath("//item").map { |fi| FeedItem.new(fi) }
  end

  def feed
    @feed ||= Nokogiri::XML(HTTParty.get(FEED_URL).body)
  end
end
