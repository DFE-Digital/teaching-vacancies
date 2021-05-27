class DocumentComponent < GovukComponent::Base
  delegate :open_in_new_tab_link_to, to: :helpers

  attr_reader :document

  def initialize(document:, classes: [], html_attributes: {})
    super(classes: classes, html_attributes: html_attributes)

    @document = document
  end

  def document_size
    "#{number_with_precision(document.size / 1024.0 / 1024.0, precision: 2)} MB"
  end

  private

  def default_classes
    %w[document-component icon icon--left icon--document]
  end
end
