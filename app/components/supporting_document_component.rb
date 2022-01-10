class SupportingDocumentComponent < GovukComponent::Base
  delegate :open_in_new_tab_link_to, to: :helpers

  attr_reader :supporting_document

  def initialize(supporting_document:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @supporting_document = supporting_document
  end

  def document_size
    number_to_human_size(supporting_document.byte_size)
  end

  private

  def default_classes
    %w[supporting-document-component icon icon--left icon--document]
  end
end
