class SupportingDocumentComponent < ApplicationComponent
  delegate :open_in_new_tab_link_to, to: :helpers

  attr_reader :supporting_document

  def initialize(supporting_document:, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @supporting_document = supporting_document
  end

  def document_size
    number_to_human_size(supporting_document.byte_size)
  end

  private

  def default_attributes
    { class: %w[supporting-document-component icon icon--left icon--document] }
  end
end
