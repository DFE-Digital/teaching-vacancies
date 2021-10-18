class CopyVacancy
  def initialize(vacancy)
    @vacancy = vacancy
    setup_new_vacancy
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
    @new_vacancy.organisations = @vacancy.organisations
  end
end
