require 'rails_helper'
require 'add_dsi_approvers_to_spreadsheet'

RSpec.describe AddDSIApproversToSpreadsheet do
  let(:endpoint) { :approvers }
  let(:dsi_worksheet_gid) { DSI_APPROVER_WORKSHEET_GID }
  let(:expected_spreadsheet_rows_one) { map_json_to_rows(response_file_to_json(1)) }
  let(:expected_spreadsheet_rows_two) { map_json_to_rows(response_file_to_json(2)) }

  subject { described_class.new }

  it_behaves_like 'a DFE API response to spreadsheet'

  def map_json_to_rows(json_response)
    json_response['users'].map do |user|
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
end
