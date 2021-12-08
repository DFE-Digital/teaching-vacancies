require "rails_helper"

RSpec.describe VacancyPresenter do
  subject { described_class.new(vacancy) }

  let(:vacancy) { build(:vacancy) }

  describe "#expired?" do
    context "when the vacancy has expired by now" do
      let(:vacancy) { build_stubbed(:vacancy, expires_at: 1.hour.ago) }

      it "returns true" do
        expect(subject).to be_expired
      end
    end

    context "when the vacancy expires later today" do
      let(:vacancy) { build_stubbed(:vacancy, expires_at: 1.hour.from_now) }

      it "returns false" do
        expect(subject).not_to be_expired
      end
    end
  end

  describe "#publish_today?" do
    let(:vacancy) { build_stubbed(:vacancy, publish_on: Date.current) }

    it "verifies that the publish_on is set to today" do
      expect(subject.publish_today?).to eq(true)
    end
  end

  describe "#job_advert" do
    let(:vacancy) { build_stubbed(:vacancy, job_advert: "<script> call();</script>Sanitized content") }

    it "sanitizes and transforms the job_advert into HTML" do
      expect(subject.job_advert).to eq("<p> call();Sanitized content</p>")
    end

    context "when the advert is well-formatted (has line breaks between list items)" do
      let(:vacancy) do
        build(:vacancy, job_advert:
          "Deputy Head Teacher\n" \
         "To be successful, you will:\n" \
         "·   Have quality one\n" \
         "·   Have quality two\n" \
         "·   Have quality three\n" \
         "Apply now. ")
      end

      it "does not reformat" do
        expect(subject.job_advert).to eq(
          "<p>Deputy Head Teacher\n<br />" \
          "To be successful, you will:\n<br />" \
          "•   Have quality one\n<br />" \
          "•   Have quality two\n<br />" \
          "•   Have quality three\n<br />" \
          "Apply now. </p>",
        )
      end
    end

    context "when the advert is badly formatted (no line breaks between list items)" do
      let(:vacancy) do
        build(:vacancy, job_advert:
          " Sentence one. Sentence two.\n" \
          "Paragraph two. Qualifications:\n" \
          "•    Skill one." \
          "•    Skill two." \
          "•    Skill three.\n" \
          "Penultimate paragraph.\n" \
          "Last paragraph \n")
      end

      it "transforms badly formatted inline bullet point symbols into validly formatted <li> tags" do
        expect(subject.job_advert).to eq(
          "<p> Sentence one. Sentence two.\n<br />" \
          "Paragraph two. Qualifications:\n<br />" \
          "<ul>\n<br /><li>    Skill one.</li>\n<br />" \
          "<li>    Skill two.</li>\n<br />" \
          "<li>    Skill three.</li>\n<br /></ul>" \
          "\n<br />Penultimate paragraph.\n<br />" \
          "Last paragraph </p>",
        )
      end
    end

    # For backwards compatibility. Rich-text editing was removed 16th August 2021.
    context "when the advert was made using a rich text editor" do
      context "when the advert is well-formatted (has line breaks between list items)" do
        let(:vacancy) do
          build_stubbed(:vacancy, job_advert:
            "<div><!--block-->&nbsp;</div><div><!--block--><strong>Deputy Head Teacher</strong>&nbsp;<br><br></div>" \
         "<div><!--block-->To be successful, you will:&nbsp;<br><br></div>" \
         "<div><!--block-->· &nbsp; Have quality one;&nbsp;<br><br></div>" \
         "<div><!--block-->· &nbsp; Have quality two;&nbsp;<br><br></div>" \
         "<div><!--block-->· &nbsp; Have quality three;&nbsp;<br><br></div>" \
         "<div><!--block-->Apply now.&nbsp;</div>")
        end

        it "does not reformat" do
          expect(subject.job_advert).to eq(
            "<p> <strong>Deputy Head Teacher</strong> </p>\n\n" \
          "<p>To be successful, you will: </p>\n\n" \
          "<p>•   Have quality one; </p>\n\n" \
          "<p>•   Have quality two; </p>\n\n" \
          "<p>•   Have quality three; </p>\n\n" \
          "<p>Apply now. </p>",
          )
        end
      end

      context "when the advert is badly formatted" do
        let(:vacancy) do
          build_stubbed(:vacancy, job_advert:
            "<div><!--block-->&nbsp;</div><div><!--block-->Sentence one. Sentence two.&nbsp;<br><br></div>" \
          "<div><!--block-->Paragraph two. Qualifications:&nbsp;<br><br></div>" \
          "<div><!--block-->•&nbsp; &nbsp; Skill one.&nbsp;</div>" \
          "<div><!--block-->•&nbsp; &nbsp; Skill two.&nbsp;</div>" \
          "<div><!--block-->•&nbsp; &nbsp; Skill three.&nbsp;<br><br></div>" \
          "<div><!--block-->Penultimate paragraph.&nbsp;<br><br>" \
          "Last paragraph &nbsp;<br><br></div><div>")
        end

        it "transforms badly formatted inline bullet point symbols into validly formatted <li> tags" do
          expect(subject.job_advert).to eq(
            "<p> Sentence one. Sentence two. </p>\n\n" \
          "<p>Paragraph two. Qualifications: </p>\n\n" \
          "<p><ul>\n<br /><li>  Skill one.</li>\n<br />" \
          "<li>  Skill two.</li>\n<br />" \
          "<li>  Skill three.</li>\n<br />" \
          "</ul></p>\n\n<p>Penultimate paragraph. </p>\n\n" \
          "<p>Last paragraph  </p>",
          )
        end
      end
    end
  end

  describe "#about_school" do
    let(:vacancy) { build_stubbed(:vacancy, about_school: "<script> call();</script>Sanitized content") }

    it "sanitizes and transforms about_school into HTML" do
      expect(subject.about_school).to eq("<p> call();Sanitized content</p>")
    end
  end

  describe "#school_visits" do
    let(:vacancy) { build_stubbed(:vacancy, school_visits: "<script> call();</script>Sanitized content") }

    it "sanitizes and transforms school_visits into HTML" do
      expect(subject.school_visits).to eq("<p> call();Sanitized content</p>")
    end
  end

  describe "#how_to_apply" do
    let(:vacancy) { build_stubbed(:vacancy, how_to_apply: "<script> call();</script>Sanitized content") }

    it "sanitizes and transforms school_visits into HTML" do
      expect(subject.how_to_apply).to eq("<p> call();Sanitized content</p>")
    end
  end

  describe "#all_job_roles" do
    let(:vacancy) { build_stubbed(:vacancy) }

    it "returns the main job role" do
      expect(subject.all_job_roles).to include subject.show_main_job_role
    end

    it "returns the additional job roles" do
      vacancy.additional_job_roles.each do |additional_job_role|
        expect(subject.all_job_roles).to include subject.additional_job_role(additional_job_role)
      end
    end
  end

  describe "#working_patterns" do
    context "when working_patterns is unset" do
      let(:vacancy) { build_stubbed(:vacancy, :without_working_patterns) }

      it "returns nil" do
        expect(subject.working_patterns).to be_nil
      end
    end

    context "when only working_patterns is set" do
      let(:vacancy) { build_stubbed(:vacancy, working_patterns: %w[full_time part_time], working_patterns_details: nil) }

      it "returns a string only containing the working pattern" do
        expect(subject.show_working_patterns).to eq(I18n.t("jobs.working_patterns_info", patterns: "full time, part time", count: 2))
      end
    end

    context "when both working_patterns and working_patterns_details have been set" do
      let(:vacancy) { build_stubbed(:vacancy, working_patterns: %w[full_time part_time]) }

      it "returns a string containing the working pattern and working_patterns_details" do
        expect(subject.show_working_patterns).to eq(safe_join([subject.working_patterns,
                                                               tag.br,
                                                               tag.span(subject.working_patterns_details, class: "govuk-hint govuk-!-margin-bottom-0")]))
      end
    end
  end

  describe "#working_patterns_for_job_schema" do
    context "when working_patterns is unset" do
      let(:vacancy) { build_stubbed(:vacancy, :without_working_patterns) }

      it "returns blank" do
        expect(subject.working_patterns_for_job_schema).to be_blank
      end
    end

    context "when working_patterns is set" do
      let(:vacancy) { build_stubbed(:vacancy, working_patterns: %w[full_time part_time]) }

      it "returns a string containing the working pattern" do
        expect(subject.working_patterns_for_job_schema).to eq("FULL_TIME, PART_TIME")
      end
    end
  end

  describe "#share_url" do
    let(:vacancy) { create(:vacancy, job_title: "PE Teacher") }

    it "returns the absolute public url for the job post" do
      expected_url = URI("localhost:3000/jobs/pe-teacher")
      expect(subject.share_url).to match(expected_url.to_s)
    end

    context "when campaign parameters are passed" do
      it "builds the campaign URL" do
        expected_campaign_url = URI("http://localhost:3000/jobs/pe-teacher?utm_medium=interpretative_dance&utm_source=alert_run_id")
        expect(subject.share_url(utm_source: "alert_run_id", utm_medium: "interpretative_dance")).to match(expected_campaign_url.to_s)
      end
    end
  end

  describe "#fixed_term_contract_duration" do
    let(:vacancy) { build_stubbed(:vacancy, contract_type: contract_type, fixed_term_contract_duration: fixed_term_contract_duration) }

    context "when permanent" do
      let(:contract_type) { :permanent }
      let(:fixed_term_contract_duration) { nil }

      it "returns Permanent" do
        expect(subject.contract_type_with_duration).to eq "Permanent"
      end
    end

    context "when fixed term" do
      let(:contract_type) { :fixed_term }
      let(:fixed_term_contract_duration) { "6 months" }

      it "returns Fixed term (duration)" do
        expect(subject.contract_type_with_duration).to eq "Fixed term (6 months)"
      end
    end
  end

  describe "#maternity_cover_contract_duration" do
    let(:vacancy) { build_stubbed(:vacancy, contract_type: contract_type, maternity_cover_contract_duration: maternity_cover_contract_duration) }

    context "when permanent" do
      let(:contract_type) { :permanent }
      let(:maternity_cover_contract_duration) { nil }

      it "returns Permanent" do
        expect(subject.contract_type_with_duration).to eq "Permanent"
      end
    end

    context "when maternity cover" do
      let(:contract_type) { :maternity_cover }
      let(:maternity_cover_contract_duration) { "6 months" }

      it "returns Maternity cover (duration)" do
        expect(subject.contract_type_with_duration).to eq "Maternity cover (6 months)"
      end
    end
  end

  describe "#show_subjects" do
    let(:vacancy) { build_stubbed(:vacancy, subjects: %w[Acrobatics Tapestry]) }

    it "joins them correctly" do
      expect(subject.show_subjects).to eq("Acrobatics, Tapestry")
    end

    context "when there are no subjects" do
      let(:vacancy) { build_stubbed(:vacancy, subjects: []) }

      it "returns empty string" do
        expect(subject.show_subjects).to be_blank
      end
    end
  end

  describe "#show_key_stages" do
    let(:vacancy) { build_stubbed(:vacancy, key_stages: %w[ks1 early_years]) }

    it "joins them correctly" do
      expect(subject.show_key_stages).to eq("KS1, Early years")
    end

    context "when there are no subjects" do
      let(:vacancy) { build_stubbed(:vacancy, key_stages: []) }

      it "returns empty string" do
        expect(subject.show_key_stages).to be_blank
      end
    end
  end

  describe "#columns" do
    it "delegates to the record's columns" do
      expect(subject.columns).to eq(vacancy.class.columns)
    end
  end
end
