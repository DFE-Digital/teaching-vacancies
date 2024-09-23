class JobApplicationPdfGenerator
  include PdfHelper

  def initialize(job_application, vacancy)
    @job_application = job_application
    @vacancy = vacancy
  end

  def generate
    Prawn::Document.new do |pdf|
      add_headers(pdf)
      add_personal_details(pdf)
      add_professional_status(pdf)
      add_qualifications(pdf)
      add_training_and_cpds(pdf)
      add_employment_history(pdf)
      add_personal_statement(pdf)
      add_references(pdf)
      add_ask_for_support(pdf)
      add_declarations(pdf)
    end
  end

  private

  attr_reader :job_application, :vacancy
end
