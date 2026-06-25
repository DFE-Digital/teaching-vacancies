require "rails_helper"

RSpec.describe VacancyCounter do
  let(:college) { create(:school, :college) }
  let(:school_scope) { PublishedVacancy.live.in_organisation_ids(Organisation.in_scope_schools.pluck(:id)) }
  let(:fe_scope) { PublishedVacancy.live.in_organisation_ids(Organisation.colleges.pluck(:id)) }

  describe "role_counts" do
    before do
      create_list(:vacancy, 3, job_roles: %w[teacher teaching_assistant], phases: %w[primary])
      create(:vacancy, job_roles: %w[headteacher], phases: %w[secondary])
    end

    it "returns counts for all roles by default" do
      expect(described_class.role_counts(scope: school_scope)).to eq(teacher: 3, teaching_assistant: 3, headteacher: 1)
    end

    context "with a scope" do
      before do
        create(:vacancy, job_roles: %w[teacher], organisations: [college])
      end

      it "scopes to school phases" do
        expect(described_class.role_counts(scope: school_scope)).to eq(teacher: 3, teaching_assistant: 3, headteacher: 1)
      end

      it "scopes to FE phases" do
        expect(described_class.role_counts(scope: fe_scope)).to eq(teacher: 1)
      end
    end
  end

  describe "phase_counts" do
    before do
      create_list(:vacancy, 3, phases: %w[primary])
      create(:vacancy, phases: %w[secondary primary])
    end

    context "with a scope" do
      before do
        create_list(:vacancy, 2, phases: %w[secondary])
        create_list(:vacancy, 2, phases: %w[sixth_form_or_college], organisations: [college])
      end

      it "scopes to school phases" do
        expect(described_class.phase_counts(scope: school_scope)).to eq(primary: 4, secondary: 3)
      end

      it "scopes to FE phases" do
        expect(described_class.phase_counts(scope: fe_scope)).to eq(sixth_form_or_college: 2)
      end
    end
  end

  describe "working_pattern_counts" do
    before do
      create_list(:vacancy, 3, working_patterns: %w[part_time], phases: %w[primary])
      create(:vacancy, working_patterns: %w[full_time part_time], phases: %w[primary])
    end

    context "with a scope" do
      before do
        create(:vacancy, working_patterns: %w[full_time], phases: %w[primary])
        create(:vacancy, working_patterns: %w[full_time], organisations: [college])
      end

      it "scopes to school phases" do
        expect(described_class.working_pattern_counts(scope: school_scope)).to eq(part_time: 4, full_time: 2)
      end

      it "scopes to FE phases" do
        expect(described_class.working_pattern_counts(scope: fe_scope)).to eq(full_time: 1)
      end
    end
  end

  describe "job_share_counts" do
    before do
      create_list(:vacancy, 3, is_job_share: true, phases: %w[primary])
      create_list(:vacancy, 2, is_job_share: false, phases: %w[primary])
    end

    context "with a scope" do
      before do
        create(:vacancy, is_job_share: true, phases: %w[primary])
        create(:vacancy, is_job_share: true, organisations: [college])
      end

      it "scopes to school phases" do
        expect(described_class.job_share_counts(scope: school_scope)).to eq(4)
      end

      it "scopes to FE phases" do
        expect(described_class.job_share_counts(scope: fe_scope)).to eq(1)
      end
    end
  end

  describe "subject_counts" do
    context "with a variety of subjects" do
      before do
        create_list(:vacancy, 3, :secondary, subjects: %w[Mathematics])
        create(:vacancy, :secondary, subjects: %w[English])
        create(:vacancy, :secondary, subjects: %w[Spanish French])
        create(:vacancy)
      end

      it "returns counts for all subjects by default" do
        expect(described_class.subject_counts(scope: school_scope)).to include(Mathematics: 3, English: 1, Spanish: 1, French: 1, Science: 0, "Foreign Languages": 2)
      end
    end

    context "with modern foreign languages" do
      before do
        create(:vacancy, :secondary, subjects: %w[French])
        create(:vacancy, :secondary, subjects: %w[Spanish])
        create(:vacancy, :secondary, subjects: %w[German])
        create(:vacancy, :secondary, subjects: %w[Mandarin])
        create(:vacancy, :secondary, subjects: %w[Classics])
        create(:vacancy, :secondary, subjects: ["Foreign Languages"])
      end

      it "successfully groups modern foreign languages together" do
        expect(described_class.subject_counts(scope: school_scope))
          .to include(French: 1, Spanish: 1, Mandarin: 1, Classics: 1, German: 1, "Foreign Languages": 6)
      end
    end

    context "with science subjects" do
      before do
        create(:vacancy, :secondary, subjects: %w[Physics])
        create(:vacancy, :secondary, subjects: %w[Chemistry])
        create(:vacancy, :secondary, subjects: %w[Biology])
        create(:vacancy, :secondary, subjects: %w[Science])
      end

      it "successfully groups science subjects together" do
        expect(described_class.subject_counts(scope: school_scope)).to include(Science: 4, Physics: 1, Chemistry: 1, Biology: 1)
      end
    end

    context "with a scope" do
      before do
        create(:vacancy, :secondary, subjects: %w[Mathematics])
        create(:vacancy, :secondary, organisations: [college], subjects: %w[Mathematics])
        create(:vacancy, :secondary, organisations: [college], subjects: %w[Physics])
      end

      it "scopes to school phases" do
        expect(described_class.subject_counts(scope: school_scope)).to include(Mathematics: 1, Science: 0, "Foreign Languages": 0)
      end

      it "scopes to FE phases" do
        expect(described_class.subject_counts(scope: fe_scope)).to include(Mathematics: 1, Physics: 1, Science: 1, "Foreign Languages": 0)
      end
    end

    context "with art and design technology subjects" do
      before do
        create(:vacancy, :secondary, subjects: ["Art and design"])
        create(:vacancy, :secondary, subjects: ["Design and technology"])
        create(:vacancy, :secondary, subjects: ["Art and design", "Design and technology"])
      end

      it "groups art and design technology subjects together" do
        expect(described_class.subject_counts(scope: school_scope))
          .to eq("Art and design": 2,
                 "Dance, Drama and Music": 0,
                 "English and Media Studies": 0,
                 "Foreign Languages": 0,
                 "Health and Social Care": 0,
                 "ICT and Computer Science": 0,
                 "Design and technology": 2,
                 "Economics and Business Studies": 0,
                 "Politics, Humanities and Social Sciences": 0,
                 "Psychology, Sociology and RE": 0,
                 Science: 0)
      end
    end

    context "with dance, drama and music subjects" do
      before do
        create(:vacancy, :secondary, subjects: %w[Dance])
        create(:vacancy, :secondary, subjects: %w[Drama])
        create(:vacancy, :secondary, subjects: %w[Music])
      end

      it "groups dance, drama and music subjects together" do
        expect(described_class.subject_counts(scope: school_scope))
          .to include("Dance, Drama and Music": 3, Dance: 1, Drama: 1, Music: 1)
      end
    end

    context "with economics and business studies subjects" do
      before do
        create(:vacancy, :secondary, subjects: %w[Economics])
        create(:vacancy, :secondary, subjects: ["Business studies"])
      end

      it "groups economics and business studies subjects together" do
        expect(described_class.subject_counts(scope: school_scope))
          .to include("Economics and Business Studies": 2, Economics: 1, "Business studies": 1)
      end
    end

    context "with english and media studies subjects" do
      before do
        create(:vacancy, :secondary, subjects: %w[English])
        create(:vacancy, :secondary, subjects: ["Media studies"])
      end

      it "groups english and media studies subjects together" do
        expect(described_class.subject_counts(scope: school_scope))
          .to include("English and Media Studies": 2, English: 1, "Media studies": 1)
      end
    end

    context "with health and social care subjects" do
      before do
        create(:vacancy, :secondary, subjects: ["Health and social care"])
        create(:vacancy, :secondary, subjects: ["Relationships and sex education"])
      end

      it "groups health and social care subjects together" do
        expect(described_class.subject_counts(scope: school_scope))
          .to include("Health and Social Care": 2, "Health and social care": 1, "Relationships and sex education": 1)
      end
    end

    context "with ICT and computer science subjects" do
      before do
        create(:vacancy, :secondary, subjects: %w[ICT])
        create(:vacancy, :secondary, subjects: %w[Computing])
      end

      it "groups ICT and computer science subjects together" do
        expect(described_class.subject_counts(scope: school_scope))
          .to include("ICT and Computer Science": 2, ICT: 1, Computing: 1)
      end
    end

    context "with politics, humanities and social sciences subjects" do
      before do
        create(:vacancy, :secondary, subjects: %w[Politics])
        create(:vacancy, :secondary, subjects: %w[Humanities])
        create(:vacancy, :secondary, subjects: ["Social sciences"])
      end

      it "groups politics, humanities and social sciences subjects together" do
        expect(described_class.subject_counts(scope: school_scope))
          .to include("Politics, Humanities and Social Sciences": 3, Politics: 1, Humanities: 1, "Social sciences": 1)
      end
    end

    context "with psychology, sociology and RE subjects" do
      before do
        create(:vacancy, :secondary, subjects: %w[Psychology])
        create(:vacancy, :secondary, subjects: %w[Philosophy])
        create(:vacancy, :secondary, subjects: %w[Sociology])
        create(:vacancy, :secondary, subjects: ["Religious education"])
      end

      it "groups psychology, sociology and RE subjects together" do
        expect(described_class.subject_counts(scope: school_scope))
          .to include("Psychology, Sociology and RE": 4, Psychology: 1, Philosophy: 1, Sociology: 1, "Religious education": 1)
      end
    end
  end
end
