require 'rails_helper'
require 'add_dsi_users_to_spreadsheet'

RSpec.describe AddDSIUsersToSpreadsheet do
  let(:endpoint) { :users }
  let(:dsi_worksheet_gid) { DSI_USER_WORKSHEET_GID }
  let(:expected_spreadsheet_rows_one) { map_json_to_rows(response_file_to_json(1)) }
  let(:expected_spreadsheet_rows_two) { map_json_to_rows(response_file_to_json(2)) }

  subject { described_class.new }

  it_behaves_like 'a DFE API response to spreadsheet'

  def map_json_to_rows(json_response)
    json_response['users'].map do |user|
      [
        user['roleName'],
        user['userId'],
        format_datetime_with_seconds(user['approvedAt']),
        format_datetime_with_seconds(user['updatedAt']),
        user['givenName'],
        user['familyName'],
        user['email'],
        user.dig('organisation', 'URN'),
        user.dig('organisation', 'name'),
        user.dig('organisation', 'Status'),
        user.dig('organisation', 'phaseOfEducation'),
        user.dig('organisation', 'telephone'),
        user.dig('organisation', 'regionCode'),
        format_datetime_with_seconds(user.dig('organisation', 'createdAt')),
        format_datetime_with_seconds(user.dig('organisation', 'updatedAt'))
      ]
    end
  end
end
