class JobApplicationPdfGenerator
  include Prawn::View
  include PdfUiHelper

  def initialize(job_application)
    @datasource = JobApplicationPdf.new(job_application)
    @document = Prawn::Document.new(page_size: "A4", margin: 1.cm)
  end

  def generate
    page_style
    job_application_page_header
    page_footer(datasource.footer_text)

    render_table_section(:personal_details)
    render_table_section(:professional_status)
    render_nested_section(:qualifications)
    render_nested_section(:training_and_cpds)
    render_nested_section(:professional_body_memberships)
    render_nested_section(:employment_history)
    render_page(:personal_statement)
    render_nested_section(:references)
    render_table_section(:ask_for_support)
    render_table_section(:declarations)

    number_pages "<page> of <total>",
                 at: [bounds.right - 50, bounds.bottom - 10],
                 size: 8

    document
  end

  private

  attr_reader :datasource, :document

  # :nocov:
  def job_application_page_header
    page_header do
      text datasource.header_text, size: 12, style: :italic
      move_down 0.5.cm
      text datasource.applicant_name, size: 22, style: :bold
    end
  end

  def render_table_section(section_name)
    page_section do
      page_title(section_name.to_s.titleize)
      page_table(datasource.public_send(section_name))
    end
  end

  def render_nested_section(section_name)
    page_section do
      page_title(section_name.to_s.titleize)
      datasource.public_send(section_name).each do |sub_title, group|
        page_sub_title(sub_title) if sub_title.present?
        next if group.blank?

        group.each do
          page_table(it)
          move_down 1.cm
        end
      end
    end
  end

  def render_page(page_name)
    start_new_page
    page_section do
      page_title(page_name.to_s.titleize)
      move_down 0.3.cm
      text datasource.public_send(page_name), size: 12, leading: 4
    end
    start_new_page
  end
  # :nocov:
end
