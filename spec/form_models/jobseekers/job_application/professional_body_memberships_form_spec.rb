require "rails_helper"

RSpec.describe Jobseekers::JobApplication::ProfessionalBodyMembershipsForm, type: :model do
  let(:form) { described_class.new }

  describe "section completion validation" do
    it "errors when not answered" do
      expect(form).not_to be_valid
      expect(form.errors[:professional_body_memberships_section_completed])
                 .to eq(["Select yes if you have completed this section"])
    end

    it "accepts 'true' as an answer" do
      form.professional_body_memberships_section_completed = true
      expect(form).to be_valid
    end

    it "accepts 'false' as an answer" do
      form.professional_body_memberships_section_completed = false
      expect(form).to be_valid
    end
  end
end
