require "rails_helper"

RSpec.describe ErrorSummaryPresenter do
  let(:record) { build(:vacancy) }
  let(:errors) do
    [
      ActiveModel::Error.new(record, :job_title),
      ActiveModel::Error.new(record, :starts_asap),
    ]
  end

  describe "#formatted_error_messages" do
    context "with no link generator" do
      subject(:presenter) { described_class.new(errors) }

      it "provides local page anchors" do
        expect(presenter.formatted_error_messages).to eq(
          [
            [:job_title, "is invalid", "#job_title"],
            [:starts_asap, "is invalid", "#starts_asap"],
          ],
        )
      end
    end

    context "with a link generator" do
      subject(:presenter) { described_class.new(errors, link_generator) }

      let(:link_generator) do
        ->(error) { "/custom-error/#{error.attribute}" }
      end

      it "provides the generated links" do
        expect(presenter.formatted_error_messages).to eq(
          [
            [:job_title, "is invalid", "/custom-error/job_title"],
            [:starts_asap, "is invalid", "/custom-error/starts_asap"],
          ],
        )
      end
    end
  end
end
