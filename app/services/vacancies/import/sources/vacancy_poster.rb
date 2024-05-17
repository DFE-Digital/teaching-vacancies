require "cgi"

class Vacancies::Import::Sources::VacancyPoster
  FEED_URL = ENV.fetch("VACANCY_SOURCE_VACANCY_POSTER_FEED_URL").freeze
  VENTRUS_TRUST_UID = "".freeze
  SOURCE_NAME = "vacancy_poster".freeze

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
      v = Vacancy.find_or_initialize_by(
        external_source: SOURCE_NAME,
        external_reference: item["reference"]&.strip,
      )

      # An external vacancy is by definition always published
      v.status = :published
      # Consider publish_on date to be the first time we saw this vacancy come through
      # (i.e. today, unless it already has a publish on date set)
      v.publish_on ||= Date.today

      begin
        v.assign_attributes(attributes_for(item))
      rescue ArgumentError => e
        v.errors.add(:base, e)
      end

      yield v
    end
  end

  def attributes_for(item)
    {
      job_title: item["jobTitle"],
      job_advert: job_advert_for(item),
      salary: item["salary"],
      expires_at: Time.zone.parse(item["expiresAt"]),
      external_advert_url: item["advertUrl"]&.strip,

      job_roles: job_roles_for(item),
      ect_status: ect_status_for(item),
      key_stages: item["keyStages"].presence&.split(","),
      subjects: item["subjects"].presence&.split(","),
      working_patterns: item["workingPatterns"].presence&.split(","),
      contract_type: item["contractType"].presence,
      phases: phase_for(item),
      visa_sponsorship_available: false,
    }.merge(organisation_fields(item))
  end

  def job_advert_for(item)
    sanitised_text = Rails::Html::WhiteListSanitizer.new.sanitize(item["jobAdvert"], tags: %w[p br])
    CGI.unescapeHTML(sanitised_text)
  end

  def ect_status_for(item)
    return unless item["ectSuitable"].presence

    item["ectSuitable"] == "yes" ? "ect_suitable" : "ect_unsuitable"
  end

  def organisation_fields(item)
    schools = find_schools(item)
    first_school = schools.first

    {
      organisations: schools,
      readable_job_location: first_school&.name,
      about_school: first_school&.description,
    }
  end

  def find_schools(item)
    multi_academy_trust = SchoolGroup.trusts.find_by(uid: item["trustUID"]&.strip)

    multi_academy_trust&.schools&.where(urn: item["schoolUrns"]&.strip).presence ||
      Organisation.where(urn: item["schoolUrns"]).presence ||
      Array(multi_academy_trust)
  end

  def job_roles_for(item)
    role = item["jobRole"]&.strip
    return [] if role.blank?

    # Translate legacy senior/middle leader into all the granular roles split from them
    return Vacancy::SENIOR_LEADER_JOB_ROLES if role.include? "senior_leader"
    return Vacancy::MIDDLE_LEADER_JOB_ROLES if role.include? "middle_leader"

    Array.wrap(role.gsub("deputy_headteacher_principal", "deputy_headteacher")
               .gsub("assistant_headteacher_principal", "assistant_headteacher")
               .gsub("headteacher_principal", "headteacher")
               .gsub(/head_of_year_or_phase|head_of_year/, "head_of_year_or_phase")
               .gsub(/learning_support|other_support|science_technician/, "education_support")
               .gsub(/\s+/, ""))
  end

  def phase_for(item)
    return if item["phase"].blank?

    item["phase"].strip
    .parameterize(separator: "_")
    .gsub("through_school", "through")
    .gsub(/16-19|16_19/, "sixth_form_or_college")
  end

  def items
    feed.xpath("//item").map { |fi| FeedItem.new(fi) }
  end

  def feed
    @feed ||= Nokogiri::XML(HTTParty.get(FEED_URL).body)
  end
end
