require 'export_to_spreadsheet'

class AddVacanciesToSpreadsheet < ExportToSpreadsheet
  def initialize
    @category = 'vacancies'
  end

  private

  def query
    Vacancy.all
  end

  def to_row(vacancy)
    [
      Time.zone.now.to_s,
      vacancy.id,
      vacancy.slug,
      vacancy.created_at.to_s,
      vacancy.status,
      vacancy.publish_on,
      vacancy.expires_on,
      vacancy.starts_on,
      vacancy.ends_on,
      vacancy.working_patterns.join(','),
      vacancy.school.urn,
      vacancy.school.county
    ]
  end

  def present(vacancy)
    to_row(vacancy)
  end
end
