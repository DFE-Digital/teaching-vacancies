class Vacancies::Import::Sources::Ark
  include Vacancies::Import::Parser
  include Vacancies::Import::Shared

  FEED_URL = ENV.fetch("VACANCY_SOURCE_ARK_FEED_URL").freeze
  SOURCE_NAME = "ark".freeze
  TRUST_UID = "2157".freeze

  # Helper class for less verbose handling of items in the feed
  class FeedItem
    def initialize(xml_node)
      @xml_node = xml_node
    end

    def [](key, namespace = nil)
      node = if namespace
               @xml_node.xpath(".//#{namespace}:#{key}")
             else
               @xml_node.xpath(".//#{key}")
             end
      node&.text&.presence
    end

    def fetch_by_attribute(element_name, attribute_name, attribute_value, namespace = nil)
      query = ".//#{namespace}:#{element_name}[@#{attribute_name}='#{attribute_value}']" if namespace
      query ||= ".//#{element_name}[@#{attribute_name}='#{attribute_value}']"
      @xml_node.xpath(query)&.text&.presence
    end

    def supp_value
      query = ".//category[@domain='School/Network']/@suppValue"
      @xml_node.xpath(query)&.first&.value&.presence
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
        external_reference: item["vacancyid", "engAts"],
      )

      # An external vacancy is by definition always published
      v.status = :published

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
      job_title: item["title"],
      job_advert: item["jobdescription", "engAts"],
      salary: salary_range_for(item),
      expires_at: (Time.zone.parse(item["endDate", "engAts"]) if item["endDate", "engAts"].present?),
      external_advert_url: item["advertUrl", "engAts"],
      job_roles: job_roles_for(item),
      ect_status: ect_status_for(item),
      subjects: item["subjects"].presence&.split(",") || [],
      working_patterns: working_patterns_for(item),
      contract_type: contract_type_for(item),
      phases: phases_for(item),
      publish_on: publish_on_for(item),
      visa_sponsorship_available: visa_sponsorship_available_for(item),
      is_job_share: is_job_share_for(item)
    }.merge(organisation_fields(schools))
    .merge(start_date_fields(item))
  end

  # Consider publish_on date to be the first time we saw this vacancy come through
  # (i.e. today, unless it already has a publish on date set)
  def publish_on_for(item)
    if item["pubDate"].present?
      Date.parse(item["pubDate"])
    else
      Date.today
    end
  end

  def salary_range_for(item)
    from = item["salaryRangeFrom", "engAts"]
    to = item["salaryRangeTo", "engAts"]

    if from.present? && to.present?
      "#{from} - #{to}"
    elsif from.present?
      "From #{from}"
    elsif to.present?
      "Up to #{to}"
    end
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

  # rubocop:disable Metrics/MethodLength
  def job_roles_for(item)
    roles = item.fetch_by_attribute("category", "domain", "Role Type")&.strip&.split(",")
    return [] if roles.blank?

    roles.flat_map do |role|
      Array.wrap(role.strip
        .gsub(/^Teacher$|Cover Support Teacher|TLRs|Lead Practitioner|Trainee Teacher|Peripatetic Music/, "teacher")
        .gsub(/^Principal$|Head of School|Associate Principal|Executive Principal/, "headteacher")
        .gsub("Vice Principal", "deputy_headteacher")
        .gsub("Assistant Principal", "assistant_headteacher")
        .gsub(/Head of Department|Head of Dept/, "head_of_department_or_curriculum")
        .gsub(/Head of Year|Head of Phase/, "head_of_year_or_phase")
        .gsub(/Teaching Assistant|Cover Support Teaching Assistant/, "teaching_assistant")
        .gsub(%r{SEN/Inclusion Support|Technician|Librarian}, "education_support")
        .gsub("SEN/Inclusion Teacher", "sendco")
        .gsub(/Finance|HR|School Admin|Data/, "administration_hr_data_and_finance")
        .gsub(/Estates & Premises|Catering|Cleaning/, "catering_cleaning_and_site_management")
        .gsub(/Pastoral|School Nurse/, "pastoral_health_and_welfare")
        .gsub("Operations Leadership", "other_leadership")
        .gsub(/School Marketing and Comms|Governance|Exam Invigilator/, "other_support"))
    end
  end
  # rubocop:enable Metrics/MethodLength

  def ect_status_for(item)
    item["ectSuitable"] == "yes" ? "ect_suitable" : "ect_unsuitable"
  end

  def working_patterns_for(item)
    item.fetch_by_attribute("category", "domain", "Working Pattern")
    .gsub("Full Time", "full_time")
    .gsub(/Part Time|Casual|Flexible|Term Time|Job Share/, "part_time")
  end

  def is_job_share_for(item)
    item.fetch_by_attribute("category", "domain", "Working Pattern") == "Job Share"
  end

  def contract_type_for(item)
    item.fetch_by_attribute("category", "domain", "Contract Type")
    .gsub("Permanent", "permanent")
    .gsub(/Fixed Term|Casual/, "fixed_term")
  end

  def phases_for(item)
    item.fetch_by_attribute("category", "domain", "Phase")
    .gsub("Nursery", "nursery")
    .gsub("Primary", "primary")
    .gsub("Secondary", "secondary")
    .gsub("All-through", "through")
    .gsub(/\s+/, "")
  end

  def visa_sponsorship_available_for(item)
    item["engAts:visaSponsorshipAvailable"] == "true"
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
    multi_academy_trust = SchoolGroup.trusts.find_by(uid: TRUST_UID)
    school_urn = item.supp_value

    return [] if multi_academy_trust.blank? && school_urn.blank?
    return Organisation.where(urn: school_urn) if multi_academy_trust.blank?
    return Array(multi_academy_trust) if school_urn.blank?

    # When having both trust and schools, only return the schools that are in the trust if any. Otherwise, return the trust itself.
    multi_academy_trust.schools.where(urn: school_urn).order(:created_at).presence || Array(multi_academy_trust)
  end

  def items
    feed.xpath("//item").map { |fi| FeedItem.new(fi) }
  end

  def feed
    @feed ||= Nokogiri::XML(HTTParty.get(FEED_URL).body)
  end
end
