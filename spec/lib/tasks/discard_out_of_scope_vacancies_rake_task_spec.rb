require "rails_helper"

RSpec.describe "vacancies:discard_out_of_scope" do
  include_context "rake"

  let(:task_path) { "lib/tasks/discard_out_of_scope_vacancies" }

  # rubocop:disable RSpec/NamedSubject
  it "trashes vacancies from out-of-scope schools" do
    in_scope_school = create(:school, detailed_school_type: "Academy sponsor led")
    in_scope_vacancy = create(:vacancy, organisations: [in_scope_school])
    out_of_scope_school = create(:school, detailed_school_type: "Other independent school")
    further_education_school = create(:school, detailed_school_type: "Further education")
    higher_education_school = create(:school, detailed_school_type: "Higher education institutions")

    out_of_scope_vacancy = create(:vacancy, organisations: [out_of_scope_school])
    further_ed_vacancy = create(:vacancy, organisations: [further_education_school])
    higher_ed_vacancy = create(:vacancy, organisations: [higher_education_school])

    expect {
      subject.invoke
    }.to change { PublishedVacancy.kept.count }.by(-3)

    expect(out_of_scope_vacancy.reload).to be_discarded
    expect(further_ed_vacancy.reload).to be_discarded
    expect(higher_ed_vacancy.reload).to be_discarded
    expect(in_scope_vacancy.reload).not_to be_discarded
  end
  # rubocop:enable RSpec/NamedSubject
end
