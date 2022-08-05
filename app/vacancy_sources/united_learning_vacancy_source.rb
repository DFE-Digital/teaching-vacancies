##
# An experimental vacancy source for a vacancy feed for United Learning.
#
# Allows enumerating over the feed's contents and yields intialized `Vacancy` objects that can be
# manipulated and persisted by calling code (e.g. an import job).
#
# Notes:
#   - Ruby's `RSS` class doesn't recognise the demo feed as an Atom feed for some reason, so this
#     uses slightly uglier vanilla XML parsing
class UnitedLearningVacancySource
  FEED_URL = ENV.fetch("VACANCY_SOURCE_UNITED_LEARNING_FEED_URL").freeze
  UNITED_LEARNING_TRUST_UID = "5143".freeze
  SOURCE_NAME = "united_learning".freeze

  # Helper class for less verbose handling of items in the feed
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

      v.assign_attributes(attributes_for(item))

      yield v
    rescue StandardError => e
      Sentry.capture_exception(e)
    end
  end

  private

  def attributes_for(item)
    {
      # Base data
      job_title: item["Vacancy_title"],
      job_advert: item["Advert_text"],
      salary: item["Salary"],
      expires_at: Time.zone.parse(item["Expiry_date"]),
      external_advert_url: item["link", root: true],

      # New structured fields
      job_role: item["Job_roles"].presence&.gsub("leadership", "senior_leader")&.gsub(/\s+/, ""),
      ect_status: ect_status_for(item),
      subjects: item["Subjects"].presence&.split(","),
      working_patterns: item["Working_patterns"].presence&.split(","),
      contract_type: item["Contract_type"].presence,
      # TODO: This is coming through unexpectedly in the feed - the parameterize call can be removed
      #       when the correct values are coming through
      phase: item["Phase"].presence&.parameterize(separator: "_"),
      organisations: organisations_for(item),
      about_school: organisations_for(item).first&.description,
    }
  end

  def ect_status_for(item)
    return unless item["ect_suitable"].presence

    item["ect_suitable"] == "yes" ? "ect_suitable" : "ect_unsuitable"
  end

  def organisations_for(item)
    # TODO: What about central office/multiple school vacancies?
    [school_group.schools.find_by(urn: item["URN"])]
  end

  def school_group
    @school_group ||= SchoolGroup.find_by(uid: UNITED_LEARNING_TRUST_UID)
  end

  def feed
    @feed ||= Nokogiri::XML(HTTParty.get(FEED_URL))
  end

  def items
    feed.xpath("//item").map { |fi| FeedItem.new(fi) }
  end
end
