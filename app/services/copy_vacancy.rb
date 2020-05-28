require 'get_subject_name'

class CopyVacancy
  include GetSubjectName

  def initialize(vacancy)
    @vacancy = vacancy
  end

  def call
    @new_vacancy = @vacancy.dup
    @new_vacancy.status = :draft
    @new_vacancy.weekly_pageviews = 0
    @new_vacancy.weekly_pageviews_updated_at = Time.zone.now
    @new_vacancy.total_pageviews = 0
    @new_vacancy.total_pageviews_updated_at = Time.zone.now
    @new_vacancy.total_get_more_info_clicks = 0
    @new_vacancy.total_get_more_info_clicks_updated_at = Time.zone.now

    if @vacancy.any_candidate_specification?
      @new_vacancy.experience = nil
      @new_vacancy.education = nil
      @new_vacancy.qualifications = nil
    end

    copy_legacy_subjects

    @new_vacancy.save

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
  end
end
