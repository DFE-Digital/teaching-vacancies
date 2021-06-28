require "rails_helper"

RSpec.describe VacancyPresenter do
  describe "#expired?" do
    it "returns true when the vacancy has expired by now" do
      vacancy = VacancyPresenter.new(build(:vacancy, expires_at: 1.hour.ago))

      expect(vacancy).to be_expired
    end

    it "returns false when the vacancy expires later today" do
      vacancy = VacancyPresenter.new(build(:vacancy, expires_at: 1.hour.from_now))

      expect(vacancy).not_to be_expired
    end
  end

  describe "#publish_today?" do
    it "verifies that the publish_on is set to today" do
      vacancy = VacancyPresenter.new(build(:vacancy, publish_on: Date.current))

      expect(vacancy.publish_today?).to eq(true)
    end
  end

  describe "#job_advert" do
    it "sanitizes and transforms the job_advert into HTML" do
      vacancy = build(:vacancy, job_advert: "<script> call();</script>Sanitized content")
      presenter = VacancyPresenter.new(vacancy)

      expect(presenter.job_advert).to eq("<p> call();Sanitized content</p>")
    end
  end

  describe "#about_school" do
    it "sanitizes and transforms about_school into HTML" do
      vacancy = build(:vacancy, about_school: "<script> call();</script>Sanitized content")
      presenter = VacancyPresenter.new(vacancy)

      expect(presenter.about_school).to eq("<p> call();Sanitized content</p>")
    end
  end

  describe "#school_visits" do
    it "sanitizes and transforms school_visits into HTML" do
      vacancy = build(:vacancy, school_visits: "<script> call();</script>Sanitized content")
      presenter = VacancyPresenter.new(vacancy)

      expect(presenter.school_visits).to eq("<p> call();Sanitized content</p>")
    end
  end

  describe "#how_to_apply" do
    it "sanitizes and transforms school_visits into HTML" do
      vacancy = build(:vacancy, how_to_apply: "<script> call();</script>Sanitized content")
      presenter = VacancyPresenter.new(vacancy)

      expect(presenter.how_to_apply).to eq("<p> call();Sanitized content</p>")
    end
  end

  describe "#working_patterns" do
    it "returns nil if working_patterns is unset" do
      vacancy = VacancyPresenter.new(create(:vacancy, :without_working_patterns))
      vacancy.organisation_vacancies.create(organisation: create(:school, name: "Smith High School"))

      expect(vacancy.working_patterns).to be_nil
    end

    it "returns a working patterns string if working_patterns is set" do
      vacancy = VacancyPresenter.new(create(:vacancy, working_patterns: %w[full_time part_time]))
      vacancy.organisation_vacancies.create(organisation: create(:school, name: "Smith High School"))

      expect(vacancy.working_patterns).to eq(I18n.t("jobs.working_patterns_info_many",
                                                    patterns: "full-time, part-time"))
    end
  end

  describe "#working_patterns_for_job_schema" do
    it "returns blank if working_patterns is unset" do
      vacancy = VacancyPresenter.new(create(:vacancy, :without_working_patterns))
      vacancy.organisation_vacancies.create(organisation: create(:school, name: "Smith High School"))

      expect(vacancy.working_patterns_for_job_schema).to be_blank
    end

    it "returns a working patterns string if working_patterns is set" do
      vacancy = VacancyPresenter.new(create(:vacancy, working_patterns: %w[full_time part_time]))
      vacancy.organisation_vacancies.create(organisation: create(:school, name: "Smith High School"))

      expect(vacancy.working_patterns_for_job_schema).to eq("FULL_TIME, PART_TIME")
    end
  end

  describe "#share_url" do
    let(:presenter) { VacancyPresenter.new(create(:vacancy, job_title: "PE Teacher")) }

    it "returns the absolute public url for the job post" do
      expected_url = URI("localhost:3000/jobs/pe-teacher")
      expect(presenter.share_url).to match(expected_url.to_s)
    end

    context "when campaign parameters are passed" do
      it "builds the campaign URL" do
        expected_campaign_url = URI("http://localhost:3000/jobs/pe-teacher?utm_medium=interpretative_dance&utm_source=alert_run_id")
        expect(presenter.share_url(utm_source: "alert_run_id", utm_medium: "interpretative_dance")).to match(expected_campaign_url.to_s)
      end
    end
  end

  describe "#contract_type_with_duration" do
    let(:presenter) { VacancyPresenter.new(create(:vacancy, contract_type: contract_type, contract_type_duration: contract_type_duration)) }

    context "when permanent" do
      let(:contract_type) { :permanent }
      let(:contract_type_duration) { nil }

      it "returns Permanent" do
        expect(presenter.contract_type_with_duration).to eq "Permanent"
      end
    end

    context "when fixed term" do
      let(:contract_type) { :fixed_term }
      let(:contract_type_duration) { "6 months" }

      it "returns Fixed term (duration)" do
        expect(presenter.contract_type_with_duration).to eq "Fixed term (6 months)"
      end
    end
  end
end
