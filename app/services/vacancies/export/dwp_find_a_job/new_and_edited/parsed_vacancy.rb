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
      strip_tags(vacancy.job_advert)
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