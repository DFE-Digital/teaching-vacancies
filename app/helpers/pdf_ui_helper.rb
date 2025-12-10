require "prawn/measurement_extensions"

# Intended to be included in a class that already includes `Prawn::View`
# like the class JobApplicationPdfGenerator

module PdfUiHelper
  COLOR_PALETTE = {
    light_grey: "DDDDDD",
    lighter_grey: "ECECEC",
    dark_grey: "333333",
    light_blue: "F0F8FF",
    white: "FFFFFF",
  }.freeze

  def page_style
    update_font_family
    line_width 3.cm
    stroke_color COLOR_PALETTE[:light_grey]
    fill_color COLOR_PALETTE[:dark_grey]
  end

  # false rubocop assertion
  # rubocop:disable Rails/SaveBang
  def update_font_family
    # Arial Unicode is a font that supports all characters.
    font_families.update(
      "Arial Unicode" =>
        {
          bold: Rails.root.join("app/assets/fonts/Arial-Unicode-Bold.ttf").to_s,
          normal: Rails.root.join("app/assets/fonts/Arial-Unicode-Regular.ttf").to_s,
          italic: Rails.root.join("app/assets/fonts/Arial-Unicode-Italic.ttf").to_s,
          bold_italic: Rails.root.join("app/assets/fonts/Arial-Unicode-Bold.ttf").to_s, # Fallback to bold
        },
    )
    font("Arial Unicode", encoding: "UTF-8")
  end
  # rubocop:enable Rails/SaveBang

  # rubocop:disable Metrics/AbcSize
  def page_header
    # Create a header box with background color
    fill_color COLOR_PALETTE[:light_blue]
    fill_rectangle [bounds.left, bounds.top], bounds.width, 3.cm
    fill_color COLOR_PALETTE[:dark_grey]

    # Add vacancy caption
    bounding_box([bounds.left + 1.cm, bounds.top - 0.7.cm], width: bounds.width) do
      yield
      image tvs_logo_path, at: [bounds.right - 6.cm, bounds.top + 0.5.cm], width: 4.cm
    end

    move_down 1.cm
  end
  # rubocop:enable Metrics/AbcSize

  def page_footer(footer_text)
    repeat(:all, dynamic: true) do
      bounding_box([bounds.left, bounds.bottom + 0.3.cm], width: bounds.width) do
        text footer_text, size: 8, align: :center
      end
    end
  end

  def page_section
    move_down 1.cm
    yield
    move_down 1.cm
  end

  def page_title(title)
    start_new_page if close_to_bottom?
    fill_color COLOR_PALETTE[:light_grey]
    fill_rectangle [bounds.left, cursor + 0.3.cm], bounds.width, 1.cm
    fill_color COLOR_PALETTE[:dark_grey]

    indent(0.5.cm) { text title, size: 18, style: :bold }
  end

  def page_sub_title(title)
    start_new_page if close_to_bottom?
    move_down 0.3.cm
    fill_color COLOR_PALETTE[:lighter_grey]
    fill_rectangle [bounds.left, cursor + 0.3.cm], bounds.width, 1.cm
    fill_color COLOR_PALETTE[:dark_grey]

    indent(1.cm) { text title, size: 14, style: :bold }
    move_down 0.4.cm
  end

  # rubocop:disable Metrics/AbcSize
  def page_table(data)
    start_new_page if close_to_bottom?
    table(
      data,
      cell_style: { border_color: COLOR_PALETTE[:light_grey] },
      width: bounds.width,
    ) do
      cells.padding = [8, 4]
      rows(0..-1).borders = [:top]
      rows(-1).borders = %i[top bottom]
      rows(0..-1).border_width = 0.5
      columns(0).font_style = :bold
      columns(0).align = :left
      columns(0).width = 150
      columns(0).text_color = COLOR_PALETTE[:dark_grey]
      columns(1).text_color = COLOR_PALETTE[:dark_grey]
      columns(1).align = :left

      # table label
      cells[0, 0].borders = %i[bottom top right left] if cells[0, 1]&.content.blank?
    end
  end
  # rubocop:enable Metrics/AbcSize

  def page_checkbox(label)
    move_down 0.3.cm
    line_width 3
    stroke_color COLOR_PALETTE[:dark_grey]
    stroke_rectangle [bounds.left + 0.5.cm, cursor], 0.7.cm, 0.7.cm
    bounding_box([bounds.left + 1.5.cm, cursor - 0.1.cm], width: 17.5.cm) { text(label) }
  end

  def page_list(*entries)
    entries.each do |entry|
      move_down 0.5.cm
      fill_ellipse [bounds.left + 0.7.cm, cursor], 0.15.cm # dot
      bounding_box([bounds.left + 1.5.cm, cursor + 0.2.cm], width: 17.5.cm) { text(entry) }
    end
    move_down 0.5.cm
  end

  private

  def tvs_logo_path
    Rails.root.join("app/assets/images/TVS-logo.png")
  end

  def close_to_bottom?(threshold_pct: 0.2, page_max: 282)
    cursor <= page_max * threshold_pct
  end
end
