class Vacancies::Import::Sources::Fusion
  include Vacancies::Import::Parser
  include Vacancies::Import::Shared

  FEED_URL = ENV.fetch("VACANCY_SOURCE_FUSION_FEED_URL").freeze
  SOURCE_NAME = "fusion".freeze

  class FusionImportError < StandardError; end

  include Enumerable

  def self.source_name
    SOURCE_NAME
  end

  def each
    results.each do |result|
      schools = schools_for(result)
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

  # rubocop:disable Metrics/MethodLength
  def attributes_for(item, schools)
    {
      job_title: item["jobTitle"],
      job_advert: item["jobAdvert"],
      salary: item["salary"],
      expires_at: Time.zone.parse(item["expiresAt"]),
      external_advert_url: item["advertUrl"],
      job_roles: job_roles_for(item),
      ect_status: ect_status_for(item),
      subjects: item["subjects"].presence&.split(",") || [],
      working_patterns: working_patterns_for(item),
      contract_type: contract_type_for(item),
      is_parental_leave_cover: parental_leave_cover_for?(item),
      phases: phase_for(item),
      key_stages: item["keyStages"].presence&.split(","),
      visa_sponsorship_available: visa_sponsorship_available_for(item),
      is_job_share: job_share_for?(item),

      # TODO: What about central office/multiple school vacancies?
      job_location: :at_one_school,
    }.merge(organisation_fields(item, schools))
     .merge(start_date_fields(item))
  end
  # rubocop:enable Metrics/MethodLength

  def organisation_fields(item, schools)
    {
      organisations: schools,
      readable_job_location: main_organisation(item)&.name,
      about_school: main_organisation(item)&.description,
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

  def working_patterns_for(item)
    return [] if item["workingPatterns"].blank?

    item["workingPatterns"].delete(" ").split(",").map { |pattern|
      if LEGACY_WORKING_PATTERNS.include?(pattern)
        "part_time"
      else
        pattern
      end
    }.uniq
  end

  def job_share_for?(item)
    return false unless item["workingPatterns"].split(",").include?("job_share")

    true
  end

  def schools_for(item)
    if multi_academy_trust(item).present?
      multi_academy_trust(item).schools.where(urn: item["schoolUrns"])
    else
      Organisation.where(urn: item["schoolUrns"])
    end.to_a
  end

  def multi_academy_trust(item)
    SchoolGroup.trusts.find_by(uid: item["trustUID"])
  end

  def main_organisation(item)
    schools_for(item).one? ? schools_for(item).first : multi_academy_trust(item)
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
        Array.wrap(role.gsub(/head_of_year_or_phase|head_of_year/, "head_of_year_or_phase")
                       .gsub("learning_support", "other_support")
                       .gsub(/\s+/, ""))
      end
    end
  end

  def ect_status_for(item)
    item["ectSuitable"] == true ? "ect_suitable" : "ect_unsuitable"
  end

  def phase_for(item)
    return if item["phase"].blank?

    item["phase"].strip
                 .parameterize(separator: "_")
                 .gsub("through_school", "through")
                 .gsub(/16-19|16_19/, "sixth_form_or_college")
  end

  def visa_sponsorship_available_for(item)
    item["visaSponsorshipAvailable"] == true
  end

  def contract_type_for(item)
    return "fixed_term" if item["contractType"] == "parental_leave_cover"

    item["contractType"].presence
  end

  def parental_leave_cover_for?(item)
    item["contractType"] == "parental_leave_cover"
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
