require 'get_subject_name'

class CopyVacancy
  include GetSubjectName

  def initialize(vacancy)
    @vacancy = vacancy
    setup_new_vacancy
    setup_organisation_vacancies
    setup_job_location
    reset_candidate_specification if @vacancy.any_candidate_specification?
    copy_legacy_subjects
  end

  def call
    @new_vacancy.send(:set_slug)
    @new_vacancy.save(validate: false)
    copy_documents
    @new_vacancy
  end

  private

  def copy_documents
    @vacancy.documents.each do |document|
      document_copy = DocumentCopy.new(document.google_drive_id)
      document_copy.copy
      @new_vacancy.documents.create({
        name: document.name,
        size: document.size,
        content_type: document.content_type,
        download_url: document_copy.copied.web_content_link,
        google_drive_id: document_copy.copied.id
      }) unless document_copy.google_error
    end
  end

  def copy_legacy_subjects
    @new_vacancy.subjects ||= []
    @new_vacancy.subjects += [
      get_subject_name(@vacancy.subject),
      get_subject_name(@vacancy.first_supporting_subject),
      get_subject_name(@vacancy.second_supporting_subject)
    ].uniq.reject(&:blank?) unless @new_vacancy.subjects.any?
    @new_vacancy.subject = nil
    @new_vacancy.first_supporting_subject = nil
    @new_vacancy.second_supporting_subject = nil
  end

  def reset_candidate_specification
    @new_vacancy.experience = nil
    @new_vacancy.education = nil
    @new_vacancy.qualifications = nil
  end

  def setup_new_vacancy
    @new_vacancy = @vacancy.dup
    @new_vacancy.status = :draft
    @new_vacancy.weekly_pageviews = 0
    @new_vacancy.weekly_pageviews_updated_at = Time.zone.now
    @new_vacancy.total_pageviews = 0
    @new_vacancy.total_pageviews_updated_at = Time.zone.now
    @new_vacancy.total_get_more_info_clicks = 0
    @new_vacancy.total_get_more_info_clicks_updated_at = Time.zone.now
  end

  def setup_organisation_vacancies
    @vacancy.organisation_vacancies.each do |organisation_vacancy|
      @new_vacancy.organisation_vacancies.build(organisation: organisation_vacancy.organisation)
    end
  end

  def setup_job_location
    if @new_vacancy.parent_organisation.is_a?(School)
      @new_vacancy.job_location = 'at_one_school'
      @new_vacancy.readable_job_location = @new_vacancy.parent_organisation.name
    else
      @new_vacancy.job_location = 'central_office'
      @new_vacancy.readable_job_location = I18n.t('hiring_staff.organisations.readable_job_location.central_office')
    end
  end
end
