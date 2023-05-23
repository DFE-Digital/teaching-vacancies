require "httparty"

class MyNewTermVacancySource
  include HTTParty
  include Enumerable

  BASE_URI = ENV.fetch("VACANCY_SOURCE_MY_NEW_TERM_FEED_URL").freeze
  API_KEY = ENV.fetch("VACANCY_SOURCE_MY_NEW_TERM_API_KEY").freeze
  SOURCE_NAME = "my_new_term".freeze

  def self.source_name
    SOURCE_NAME
  end

  def initialize
    @api_key = API_KEY
    authenticate
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

      begin
        v.assign_attributes(attributes_for(result))
      rescue ArgumentError => e
        v.errors.add(:base, e)
      end

      yield v
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
      job_role: job_role(item),
      ect_status: ect_status_for(item),
      subjects: item["subjects"].presence,
      working_patterns: item["workingPatterns"].presence,
      contract_type: item["contractType"]&.first,
      phases: phases_for(item),
      key_stages: key_stages_for(item),

      # TODO: What about central office/multiple school vacancies?
      job_location: :at_one_school,
    }.merge(organisation_fields(item))
  end

  def organisation_fields(item)
    multi_academy_trust = SchoolGroup.trusts.find_by(uid: item["trustUID"])
    schools = multi_academy_trust&.schools&.where(urn: item["schoolUrns"]) || Organisation.where(urn: item["schoolUrns"]) || []

    {
      organisations: schools,
      readable_job_location: schools.first&.name,
      about_school: schools.first&.description,
    }
  end

  def job_role(item)
    item["jobRole"].presence
    &.gsub("headteacher", "senior_leader")
    &.gsub("headteacher_principal", "senior_leader")
    &.gsub("deputy_headteacher_principal", "senior_leader")
    &.gsub("head_of_year", "middle_leader")
    &.gsub("assistant_headteacher_principal", "middle_leader")
    &.gsub("deputy_headteacher_principal", "middle_leader")
    &.gsub("learning_support", "education_support")
    &.gsub("other_support", "education_support")
    &.gsub("science_technician", "other_education_role")
    &.gsub(/\s+/, "")
  end

  def ect_status_for(item)
    return unless item["ectSuitable"].presence

    item["ectSuitable"] == "yes" ? "ect_suitable" : "ect_unsuitable"
  end

  def key_stages_for(item)
    item["keyStages"].presence&.map do |key_stage|
      key_stage&.gsub("key_stage_1", "ks1")
      &.gsub("key_stage_2", "ks2")
      &.gsub("key_stage_3", "ks3")
      &.gsub("key_stage_4", "ks4")
      &.gsub("key_stage_5", "ks5")
      &.gsub(/\s+/, "")
    end
  end

  def phases_for(item)
    item["phase"].presence
    &.gsub("all_through", "through")
    &.gsub(/\s+/, "")
  end

  def results
    get_job_listings["data"]["jobs"]
  end

  def get_job_listings(page_number: nil, records_per_page: nil)
    query_params = []
    query_params << "pageNumber=#{page_number}" if page_number
    query_params << "recordsPerPage=#{records_per_page}" if records_per_page
    query_string = query_params.empty? ? "" : "/#{query_params.join('&')}"

    get_endpoint("job-listings#{query_string}")
  end

  def get_endpoint(endpoint, params = {})
    headers = {
      "Authorization" => "Bearer #{@access_token}",
      "Content-Type" => "application/json",
    }
    response = self.class.get("#{BASE_URI}/#{endpoint}", headers: headers, query: params)

    case response.code
    when 200
      JSON.parse(response.body)
    when 401
      raise "Unauthorised: Invalid access token"
    else
      raise "An error occurred: #{response.message} (code: #{response.code})"
    end
  end

  def authenticate
    response = self.class.get("#{BASE_URI}/auth/#{@api_key}")

    case response.code
    when 200
      @access_token = JSON.parse(response.body)["access_token"]
    when 401
      raise "Unauthorised: Invalid API key"
    else
      raise "An error occurred during authentication: #{response.message} (code: #{response.code})"
    end
  end
end
