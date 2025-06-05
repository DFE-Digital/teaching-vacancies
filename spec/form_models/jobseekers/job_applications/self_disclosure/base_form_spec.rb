require "rails_helper"

module Jobseekers::JobApplications::SelfDisclosure
  RSpec.describe BaseForm, type: :model do
    subject(:form) { form_class.new(params).tap { it.model = self_disclosure } }

    let(:form_class) do
      Class.new(described_class) do
        attribute :name, :string
        attribute :date_of_birth, :date
        attribute :has_unspent_convictions, :boolean

        validates :has_unspent_convictions, inclusion: { in: [true] }
      end
    end
    let(:self_disclosure) do
      build(:self_disclosure, name: "model name", date_of_birth: 30.years.ago, has_unspent_convictions: true)
    end
    let(:params) { {} }

    describe "#.fields" do
      it { expect(form_class.fields).to match_array(%w[name date_of_birth has_unspent_convictions]) }
    end

    describe ".model=" do
      context "when form has no value it assign model attributes" do
        it { expect(form.name).to eq(self_disclosure.name) }
        it { expect(form.date_of_birth).to eq(self_disclosure.date_of_birth) }
        it { expect(form.has_unspent_convictions).to eq(self_disclosure.has_unspent_convictions) }
      end

      context "when form has updated values does not assign model attributes" do
        context "with name" do
          let(:params) { { name: expected_value } }
          let(:expected_value) { "params name" }

          it { expect(form.name).to eq(expected_value) }
          it { expect(form.date_of_birth).to eq(self_disclosure.date_of_birth) }
          it { expect(form.has_unspent_convictions).to eq(self_disclosure.has_unspent_convictions) }
        end

        context "with date_of_birth" do
          let(:params) { { date_of_birth: expected_value } }
          let(:expected_value) { Time.zone.today }

          it { expect(form.name).to eq(self_disclosure.name) }
          it { expect(form.date_of_birth).to eq(expected_value) }
          it { expect(form.has_unspent_convictions).to eq(self_disclosure.has_unspent_convictions) }
        end

        context "with has_unspent_convictions" do
          let(:params) { { has_unspent_convictions: expected_value } }
          let(:expected_value) { false }

          it { expect(form.name).to eq(self_disclosure.name) }
          it { expect(form.date_of_birth).to eq(self_disclosure.date_of_birth) }
          it { expect(form.has_unspent_convictions).to eq(expected_value) }
        end
      end
    end

    describe ".save_model!" do
      it { expect { form.save_model! }.to change(SelfDisclosure, :count).by(1) }

      describe "saved form attributes" do
        before { form.save_model! }

        it { expect(self_disclosure.name).to eq(form.name) }
        it { expect(self_disclosure.date_of_birth).to eq(form.date_of_birth) }
        it { expect(self_disclosure.has_unspent_convictions).to eq(form.has_unspent_convictions) }
      end
    end
  end
end
