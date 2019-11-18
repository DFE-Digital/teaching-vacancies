require 'dsi_api_response_to_spreadsheet'

class AddDSIUsersToSpreadsheet < DsiAPIResponseToSpreadsheet
  def initialize
    @worksheet = Spreadsheet::Writer.new(DSI_USER_SPREADSHEET_ID, DSI_USER_WORKSHEET_GID, true)
  end

  def all_service_users
    write_all_response_to_spreadsheet(:users)
  end

  private

  # rubocop:disable Metrics/AbcSize
  def response_to_rows(users_response)
    users_response['users'].map do |user|
      [
        user['roleName'],
        user['userId'],
        format_datetime_with_seconds(user['approvedAt']),
        format_datetime_with_seconds(user['updatedAt']),
        user['givenName'],
        user['familyName'],
        user['email'],
        user['organisation']['URN'],
        user['organisation']['name'],
        user['organisation']['Status'],
        user['organisation']['phaseOfEducation'],
        user['organisation']['telephone'],
        user['organisation']['regionCode'],
        format_datetime_with_seconds(user['organisation']['createdAt']),
        format_datetime_with_seconds(user['organisation']['updatedAt'])
      ]
    end
  end
  # rubocop:enable Metrics/AbcSize
end
