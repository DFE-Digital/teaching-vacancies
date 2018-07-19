namespace :spreadsheet do
  desc 'Write authentication and authorisation audit to spreadsheet'
  task write_auth: :environment do
    AUTH_SPREADSHEET_ID = ENV['AUTH_SPREADSHEET_ID']
    if AUTH_SPREADSHEET_ID.blank?
      Rails.logger.debug('No AUTH_SPREADSHEET_ID defined. Exiting task...')
      exit
    end

    require 'spreadsheet_writer'
    activities = Auditor::Auth.new.yesterdays_activities
    audit_entries = activities.inject([]) do |rows, activity|
      school_urn = activity&.trackable&.urn
      rows << [activity.created_at, activity.key, activity.session_id, school_urn]
    end

    worksheet = Spreadsheet::Writer.new(AUTH_SPREADSHEET_ID)
    worksheet.append(audit_entries)
    Rails.logger.debug('Auth auditing logs updated')
  end
end
