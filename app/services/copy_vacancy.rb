class CopyVacancy
  def initialize(vacancy)
    @vacancy = vacancy
    setup_new_vacancy
    setup_organisation_vacancies
    reset_candidate_specification if @vacancy.any_candidate_specification?
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
      next if document_copy.google_error

      @new_vacancy.documents.create({
        name: document.name,
        size: document.size,
        content_type: document.content_type,
        download_url: document_copy.copied.web_content_link,
        google_drive_id: document_copy.copied.id,
      })
    end
  end

  def reset_candidate_specification
    @new_vacancy.experience = nil
    @new_vacancy.education = nil
    @new_vacancy.qualifications = nil
  end

  def setup_new_vacancy
    @new_vacancy = @vacancy.dup
    @new_vacancy.status = :draft
    @new_vacancy.total_pageviews = 0
    @new_vacancy.total_get_more_info_clicks = 0
  end

  def setup_organisation_vacancies
    @vacancy.organisation_vacancies.each do |organisation_vacancy|
      @new_vacancy.organisation_vacancies.build(organisation: organisation_vacancy.organisation)
    end
  end
end
