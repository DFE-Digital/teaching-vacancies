class Publishers::JobListing::DocumentsConfirmationForm < BaseForm
  include ActiveModel::Attributes

  validates :upload_additional_document, inclusion: { in: [true, false] }
  validate :existing_supporting_documents_scan_safe

  attr_reader :vacancy

  def self.fields
    %i[upload_additional_document]
  end

  attribute :upload_additional_document, :boolean

  def initialize(params = {}, vacancy = nil)
    @vacancy = vacancy
    super(params)
  end

  private

  def existing_supporting_documents_scan_safe
    return unless vacancy

    vacancy.supporting_documents.each do |doc|
      blob = doc.blob
      if blob.malware_scan_malicious? || blob.malware_scan_scan_error?
        errors.add(:base, I18n.t("jobs.file_unsafe_error_message", filename: doc.filename))
      end
    end
  end
end
