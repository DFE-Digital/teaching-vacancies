require "action_text"

module Vacancies::Export::DwpFindAJob::PublishedAndUpdatedVacancies
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
      description = ""
      description += description_paragraph(I18n.t("jobs.skills_and_experience.jobseeker"), vacancy.skills_and_experience)
      description += description_paragraph(I18n.t("jobs.school_offer.jobseeker"), vacancy.school_offer)
      description += description_paragraph(I18n.t("jobs.further_details"), vacancy.further_details)
      description += description_paragraph(I18n.t("jobs.safeguarding_information.jobseeker"), vacancy.organisation.safeguarding_information)
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

    private

    def description_paragraph(title, text)
      sanitized_text = text&.scrub("") # remove invalid byte sequences
                           &.squish # remove leading/trailing whitespace and collapse multiple spaces
                           &.gsub(/[\u0001-\u001A]/, "") # remove control chars, unicode codepoints from 0001 to 001A (Invalid under XML 1.0)
      plain_text = ActionText::Fragment.from_html(sanitized_text).to_plain_text # convert HTML tags into plain text representation
      plain_text.present? ? "#{title}\n\n#{plain_text}\n\n" : ""
    end
  end
end
