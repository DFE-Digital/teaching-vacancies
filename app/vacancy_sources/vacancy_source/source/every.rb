class VacancySource::Source::Every
  include VacancySource::Parser

  FEED_URL = ENV.fetch("VACANCY_SOURCE_EVERY_FEED_URL").freeze
  SOURCE_NAME = "every".freeze

  class EveryImportError < StandardError; end

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
      job_roles: job_roles_for(item),
      ect_status: ect_status_for(item),
      subjects: item["subjects"].presence&.split(","),
      working_patterns: item["workingPatterns"].presence&.split(","),
      contract_type: item["contractType"].presence,
      phases: phase_for(item),
      key_stages: item["keyStages"].presence&.split(","),
      visa_sponsorship_available: visa_sponsorship_available_for(item),

      # TODO: What about central office/multiple school vacancies?
      job_location: :at_one_school,
    }.merge(organisation_fields(item))
     .merge(start_date_fields(item))
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

  def organisation_fields(item)
    {
      organisations: schools_for(item),
      readable_job_location: main_organisation(item)&.name,
      about_school: main_organisation(item)&.description,
    }
  end

  def schools_for(item)
    if multi_academy_trust(item).present?
      multi_academy_trust(item).schools.where(urn: item["schoolUrns"])
    else
      Organisation.where(urn: item["schoolUrns"])
    end.to_a
  end

  def visa_sponsorship_available_for(item)
    item["visaSponsorshipAvailable"] == true
  end

  def multi_academy_trust(item)
    SchoolGroup.trusts.find_by(uid: item["trustUID"])
  end

  def main_organisation(item)
    schools_for(item).one? ? schools_for(item).first : multi_academy_trust(item)
  end

  def job_roles_for(item)
    role = item["jobRole"]&.strip
    return [] if role.blank?

    # Translate legacy senior/middle leader into all the granular roles split from them
    return Vacancy::SENIOR_LEADER_JOB_ROLES if role.include? "senior_leader"
    return Vacancy::MIDDLE_LEADER_JOB_ROLES if role.include? "middle_leader"

    Array.wrap(role.gsub("deputy_headteacher_principal", "deputy_headteacher")
                   .gsub("assistant_headteacher_principal", "assistant_headteacher")
                   .gsub("headteacher_principal", "headteacher")
                   .gsub(/head_of_year_or_phase|head_of_year/, "head_of_year_or_phase")
                   .gsub(/learning_support|other_support|science_technician/, "education_support")
                   .gsub(/\s+/, ""))
  end

  def ect_status_for(item)
    return unless item["ectSuitable"].presence

    item["ectSuitable"].to_s == "true" ? "ect_suitable" : "ect_unsuitable"
  end

  def phase_for(item)
    return if item["phase"].blank?

    item["phase"].strip
                 .parameterize(separator: "_")
                 .gsub("through_school", "through")
                 .gsub(/16-19|16_19/, "sixth_form_or_college")
  end

  def results
    feed["result"]
  end

  def feed
    response = HTTParty.get(FEED_URL)
    raise HTTParty::ResponseError, error_message unless response.success?

    parsed_response = JSON.parse(response.body)
    raise EveryImportError, error_message + parsed_response["error"] if parsed_response["error"]

    parsed_response
  end

  def error_message
    "Something went wrong with Every Import. Response:"
  end
end
