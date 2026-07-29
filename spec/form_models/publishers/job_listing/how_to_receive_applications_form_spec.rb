require "rails_helper"

RSpec.describe Publishers::JobListing::HowToReceiveApplicationsForm, type: :model do
  it { is_expected.to validate_inclusion_of(:receive_applications).in_array(Vacancy.receive_applications.keys) }

  describe "#params_to_save" do
    let(:form) { described_class.new(receive_applications: "website") }

    it "sets enable_job_applications to false" do
      expect(form.params_to_save).to include(enable_job_applications: false)
    end
  end
end
