class SupportingDocumentComponent < GovukComponent::Base
  delegate :open_in_new_tab_link_to, to: :helpers

  attr_reader :supporting_document

  def initialize(supporting_document:, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @supporting_document = supporting_document
  end

  def document_size
    "#{number_with_precision(supporting_document.size / 1024.0 / 1024.0, precision: 2)} MB"
  end

  private

  def default_classes
    %w[supporting-document-component icon icon--left icon--document]
  end
end
