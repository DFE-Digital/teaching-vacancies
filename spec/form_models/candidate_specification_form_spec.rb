require 'rails_helper'
RSpec.describe CandidateSpecificationForm, type: :model do
  subject { CandidateSpecificationForm.new({}) }

  describe 'validations' do
    it { should validate_presence_of(:essential_requirements) }

  end
end
