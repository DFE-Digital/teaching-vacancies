##
# An experimental parser for a vacancy feed.
#
# Allows enumerating over the feed's and yields intialized `Vacancy` objects that can be manipulated
# and persisted by calling code (e.g. an import job).
#
# Notes:
#   - Ruby's `RSS` class doesn't recognise the demo feed as an Atom feed for some reason, so this
#     uses slightly uglier vanilla XML parsing
class DemoFeed
  FEED_URL = ENV.fetch("VACANCIES_FEED_URL_DEMO")

  class FeedItem
    def initialize(xml_node)
      @xml_node = xml_node
    end

    def [](key)
      @xml_node.at_xpath(key)&.text
    end
  end

  include Enumerable

  def each
    items.each do |item|
      expires_at = Time.zone.parse(item["a10:content/Vacancy/ExpiryDate"])
      v = Vacancy.find_or_initialize_by(external_reference: item["a10:content/Vacancy/VacancyID"])
      v.assign_attributes(
        external: true,

        # [HARDCODED] Set vacancy against the trust directly until we have school data in feed
        job_location: :central_office, #
        organisations: [SchoolGroup.find_by(uid: 5143)],

        # Known good fields from the existing barebones feed
        job_title: item["a10:content/Vacancy/VacancyTitle"],
        salary: item["a10:content/Vacancy/Salary"],
        expires_at: expires_at,
        external_advert_url: item["link"],

        # Consider publish_on date to be the first time we saw this vacancy come through
        # (i.e. today, unless it already has a publish on date set)
        status: :published,
        publish_on: v.publish_on || Date.today,

        # [HARDCODED] Test/blank data for things missing from feed that are required for a "minimal"
        #   vacancy - need to discuss if we need these and if so get them added to feed
        subjects: [],
        working_patterns: %w[full_time],
      )

      yield v
    end
  end

  private

  def feed
    @feed ||= Nokogiri::XML(HTTParty.get(FEED_URL))
  end

  def items
    feed.xpath("//item").map { |fi| FeedItem.new(fi) }
  end
end
