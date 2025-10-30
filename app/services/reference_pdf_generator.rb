class ReferencePdfGenerator
  include Prawn::View
  include PdfUiHelper

  def initialize(referee_presenter)
    @datasource = referee_presenter
    @document = Prawn::Document.new(page_size: "A4", margin: 1.cm)
  end

  def generate
    page_style
    document_page_header
    page_footer(datasource.footer_text)

    render_table_section(:referee_details)
    render_table_section(:reference_information)
    render_table_section(:candidate_ratings) if datasource.can_give_reference?

    number_pages "<page> of <total>",
                 at: [bounds.right - 50, bounds.bottom - 10],
                 size: 8

    document
  end

  private

  attr_reader :datasource, :document

  def document_page_header
    page_header do
      text datasource.header_text, size: 12, style: :italic
      move_down 0.5.cm
      text datasource.candidate_name, size: 22, style: :bold
    end
  end

  def render_table_section(section_name)
    page_section do
      page_title(section_name.to_s.tr("_", " ").capitalize)
      page_table(datasource.public_send(section_name).to_a)
    end
  end
end
