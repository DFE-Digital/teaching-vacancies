class FusionVacancySource
  FEED_URL = ENV.fetch("VACANCY_SOURCE_FUSION_FEED_URL").freeze
  SOURCE_NAME = "fusion".freeze

  class FusionImportError < StandardError; end

  include Enumerable

  def self.source_name
    SOURCE_NAME
  end

  def each
    results.each do |result|
      v = Vacancy.find_or_initialize_by(
        external_source: SOURCE_NAME,
        external_reference: result["reference"],
      )

      # An external vacancy is by definition always published
      v.status = :published
      # Consider publish_on date to be the first time we saw this vacancy come through
      # (i.e. today, unless it already has a publish on date set)
      v.publish_on ||= Date.today

      v.assign_attributes(attributes_for(result))

      yield v
    rescue StandardError => e
      Sentry.capture_exception(e)
    end
  end

  private

  def attributes_for(item)
    {
      job_title: item["jobTitle"],
      job_advert: item["jobAdvert"],
      salary: item["salary"],
      expires_at: Time.zone.parse(item["expiresAt"]),
      external_advert_url: item["advertUrl"],
      job_role: item["jobRole"].presence&.gsub("leadership", "senior_leader")&.gsub(/\s+/, ""),
      ect_status: ect_status_for(item),
      subjects: item["subjects"].presence&.split(","),
      working_patterns: item["workingPatterns"].presence&.split(","),
      contract_type: item["contractType"].presence,
      phases: item["phase"].presence&.parameterize(separator: "_"),

      # TODO: What about central office/multiple school vacancies?
      job_location: :at_one_school,
      readable_job_location: organisations_for(item).first&.name,
      organisations: organisations_for(item),
      about_school: organisations_for(item).first&.description,
    }
  end

  def ect_status_for(item)
    return unless item["ect_suitable"].presence

    item["ect_suitable"] == "yes" ? "ect_suitable" : "ect_unsuitable"
  end

  def organisations_for(item)
    [school_group(item).schools.find_by(urn: item["schoolUrns"].first)]
  end

  def school_group(item)
    @school_group ||= SchoolGroup.find_by!(uid: item["trustId"])
  end

  def results
    feed["result"]
  end

  def feed
    response = HTTParty.get(FEED_URL)
    raise HTTParty::ResponseError, error_message unless response.success?

    parsed_response = JSON.parse(response.body)
    raise FusionImportError, error_message if parsed_response["error"]

    parsed_response
  end

  def error_message
    "Something went wrong with Fusion Import"
  end
end
