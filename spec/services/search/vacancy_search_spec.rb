require "rails_helper"

# Most tests for search are in vacancy_filter_query_spec.rb
RSpec.describe Search::VacancySearch do
  subject { described_class.new(form_hash, sort: sort) }

  let(:form_hash) do
    {
      keyword: keyword,
      location: location,
      radius: radius,
      organisation_slug: organisation_slug,
      teaching_job_roles: teaching_job_roles,
      support_job_roles: support_job_roles,
      ect_statuses: ect_statuses,
      phases: phases,
      working_patterns: working_patterns,
      quick_apply: quick_apply,
      subjects: subjects,
      organisation_types: organisation_types,
      school_types: school_types,
      visa_sponsorship_availability: visa_sponsorship_availability,
    }.compact
  end

  let(:keyword) { "maths teacher" }
  let(:location) { "Louth" }
  let(:radius) { 10 }
  let(:sort) { Search::VacancySort.new(keyword: keyword) }
  let(:organisation_slug) { school.slug }
  let(:teaching_job_roles) { nil }
  let(:support_job_roles) { nil }
  let(:ect_statuses) { nil }
  let(:phases) { nil }
  let(:working_patterns) { nil }
  let(:subjects) { nil }
  let(:organisation_types) { nil }
  let(:quick_apply) { nil }
  let(:school_types) { nil }
  let(:visa_sponsorship_availability) { nil }
  let(:school) { create(:school) }
  let(:trust) { create(:trust, schools: [school]) }

  context "when clearing filters" do
    let(:teaching_job_roles) { ["teacher"] }
    let(:ect_statuses) { ["ect_suitable"] }
    let(:phases) { ["ks1"] }
    let(:working_patterns) { ["full_time"] }
    let(:quick_apply) { ["quick_apply"] }
    let(:subjects) { ["Maths"] }
    let(:organisation_types) { ["Academy"] }
    let(:school_types) { ["faith_school"] }
    let(:visa_sponsorship_availability) { ["true"] }

    it "clears selected filters" do
      expect(subject.active_criteria).to eq({ location: location, organisation_types: organisation_types, organisation_slug: organisation_slug, ect_statuses: ect_statuses, teaching_job_roles: teaching_job_roles, keyword: keyword, phases: phases, radius: 10, subjects: subjects, working_patterns: working_patterns, quick_apply: quick_apply, school_types: school_types, visa_sponsorship_availability: visa_sponsorship_availability })
      expect(subject.clear_filters_params).to eq({ keyword: keyword, location: location, radius: 10, organisation_slug: organisation_slug, teaching_job_roles: [], support_job_roles: [], ect_statuses: [], phases: [], working_patterns: [], quick_apply: [], subjects: [], organisation_types: [], school_types: [], visa_sponsorship_availability: [], skip_strip_checkboxes: true })
    end
  end

  context "with 2 vacancies" do
    let!(:school_vacancy) { create(:vacancy, job_title: "At School", organisations: [school]) }
    let(:location) { nil }
    let(:keyword) { nil }

    before { create(:vacancy, job_title: "Random") }

    context "when searching by school" do
      let(:organisation_slug) { school.slug }

      it "finds vacancies for the school only" do
        expect(subject.vacancies.map(&:job_title)).to contain_exactly(school_vacancy.job_title)
      end
    end

    context "when searching by trust" do
      let(:organisation_slug) { trust.slug }

      it "finds vacancies for the school only" do
        expect(subject.vacancies.map(&:job_title)).to contain_exactly(school_vacancy.job_title)
      end
    end
  end
end
