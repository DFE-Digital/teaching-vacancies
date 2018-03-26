require 'rails_helper'
RSpec.describe CandidateSpecificationForm, type: :model do
  subject { CandidateSpecificationForm.new({}) }

  describe 'validations' do
    it { should validate_presence_of(:education) }
    it { should validate_presence_of(:qualifications) }
    it { should validate_presence_of(:experience) }
  end
end
