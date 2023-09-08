class VacancySource::Source::Ventrus
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
        v.assign_attributes(attributes_for(item))
      rescue ArgumentError => e
        v.errors.add(:base, e)
      end

      yield v
    end
  end

  def attributes_for(item)
    {
      job_title: item["Vacancy_title"],
      job_advert: Rails::Html::WhiteListSanitizer.new.sanitize(item["Advert_text"], tags: %w[p br]),
      salary: item["Salary"],
      expires_at: Time.zone.parse(item["Expiry_date"]),
      external_advert_url: item["link", root: true],

      job_role: job_role_for(item),
      ect_status: ect_status_for(item),
      key_stages: item["Key_Stage"].presence&.split(","),
      # subjects: item["Subjects"].presence&.split(","),
      working_patterns: item["Working_Patterns"].presence&.split(","),
      contract_type: item["Contract_Type"].presence,
      phases: phases_for(item),
      visa_sponsorship_available: false,
    }.merge(organisation_fields(item))
  end

  def ect_status_for(item)
    return unless item["ECT_Suitable"].presence

    item["ECT_Suitable"] == "yes" ? "ect_suitable" : "ect_unsuitable"
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
    multi_academy_trust = SchoolGroup.trusts.find_by(uid: VENTRUS_TRUST_UID)

    multi_academy_trust&.schools&.where(urn: item["URN"]).presence ||
      Organisation.where(urn: item["URN"]).presence ||
      Array(multi_academy_trust)
  end

  def job_role_for(item)
    return if item["Job_Roles"].blank?

    item["Job_Roles"]
    .gsub(/deputy_headteacher_principal|assistant_headteacher_principal|headteacher_principal|deputy_headteacher|assistant_headteacher|headteacher/, "senior_leader")
    .gsub(/head_of_year_or_phase|head_of_department_or_curriculum|head_of_year/, "middle_leader")
    .gsub(/learning_support|other_support|science_technician/, "education_support")
    .gsub(/\s+/, "")
  end

  def phases_for(item)
    Array(item["Phase_"]).presence
  end

  def items
    feed.xpath("//item").map { |fi| FeedItem.new(fi) }
  end

  def feed
    @feed ||= Nokogiri::XML(HTTParty.get(FEED_URL).body)
  end
end
