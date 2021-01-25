require "rails_helper"

RSpec.describe Publishers::ManagedOrganisationsForm, type: :model do
  subject { described_class.new(params) }

  let(:params) { { managed_organisations: managed_organisations, managed_school_ids: managed_school_ids } }

  context "when managed_organisations and managed_school_ids are blank" do
    let(:managed_organisations) { "" }
    let(:managed_school_ids) { [] }

    it "validates presence of managed_organisations or managed_school_ids" do
      expect(subject).not_to be_valid
      expect(subject.errors.messages[:managed_organisations]).to include(
        I18n.t("publishers_publisher_preference_errors.managed_organisations.blank"),
      )
    end
  end
end
