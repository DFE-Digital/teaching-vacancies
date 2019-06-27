require 'export_to_spreadsheet'

class AddVacanciesToSpreadsheet < ExportToSpreadsheet
  def initialize
    @category = 'vacancy'
  end

  private

  def query
    Vacancy.all
  end

  def to_row(vacancy)
    {
      id: vacancy.id,
      slug: vacancy.slug,
      created_at: vacancy.created_at.to_s,
      status: vacancy.status,
      publish_on: vacancy.publish_on,
      expires_on: vacancy.expires_on,
      starts_on: vacancy.starts_on,
      ends_on: vacancy.ends_on,
      weekly_hours: vacancy.weekly_hours,
      flexible_working: vacancy.working_patterns.join(','),
      school_urn: vacancy.school.urn,
      school_county: vacancy.school.county
    }
  end

  def present(vacancy)
    row = to_row(vacancy)
    row.values.unshift(Time.zone.now.to_s)
  end
end
