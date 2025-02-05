class JobApplicationPdfGenerator
  include PdfHelper

  def initialize(job_application, vacancy)
    @job_application = job_application
    @vacancy = vacancy
  end

  def generate
    Prawn::Document.new do |pdf|
      update_font_family(pdf)
      add_image_to_first_page(pdf)
      add_headers(pdf)
      pdf.stroke_horizontal_rule
      add_personal_details(pdf)
      add_professional_status(pdf)
      add_qualifications(pdf)
      add_training_and_cpds(pdf)
      add_professional_body_memberships(pdf)
      add_employment_history(pdf)
      add_personal_statement(pdf)
      add_references(pdf)
      add_ask_for_support(pdf)
      add_declarations(pdf)
      add_footers(pdf)
    end
  end

  private

  attr_reader :job_application, :vacancy
end
