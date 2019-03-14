require 'rails_helper'
RSpec.describe 'rake data:backfill:audit_data:vacancy_publishing', type: :task do
  before do
    Timecop.freeze(Time.zone.local(2010))
  end

  after do
    Timecop.return
  end

  it 'adds a new AuditData record for every vacancy.publish PublicActivity' do
    school = create(:school)
    vacancy = create(:vacancy, :published, school: school, flexible_working: false)
    PublicActivity::Activity.create(key: 'vacancy.publish', trackable: vacancy)

    task.execute

    expect(AuditData.count).to eq(1)

    last_audit = AuditData.last
    expect(last_audit.category).to eql('vacancies')
    expect(last_audit.data).to eql(
      'created_at' => vacancy.created_at.to_s,
      'ends_on' => vacancy.ends_on,
      'expires_on' => vacancy.expires_on.strftime('%F'),
      'flexible_working' => 'No',
      'id' => vacancy.id,
      'publish_on' => vacancy.publish_on.strftime('%F'),
      'school_county' => school.county,
      'school_urn' => school.urn,
      'slug' => vacancy.slug,
      'starts_on' => vacancy.starts_on,
      'status' => vacancy.status,
      'weekly_hours' => vacancy.weekly_hours
    )
  end

  context 'when the task is called again' do
    it 'does not add duplicate AuditData records' do
      vacancy = create(:vacancy, :published)
      PublicActivity::Activity.create(key: 'vacancy.publish', trackable: vacancy)

      task.execute
      expect(AuditData.count).to eq(1)
      previous_audit_data_id = AuditData.last.id

      task.execute
      expect(AuditData.count).to eq(1)
      latest_audit_data_id = AuditData.last.id
      expect(latest_audit_data_id).to eql(previous_audit_data_id)
    end
  end

  context 'when the once published vacancy is now in a trashed state' do
    it 'adds the listing with the trashed status' do
      vacancy = create(:vacancy, :trashed)
      PublicActivity::Activity.create(key: 'vacancy.publish', trackable: vacancy)

      task.execute

      expect(AuditData.last.data).to include('status' => vacancy.status)
    end
  end
end
