class CopyVacancy
  def initialize(vacancy)
    @vacancy = vacancy
    setup_new_vacancy
    setup_organisation_vacancies
  end

  def call
    @new_vacancy.send(:set_slug)
    @new_vacancy.save(validate: false)
    copy_documents
    @new_vacancy
  end

  private

  def copy_documents
    @vacancy.supporting_documents.each do |supporting_doc|
      @new_vacancy.supporting_documents.attach(supporting_doc.blob)
    end
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
