require 'rails_helper'

RSpec.describe Document, type: :model do
  it { should belong_to(:vacancy) }

  describe 'validations' do
    context 'a new record' do
      it { should validate_presence_of(:name) }
      it { should validate_presence_of(:size) }
      it { should validate_presence_of(:content_type) }
      it { should validate_presence_of(:download_url) }
      it { should validate_presence_of(:google_drive_id) }
    end
  end
end
