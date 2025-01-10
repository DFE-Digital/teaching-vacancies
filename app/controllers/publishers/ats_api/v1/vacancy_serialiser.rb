class Publishers::AtsApi::V1::VacancySerialiser
  def initialize(vacancy:)
    @vacancy = vacancy
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def call
    {
      id: vacancy.id,
      external_advert_url: vacancy.external_advert_url,
      publish_on: vacancy.publish_on,
      expires_at: vacancy.expires_at,
      job_title: vacancy.job_title,
      skills_and_experience: vacancy.skills_and_experience,
      salary: vacancy.salary,
      benefits_details: vacancy.benefits_details,
      starts_on: vacancy.starts_on,
      external_reference: vacancy.external_reference,
      visa_sponsorship_available: vacancy.visa_sponsorship_available,
      is_job_share: vacancy.is_job_share,
      schools: serialised_schools,
      job_roles: vacancy.job_roles,
      ect_suitable: ect_suitable?,
      working_patterns: vacancy.working_patterns,
      contract_type: vacancy.contract_type,
      phases: vacancy.phases,
      key_stages: vacancy.key_stages,
      subjects: vacancy.subjects,
    }
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  private

  attr_reader :vacancy

  def serialised_schools
    organisations = vacancy.organisations

    if organisations.any?(SchoolGroup)
      school_group = organisations.find { |org| org.is_a?(SchoolGroup) }

      if school_group.schools.empty?
        { trust_uid: school_group.uid }
      else
        {
          trust_uid: school_group.uid,
          school_urns: school_group.schools.pluck(:urn),
        }
      end
    else
      { school_urns: organisations.select { |org| org.is_a?(School) }.pluck(:urn) }
    end
  end

  def ect_suitable?
    vacancy.ect_status == "ect_suitable"
  end
end
