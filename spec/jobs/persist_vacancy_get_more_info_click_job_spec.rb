require "rails_helper"

RSpec.describe PersistVacancyGetMoreInfoClickJob, type: :job do
  include ActiveJob::TestHelper

  let(:id) { SecureRandom.uuid }
  subject(:job) { described_class.perform_later(id) }

  it "executes perform" do
    vacancy_get_more_info_click = double(:vacancy_get_more_info_click)
    vacancy = double(:vacancy)
    allow(Vacancy).to receive(:find).with(id).and_return(vacancy)

    expect(VacancyGetMoreInfoClick).to receive(:new).with(vacancy).and_return(vacancy_get_more_info_click)
    expect(vacancy_get_more_info_click).to receive(:persist!)

    perform_enqueued_jobs { job }
  end
end
