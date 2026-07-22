require "rails_helper"

RSpec.describe Publishers::JobListing::SubjectsForm, type: :model do
  subject(:form) { described_class.new(subjects:) }

  context "when subjects is blank" do
    let(:subjects) { [] }

    it { is_expected.to be_valid }
  end

  context "when subject_search is present but no subject is selected" do
    subject(:form) { described_class.new(subjects: [], subject_search: "magic") }

    it { is_expected.not_to be_valid }

    it "adds the correct error message" do
      form.valid?
      expect(form.errors[:subject_search]).to include(I18n.t("publishers.vacancies.build.subjects.errors.subject_searched_for_but_not_selected"))
    end
  end

  context "when subject_search is present and a subject is selected" do
    subject(:form) { described_class.new(subjects: [SUBJECT_OPTIONS.first.first], subject_search: "magic") }

    it { is_expected.to be_valid }
  end

  context "when subject_search is blank and no subject is selected" do
    subject(:form) { described_class.new(subjects: [], subject_search: "") }

    it { is_expected.to be_valid }
  end
end
