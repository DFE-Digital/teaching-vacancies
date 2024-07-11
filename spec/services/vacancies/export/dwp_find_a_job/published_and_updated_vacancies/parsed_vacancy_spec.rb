require "rails_helper"

RSpec.describe Vacancies::Export::DwpFindAJob::PublishedAndUpdated::ParsedVacancy do
  let(:vacancy) { build_stubbed(:vacancy, :published) }

  subject(:parsed) { described_class.new(vacancy) }

  describe "#job_title" do
    it "returns the vacancy job title" do
      expect(parsed.job_title).to eq(vacancy.job_title)
    end
  end

  describe "#organisation" do
    it "returns the vacancy organisation" do
      organisation = build_stubbed(:school)
      allow(vacancy).to receive(:organisation).and_return(organisation)

      expect(parsed.organisation).to eq(organisation)
    end
  end

  describe "#apply_url" do
    it "returns the vacancy full url" do
      allow(vacancy).to receive(:slug).and_return("job-title-slug")

      expect(parsed.apply_url).to eq("http://#{DOMAIN}/jobs/job-title-slug")
    end
  end

  describe "#category_id" do
    it "returns the IT category id if the vacancy job role is it_support" do
      allow(vacancy).to receive(:job_roles).and_return(["it_support"])

      expect(parsed.category_id).to eq(described_class::CATEGORY_IT_ID)
    end

    it "returns the Education category id if the vacancy job role is not it_support" do
      allow(vacancy).to receive(:job_roles).and_return(["teacher"])

      expect(parsed.category_id).to eq(described_class::CATEGORY_EDUCATION_ID)
    end

    it "returns the IT category id if the vacancy job role is it_support and other" do
      allow(vacancy).to receive(:job_roles).and_return(%w[it_support teacher])

      expect(parsed.category_id).to eq(described_class::CATEGORY_IT_ID)
    end
  end

  describe "#description" do
    let(:school) { build_stubbed(:school, safeguarding_information: nil) }

    before do
      allow(vacancy).to receive(:skills_and_experience).and_return("")
      allow(vacancy).to receive(:school_offer).and_return("")
      allow(vacancy).to receive(:further_details).and_return("")
      allow(vacancy).to receive(:organisation).and_return(school)
    end

    context "when none of the job details are present" do
      it "returns an empty string" do
        expect(parsed.description).to eq("")
      end
    end

    context "when the vacancy has skills and experience information" do
      before { allow(vacancy).to receive(:skills_and_experience).and_return("Skills and experience info") }

      it "returns the vacancy skills and experience info" do
        expect(parsed.description).to eq("What skills and experience we're looking for\n\nSkills and experience info")
      end
    end

    context "when the vacancy has school offer information" do
      before { allow(vacancy).to receive(:school_offer).and_return("School offer info") }

      it "returns the vacancy school offer info" do
        expect(parsed.description).to eq("What the school offers its staff\n\nSchool offer info")
      end
    end

    context "when the vacancy has further details information" do
      before { allow(vacancy).to receive(:further_details).and_return("Further details info") }

      it "returns the vacancy further details info" do
        expect(parsed.description).to eq("Further details about the role\n\nFurther details info")
      end
    end

    context "when the vacancy organisation has safeguarding information" do
      before { allow(school).to receive(:safeguarding_information).and_return("Safeguarding info") }

      it "returns the vacancy organisation safeguarding information" do
        expect(parsed.description).to eq("Commitment to safeguarding\n\nSafeguarding info")
      end
    end

    context "when the vacancy has all job details" do
      before do
        allow(vacancy).to receive(:skills_and_experience).and_return("Skills and experience info")
        allow(vacancy).to receive(:school_offer).and_return("School offer info")
        allow(vacancy).to receive(:further_details).and_return("Further details info")
        allow(school).to receive(:safeguarding_information).and_return("Safeguarding info")
      end

      it "returns all the job details info" do
        expect(parsed.description).to eq(
          "What skills and experience we're looking for\n\nSkills and experience info\n\n" \
          "What the school offers its staff\n\nSchool offer info\n\n" \
          "Further details about the role\n\nFurther details info\n\n" \
          "Commitment to safeguarding\n\nSafeguarding info",
        )
      end
    end

    context "when the vacancy job details have html tags" do
      before do
        allow(vacancy).to receive(:skills_and_experience).and_return(
          "<p>First paragraph</p><ul><li>Item 0</li><li>Item 1<ul><li>Item A<ol><li>Item i</li><li>Item ii</li></ol></li><li>Item B<ul><li>Item i</li></ul></li></ul></li><li>Item 2</li></ul><p><a href='url'>link text</a></p>",
        )
      end

      it "return the html content parsed into plain text" do
        expect(parsed.description).to eq(
          "What skills and experience we're looking for\n\nFirst paragraph\n\n• Item 0\n• Item 1\n  • Item A\n    1. Item i\n    2. Item ii\n  • Item B\n    • Item i\n• Item 2\n\nlink text",
        )
      end
    end

    context "when the vacancy job details have html tags mixed with carriage return symbols" do
      before do
        allow(vacancy).to receive(:skills_and_experience).and_return(
          "<p>First\r\nparagraph</p><ul><li>Item 0</li><li>Item\r\n1</li></ul><p>Last paragraph</p>",
        )
      end

      it "return the html content parsed into plain text with the carriage symbols turned into spaces" do
        expect(parsed.description).to eq(
          "What skills and experience we're looking for\n\nFirst paragraph\n\n• Item 0\n• Item 1\n\nLast paragraph",
        )
      end
    end

    context "when the vacancy job details have more than 2 consecutive line breaks" do
      before do
        allow(vacancy).to receive(:skills_and_experience).and_return(
          "<p>\r\n\r\n\r\n</p><p>The\r\nsuccessful candidate willwork as a 1:1 GTA, working alongside our teaching\r\nteam. </p><p>\r\n\r\n\r\n\r\n</p><p>Second\r\nparagraph.</p><p>\r\n\r\n</p><p>We are aspirational for every\r\nstudent within our Trust.</p><p>\r\n\r\n\r\n\r\n\r\n\r\n</p>",
        )
      end

      it "normalises the empty lines between content to maximum 1 empty line" do
        expect(parsed.description).to eq(
          "What skills and experience we're looking for\n\nThe successful candidate willwork as a 1:1 GTA, working alongside our teaching team.\n\nSecond paragraph.\n\nWe are aspirational for every student within our Trust.",
        )
      end
    end

    context "when the vacancy job details contains an invalid byte sequence" do
      before do
        allow(vacancy).to receive(:skills_and_experience).and_return("Multi\x80\x80\x80Academy Trust")
      end

      it "removes them" do
        expect(parsed.description).to eq("What skills and experience we're looking for\n\nMultiAcademy Trust")
      end
    end

    context "when the vacancy job details contains unicode special characters" do
      before do
        allow(vacancy).to receive(:skills_and_experience).and_return("Multi\u0002'Academy' Trust. Any other info?")
      end

      it "removes them" do
        expect(parsed.description).to eq("What skills and experience we're looking for\n\nMulti'Academy' Trust. Any other info?")
      end
    end
  end

  describe "#expiry" do
    before { travel_to(Time.zone.local(2024, 5, 1, 10, 55, 30)) }
    after { travel_back }

    describe "with the original version of the vacancy" do
      before do
        allow(parsed).to receive(:version).with(vacancy).and_return(0)
      end

      it "returns nil if the vacancy expiry date is before today" do
        allow(vacancy).to receive(:expires_at).and_return(1.day.ago)
        expect(parsed.expiry).to be_nil
      end

      it "returns nil if the vacancy expiry date is today" do
        allow(vacancy).to receive(:expires_at).and_return(1.hour.after)
        expect(parsed.expiry).to be_nil
      end

      it "returns nil if the expiry date is over 31 days after the publishing date" do
        allow(vacancy).to receive_messages(publish_on: 1.days.ago, expires_at: 31.days.after)
        expect(parsed.expiry).to be_nil
      end

      context "when the expiry date is 31 days after the publishing date" do
        before { allow(vacancy).to receive(:expires_at).and_return(30.days.after) }

        it "returns nil if it was published before 23:30" do
          allow(vacancy).to receive(:publish_on).and_return(1.day.ago.change(hour: 23, min: 29))
          expect(parsed.expiry).to be_nil
        end

        it "returns the expiry date if it was published after 23:30" do
          allow(vacancy).to receive(:publish_on).and_return(1.day.ago.change(hour: 23, min: 30, sec: 1))
          expect(parsed.expiry).to eq(30.days.after.to_date.to_s)
        end
      end

      it "returns the expiry date if it is 30 days after the publishing date" do
        allow(vacancy).to receive_messages(publish_on: 1.day.ago, expires_at: 29.days.after)
        expect(parsed.expiry).to eq(29.days.after.to_date.to_s)
      end
    end

    context "with a newer version of the vacancy" do
      before do
        allow(parsed).to receive(:version).with(vacancy).and_return(2)
        allow(vacancy).to receive(:publish_on).and_return(1.hour.ago)
      end

      it "returns the vacancy expiry date if it is after the publishing date of the given version" do
        allow(vacancy).to receive(:expires_at).and_return(63.days.after)
        expect(parsed.expiry).to eq(63.days.after.to_date.to_s)
      end

      context "when the expiry date is a multiplier of 31 days after the original publishing date" do
        before { allow(vacancy).to receive(:expires_at).and_return(92.days.after) }

        it "returns nil if it was published before 23:30" do
          allow(vacancy).to receive(:publish_on).and_return(1.day.ago.change(hour: 23, min: 29))
          expect(parsed.expiry).to be_nil
        end

        it "returns the expiry date if it was published after 23:30" do
          allow(vacancy).to receive(:publish_on).and_return(1.day.ago.change(hour: 23, min: 30, sec: 1))
          expect(parsed.expiry).to eq(92.days.after.to_date.to_s)
        end
      end

      it "returns the vacancy expiry date is on the last allowed day after the publishing date of the given version" do
        allow(vacancy).to receive(:expires_at).and_return(92.days.after)
        expect(parsed.expiry).to eq(92.days.after.to_date.to_s)
      end

      it "returns nil if the vacancy expiry date surpases the last allowed day after the publishing date of the given version" do
        allow(vacancy).to receive(:expires_at).and_return(93.days.after)
        expect(parsed.expiry).to be_nil
      end
    end
  end

  describe "#reference" do
    it "gets the versioned reference for the vacancy" do
      allow(parsed).to receive(:versioned_reference).with(vacancy).and_return("123-1")
      expect(parsed.reference).to eq("123-1")
      expect(parsed).to have_received(:versioned_reference).with(vacancy)
    end
  end

  describe "#status_id" do
    it "returns the full time status id if the vacancy working patterns include full_time" do
      allow(vacancy).to receive(:working_patterns).and_return(%w[full_time part_time])

      expect(parsed.status_id).to eq(described_class::STATUS_FULL_TIME_ID)
    end

    it "returns the full time status id if the vacancy working patterns include term_time and exclude part_time" do
      allow(vacancy).to receive(:working_patterns).and_return(["term_time"])

      expect(parsed.status_id).to eq(described_class::STATUS_FULL_TIME_ID)
    end

    it "returns the part time status id if the vacancy working patterns include part_time" do
      allow(vacancy).to receive(:working_patterns).and_return(["part_time"])

      expect(parsed.status_id).to eq(described_class::STATUS_PART_TIME_ID)
    end

    it "returns the part time status id if the vacancy working patterns include term_time and part_time" do
      allow(vacancy).to receive(:working_patterns).and_return(%w[term_time part_time])

      expect(parsed.status_id).to eq(described_class::STATUS_PART_TIME_ID)
    end

    it "returns nil if the vacancy working patterns are blank" do
      allow(vacancy).to receive(:working_patterns).and_return([])

      expect(parsed.status_id).to be_nil
    end
  end

  describe "#type_id" do
    it "returns the permanent type id if the vacancy contract type is permanent" do
      allow(vacancy).to receive(:contract_type).and_return("permanent")

      expect(parsed.type_id).to eq(described_class::TYPE_PERMANENT_ID)
    end

    it "returns the contract type id if the vacancy contract type is fixed_term" do
      allow(vacancy).to receive(:contract_type).and_return("fixed_term")

      expect(parsed.type_id).to eq(described_class::TYPE_CONTRACT_ID)
    end

    it "returns the contract type id if the vacancy contract type is parental_leave_cover" do
      allow(vacancy).to receive(:contract_type).and_return("parental_leave_cover")

      expect(parsed.type_id).to eq(described_class::TYPE_CONTRACT_ID)
    end
  end
end
