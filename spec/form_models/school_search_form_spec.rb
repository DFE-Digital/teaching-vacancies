require "rails_helper"

RSpec.describe SchoolSearchForm, type: :model do
  let(:school_search_form) { described_class.new(params) }
  let(:params) { {} }

  describe "#job_availability_options" do
    subject { school_search_form.job_availability_options }

    let(:expected_options) do
      [["true", I18n.t(true, scope: "organisations.filters.job_availability.options")]]
    end

    it { is_expected.to match_array(expected_options) }
  end
end
