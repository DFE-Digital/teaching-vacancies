class JobApplicationPdfGenerator
  include PdfHelper

  def initialize(job_application, vacancy)
    @job_application = job_application
    @vacancy = vacancy
  end

  def generate
    logger = Rails.logger
    Prawn::Document.new do |pdf|
      logger.debug("start - update_font_family")
      update_font_family(pdf)
      logger.debug("add_image_to_first_page")
      add_image_to_first_page(pdf)
      logger.debug("add_headers")
      add_headers(pdf)
      pdf.stroke_horizontal_rule
      logger.debug("add_personal_details")
      add_personal_details(pdf)
      logger.debug("add_professional_status")
      add_professional_status(pdf)
      logger.debug("add_qualifications")
      add_qualifications(pdf)
      logger.debug("add_training_and_cpds")
      add_training_and_cpds(pdf)
      logger.debug("add_employment_history")
      add_employment_history(pdf)
      logger.debug("add_personal_statement")
      add_personal_statement(pdf)
      logger.debug("add_references")
      add_references(pdf)
      logger.debug("add_ask_for_support")
      add_ask_for_support(pdf)
      logger.debug("add_declarations")
      add_declarations(pdf)
      logger.debug("add_footers")
      add_footers(pdf)
      logger.debug("done")
    end
  end

  private

  attr_reader :job_application, :vacancy
end
