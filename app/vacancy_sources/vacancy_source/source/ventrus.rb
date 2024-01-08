class VacancySource::Source::Ventrus
  include VacancySource::Shared

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
      next if vacancy_listed_at_excluded_school_type?(schools)

      v = Vacancy.find_or_initialize_by(
        external_source: SOURCE_NAME,
        external_reference: item["VacancyID"],
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
      job_title: item["Vacancy_title"],
      job_advert: Rails::Html::WhiteListSanitizer.new.sanitize(item["Advert_text"], tags: %w[p br]),
      salary: item["Salary"],
      expires_at: Time.zone.parse(item["Expiry_date"]),
      external_advert_url: item["link", root: true],

      job_roles: job_roles_for(item),
      ect_status: ect_status_for(item),
      key_stages: item["Key_Stage"].presence&.split(","),
      # subjects: item["Subjects"].presence&.split(","),
      working_patterns: item["Working_Patterns"].presence&.split(","),
      contract_type: item["Contract_Type"].presence,
      phases: phase_for(item),
      visa_sponsorship_available: visa_sponsorship_available_for(item),
    }.merge(organisation_fields(schools))
  end

  def ect_status_for(item)
    return unless item["ECT_Suitable"].presence

    item["ECT_Suitable"] == "yes" ? "ect_suitable" : "ect_unsuitable"
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
    multi_academy_trust = SchoolGroup.trusts.find_by(uid: VENTRUS_TRUST_UID)

    multi_academy_trust&.schools&.where(urn: item["URN"]).presence ||
      Organisation.where(urn: item["URN"]).presence ||
      Array(multi_academy_trust)
  end

  def job_roles_for(item)
    role = item["Job_Roles"]&.strip
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
    return if item["Phase_"].blank?

    item["Phase_"].strip
                 .parameterize(separator: "_")
                 .gsub("through_school", "through")
                 .gsub(/16-19|16_19/, "sixth_form_or_college")
  end

  def visa_sponsorship_available_for(item)
    item["Visa_Sponsorship_Available"] == "true"
  end

  def items
    feed.xpath("//item").map { |fi| FeedItem.new(fi) }
  end

  def feed
    @feed ||= Nokogiri::XML(HTTParty.get(FEED_URL).body)
  end
end
