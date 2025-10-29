require "rails_helper"

RSpec.describe RefereePresenter do
  subject(:presenter) { described_class.new(referee) }

  let(:job_reference) { build_stubbed(:job_reference) }
  let(:referee) { build_stubbed(:referee, reference_request:) }
  let(:reference_request) { build_stubbed(:reference_request, job_reference:) }

  describe ".candidate_name" do
    subject(:presenter) { described_class.new(referee).candidate_name }

    it { is_expected.to eq(referee.job_application.name) }
  end

  describe ".header_text" do
    subject(:presenter) { described_class.new(referee).header_text }

    it { is_expected.to eq("Reference") }
  end

  describe ".footer_text" do
    subject(:presenter) { described_class.new(referee).footer_text }

    it { is_expected.to eq("Reference - #{referee.job_application.name}") }
  end

  describe ".referee_details" do
    let(:scope) { "publishers.vacancies.job_applications.reference_requests.show.referee_details" }
    let(:expected_row) do
      {
        name: [I18n.t(".name", scope:), referee.name],
        job_title: [I18n.t(".job_title", scope:), referee.job_title],
        organisation: [I18n.t(".organisation", scope:), referee.organisation],
        relationship: [I18n.t(".relationship", scope:), referee.relationship],
        email: [I18n.t(".email", scope:), referee.email],
        phone_number: [I18n.t(".phone_number", scope:), referee.phone_number],
      }
    end

    %i[
      name
      job_title
      organisation
      relationship
      email
      phone_number
    ].each_with_index do |field, idx|
      it "returns personal details #{field}" do
        expect(presenter.referee_details.to_a[idx]).to match_array(expected_row[field])
      end
    end
  end

  describe "#reference_information" do
    context "when cannot give reference" do
      let(:job_reference) { build_stubbed(:job_reference, can_give_reference: false) }
      let(:expected) { [["Can you provide a reference for #{presenter.candidate_name}?", "No, I am unable to provide a reference"]] }

      it { expect(presenter.reference_information).to match_array(expected) }
    end

    context "when can give reference" do
      let(:non_warning_fields) do
        [
          [I18n.t("helpers.legend.referees_can_give_reference_form.can_give_reference", name: presenter.candidate_name), "Yes, I can provide a reference"],
          [I18n.t("helpers.legend.referees_can_share_reference_form.is_reference_sharable", name: presenter.candidate_name), "No, it should be treated as confidential"],
          [I18n.t("helpers.label.referees_employment_reference_form.how_do_you_know_the_candidate"), job_reference.how_do_you_know_the_candidate],
          [I18n.t("helpers.legend.referees_employment_reference_form.employment_start_date"), "12 April 2012"],
          [I18n.t("helpers.legend.referees_employment_reference_form.currently_employed"), "No"],
          [I18n.t("helpers.legend.referees_employment_reference_form.employment_end_date"), "28 July 2019"],
          [I18n.t("helpers.legend.referees_employment_reference_form.would_reemploy_current"), "Yes, wonderful"],
          [I18n.t("helpers.legend.referees_employment_reference_form.would_reemploy_any"), "Yes, fantastic"],
        ]
      end

      context "without any details fields" do
        let(:warning_fields) do
          [
            [I18n.t("helpers.legend.referees_reference_information_form.under_investigation"), "No"],
            [I18n.t("helpers.legend.referees_reference_information_form.warnings"), "No"],
            [I18n.t("helpers.legend.referees_reference_information_form.allegations"), "No"],
            [I18n.t("helpers.legend.referees_reference_information_form.not_fit_to_practice"), "No"],
            [I18n.t("helpers.legend.referees_reference_information_form.able_to_undertake_role"), "Yes"],
          ]
        end

        context "when still employed" do
          let(:non_warning_fields) do
            [
              [I18n.t("helpers.legend.referees_can_give_reference_form.can_give_reference", name: presenter.candidate_name), "Yes, I can provide a reference"],
              [I18n.t("helpers.legend.referees_can_share_reference_form.is_reference_sharable", name: presenter.candidate_name), "No, it should be treated as confidential"],
              [I18n.t("helpers.label.referees_employment_reference_form.how_do_you_know_the_candidate"), job_reference.how_do_you_know_the_candidate],
              [I18n.t("helpers.legend.referees_employment_reference_form.employment_start_date"), "12 April 2012"],
              [I18n.t("helpers.legend.referees_employment_reference_form.currently_employed"), "Yes"],
              [I18n.t("helpers.legend.referees_employment_reference_form.would_reemploy_current"), "Yes, wonderful"],
              [I18n.t("helpers.legend.referees_employment_reference_form.would_reemploy_any"), "Yes, fantastic"],
            ]
          end

          let(:job_reference) do
            build_stubbed(:job_reference, :reference_given,
                          employment_start_date: Date.new(2012, 4, 12),
                          currently_employed: true)
          end

          it { expect(presenter.reference_information).to match_array(non_warning_fields + warning_fields) }
        end

        context "when not employed" do
          let(:job_reference) do
            build_stubbed(:job_reference, :reference_given,
                          employment_start_date: Date.new(2012, 4, 12),
                          employment_end_date: Date.new(2019, 7, 28))
          end
          let(:warning_fields) do
            [
              [I18n.t("helpers.legend.referees_reference_information_form.under_investigation"), "No"],
              [I18n.t("helpers.legend.referees_reference_information_form.warnings"), "No"],
              [I18n.t("helpers.legend.referees_reference_information_form.allegations"), "No"],
              [I18n.t("helpers.legend.referees_reference_information_form.not_fit_to_practice"), "No"],
              [I18n.t("helpers.legend.referees_reference_information_form.able_to_undertake_role"), "Yes"],
            ]
          end

          it { expect(presenter.reference_information).to match_array(non_warning_fields + warning_fields) }
        end
      end

      context "when under_investigation" do
        let(:job_reference) do
          build_stubbed(:job_reference, :reference_given,
                        employment_start_date: Date.new(2012, 4, 12),
                        employment_end_date: Date.new(2019, 7, 28),
                        under_investigation: true,
                        under_investigation_details: Faker::Lorem.sentence)
        end
        let(:expected) do
          [
            [I18n.t("helpers.legend.referees_reference_information_form.under_investigation"), "Yes"],
            ["Under investigation details", job_reference.under_investigation_details],
            [I18n.t("helpers.legend.referees_reference_information_form.warnings"), "No"],
            [I18n.t("helpers.legend.referees_reference_information_form.allegations"), "No"],
            [I18n.t("helpers.legend.referees_reference_information_form.not_fit_to_practice"), "No"],
            [I18n.t("helpers.legend.referees_reference_information_form.able_to_undertake_role"), "Yes"],
          ]
        end

        it { expect(presenter.reference_information.to_a - non_warning_fields).to match_array(expected) }
      end

      context "with warnings and allegations and not fit to practice" do
        let(:job_reference) do
          build_stubbed(:job_reference, :reference_given,
                        employment_start_date: Date.new(2012, 4, 12),
                        employment_end_date: Date.new(2019, 7, 28),
                        warnings: true,
                        not_fit_to_practice: true,
                        warning_details: Faker::Lorem.sentence,
                        allegations: true)
        end
        let(:expected) do
          [
            [I18n.t("helpers.legend.referees_reference_information_form.under_investigation"), "No"],
            [I18n.t("helpers.legend.referees_reference_information_form.warnings"), "Yes"],
            ["Warning details", job_reference.warning_details],
            [I18n.t("helpers.legend.referees_reference_information_form.allegations"), "Yes"],
            [I18n.t("helpers.legend.referees_reference_information_form.not_fit_to_practice"), "Yes"],
            [I18n.t("helpers.legend.referees_reference_information_form.able_to_undertake_role"), "Yes"],
          ]
        end

        it { expect(presenter.reference_information.to_a - non_warning_fields).to match_array(expected) }
      end

      context "with unable to undertake role" do
        let(:job_reference) do
          build_stubbed(:job_reference, :reference_given,
                        employment_start_date: Date.new(2012, 4, 12),
                        employment_end_date: Date.new(2019, 7, 28),
                        able_to_undertake_role: false,
                        unable_to_undertake_reason: Faker::Lorem.sentence)
        end
        let(:expected) do
          [
            [I18n.t("helpers.legend.referees_reference_information_form.under_investigation"), "No"],
            [I18n.t("helpers.legend.referees_reference_information_form.warnings"), "No"],
            [I18n.t("helpers.legend.referees_reference_information_form.allegations"), "No"],
            [I18n.t("helpers.legend.referees_reference_information_form.not_fit_to_practice"), "No"],
            [I18n.t("helpers.legend.referees_reference_information_form.able_to_undertake_role"), "No"],
            ["Unable to undertake role details", job_reference.unable_to_undertake_reason],
          ]
        end

        it { expect(presenter.reference_information.to_a - non_warning_fields).to match_array(expected) }
      end
    end
  end

  describe ".candidate_ratings" do
    let(:job_reference) do
      build_stubbed(:job_reference,
                    punctuality: :na,
                    working_relationships: :outstanding,
                    customer_care: :good,
                    adapt_to_change: :satisfactory,
                    deal_with_conflict: :poor,
                    prioritise_workload: :na,
                    team_working: :outstanding,
                    communication: :good,
                    problem_solving: :satisfactory,
                    general_attitude: :poor,
                    technical_competence: :na,
                    leadership: :outstanding)
    end
    let(:expected_row) do
      {
        punctuality: ["Punctuality/timekeeping", "N/A"],
        working_relationships: ["Ability to build effective working relationships", "Outstanding"],
        customer_care: ["Customer care skills", "Good"],
        adapt_to_change: ["Ability to adapt to change", "Satisfactory"],
        deal_with_conflict: ["Ability to deal with conflict", "Poor"],
        prioritise_workload: ["Ability to manage and prioritise own workload", "N/A"],
        team_working: ["Outstanding", "Team working skills"],
        communication: ["Communication skills", "Good"],
        problem_solving: ["Problem solving/decision making skills", "Satisfactory"],
        general_attitude: ["General attitude", "Poor"],
        technical_competence: ["Technical/clinical competence (for clinical/professional posts only)", "N/A"],
        leadership: ["Leadership (if appropriate)", "Outstanding"],
      }
    end

    JobReference::RATINGS_FIELDS.each_with_index do |field, idx|
      it "returns personal details #{field}" do
        expect(presenter.candidate_ratings.to_a[idx]).to match_array(expected_row[field])
      end
    end
  end
end
