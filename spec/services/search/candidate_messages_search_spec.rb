require "rails_helper"

RSpec.describe Search::CandidateMessagesSearch do
  subject(:search) { described_class.new(search_criteria, scope: base_scope) }

  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher, organisations: [organisation]) }
  let(:jobseeker) { create(:jobseeker) }

  let(:science_vacancy) { create(:vacancy, :live, job_title: "Science Teacher", organisations: [organisation]) }
  let(:math_vacancy) { create(:vacancy, :live, job_title: "Mathematics Teacher", organisations: [organisation]) }
  let(:english_vacancy) { create(:vacancy, :live, job_title: "English Teacher", organisations: [organisation]) }

  let(:science_application) { create(:job_application, :submitted, vacancy: science_vacancy, jobseeker: jobseeker, status: "interviewing") }
  let(:math_application) { create(:job_application, :submitted, vacancy: math_vacancy, jobseeker: jobseeker, status: "interviewing") }
  let(:english_application) { create(:job_application, :submitted, vacancy: english_vacancy, jobseeker: jobseeker, status: "interviewing") }

  let!(:science_conversation) { create(:conversation, job_application: science_application) }
  let!(:math_conversation) { create(:conversation, job_application: math_application) }
  let!(:english_conversation) { create(:conversation, job_application: english_application) }

  let(:base_scope) { Conversation.for_organisations(organisation.id).inbox }
  let(:current_tab) { "inbox" }

  describe "with no search criteria" do
    let(:search_criteria) { {} }

    it "returns all conversations in scope" do
      expect(search.conversations).to contain_exactly(science_conversation, math_conversation, english_conversation)
    end

    it "returns correct total count" do
      expect(search.total_count).to eq(3)
    end

    it "has no active criteria" do
      expect(search.active_criteria?).to be false
    end
  end

  describe "with keyword search" do
    let(:search_criteria) { { keyword: keyword } }

    context "when searching by job title" do
      let(:keyword) { "Science" }

      it "finds conversations with matching job titles" do
        expect(search.conversations).to include(science_conversation)
        expect(search.conversations).not_to include(math_conversation, english_conversation)
      end

      it "returns correct count for filtered results" do
        expect(search.total_count).to eq(1)
      end

      it "has active criteria" do
        expect(search.active_criteria?).to be true
      end
    end

    context "when searching by partial job title" do
      let(:keyword) { "Teacher" }

      it "finds all conversations with teacher in the job title" do
        expect(search.conversations).to contain_exactly(science_conversation, math_conversation, english_conversation)
      end
    end

    context "when searching by message content" do
      let(:keyword) { "interview" }

      before do
        create(:jobseeker_message, conversation: science_conversation, content: "Looking forward to the interview")
        create(:publisher_message, conversation: math_conversation, content: "Thank you for your application")
        create(:jobseeker_message, conversation: english_conversation, content: "When is the interview scheduled?")
      end

      it "finds conversations with matching message content" do
        expect(search.conversations).to include(science_conversation, english_conversation)
        expect(search.conversations).not_to include(math_conversation)
      end
    end

    context "when no results match" do
      let(:keyword) { "nonexistent" }

      it "returns empty results" do
        expect(search.conversations).to be_empty
      end

      it "returns zero count" do
        expect(search.total_count).to eq(0)
      end

      it "still has active criteria" do
        expect(search.active_criteria?).to be true
      end
    end

    context "with blank keyword" do
      let(:keyword) { "" }

      it "returns all conversations" do
        expect(search.conversations).to contain_exactly(science_conversation, math_conversation, english_conversation)
      end

      it "has no active criteria" do
        expect(search.active_criteria?).to be false
      end
    end
  end

  describe "#active_criteria" do
    context "with keyword" do
      let(:search_criteria) { { keyword: "science" } }

      it "returns criteria with values" do
        expect(search.active_criteria).to eq({ keyword: "science" })
      end
    end

    context "with blank keyword" do
      let(:search_criteria) { { keyword: "" } }

      it "excludes blank values" do
        expect(search.active_criteria).to be_empty
      end
    end

    context "with nil keyword" do
      let(:search_criteria) { { keyword: nil } }

      it "excludes nil values" do
        expect(search.active_criteria).to be_empty
      end
    end
  end
end
