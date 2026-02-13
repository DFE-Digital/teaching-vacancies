class SelfDisclosurePdfGenerator
  include Prawn::View
  include PdfUiHelper

  def initialize(self_disclosure_presenter)
    @datasource = self_disclosure_presenter
    @document = Prawn::Document.new(page_size: "A4", margin: 1.cm)
  end

  def generate
    page_style
    self_disclosure_page_header
    page_footer(datasource.footer_text)

    render_table_section(:personal_details)
    datasource.sections.each do |section|
      render_nested_section(section.title, section.fields)
    end

    render_signature_section

    number_pages "<page> of <total>",
                 at: [bounds.right - 50, bounds.bottom - 10],
                 size: 8

    document
  end

  private

  attr_reader :datasource, :document

  def self_disclosure_page_header
    page_header do
      text datasource.header_text, size: 12, style: :italic
      move_down 0.5.cm
      text datasource.applicant_name, size: 22, style: :bold
    end
  end

  def render_table_section(section_name)
    page_section do
      page_title(section_name.to_s.tr("_", " ").capitalize)
      page_table(datasource.public_send(section_name).to_a)
    end
  end

  def render_nested_section(section_name, fields)
    page_section do
      page_title(section_name)
      move_down 1.cm

      fields.each do |question, answer|
        if question.present?
          text question, style: :bold
          move_down 0.3.cm
        end
        text answer
        move_down 0.5.cm
      end
    end
  end

  def render_signature_section
    start_new_page unless cursor > 6.cm
    move_down 2.cm

    text "Declaration and Signature", size: 12, style: :bold

    move_down 1.cm

    draw_signature_row("Signature")
    draw_signature_row("Name")
    draw_signature_row("Date")

    move_down 1.cm
  end

  # rubocop:disable Metrics/MethodLength
  def draw_signature_row(label)
    label_width = 3.cm
    gap         = 0.5.cm
    fill_ratio = 0.5
    row_height  = 1.cm
    y_top       = cursor

    text_box(
      "#{label}:",
      at: [0, y_top],
      width: label_width,
      height: row_height,
      size: 10,
      valign: :center,
    )

    underline_x      = label_width + gap
    underline_width  = (bounds.width - underline_x) * fill_ratio

    text_box(
      "_" * 38,
      at: [underline_x, y_top],
      width: underline_width,
      height: row_height,
      size: 10,
      align: :right,
      valign: :center,
      kerning: false,
    )

    move_down row_height + 4
  end
  # rubocop:enable Metrics/MethodLength
end
