class JobApplicationPdfGenerator
  include Prawn::View
  include PdfUiHelper

  def initialize(presenter)
    @datasource = presenter
    @document = Prawn::Document.new(page_size: "A4", margin: 1.cm)
  end

  # rubocop:disable Metrics/MethodLength
  def generate
    page_style
    job_application_page_header
    page_footer(datasource.footer_text)

    text I18n.t("jobseekers.job_applications.show.consent_text"), size: 10, style: :italic

    %i[personal_details professional_status].each do |section|
      render_table_section(section)
    end
    %i[qualifications training_and_cpds professional_body_memberships employment_history].each do |section|
      render_nested_section(section)
    end

    render_page(:personal_statement)
    render_table_section(:religious_information) if datasource.religious_application?
    render_nested_section(:referees)

    %i[ask_for_support declarations].each do |section|
      render_table_section(section)
    end

    render_confirmation if datasource.is_a?(BlankJobApplicationPdf)

    number_pages "<page> of <total>",
                 at: [bounds.right - 50, bounds.bottom - 10],
                 size: 8

    document
  end
  # rubocop:enable Metrics/MethodLength

  private

  attr_reader :datasource, :document

  def job_application_page_header
    page_header do
      text datasource.header_text, size: 12, style: :italic
      move_down 0.5.cm
      text datasource.applicant_name, size: 22, style: :bold
    end
  end

  def render_table_section(section_name)
    page_section do
      page_title(I18n.t("jobseekers.job_applications.show.#{section_name}.heading"))
      page_table(datasource.public_send(section_name))
    end
  end

  def render_nested_section(section_name)
    page_section do
      page_title(I18n.t("jobseekers.job_applications.show.#{section_name}.heading"))
      datasource.public_send(section_name).each do |sub_title, group|
        page_sub_title(sub_title) if sub_title.present?
        next if group.blank?

        group.each do |item|
          page_table(item)
          move_down 1.cm
        end
      end
    end
  end

  def render_page(page_name)
    start_new_page
    page_section do
      page_title(I18n.t("jobseekers.job_applications.show.#{page_name}.heading"))
      move_down 0.3.cm
      text datasource.public_send(page_name), size: 12, leading: 4
    end
    start_new_page
  end

  def render_confirmation
    page_section do
      page_title("Confirmation")
      page_checkbox("I confirm that the above information is accurate and complete")
    end
    page_section do
      page_title("How your data is used")
      move_down 0.3.cm
      text "When you submit your application, your data will shared with:"
      page_list(
        "the Department for Education",
        "the school, trust or local authority which posted the job listing",
        "the school or schools the job is at",
      )
      text "Please read the Teaching Vacancies Privacy Policy for more information on how your data is used."
      page_checkbox("I consent to my data being shared with and processed by these organisations for recruitment purposes (for example, background and qualification checks)")
    end
  end
end
