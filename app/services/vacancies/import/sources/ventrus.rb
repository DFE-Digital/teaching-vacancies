class Vacancies::Import::Sources::Ventrus
  include Vacancies::Import::Shared

  FEED_URL = ENV.fetch("VACANCY_SOURCE_VENTRUS_FEED_URL").freeze
  VENTRUS_TRUST_UID = "4243".freeze
  SOURCE_NAME = "ventrus".freeze

  class FeedItem
    def initialize(xml_node)
      @xml_node = xml_node
    end

    def [](key, root: false)
      @xml_node.at_xpath(root ? key : "a10:content/Vacancy/#{key}")&.text&.presence
    end
  end

  include Enumerable

  def self.source_name
    SOURCE_NAME
  end

  def each
    items.each do |item|
      schools = find_schools(item)
      next if schools.blank?
      next if vacancy_listed_at_excluded_school_type?(schools)

      # An external vacancy is by definition always published
      v = PublishedVacancy.find_or_initialize_by(
        external_source: SOURCE_NAME,
        external_reference: item["VacancyID"],
      )

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
      job_title: item["Vacancy_title"],
      job_advert: Rails::Html::WhiteListSanitizer.new.sanitize(item["Advert_text"], tags: %w[p br]),
      salary: item["Salary"],
      expires_at: Time.zone.parse(item["Expiry_date"]),
      external_advert_url: item["link", root: true],

      job_roles: job_roles_for(item),
      ect_status: ect_status_for(item),
      key_stages: item["Key_Stage"].presence&.split(","),
      # subjects: item["Subjects"].presence&.split(",") || [], # Ventrus don't have subjects in their feed
      working_patterns: working_patterns_for(item),
      contract_type: contract_type_for(item),
      is_parental_leave_cover: parental_leave_cover_for?(item),
      phases: phase_for(item),
      visa_sponsorship_available: visa_sponsorship_available_for?(item),
      is_job_share: job_share_for?(item),
      religion_type: religion_type_for(item),
    }.merge(organisation_fields(schools))
  end

  def working_patterns_for(item)
    return [] if item["Working_Patterns"].blank?

    item["Working_Patterns"].delete(" ").split(",").map { |pattern|
      if Vacancies::Import::Shared::LEGACY_WORKING_PATTERNS.include?(pattern)
        "part_time"
      else
        pattern
      end
    }.uniq
  end

  def job_share_for?(item)
    item["Working_Patterns"]&.include?("job_share")
  end

  def ect_status_for(item)
    case item["ECT_Suitable"]
    when "True", "true" then "ect_suitable"
    else "ect_unsuitable"
    end
  end

  def organisation_fields(schools)
    first_school = schools.first

    {
      organisations: schools,
      readable_job_location: first_school&.name,
      about_school: first_school&.description,
    }
  end

  # All the vacancies in the feed must belong to Ventrus trust schools
  def find_schools(item)
    return [] if item["TrustUID"] != VENTRUS_TRUST_UID

    multi_academy_trust = SchoolGroup.trusts.find_by(uid: item["TrustUID"])
    return [] if multi_academy_trust.blank?

    school_urns = item["URN"]&.split(",")
    schools = Organisation.where(urn: school_urns) if school_urns.present?
    return Array(multi_academy_trust) if schools.blank?

    # When having both trust and schools, only return the schools that are in the trust if any. Otherwise, return the trust itself.
    multi_academy_trust.schools.where(urn: school_urns).order(:created_at).presence || Array(multi_academy_trust)
  end

  def job_roles_for(item)
    roles = item["Job_Roles"]&.strip&.split(",")
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

  def phase_for(item)
    return if item["Phase_"].blank?

    item["Phase_"].strip
                 .parameterize(separator: "_")
                 .gsub("through_school", "through")
                 .gsub(/16-19|16_19/, "sixth_form_or_college")
  end

  def contract_type_for(item)
    return "fixed_term" if item["Contract_Type"] == "parental_leave_cover"

    item["Contract_Type"].presence
  end

  def parental_leave_cover_for?(item)
    item["Contract_Type"] == "parental_leave_cover"
  end

  def visa_sponsorship_available_for?(item)
    item["Visa_Sponsorship_Available"] == "true"
  end

  def religion_type_for(item)
    religion_type = item["Religion_Type"].presence
    return "no_religion" if religion_type.blank? || religion_type == "nil"

    religion_type
  end

  def items
    feed.xpath("//item").map { |fi| FeedItem.new(fi) }
  end

  def feed
    @feed ||= Nokogiri::XML(HTTParty.get(FEED_URL).body)
  end
end
