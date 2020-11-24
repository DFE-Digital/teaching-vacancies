require "rails_helper"

RSpec.describe VacanciesOptionsHelper, type: :helper do
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

  describe "#job_role_options" do
    it "returns an array of vacancy job role options" do
      expect(helper.job_role_options).to eq(
        [
          %w[Teacher teacher],
          %w[Leadership leadership],
          ["SEN specialist", "sen_specialist"],
        ],
      )
    end
  end

  describe "#job_sorting_options" do
    it "returns an array of vacancy job sorting options" do
      expect(helper.job_sorting_options).to eq(
        [
          [I18n.t("jobs.sort_by.most_relevant"), ""],
          [I18n.t("jobs.sort_by.publish_on.descending"), "publish_on_desc"],
          [I18n.t("jobs.sort_by.expires_at.descending"), "expires_at_desc"],
          [I18n.t("jobs.sort_by.expires_at.ascending"), "expires_at_asc"],
        ],
      )
    end
  end

  describe "#working_pattern_options" do
    it "returns an array of vacancy working patterns" do
      expect(helper.working_pattern_options).to eq(
        [
          %w[Full-time full_time],
          %w[Part-time part_time],
          ["Job share", "job_share"],
        ],
      )
    end
  end
end
