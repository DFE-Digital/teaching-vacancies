require "rails_helper"

RSpec.describe Jobseekers::JobApplication::ProfessionalStatusForm, type: :model do
  it { is_expected.to validate_inclusion_of(:qualified_teacher_status).in_array(%w[yes no on_track]) }
  it { is_expected.to validate_inclusion_of(:statutory_induction_complete).in_array(%w[yes no]) }

  context "when qualified_teacher_status is yes" do
    before { allow(subject).to receive(:qualified_teacher_status).and_return("yes") }

    it { is_expected.to validate_numericality_of(:qualified_teacher_status_year).is_less_than_or_equal_to(Time.current.year) }
  end

  context "when qualified_teacher_status is no" do
    before { allow(subject).to receive(:qualified_teacher_status).and_return("no") }

    it { is_expected.to validate_presence_of(:no_qualified_teacher_status_details) }
  end
end
