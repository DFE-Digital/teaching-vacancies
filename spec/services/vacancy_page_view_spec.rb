require 'rails_helper'

RSpec.describe VacancyPageView do
  let(:model) { create(:vacancy) }
  subject(:counter) { described_class.new(model) }

  it_behaves_like Counter
end
