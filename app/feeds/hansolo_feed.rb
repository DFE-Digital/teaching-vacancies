##
# An experimental parser for a vacancy feed for "Han Solo".
class HansoloFeed
  FEED_URL = ENV.fetch("VACANCIES_FEED_URL_HANSOLO")

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
      v = Vacancy.find_or_initialize_by(
        external_feed_id: "hansolo",
        external_reference: item["referencenumber"],
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
      # Known good fields from the existing barebones feed
      job_title: item["title"],
      salary: item["salary"],
      external_advert_url: item["url"],
      job_advert: job_advert_text_for(item),

      # [HARDCODED] Test/blank data for things missing from feed that are required for "minimal" vacancy
      expires_at: 3.months.from_now,
      subjects: [],
      working_patterns: %w[full_time],
    }.merge(guess_organisation_attributes_for(item))
  end

  def guess_organisation_attributes_for(item)
    # Guesses which school a vacancy might be at based on postcode, assigns to central office if that fails
    # TODO: Stop guessing once we actually get URNs through from the feed
    postcode = item["postalcode"]
    school = school_group.schools.find_by(postcode: postcode)

    if school
      {
        job_location: :at_one_school,
        organisations: [school],
      }
    else
      {
        job_location: :central_office,
        organisations: [school_group],
      }
    end
  end

  def job_advert_text_for(item)
    # TODO: How much tidying will we need to do here?
    Loofah.fragment(item["description"]).scrub!(:strip).text
  end

  def school_group
    @school_group ||= SchoolGroup.find_by(uid: 4903)
  end

  def feed
    @feed ||= Nokogiri::XML(HTTParty.get(FEED_URL))
  end

  def items
    feed.xpath("//job").map { |fi| FeedItem.new(fi) }
  end
end
