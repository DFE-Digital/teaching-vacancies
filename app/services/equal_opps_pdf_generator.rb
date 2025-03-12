class EqualOppsPdfGenerator
  include PdfHelper

  def initialize(vacancy, equal_opps_reports)
    @vacancy = vacancy
    @equal_opps_reports = equal_opps_reports
  end

  def generate_for_single_vacancy
    Prawn::Document.new do |pdf|
      update_font_family(pdf)
      add_equal_opps_headers(pdf)
      pdf.stroke_horizontal_rule
      add_age_data_for_single_vacancy(pdf, equal_opps_reports)
      add_gender_data_for_single_vacancy(pdf, equal_opps_reports)
    end
  end

  def generate_for_organisation
    Prawn::Document.new do |pdf|
      update_font_family(pdf)
      add_equal_opps_headers_for_organisation(pdf)
      pdf.stroke_horizontal_rule
      add_age_date_for_organisation(pdf, equal_opps_reports)
      add_gender_data_for_organisation(pdf, equal_opps_reports)
    end
  end

  private

  attr_reader :vacancy, :equal_opps_reports
end
