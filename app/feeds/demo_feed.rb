##
# An experimental parser for a vacancy feed.
#
# Allows enumerating over the feed's and yields intialized `Vacancy` objects that can be manipulated
# and persisted by calling code (e.g. an import job).
#
# Notes:
#   - Ruby's `RSS` class doesn't recognise the demo feed as an Atom feed for some reason, so this
#     uses slightly uglier vanilla XML parsing
#   - Until the feed gets modified based on our findings from this spike, we hardcode some fields
#     to example or empty values
#   - We currently don't get a machine-readable identifier for the school through from the feed
#     (although this *will* happen eventually), so we pick a "best guess" school from the children
#     of the feed's school group, and assign the vacancy to the school group itself if we fail
#   - Question: What do we do with vacancies that are removed from the feed - do we need to prune
#     vacancies that no longer come through as part of every update?
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
      v = Vacancy.find_or_initialize_by(external_reference: item["a10:content/Vacancy/VacancyID"])

      v.external = true
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
    expires_at = Time.zone.parse(item["a10:content/Vacancy/ExpiryDate"])

    {
      external: true,

      # Known good fields from the existing barebones feed
      job_title: item["a10:content/Vacancy/VacancyTitle"],
      salary: item["a10:content/Vacancy/Salary"],
      expires_at: expires_at,
      external_advert_url: item["link"],

      # [HARDCODED] Test/blank data for things missing from feed that are required for a "minimal"
      #   vacancy - need to discuss if we need these and if so get them added to feed
      subjects: [],
      working_patterns: %w[full_time],
      job_advert: "🚧🚧🚧 This is an automatically imported vacancy. 🚧🚧🚧\n\nOnce we get a full job advert from the feed, it will show up here.",
    }.merge(guess_organisation_attributes_for(item))
  end

  def guess_organisation_attributes_for(item)
    # Guesses which school a vacancy might be at, assigns to central office if that fails
    # TODO: Stop guessing once we actually get URNs through from the feed
    structure_level = item["a10:content/Vacancy/StructureLevel"]
    school = structure_level.include?("/") && school_group.schools.find_by("name ILIKE ?", "%#{structure_level.split('/').second.strip}%")

    if structure_level == "Central Office" || !school
      {
        job_location: :central_office,
        organisations: [school_group],
      }
    else
      {
        job_location: :at_one_school,
        organisations: [school],
      }
    end
  end

  def school_group
    @school_group ||= SchoolGroup.find_by(uid: 5143)
  end

  def feed
    @feed ||= Nokogiri::XML(HTTParty.get(FEED_URL))
  end

  def items
    feed.xpath("//item").map { |fi| FeedItem.new(fi) }
  end
end
