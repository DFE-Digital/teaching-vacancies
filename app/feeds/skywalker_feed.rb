##
# An experimental parser for a vacancy feed for "Skywalker".
#
# Allows enumerating over the feed's and yields intialized `Vacancy` objects that can be manipulated
# and persisted by calling code (e.g. an import job).
#
# Notes:
#   - Ruby's `RSS` class doesn't recognise the demo feed as an Atom feed for some reason, so this
#     uses slightly uglier vanilla XML parsing
class SkywalkerFeed
  FEED_URL = ENV.fetch("VACANCIES_FEED_URL_SKYWALKER")

  class FeedItem
    def initialize(xml_node)
      @xml_node = xml_node
    end

    def [](key, root: false)
      @xml_node.at_xpath(root ? key : "a10:content/Vacancy/#{key}")&.text&.presence
    end
  end

  include Enumerable

  def each
    items.each do |item|
      v = Vacancy.find_or_initialize_by(
        external_feed_source: "skywalker",
        external_reference: item["VacancyID"],
      )

      # An external vacancy is by definition always published
      v.status = :published
      # Consider publish_on date to be the first time we saw this vacancy come through
      # (i.e. today, unless it already has a publish on date set)
      v.publish_on = v.publish_on || Date.today

      v.assign_attributes(attributes_for(item))

      yield v
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
      job_roles: item["Job_roles"].presence&.split(","),
      subjects: item["Subjects"].presence&.split(","),
      working_patterns: item["Working_patterns"].presence&.split(","),
      contract_type: item["Contract_type"].presence,
      phase: item["Phase"].presence&.downcase,

      # TODO: What about central office/multiple school vacancies?
      job_location: :at_one_school,
      organisations: organisations_for(item),
      about_school: organisations_for(item).first&.description,
    }
  end

  def organisations_for(item)
    [school_group.schools.find_by(urn: item["URN"])]
  end

  def school_group
    @school_group ||= SchoolGroup.find_by(uid: "5143")
  end

  def feed
    @feed ||= Nokogiri::XML(HTTParty.get(FEED_URL))
  end

  def items
    feed.xpath("//item").map { |fi| FeedItem.new(fi) }
  end
end
