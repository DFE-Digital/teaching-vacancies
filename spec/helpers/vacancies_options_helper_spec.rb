require "rails_helper"

RSpec.describe VacanciesOptionsHelper do
  describe "#job_location_options" do
    context "when the organisation is a local authority" do
      let(:organisation) { create(:local_authority) }

      it "returns an array including the multi-school option" do
        expect(helper.job_location_options(organisation)).to eq(
          [
            ["At one school in the local authority", "at_one_school"],
            ["At more than one school in the local authority", "at_multiple_schools"],
          ],
        )
      end
    end

    context "when the organisation is a trust" do
      let(:organisation) { create(:trust) }

      it "returns an array including the multi-school option" do
        expect(helper.job_location_options(organisation)).to eq(
          [
            ["At one school in the trust", "at_one_school"],
            ["At more than one school in the trust", "at_multiple_schools"],
            ["At the trust's head office", "central_office"],
          ],
        )
      end
    end
  end
end
