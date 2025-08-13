require "rails_helper"

RSpec.describe RefereePresenter do
  subject(:presenter) { described_class.new(referee) }

  let(:job_reference) { build_stubbed(:job_reference) }
  let(:referee) { build_stubbed(:referee, job_reference:) }

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

  describe ".reference_information" do
    context "when cannot give reference" do
      let(:job_reference) { build_stubbed(:job_reference, can_give_reference: false) }
      let(:expected) { [["Can you provide a reference for #{presenter.candidate_name}?", "No, I am unable to provide a reference"]] }

      it { expect(presenter.reference_information).to match_array(expected) }
    end

    context "when can give reference" do
      context "with under_investigation" do
        let(:job_reference) do
          build_stubbed(:job_reference, :reference_given,
                        email: "my@email.com",
                        how_do_you_know_the_candidate: "i know the candidate for 2 years",
                        employment_start_date: Date.new(2012, 4, 12),
                        under_investigation: true,
                        under_investigation_details: "blah blah")
        end
        let(:expected) do
          [
            [I18n.t("helpers.legend.referees_can_give_reference_form.can_give_reference", name: presenter.candidate_name), "Yes, I can provide a reference"],
            [I18n.t("helpers.legend.referees_can_share_reference_form.is_reference_sharable", name: presenter.candidate_name), "No, it should be treated as confidential"],
            [I18n.t("helpers.legend.referees_employment_reference_form.how_do_you_know_the_candidate"), "i know the candidate for 2 years"],
            [I18n.t("helpers.legend.referees_employment_reference_form.employment_start_date"), "12 April 2012"],
            ["Is the candidate currently employed at this organisation?", "No"],
            ["Would you re-employ the candidate in the same job as they currently hold or held?", "Yes, wonderful"],
            ["Would you re-employ the candidate in any role within your organisation?", "Yes, fantastic"],
            ["Is the candidate currently under investigation for any matter (incl. conduct, capability, or performance) under any of your organisation policies?", "Yes"],
            ["Under investigation details", "blah blah"],
            ["Are there any warnings on the candidate’s record (disciplinary, performance, or absence related) that have not been disposed of?", "No"],
            ["Are you aware of any allegations or concerns that have been raised (whether formal or informal) about the candidate that relate to any safeguarding issues/ or the candidate’s behaviour towards adults at risk and/or children?", "No"],
            ["If the candidate is employed in a position where they are subject to a fit and proper persons check, have they been investigated for, or been found not fit to practice?", "No"],
            ["To the best of your knowledge and with reference to the attached job description and person specification, are you satisfied that the candidate has the ability and is suitable to undertake this role?", "Yes"],
          ]
        end

        it { expect(presenter.reference_information).to match_array(expected) }
      end

      context "with warnings" do
        let(:job_reference) do
          build_stubbed(:job_reference, :reference_given,
                        email: "my@email.com",
                        how_do_you_know_the_candidate: "i know the candidate for 2 years",
                        employment_start_date: Date.new(2012, 4, 12),
                        warnings: true,
                        warning_details: "use with caution")
        end
        let(:expected) do
          [
            [I18n.t("helpers.legend.referees_can_give_reference_form.can_give_reference", name: presenter.candidate_name), "Yes, I can provide a reference"],
            [I18n.t("helpers.legend.referees_can_share_reference_form.is_reference_sharable", name: presenter.candidate_name), "No, it should be treated as confidential"],
            [I18n.t("helpers.legend.referees_employment_reference_form.how_do_you_know_the_candidate"), "i know the candidate for 2 years"],
            [I18n.t("helpers.legend.referees_employment_reference_form.employment_start_date"), "12 April 2012"],
            ["Is the candidate currently employed at this organisation?", "No"],
            ["Would you re-employ the candidate in the same job as they currently hold or held?", "Yes, wonderful"],
            ["Would you re-employ the candidate in any role within your organisation?", "Yes, fantastic"],
            ["Is the candidate currently under investigation for any matter (incl. conduct, capability, or performance) under any of your organisation policies?", "No"],
            ["Are there any warnings on the candidate’s record (disciplinary, performance, or absence related) that have not been disposed of?", "Yes"],
            ["Warning details", "use with caution"],
            ["Are you aware of any allegations or concerns that have been raised (whether formal or informal) about the candidate that relate to any safeguarding issues/ or the candidate’s behaviour towards adults at risk and/or children?", "No"],
            ["If the candidate is employed in a position where they are subject to a fit and proper persons check, have they been investigated for, or been found not fit to practice?", "No"],
            ["To the best of your knowledge and with reference to the attached job description and person specification, are you satisfied that the candidate has the ability and is suitable to undertake this role?", "Yes"],
          ]
        end

        it { expect(presenter.reference_information).to match_array(expected) }
      end

      context "with unable to undertake role" do
        let(:job_reference) do
          build_stubbed(:job_reference, :reference_given,
                        email: "my@email.com",
                        how_do_you_know_the_candidate: "i know the candidate for 2 years",
                        employment_start_date: Date.new(2012, 4, 12),
                        able_to_undertake_role: false,
                        unable_to_undertake_reason: "some reason")
        end
        let(:expected) do
          [
            [I18n.t("helpers.legend.referees_can_give_reference_form.can_give_reference", name: presenter.candidate_name), "Yes, I can provide a reference"],
            [I18n.t("helpers.legend.referees_can_share_reference_form.is_reference_sharable", name: presenter.candidate_name), "No, it should be treated as confidential"],
            [I18n.t("helpers.legend.referees_employment_reference_form.how_do_you_know_the_candidate"), "i know the candidate for 2 years"],
            [I18n.t("helpers.legend.referees_employment_reference_form.employment_start_date"), "12 April 2012"],
            ["Is the candidate currently employed at this organisation?", "No"],
            ["Would you re-employ the candidate in the same job as they currently hold or held?", "Yes, wonderful"],
            ["Would you re-employ the candidate in any role within your organisation?", "Yes, fantastic"],
            ["Is the candidate currently under investigation for any matter (incl. conduct, capability, or performance) under any of your organisation policies?", "No"],
            ["Are there any warnings on the candidate’s record (disciplinary, performance, or absence related) that have not been disposed of?", "No"],
            ["Are you aware of any allegations or concerns that have been raised (whether formal or informal) about the candidate that relate to any safeguarding issues/ or the candidate’s behaviour towards adults at risk and/or children?", "No"],
            ["If the candidate is employed in a position where they are subject to a fit and proper persons check, have they been investigated for, or been found not fit to practice?", "No"],
            ["To the best of your knowledge and with reference to the attached job description and person specification, are you satisfied that the candidate has the ability and is suitable to undertake this role?", "No"],
            ["Warning details", "some reason"],
          ]
        end

        it { expect(presenter.reference_information).to match_array(expected) }
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
