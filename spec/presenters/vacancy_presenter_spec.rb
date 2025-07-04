require "rails_helper"
require "nokogiri"

def normalize_html(html)
  Nokogiri::HTML.fragment(html).to_html
end

RSpec.shared_examples "a fields that outputs the correct HTML" do |field|
  context "when the field has undesired tags" do
    let(:vacancy) { build_stubbed(:vacancy, field => unsanitized_text) }
    let(:unsanitized_text) { "<script> call();</script>Sanitized content" }
    let(:sanitized_text) { "<p> call();Sanitized content</p>" }

    it "sanitizes and transforms the field into safe HTML" do
      expect(normalize_html(subject.public_send(field))).to eq(normalize_html(sanitized_text))
    end
  end

  context "when the field is well-formatted (has line breaks between list items)" do
    let(:vacancy) { build_stubbed(:vacancy, field => well_formatted_text) }
    let(:well_formatted_text) do
      "Some list\n" \
      "Some itmes to follow:\n" \
      "·   Item number one\n" \
      "·   Item number two\n" \
      "·   Item number three\n" \
      "Apply now. "
    end
    let(:well_formatted_html) do
      "<p>Some list\n<br />" \
      "Some itmes to follow:\n<br />" \
      "•   Item number one\n<br />" \
      "•   Item number two\n<br />" \
      "•   Item number three\n<br />" \
      "Apply now. </p>"
    end

    it "does not reformat text" do
      expect(normalize_html(subject.public_send(field))).to eq(normalize_html(well_formatted_html))
    end
  end

  context "when the field is badly formatted (no line breaks between list items)" do
    let(:vacancy) { build_stubbed(:vacancy, field => badly_formatted_text) }

    let(:badly_formatted_text) do
      " Sentence one. Sentence two.\n" \
      "Paragraph two. Qualifications:\n" \
      "•    Skill one." \
      "•    Skill two." \
      "•    Skill three.\n" \
      "Penultimate paragraph.\n" \
      "Last paragraph \n"
    end

    let(:well_formatted_html) do
      "<p> Sentence one. Sentence two.\n<br />" \
      "Paragraph two. Qualifications:\n<br />" \
      "<ul>" \
      "<li>    Skill one.</li>" \
      "<li>    Skill two.</li>" \
      "<li>    Skill three.</li>" \
      "</ul>" \
      "\n<br />Penultimate paragraph.\n<br />" \
      "Last paragraph </p>"
    end

    it "transforms badly formatted inline bullet point symbols into validly formatted <li> tags" do
      expect(normalize_html(subject.public_send(field))).to eq(normalize_html(well_formatted_html))
    end
  end

  # For backwards compatibility. Rich-text editing was removed 16th August 2021.
  context "when the field was made using a rich text editor" do
    context "when the field is well-formatted (has line breaks between list items)" do
      let(:vacancy) { build_stubbed(:vacancy, field => well_formatted_text) }

      let(:well_formatted_text) do
        "<div><!--block-->&nbsp;</div><div><!--block--><strong>Some list</strong>&nbsp;<br><br></div>" \
        "<div><!--block-->Some itmes to follow:&nbsp;<br><br></div>" \
        "<div><!--block-->· &nbsp; Item number one;&nbsp;<br><br></div>" \
        "<div><!--block-->· &nbsp; Item number two;&nbsp;<br><br></div>" \
        "<div><!--block-->· &nbsp; Item number three;&nbsp;<br><br></div>" \
        "<div><!--block-->Apply now.&nbsp;</div>"
      end

      let(:well_formatted_html) do
        "<p> <strong>Some list</strong> </p>\n\n" \
        "<p>Some itmes to follow: </p>\n\n" \
        "<p>•   Item number one; </p>\n\n" \
        "<p>•   Item number two; </p>\n\n" \
        "<p>•   Item number three; </p>\n\n" \
        "<p>Apply now. </p>"
      end

      it "does not reformat text" do
        expect(normalize_html(subject.public_send(field))).to eq(normalize_html(well_formatted_html))
      end
    end

    context "when the field is badly formatted" do
      let(:vacancy) { build_stubbed(:vacancy, field => badly_formatted_text) }

      let(:badly_formatted_text) do
        "<div><!--block-->&nbsp;</div><div><!--block-->Sentence one. Sentence two.&nbsp;<br><br></div>" \
        "<div><!--block-->Paragraph two. Qualifications:&nbsp;<br><br></div>" \
        "<div><!--block-->•&nbsp; &nbsp; Skill one.&nbsp;</div>" \
        "<div><!--block-->•&nbsp; &nbsp; Skill two.&nbsp;</div>" \
        "<div><!--block-->•&nbsp; &nbsp; Skill three.&nbsp;<br><br></div>" \
        "<div><!--block-->Penultimate paragraph.&nbsp;<br><br>" \
        "Last paragraph &nbsp;<br><br></div><div>"
      end

      let(:well_formatted_html) do
        "<p> Sentence one. Sentence two. </p>\n\n" \
        "<p>Paragraph two. Qualifications: </p>\n\n" \
        "<p></p><ul>\n" \
        "<li>  Skill one.</li>\n" \
        "<li>  Skill two.</li>\n" \
        "<li>  Skill three.</li>\n" \
        "</ul>\n\n" \
        "<p>Penultimate paragraph. </p>\n\n" \
        "<p>Last paragraph  </p>"
      end

      it "transforms badly formatted inline bullet point symbols into validly formatted <li> tags" do
        expect(normalize_html(subject.public_send(field))).to eq(normalize_html(well_formatted_html))
      end
    end
  end
end

RSpec.describe VacancyPresenter do
  subject { described_class.new(vacancy) }

  let(:vacancy) { build_stubbed(:vacancy) }

  describe "#benefits_details" do
    it_behaves_like "a fields that outputs the correct HTML", :benefits_details
  end

  describe "#readable_working_patterns" do
    context "when is_job_share" do
      let(:vacancy) { build_stubbed(:vacancy, working_patterns: %w[full_time part_time], is_job_share: true) }

      it "returns working patterns" do
        expect(subject.readable_working_patterns).to eq("Full time, part time (Can be done as a job share)")
      end
    end

    context "when is_job_share == false" do
      let(:vacancy) { build_stubbed(:vacancy, working_patterns: %w[full_time part_time], is_job_share: false) }
      it "returns working patterns" do
        expect(subject.readable_working_patterns).to eq("Full time, part time")
      end
    end
  end

  describe "#readable_working_patterns_with_details" do
    let(:working_patterns) { %w[full_time part_time] }
    let(:working_patterns_details) { "Some details" }
    let(:vacancy) { build_stubbed(:vacancy, working_patterns:, working_patterns_details:, is_job_share: false) }

    it "returns the working with details" do
      expect(subject.readable_working_patterns_with_details).to eq("Full time, part time: Some details")
    end

    context "when there is no details" do
      let(:working_patterns_details) { "" }

      it "returns the working patterns" do
        expect(subject.readable_working_patterns_with_details).to eq("Full time, part time")
      end
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
  end

  describe "#fixed_term_contract_duration" do
    let(:vacancy) do
      build_stubbed(:vacancy, contract_type: contract_type,
                              fixed_term_contract_duration: fixed_term_contract_duration,
                              is_parental_leave_cover: is_parental_leave_cover)
    end

    context "when permanent" do
      let(:contract_type) { :permanent }
      let(:fixed_term_contract_duration) { "" }
      let(:is_parental_leave_cover) { nil }

      it "returns Permanent" do
        expect(subject.contract_type_with_duration).to eq "Permanent"
      end
    end

    context "when fixed term" do
      let(:contract_type) { :fixed_term }
      let(:fixed_term_contract_duration) { "6 months" }

      context "when is_parental_leave_cover is false" do
        let(:is_parental_leave_cover) { false }

        it "returns Fixed term (duration)" do
          expect(subject.contract_type_with_duration).to eq "Fixed term - 6 months"
        end
      end

      context "when is_parental_leave_cover is true" do
        let(:is_parental_leave_cover) { true }

        it "returns Fixed term (duration)" do
          expect(subject.contract_type_with_duration).to eq "Fixed term - 6 months - Maternity or parental leave cover"
        end
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
      expect(subject.readable_key_stages).to eq("Key stage 1, Early years")
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
        build_stubbed(:vacancy,
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
        build_stubbed(:vacancy,
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
        build_stubbed(:vacancy,
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
        build_stubbed(:vacancy,
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
        build_stubbed(:vacancy,
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
        build_stubbed(:vacancy,
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
        build_stubbed(:vacancy,
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
      build_stubbed(:vacancy,
                    organisations: organisations,
                    publisher_organisation: publisher_organisation,
                    publisher: publisher)
    end
    let(:school) { build(:school, gias_data: { "ReligiousCharacter (name)" => "Church of England" }) }
    let(:organisations) { [school] }
    let(:publisher_organisation) { school }
    let(:publisher) { build_stubbed(:publisher) }

    it "returns the religious character of each school" do
      expect(subject.religious_character).to eq([school.religious_character])
    end

    context "when the vacancy isn't associated with any schools" do
      let(:trust) { build_stubbed(:trust) }
      let(:organisations) { [trust] }
      let(:publisher_organisation) { trust }

      it "returns an empty array" do
        expect(subject.religious_character).to eq([])
      end
    end
  end
end
