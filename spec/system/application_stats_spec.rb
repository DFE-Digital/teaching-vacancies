require 'rails_helper'
RSpec.describe 'Application statistics' do
  scenario 'a visitor to the website can view the application statistics' do
    job = create(:vacancy)
    5.times { Auditor::Audit.new(nil, 'dfe-sign-in.authentication.success', 'sample').log_without_association }
    2.times { Auditor::Audit.new(nil, 'dfe-sign-in.authorisation.failure', 'sample').log_without_association }
    Auditor::Audit.new(job, 'vacancy.publish', 'sample-id').log
    4.times { Auditor::Audit.new(job, 'vacancy.update', 'sample-id').log }

    visit stats_path
    expect(page).to have_content('dfe-sign-in.authorisation.failure: 2')
    expect(page).to have_content('dfe-sign-in.authentication.success: 5')
    expect(page).to have_content('vacancy.publish: 1')
    expect(page).to have_content('vacancy.update: 4')
    expect(page).to have_content(I18n.t('stats.intro'))
  end
end
