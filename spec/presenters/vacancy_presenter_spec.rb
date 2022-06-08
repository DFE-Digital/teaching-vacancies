require "rails_helper"

RSpec.describe VacancyPresenter do
  subject { described_class.new(vacancy) }

  let(:vacancy) { build(:vacancy) }

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

  describe "#readable_working_patterns" do
    let(:vacancy) { build_stubbed(:vacancy, working_patterns: %w[full_time part_time]) }

    it "returns working patterns" do
      expect(subject.readable_working_patterns).to eq("Full time, part time")
    end
  end

  describe "#working_patterns_for_job_schema" do
    context "when FULL_TIME" do
      let(:vacancy) { build_stubbed(:vacancy, working_patterns: %w[full_time], fixed_term_contract_duration: nil) }

      it "returns an array containing FULL_TIME" do
        expect(subject.working_patterns_for_job_schema).to eq %w[FULL_TIME]
      end
    end

    context "when PART_TIME" do
      let(:vacancy) { build_stubbed(:vacancy, working_patterns: %w[part_time], fixed_term_contract_duration: nil) }

      it "returns an array containing PART_TIME" do
        expect(subject.working_patterns_for_job_schema).to eq %w[PART_TIME]
      end
    end

    context "when TEMPORARY" do
      let(:vacancy) { build_stubbed(:vacancy, working_patterns: %w[term_time], fixed_term_contract_duration: "2 months") }

      it "returns an array containing TEMPORARY" do
        expect(subject.working_patterns_for_job_schema).to eq %w[TEMPORARY]
      end
    end

    context "when OTHER" do
      let(:vacancy) { build_stubbed(:vacancy, working_patterns: %w[term_time], fixed_term_contract_duration: nil) }

      it "returns an array containing OTHER" do
        expect(subject.working_patterns_for_job_schema).to eq %w[OTHER]
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

  describe "#parental_leave_cover_contract_duration" do
    let(:vacancy) { build_stubbed(:vacancy, contract_type: contract_type, parental_leave_cover_contract_duration: parental_leave_cover_contract_duration) }

    context "when permanent" do
      let(:contract_type) { :permanent }
      let(:parental_leave_cover_contract_duration) { nil }

      it "returns Permanent" do
        expect(subject.contract_type_with_duration).to eq "Permanent"
      end
    end

    context "when parental_leave cover" do
      let(:contract_type) { :parental_leave_cover }
      let(:parental_leave_cover_contract_duration) { "6 months" }

      it "returns Maternity or parental leave cover (duration)" do
        expect(subject.contract_type_with_duration).to eq "Maternity or parental leave cover (6 months)"
      end
    end
  end

  describe "#readable_subjects" do
    let(:vacancy) { build_stubbed(:vacancy, subjects: %w[Acrobatics Tapestry]) }

    it "joins them correctly" do
      expect(subject.readable_subjects).to eq("Acrobatics, Tapestry")
    end

    context "when there are no subjects" do
      let(:vacancy) { build_stubbed(:vacancy, subjects: []) }

      it "returns empty string" do
        expect(subject.readable_subjects).to be_blank
      end
    end
  end

  describe "#readable_key_stages" do
    let(:vacancy) { build_stubbed(:vacancy, key_stages: %w[ks1 early_years]) }

    it "joins them correctly" do
      expect(subject.readable_key_stages).to eq("KS1, Early years")
    end

    context "when there are no subjects" do
      let(:vacancy) { build_stubbed(:vacancy, key_stages: []) }

      it "returns empty string" do
        expect(subject.readable_key_stages).to be_blank
      end
    end
  end

  describe "#columns" do
    it "delegates to the record's columns" do
      expect(subject.columns).to eq(vacancy.class.columns)
    end
  end

  describe "#school_group_names" do
    let(:publisher) { build_stubbed(:publisher) }
    let(:trust) { build_stubbed(:trust, name: "Cheesy trust name") }
    let(:local_authority) { build_stubbed(:local_authority, name: "Tower Hamlets") }

    context "when the vacancy isn't associated with any schools" do
      let(:vacancy) do
        build_stubbed(:vacancy, :central_office,
                      organisations: organisations,
                      publisher_organisation: publisher_organisation,
                      publisher: publisher)
      end
      let(:organisations) { [trust] }
      let(:publisher_organisation) { trust }

      it "returns the names of all of the school groups the job is associated with" do
        expect(subject.school_group_names).to eq([trust.name])
      end
    end

    context "when the vacancy is at one school" do
      let(:vacancy) do
        build_stubbed(:vacancy, :at_one_school,
                      organisations: organisations,
                      publisher_organisation: publisher_organisation,
                      publisher: publisher)
      end
      let(:organisations) { [school] }
      let(:school) { build_stubbed(:school, school_groups: [local_authority]) }
      let(:publisher_organisation) { school }

      it "returns the name of the local authority the school is within" do
        expect(subject.school_group_names).to eq([local_authority.name])
      end
    end

    context "when the vacancy is at multiple schools" do
      let(:vacancy) do
        build_stubbed(:vacancy, :at_multiple_schools,
                      organisations: organisations,
                      publisher_organisation: publisher_organisation,
                      publisher: publisher)
      end
      let(:school_one) { build_stubbed(:school, school_groups: [trust, local_authority]) }
      let(:school_two) { build_stubbed(:school, school_groups: [trust, local_authority]) }
      let(:organisations) { [school_one, school_two] }
      let(:publisher_organisation) { trust }

      it "returns the names of all of the school groups the vacancy is associated with" do
        expect(subject.school_group_names).to eq([trust.name, local_authority.name])
      end
    end
  end

  describe "#school_group_types" do
    let(:publisher) { build_stubbed(:publisher) }
    let(:trust) { build_stubbed(:trust, name: "Cheesy trust name") }
    let(:local_authority) { build_stubbed(:local_authority, name: "Tower Hamlets") }

    context "when the vacancy isn't associated with any schools" do
      let(:vacancy) do
        build_stubbed(:vacancy, :central_office,
                      organisations: organisations,
                      publisher_organisation: publisher_organisation,
                      publisher: publisher)
      end
      let(:organisations) { [trust] }
      let(:publisher_organisation) { trust }

      it "returns the names of all of the school groups the vacancy is associated with" do
        expect(subject.school_group_types).to eq([trust.group_type])
      end
    end

    context "when the vacancy is at one school" do
      let(:vacancy) do
        build_stubbed(:vacancy, :at_one_school,
                      organisations: organisations,
                      publisher_organisation: publisher_organisation,
                      publisher: publisher)
      end
      let(:organisations) { [school] }
      let(:school) { build_stubbed(:school, school_groups: [local_authority]) }
      let(:publisher_organisation) { school }

      it "returns the name of the local authority the school is within" do
        expect(subject.school_group_types).to eq([local_authority.group_type])
      end
    end

    context "when the vacancy is at multiple schools" do
      let(:vacancy) do
        build_stubbed(:vacancy, :at_multiple_schools,
                      organisations: organisations,
                      publisher_organisation: publisher_organisation,
                      publisher: publisher)
      end
      let(:school_one) { build_stubbed(:school, school_groups: [trust, local_authority]) }
      let(:school_two) { build_stubbed(:school, school_groups: [trust, local_authority]) }
      let(:organisations) { [school_one, school_two] }
      let(:publisher_organisation) { trust }

      it "returns the names of all of the school groups the vacancy is associated with" do
        expect(subject.school_group_types).to eq([trust.group_type, local_authority.group_type])
      end
    end

    context "when the school group does not have a group type" do
      let(:vacancy) do
        build_stubbed(:vacancy, :at_one_school,
                      organisations: organisations,
                      publisher_organisation: publisher_organisation,
                      publisher: publisher)
      end
      let(:trust_with_no_group_type) { build_stubbed(:trust, group_type: "") }
      let(:school) { build_stubbed(:school, school_groups: [trust_with_no_group_type]) }
      let(:organisations) { [school] }
      let(:publisher_organisation) { school }

      it "returns an empty array" do
        expect(subject.school_group_types).to eq([])
      end
    end
  end

  describe "#religious_character" do
    let(:vacancy) do
      build_stubbed(:vacancy, location,
                    organisations: organisations,
                    publisher_organisation: publisher_organisation,
                    publisher: publisher)
    end
    let(:location) { :at_one_school }
    let(:school) { build(:school) }
    let(:organisations) { [school] }
    let(:publisher_organisation) { school }
    let(:publisher) { build_stubbed(:publisher) }

    it "returns the religious character of each school" do
      expect(subject.religious_character).to eq([school.religious_character])
    end

    context "when the vacancy isn't associated with any schools" do
      let(:location) { :central_office }
      let(:trust) { build_stubbed(:trust) }
      let(:organisations) { [trust] }
      let(:publisher_organisation) { trust }

      it "returns an empty array" do
        expect(subject.religious_character).to eq(nil)
      end
    end
  end
end
