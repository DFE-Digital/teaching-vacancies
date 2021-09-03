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

    it "transforms badly formatted inline `•` symbols into validly formatted <li> tags" do
      vacancy = build(:vacancy, job_advert:
        "Required skills: \n\n• Skill • Competency \n" \
        "This is a paragraph that's not part of the bullet pointy bit. \n" \
        "And this is going to have some more bullet points... \n" \
        "• Interpersonal skills • Wonderfulness • Skill three \n" \
        "There you go. No more bullet points.")
      presenter = VacancyPresenter.new(vacancy)

      expect(presenter.job_advert).to eq(
        "<p>Required skills: </p>\n\n" \
        "<p>" \
          "<ul>\n<br />" \
            "<li> Skill </li>\n<br />" \
            "<li> Competency </li>\n<br />" \
          "</ul>\n" \
          "<br />This is a paragraph that's not part of the bullet pointy bit. \n" \
          "<br />And this is going to have some more bullet points... \n<br />" \
          "<ul>\n" \
            "<br /><li> Interpersonal skills </li>\n" \
            "<br /><li> Wonderfulness </li>\n" \
            "<br /><li> Skill three </li>\n" \
            "<br />" \
          "</ul>\n" \
        "<br />There you go. No more bullet points." \
        "</p>",
      )
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

  describe "#all_job_roles" do
    subject { VacancyPresenter.new(vacancy) }

    let(:vacancy) { build(:vacancy) }

    it "returns the primary job role" do
      expect(subject.all_job_roles).to include subject.show_primary_job_role
    end

    it "returns the additional job roles" do
      vacancy.additional_job_roles.each do |additional_job_role|
        expect(subject.all_job_roles).to include subject.additional_job_role(additional_job_role)
      end
    end
  end

  describe "#working_patterns" do
    it "returns nil if working_patterns is unset" do
      vacancy = VacancyPresenter.new(create(:vacancy, :without_working_patterns))
      vacancy.organisation_vacancies.create(organisation: create(:school, name: "Smith High School"))

      expect(vacancy.working_patterns).to be_nil
    end

    context "when only working_patterns is set" do
      it "returns a string only containing the working pattern" do
        vacancy = VacancyPresenter.new(create(:vacancy, working_patterns: %w[full_time part_time], working_patterns_details: nil))
        vacancy.organisation_vacancies.create(organisation: create(:school, name: "Smith High School"))

        expect(vacancy.show_working_patterns).to eq(I18n.t("jobs.working_patterns_info", patterns: "full-time, part-time", count: vacancy.model_working_patterns.count))
      end
    end

    context "when both working_patterns and working_patterns_details have been set" do
      it "returns a string containing the working pattern and working_patterns_details" do
        vacancy = VacancyPresenter.new(create(:vacancy, working_patterns: %w[full_time part_time]))
        vacancy.organisation_vacancies.create(organisation: create(:school, name: "Smith High School"))

        expect(vacancy.show_working_patterns).to eq(safe_join([vacancy.working_patterns,
                                                               tag.br,
                                                               tag.span(vacancy.working_patterns_details, class: "govuk-hint govuk-!-margin-bottom-0")]))
      end
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
