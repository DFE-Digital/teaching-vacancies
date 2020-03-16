class CopyVacancy
  def initialize(vacancy)
    @vacancy = vacancy
  end

  def call
    new_vacancy = @vacancy.dup
    new_vacancy.status = :draft
    new_vacancy.weekly_pageviews = 0
    new_vacancy.weekly_pageviews_updated_at = Time.zone.now
    new_vacancy.total_pageviews = 0
    new_vacancy.total_pageviews_updated_at = Time.zone.now
    new_vacancy.total_get_more_info_clicks = 0
    new_vacancy.total_get_more_info_clicks_updated_at = Time.zone.now
    new_vacancy.save

    @vacancy.documents.each do |document|
      document_copy = DocumentCopy.new(document.google_drive_id)
      document_copy.copy
      new_vacancy.documents.create({
        name: document.name,
        size: document.size,
        content_type: document.content_type,
        download_url: document_copy.copied.web_content_link,
        google_drive_id: document_copy.copied.id
      }) unless document_copy.google_error
    end

    new_vacancy
  end
end
