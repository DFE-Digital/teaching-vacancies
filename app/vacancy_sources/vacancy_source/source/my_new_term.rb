require "httparty"

class VacancySource::Source::MyNewTerm
  include HTTParty
  include Enumerable
  include VacancySource::Parser
  include VacancySource::Shared

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
      schools = find_schools(result)
      next if vacancy_listed_at_excluded_school_type?(schools)

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
        v.assign_attributes(attributes_for(result, schools))
      rescue ArgumentError => e
        v.errors.add(:base, e)
      end

      yield v
    end
  end

  private

  def attributes_for(item, schools)
    {
      job_title: item["jobTitle"]&.strip,
      job_advert: item["jobAdvert"]&.strip,
      salary: item["salary"]&.strip,
      expires_at: Time.zone.parse(item["expiresAt"]),
      external_advert_url: item["advertUrl"]&.strip,
      job_roles: job_roles_for(item),
      ect_status: ect_status_for(item),
      subjects: item["subjects"].presence || [],
      working_patterns: item["workingPatterns"].presence,
      contract_type: item["contractType"]&.first,
      phases: phase_for(item),
      key_stages: key_stages_for(item),
      job_location: :at_one_school,
      visa_sponsorship_available: visa_sponsorship_available_for(item),
    }.merge(organisation_fields(schools))
     .merge(start_date_fields(item))
  end

  def organisation_fields(schools)
    first_school = schools.first

    {
      organisations: schools,
      readable_job_location: first_school&.name,
      about_school: first_school&.description,
    }
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

  def find_schools(item)
    multi_academy_trust = SchoolGroup.trusts.find_by(uid: item["trustUID"])
    school_urns = item["schoolUrns"]&.split(",")

    return [] if multi_academy_trust.blank? && school_urns.blank?
    return Organisation.where(urn: school_urns) if multi_academy_trust.blank?
    return Array(multi_academy_trust) if school_urns.blank?

    # When having both trust and schools, only return the schools that are in the trust if any. Otherwise, return the trust itself.
    multi_academy_trust.schools.where(urn: school_urns).order(:created_at).presence || Array(multi_academy_trust)
  end

  def job_roles_for(item)
    roles = item["jobRole"]&.strip&.split(",")
    return [] if roles.blank?

    roles.flat_map do |role|
      # Translate legacy senior/middle leader into all the granular roles split from them

      if role == "senior_leader"
        Vacancy::SENIOR_LEADER_JOB_ROLES
      elsif role == "middle_leader"
        Vacancy::MIDDLE_LEADER_JOB_ROLES
      else
        Array.wrap(role.gsub("deputy_headteacher_principal", "deputy_headteacher")
                       .gsub("assistant_headteacher_principal", "assistant_headteacher")
                       .gsub("headteacher_principal", "headteacher")
                       .gsub(/head_of_year_or_phase|head_of_year/, "head_of_year_or_phase")
                       .gsub(/learning_support|other_support|science_technician/, "education_support")
                       .gsub(/\s+/, ""))
      end
    end
  end

  def ect_status_for(item)
    item["ectSuitable"] == true ? "ect_suitable" : "ect_unsuitable"
  end

  def visa_sponsorship_available_for(item)
    item["visaSponsorshipAvailable"] == true
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

  def phase_for(item)
    return if item["phase"].blank?

    item["phase"].strip
                 .gsub(/all_through|through_school/, "through")
                 .gsub(/16-19|16_19/, "sixth_form_or_college")
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
