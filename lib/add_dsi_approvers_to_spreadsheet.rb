require 'dsi_api_response_to_spreadsheet'

class AddDSIApproversToSpreadsheet < DsiAPIResponseToSpreadsheet
  def initialize
    @worksheet = Spreadsheet::Writer.new(DSI_USER_SPREADSHEET_ID, DSI_APPROVER_WORKSHEET_GID, true)
  end

  def all_service_approvers
    write_all_response_to_spreadsheet(:approvers)
  end

  private
  # rubocop:disable Metrics/AbcSize
  def response_to_rows(approvers_response)
    approvers_response['users'].map do |user|
      [
        user['roleName'],
        user['userId'],
        user['givenName'],
        user['familyName'],
        user['email'],
        user.dig('organisation', 'id'),
        user.dig('organisation', 'name'),
        user.dig('organisation', 'category', 'name'),
        user.dig('organisation', 'type', 'name'),
        user.dig('organisation', 'urn'),
        user.dig('organisation', 'status', 'name'),
        format_datetime_with_seconds(user.dig('organisation', 'closedOn')),
        user.dig('organisation', 'address'),
        user.dig('organisation', 'telephone'),
        user.dig('organisation', 'region', 'name'),
        user.dig('organisation', 'phaseOfEducation', 'name'),
        user.dig('organisation', 'statutoryLowAge'),
        user.dig('organisation', 'statutoryHighAge'),
      ]
    end
  end
  # rubocop:enable Metrics/AbcSize
end
