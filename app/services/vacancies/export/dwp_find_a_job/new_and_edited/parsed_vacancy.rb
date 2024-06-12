module Vacancies::Export::DwpFindAJob::NewAndEdited
  class ParsedVacancy
    include ActionView::Helpers::SanitizeHelper
    include Rails.application.routes.url_helpers

    CATEGORY_IT_ID = 14
    CATEGORY_EDUCATION_ID = 27
    STATUS_FULL_TIME_ID = 1
    STATUS_PART_TIME_ID = 2
    TYPE_PERMANENT_ID = 1
    TYPE_CONTRACT_ID = 2

    attr_reader :vacancy

    delegate :id, :job_title, :organisation, to: :vacancy

    def initialize(vacancy)
      @vacancy = vacancy
    end

    def apply_url
      job_url(vacancy)
    end

    def category_id
      vacancy.job_roles.include?("it_support") ? CATEGORY_IT_ID : CATEGORY_EDUCATION_ID
    end

    def description
      skills_and_experience = strip_tags(vacancy.skills_and_experience)
      school_offer = strip_tags(vacancy.school_offer)
      further_details = strip_tags(vacancy.further_details)
      safeguarding = strip_tags(vacancy.organisation.safeguarding_information)
      description = ""
      description += "#{I18n.t('jobs.skills_and_experience.jobseeker')}\n\n#{skills_and_experience}\n\n" if skills_and_experience.present?
      description += "#{I18n.t('jobs.school_offer.jobseeker')}\n\n#{school_offer}\n\n" if school_offer.present?
      description += "#{I18n.t('jobs.further_details')}\n\n#{further_details}\n\n" if further_details.present?
      description += "#{I18n.t('jobs.safeguarding_information.jobseeker')}\n\n#{safeguarding}" if safeguarding.present?
      description.strip
    end

    def expiry
      expiry_date = vacancy.expires_at.to_date
      return unless expiry_date.between?(Date.today + 1, Date.today + 30.days)

      expiry_date.to_s
    end

    def status_id
      wp = vacancy.working_patterns
      if wp.blank?
        nil
      elsif wp.include?("full_time") || (wp.include?("term_time") && wp.exclude?("part_time"))
        STATUS_FULL_TIME_ID
      else
        STATUS_PART_TIME_ID
      end
    end

    def type_id
      case vacancy.contract_type
      when "permanent"
        TYPE_PERMANENT_ID
      when "fixed_term", "parental_leave_cover"
        TYPE_CONTRACT_ID
      end
    end
  end
end
